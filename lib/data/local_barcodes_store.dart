import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// An in-store item saved on this device (PRD §7.5).
class LocalItem {
  const LocalItem({required this.name, this.price, this.weight, required this.savedAt});

  final String name;
  final String? price;
  final String? weight;
  final DateTime savedAt;

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': ?price,
        'weight': ?weight,
        'savedAt': savedAt.toUtc().toIso8601String(),
      };

  static LocalItem? fromJson(Object? json) {
    if (json is! Map) return null;
    final name = json['name'];
    if (name is! String || name.trim().isEmpty) return null;
    String? opt(Object? v) => v is String && v.trim().isNotEmpty ? v.trim() : null;
    return LocalItem(
      name: name.trim(),
      price: opt(json['price']),
      weight: opt(json['weight']),
      savedAt: DateTime.tryParse(json['savedAt'] as String? ?? '')?.toLocal() ?? DateTime.now(),
    );
  }
}

/// On-device inventory for GS1 in-store codes (prefix 2). Never synced, never
/// sent to the server, works offline. Key and shape match the web app:
/// `rapscanz.localBarcodes.v1` → `{ [barcode]: { name, price?, weight?, savedAt } }`.
class LocalBarcodesStore {
  LocalBarcodesStore(this._prefs);

  final SharedPreferencesAsync _prefs;

  static const storageKey = 'rapscanz.localBarcodes.v1';

  Future<Map<String, dynamic>> _readAll() async {
    try {
      final raw = await _prefs.getString(storageKey);
      final decoded = raw == null ? null : jsonDecode(raw);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : {};
    } catch (_) {
      return {};
    }
  }

  Future<LocalItem?> get(String barcode) async => LocalItem.fromJson((await _readAll())[barcode]);

  Future<void> save(String barcode, LocalItem item) async {
    final all = await _readAll();
    all[barcode] = item.toJson();
    await _prefs.setString(storageKey, jsonEncode(all));
  }

  /// Removes the item from this device only.
  Future<void> remove(String barcode) async {
    final all = await _readAll();
    if (all.remove(barcode) != null) await _prefs.setString(storageKey, jsonEncode(all));
  }
}

final localBarcodesStoreProvider = Provider<LocalBarcodesStore>((ref) => LocalBarcodesStore(SharedPreferencesAsync()));

final localItemProvider = FutureProvider.autoDispose.family<LocalItem?, String>(
  (ref, barcode) => ref.watch(localBarcodesStoreProvider).get(barcode),
);
