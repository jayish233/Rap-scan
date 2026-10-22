import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/session.dart';
import '../../app/theme.dart';
import '../../l10n/strings.dart';
import '../../widgets/adaptive.dart';

/// Authenticated shell with the 5-tab bottom navigation (handoff spec §3).
/// iOS: white bar with a hairline top border, 26px icons, 10px labels,
/// active = primary. Android: M3 NavigationBar (#EEF4EF, #CDEFCB pill).
/// Signed-out visitors only reach the public Leaderboard branch, so the
/// nav bar is hidden for them.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _items = [
    (Icons.document_scanner_outlined, Strings.navScan),
    (Icons.history, Strings.navHistory),
    (Icons.local_fire_department_outlined, Strings.navWeekly),
    (Icons.emoji_events_outlined, Strings.navRanks),
    (Icons.person_outline, Strings.navProfile),
  ];

  void _select(int i) => navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = ref.watch(sessionStateProvider).signedIn;
    if (!signedIn) return Scaffold(body: navigationShell);

    final current = navigationShell.currentIndex;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: isIos(context) ? _IosTabBar(current: current, items: _items, onSelect: _select) : _AndroidNavBar(current: current, onSelect: _select),
    );
  }
}

class _AndroidNavBar extends StatelessWidget {
  const _AndroidNavBar({required this.current, required this.onSelect});

  final int current;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: current,
      onDestinationSelected: onSelect,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.document_scanner_outlined), label: Strings.navScan),
        NavigationDestination(icon: Icon(Icons.history), label: Strings.navHistory),
        NavigationDestination(icon: Icon(Icons.local_fire_department_outlined), label: Strings.navWeekly),
        NavigationDestination(icon: Icon(Icons.emoji_events_outlined), label: Strings.navRanks),
        NavigationDestination(icon: Icon(Icons.person_outline), label: Strings.navProfile),
      ],
    );
  }
}

class _IosTabBar extends StatelessWidget {
  const _IosTabBar({required this.current, required this.items, required this.onSelect});

  final int current;
  final List<(IconData, String)> items;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: EdgeInsets.only(top: 8, left: 8, right: 8, bottom: MediaQuery.paddingOf(context).bottom + 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final (i, (icon, label)) in items.indexed)
            _IosTabItem(icon: icon, label: label, active: i == current, onTap: () => onSelect(i)),
        ],
      ),
    );
  }
}

class _IosTabItem extends StatelessWidget {
  const _IosTabItem({required this.icon, required this.label, required this.active, required this.onTap});

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textMuted;
    return Semantics(
      button: true,
      selected: active,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 64, minHeight: 44),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 26, color: color),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 10,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
