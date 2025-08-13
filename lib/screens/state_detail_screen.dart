// lib/screens/state_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:khrajni/models/location.dart';
import 'package:khrajni/models/state.dart';
import 'package:khrajni/services/data_service.dart';
import 'package:khrajni/widgets/location_card.dart';

class StateDetailScreen extends StatelessWidget {
  final StateModel state;
  final String selectedLanguage;

  const StateDetailScreen({
    Key? key,
    required this.state,
    required this.selectedLanguage,
  }) : super(key: key);

  String _getStateName(String lang) {
    switch (lang) {
      case 'ar':
        return state.translations['ar']?['name'] ??
            state.translations['en']?['name'] ??
            state.id;
      case 'en':
        return state.translations['en']?['name'] ?? state.id;
      case 'fr':
        return state.translations['fr']?['name'] ??
            state.translations['en']?['name'] ??
            state.id;
      case 'ru':
        return state.translations['ru']?['name'] ??
            state.translations['en']?['name'] ??
            state.id;
      case 'de':
        return state.translations['de']?['name'] ??
            state.translations['en']?['name'] ??
            state.id;
      default:
        return state.translations['en']?['name'] ?? state.id;
    }
  }

  String _getDescription(String lang) {
    switch (lang) {
      case 'ar':
        return state.translations['ar']?['description'] ??
            state.translations['en']?['description'] ??
            'No description available';
      case 'en':
        return state.translations['en']?['description'] ??
            'No description available';
      case 'fr':
        return state.translations['fr']?['description'] ??
            state.translations['en']?['description'] ??
            'No description available';
      case 'ru':
        return state.translations['ru']?['description'] ??
            state.translations['en']?['description'] ??
            'No description available';
      case 'de':
        return state.translations['de']?['description'] ??
            state.translations['en']?['description'] ??
            'No description available';
      default:
        return state.translations['en']?['description'] ??
            'No description available';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(_getStateName(selectedLanguage)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                state.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  width: double.infinity,
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                  child: const Center(
                      child: Icon(Icons.image_not_supported, size: 50)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getDescription(selectedLanguage),
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              selectedLanguage == 'ar'
                  ? 'أماكن الجذب'
                  : selectedLanguage == 'en'
                      ? 'Attractions'
                      : selectedLanguage == 'fr'
                          ? 'Attractions'
                          : selectedLanguage == 'ru'
                              ? 'Достопримечательности'
                              : 'Attraktionen',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<Location>>(
              future: DataService.loadLocationsByState(state.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text(
                    selectedLanguage == 'ar'
                        ? 'خطأ في تحميل الأماكن: ${snapshot.error}'
                        : selectedLanguage == 'en'
                            ? 'Error loading attractions: ${snapshot.error}'
                            : selectedLanguage == 'fr'
                                ? 'Erreur de chargement des attractions: ${snapshot.error}'
                                : selectedLanguage == 'ru'
                                    ? 'Ошибка загрузки достопримечательностей: ${snapshot.error}'
                                    : 'Fehler beim Laden der Attraktionen: ${snapshot.error}',
                    style: TextStyle(
                        color: isDarkMode ? Colors.red[300] : Colors.red),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text(
                    selectedLanguage == 'ar'
                        ? 'لا يوجد أماكن جذب متاحة'
                        : selectedLanguage == 'en'
                            ? 'No attractions available'
                            : selectedLanguage == 'fr'
                                ? 'Aucune attraction disponible'
                                : selectedLanguage == 'ru'
                                    ? 'Нет доступных достопримечательностей'
                                    : 'Keine Attraktionen verfügbar',
                    style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final location = snapshot.data![index];
                    return LocationCard(
                      location: location,
                      onTap: () {
                        // Navigate to a detailed location page if needed
                      },
                      selectedLanguage: selectedLanguage,
                      isDarkMode: isDarkMode,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
