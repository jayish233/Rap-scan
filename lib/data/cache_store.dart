import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Small JSON cache for offline reading of already-loaded screens
/// (architecture.md §2.4.5). Keys are namespaced per user so one account's
/// data is never shown to another.
class CacheStore {
  CacheStore(this._prefs);

  final SharedPreferencesAsync _prefs;

  static const _prefix = 'rapscanz.cache.v1';

  String _key(String userId, String name) => '$_prefix.$userId.$name';

  Future<Object?> read(String userId, String name) async {
    try {
      final raw = await _prefs.getString(_key(userId, name));
      return raw == null ? null : jsonDecode(raw);
    } catch (_) {
      return null; // A corrupt entry is just a cache miss.
    }
  }

  Future<void> write(String userId, String name, Object? value) async {
    try {
      await _prefs.setString(_key(userId, name), jsonEncode(value));
    } catch (_) {
      // Caching is best-effort.
    }
  }
}

final cacheStoreProvider = Provider<CacheStore>((ref) => CacheStore(SharedPreferencesAsync()));
