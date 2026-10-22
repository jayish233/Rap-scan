import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../data/local_barcodes_store.dart';
import '../../../l10n/strings.dart';

/// Local inventory for an in-store code (PRD §7.5): the saved card when this
/// device knows the code, otherwise a prompt to add it. No server call.
class LocalInventoryPanel extends ConsumerWidget {
  const LocalInventoryPanel({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(localItemProvider(code));
    return switch (item) {
      AsyncData(value: final saved?) => _SavedCard(code: code, item: saved),
      AsyncData() => _UnknownCard(code: code),
      AsyncError() => _UnknownCard(code: code),
      _ => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
    };
  }
}

class _SavedCard extends ConsumerWidget {
  const _SavedCard({required this.code, required this.item});

  final String code;
  final LocalItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final details = [?item.price, ?item.weight];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.storefront, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(item.name, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
              ],
            ),
            if (details.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(details.join(' · '), style: text.bodyLarge),
            ],
            const SizedBox(height: 4),
            Text(Strings.barcodeLine(code), style: text.bodySmall?.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone_iphone, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(Strings.localSavedCard, style: text.bodySmall?.copyWith(color: AppColors.textMuted)),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () async {
                  await ref.read(localBarcodesStoreProvider).remove(code);
                  ref.invalidate(localItemProvider(code));
                },
                icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                label: const Text(Strings.localRemove, style: TextStyle(color: AppColors.danger)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnknownCard extends StatelessWidget {
  const _UnknownCard({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.storefront_outlined, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(Strings.inStoreTitle, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
              ],
            ),
            const SizedBox(height: 6),
            Text(Strings.inStoreBody(code), style: text.bodyMedium),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: () => showAddLocalItemDialog(context, code),
              icon: const Icon(Icons.add),
              label: const Text(Strings.localAddButton),
            ),
          ],
        ),
      ),
    );
  }
}

/// Name (required), price and weight/size (optional) → saved on this device.
Future<void> showAddLocalItemDialog(BuildContext context, String code) {
  return showDialog<void>(context: context, builder: (_) => _AddLocalItemDialog(code: code));
}

class _AddLocalItemDialog extends StatefulWidget {
  const _AddLocalItemDialog({required this.code});

  final String code;

  @override
  State<_AddLocalItemDialog> createState() => _AddLocalItemDialogState();
}

class _AddLocalItemDialogState extends State<_AddLocalItemDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _weight = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _weight.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    String? opt(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
    // Captured before the await: the dialog may be dismissed meanwhile.
    final container = ProviderScope.containerOf(context, listen: false);
    await container.read(localBarcodesStoreProvider).save(
          widget.code,
          LocalItem(name: _name.text.trim(), price: opt(_price), weight: opt(_weight), savedAt: DateTime.now()),
        );
    container.invalidate(localItemProvider(widget.code));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(Strings.localAddTitle),
      content: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(Strings.barcodeLine(widget.code), style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('local-name'),
                controller: _name,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: Strings.localNameLabel),
                validator: (v) => (v ?? '').trim().isEmpty ? Strings.localNameRequired : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('local-price'),
                controller: _price,
                decoration: const InputDecoration(labelText: Strings.localPriceLabel),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('local-weight'),
                controller: _weight,
                decoration: const InputDecoration(labelText: Strings.localWeightLabel),
                onFieldSubmitted: (_) => _save(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.of(context).pop(), child: const Text(Strings.cancel)),
        FilledButton(onPressed: _saving ? null : _save, child: const Text(Strings.save)),
      ],
    );
  }
}
