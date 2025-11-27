import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _keyFavorites = 'favorite_ids';

  // Ambil daftar ID yang difavoritkan
  Future<List<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyFavorites) ?? [];
  }

  // Tambah/Hapus ID dari favorit
  Future<void> toggleFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> ids = prefs.getStringList(_keyFavorites) ?? [];

    if (ids.contains(id)) {
      ids.remove(id); // Hapus jika sudah ada
    } else {
      ids.add(id); // Tambah jika belum ada
    }

    await prefs.setStringList(_keyFavorites, ids);
  }

  // Cek apakah ID ini favorit?
  Future<bool> isFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> ids = prefs.getStringList(_keyFavorites) ?? [];
    return ids.contains(id);
  }
}