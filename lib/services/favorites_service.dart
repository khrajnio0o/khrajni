import 'package:shared_preferences/shared_preferences.dart';
import 'package:khrajni/models/location.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_locations';

  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  static Future<void> addFavorite(String locationId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    if (!favorites.contains(locationId)) {
      favorites.add(locationId);
      await prefs.setStringList(_favoritesKey, favorites);
    }
  }

  static Future<void> removeFavorite(String locationId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    favorites.remove(locationId);
    await prefs.setStringList(_favoritesKey, favorites);
  }

  static Future<bool> isFavorite(String locationId) async {
    final favorites = await getFavorites();
    return favorites.contains(locationId);
  }

  static Future<List<Location>> getFavoriteLocations(
      List<Location> allLocations) async {
    final favoriteIds = await getFavorites();
    return allLocations
        .where((location) => favoriteIds.contains(location.id))
        .toList();
  }
}
