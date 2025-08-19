import 'package:flutter/material.dart';
import 'package:khrajni/models/location.dart';
import 'package:khrajni/screens/location_detail_screen.dart';
import 'package:khrajni/services/favorites_service.dart';
import 'package:khrajni/widgets/location_card.dart';

class FavoritesScreen extends StatelessWidget {
  final String selectedLanguage;
  final Function(String) updateLanguage;
  final List<Location> allLocations;

  const FavoritesScreen({
    Key? key,
    required this.selectedLanguage,
    required this.updateLanguage,
    required this.allLocations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return FutureBuilder<List<Location>>(
      future: FavoritesService.getFavoriteLocations(allLocations),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              selectedLanguage == 'ar'
                  ? 'خطأ في تحميل المفضلة: ${snapshot.error}'
                  : selectedLanguage == 'en'
                      ? 'Error loading favorites: ${snapshot.error}'
                      : selectedLanguage == 'fr'
                          ? 'Erreur de chargement des favoris: ${snapshot.error}'
                          : selectedLanguage == 'ru'
                              ? 'Ошибка загрузки избранного: ${snapshot.error}'
                              : 'Fehler beim Laden der Favoriten: ${snapshot.error}',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.red[300] : Colors.red,
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              selectedLanguage == 'ar'
                  ? 'لا توجد أماكن مفضلة'
                  : selectedLanguage == 'en'
                      ? 'No favorite locations'
                      : selectedLanguage == 'fr'
                          ? 'Aucun lieu favori'
                          : selectedLanguage == 'ru'
                              ? 'Нет избранных мест'
                              : 'Keine Favoriten',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            // Trigger a rebuild to refresh favorites
            return Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final location = snapshot.data![index];
              return LocationCard(
                location: location,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LocationDetailScreen(
                        location: location,
                        selectedLanguage: selectedLanguage,
                        updateLanguage: updateLanguage,
                      ),
                    ),
                  );
                },
                selectedLanguage: selectedLanguage,
                isDarkMode: isDarkMode,
              );
            },
          ),
        );
      },
    );
  }
}
