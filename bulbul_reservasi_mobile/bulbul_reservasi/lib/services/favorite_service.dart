import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const String keyFavorites = 'favorite_facilities';

  /// Ambil semua favorit → List<int> (ID fasilitas)
  Future<List<int>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(keyFavorites);

    if (jsonString == null) return [];
    List<dynamic> list = jsonDecode(jsonString);

    return list.map((e) => e as int).toList();
  }

  /// Simpan list favorit
  Future<void> saveFavorites(List<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyFavorites, jsonEncode(ids));
  }

  /// Tambah/hapus favorit (toggle)
  Future<void> toggleFavorite(int id) async {
    List<int> favs = await getFavorites();

    if (favs.contains(id)) {
      favs.remove(id);
    } else {
      favs.add(id);
    }

    await saveFavorites(favs);
  }

  /// Cek apakah id adalah favorit
  Future<bool> isFavorite(int id) async {
    List<int> favs = await getFavorites();
    return favs.contains(id);
  }
}
