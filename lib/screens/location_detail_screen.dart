import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:khrajni/models/location.dart';

class LocationDetailScreen extends StatelessWidget {
  final Location location;
  final String selectedLanguage;
  final Function(String) updateLanguage;

  const LocationDetailScreen({
    Key? key,
    required this.location,
    required this.selectedLanguage,
    required this.updateLanguage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final appBarBackgroundColor =
        isDarkMode ? Colors.grey[850] : Colors.blue.shade700;
    final appBarForegroundColor = isDarkMode ? Colors.white : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(location.getName(selectedLanguage)),
        backgroundColor: appBarBackgroundColor,
        foregroundColor: appBarForegroundColor,
        actions: [
          DropdownButton<String>(
            value: selectedLanguage,
            dropdownColor: appBarBackgroundColor,
            style: TextStyle(color: appBarForegroundColor),
            iconEnabledColor: appBarForegroundColor,
            items: const {
              'en': 'English',
              'ar': 'العربية',
              'fr': 'Français',
              'ru': 'Русский',
              'de': 'Deutsch',
            }.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                updateLanguage(newValue);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(location.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.getName(selectedLanguage),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    children: location
                        .getCategories(selectedLanguage)
                        .map((category) {
                      final chipBackgroundColor = isDarkMode
                          ? Colors.blueGrey.shade700.withOpacity(0.7)
                          : Colors.blue.shade100;
                      final labelColor =
                          isDarkMode ? Colors.white70 : Colors.blue.shade900;
                      return Chip(
                        label: Text(category),
                        backgroundColor: chipBackgroundColor,
                        labelStyle: TextStyle(color: labelColor),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    selectedLanguage == 'ar'
                        ? 'الوصف'
                        : selectedLanguage == 'en'
                            ? 'Description'
                            : selectedLanguage == 'fr'
                                ? 'Description'
                                : selectedLanguage == 'ru'
                                    ? 'Описание'
                                    : 'Beschreibung',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    location.getDescription(selectedLanguage),
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    selectedLanguage == 'ar'
                        ? 'التوصيات'
                        : selectedLanguage == 'en'
                            ? 'Recommendations'
                            : selectedLanguage == 'fr'
                                ? 'Recommandations'
                                : selectedLanguage == 'ru'
                                    ? 'Рекомендации'
                                    : 'Empfehlungen',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (location.getRecommendations(selectedLanguage).isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        selectedLanguage == 'ar'
                            ? 'لا توجد توصيات متاحة حاليًا'
                            : selectedLanguage == 'en'
                                ? 'No recommendations available at the moment'
                                : selectedLanguage == 'fr'
                                    ? 'Aucune recommandation disponible pour le moment'
                                    : selectedLanguage == 'ru'
                                        ? 'На данный момент нет рекомендаций'
                                        : 'Derzeit keine Empfehlungen verfügbar',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  else
                    Column(
                      children: location
                          .getRecommendations(selectedLanguage)
                          .map((recommendation) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.check_circle,
                                        size: 16, color: Colors.blue.shade700),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        recommendation,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    selectedLanguage == 'ar'
                        ? 'ساعات العمل'
                        : selectedLanguage == 'en'
                            ? 'Open Time'
                            : selectedLanguage == 'fr'
                                ? 'Horaires d\'ouverture'
                                : selectedLanguage == 'ru'
                                    ? 'Время работы'
                                    : 'Öffnungszeiten',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    location.getOpenTime(selectedLanguage).isEmpty
                        ? (selectedLanguage == 'ar'
                            ? 'غير متاح'
                            : selectedLanguage == 'en'
                                ? 'Not available'
                                : selectedLanguage == 'fr'
                                    ? 'Non disponible'
                                    : selectedLanguage == 'ru'
                                        ? 'Недоступно'
                                        : 'Nicht verfügbar')
                        : location.getOpenTime(selectedLanguage),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    selectedLanguage == 'ar'
                        ? 'الأسعار'
                        : selectedLanguage == 'en'
                            ? 'Prices'
                            : selectedLanguage == 'fr'
                                ? 'Prix'
                                : selectedLanguage == 'ru'
                                    ? 'Цены'
                                    : 'Preise',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    location.getPrices(selectedLanguage).isEmpty
                        ? (selectedLanguage == 'ar'
                            ? 'غير متاح'
                            : selectedLanguage == 'en'
                                ? 'Not available'
                                : selectedLanguage == 'fr'
                                    ? 'Non disponible'
                                    : selectedLanguage == 'ru'
                                        ? 'Недоступно'
                                        : 'Nicht verfügbar')
                        : location.getPrices(selectedLanguage),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    selectedLanguage == 'ar'
                        ? 'أقرب محطة مترو'
                        : selectedLanguage == 'en'
                            ? 'Nearest Metro Station'
                            : selectedLanguage == 'fr'
                                ? 'Station de métro la plus proche'
                                : selectedLanguage == 'ru'
                                    ? 'Ближайшая станция метро'
                                    : 'Nächste U-Bahn-Station',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (location
                      .getNearestMetroStation(selectedLanguage)['name']!
                      .isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        selectedLanguage == 'ar'
                            ? 'لا توجد معلومات عن أقرب محطة مترو حاليًا'
                            : selectedLanguage == 'en'
                                ? 'No nearest metro station information available at the moment'
                                : selectedLanguage == 'fr'
                                    ? 'Aucune information sur la station de métro la plus proche pour le moment'
                                    : selectedLanguage == 'ru'
                                        ? 'На данный момент нет информации о ближайшей станции метро'
                                        : 'Derzeit keine Informationen zur nächsten U-Bahn-Station verfügbar',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode
                                ? Colors.black.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.subway,
                            color: Colors.green,
                            size: 30,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  location.getNearestMetroStation(
                                      selectedLanguage)['name']!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  location.getNearestMetroStation(
                                      selectedLanguage)['description']!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    selectedLanguage == 'ar'
                        ? 'مميزات الزيارة'
                        : selectedLanguage == 'en'
                            ? 'Advantages of Visiting'
                            : selectedLanguage == 'fr'
                                ? 'Avantages de la visite'
                                : selectedLanguage == 'ru'
                                    ? 'Преимущества посещения'
                                    : 'Vorteile des Besuchs',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (location.getAdvantages(selectedLanguage).isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        selectedLanguage == 'ar'
                            ? 'لا توجد مميزات متاحة حاليًا'
                            : selectedLanguage == 'en'
                                ? 'No advantages available at the moment'
                                : selectedLanguage == 'fr'
                                    ? 'Aucun avantage disponible pour le moment'
                                    : selectedLanguage == 'ru'
                                        ? 'На данный момент нет преимуществ'
                                        : 'Derzeit keine Vorteile verfügbar',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  else
                    Column(
                      children: location
                          .getAdvantages(selectedLanguage)
                          .map((advantage) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.star,
                                        size: 16,
                                        color: Colors.yellow.shade700),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        advantage,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    selectedLanguage == 'ar'
                        ? 'نصائح قبل الزيارة'
                        : selectedLanguage == 'en'
                            ? 'Advice Before Visiting'
                            : selectedLanguage == 'fr'
                                ? 'Conseils avant la visite'
                                : selectedLanguage == 'ru'
                                    ? 'Советы перед посещением'
                                    : 'Tipps vor dem Besuch',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (location.getAdvice(selectedLanguage).isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        selectedLanguage == 'ar'
                            ? 'لا توجد نصائح متاحة حاليًا'
                            : selectedLanguage == 'en'
                                ? 'No advice available at the moment'
                                : selectedLanguage == 'fr'
                                    ? 'Aucun conseil disponible pour le moment'
                                    : selectedLanguage == 'ru'
                                        ? 'На данный момент нет советов'
                                        : 'Derzeit keine Tipps verfügbar',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  else
                    Column(
                      children: location
                          .getAdvice(selectedLanguage)
                          .map((advice) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.info,
                                        size: 16, color: Colors.blue.shade700),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        advice,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    selectedLanguage == 'ar'
                        ? 'خريطة الموقع'
                        : selectedLanguage == 'en'
                            ? 'Map Location'
                            : selectedLanguage == 'fr'
                                ? 'Localisation de la carte'
                                : selectedLanguage == 'ru'
                                    ? 'Расположение на карте'
                                    : 'Kartenauschnitt',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Container(
                            color: Colors.blue.shade50,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.map,
                                    size: 50,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    selectedLanguage == 'ar'
                                        ? 'عرض الموقع على Google Maps'
                                        : selectedLanguage == 'en'
                                            ? 'View on Google Maps'
                                            : selectedLanguage == 'fr'
                                                ? 'Voir sur Google Maps'
                                                : selectedLanguage == 'ru'
                                                    ? 'Посмотреть на Google Maps'
                                                    : 'Auf Google Maps ansehen',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final Uri url =
                                          Uri.parse(location.mapUrl);
                                      if (await launchUrl(url)) {
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              selectedLanguage == 'ar'
                                                  ? 'تعذر فتح رابط الخريطة'
                                                  : selectedLanguage == 'en'
                                                      ? 'Failed to open map link'
                                                      : selectedLanguage == 'fr'
                                                          ? 'Échec de l’ouverture du lien de la carte'
                                                          : selectedLanguage ==
                                                                  'ru'
                                                              ? 'Не удалось открыть ссылку на карту'
                                                              : 'Fehler beim Öffnen des Kartenlinks',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    icon:
                                        const Icon(Icons.open_in_new, size: 16),
                                    label: Text(
                                      selectedLanguage == 'ar'
                                          ? 'فتح الخريطة'
                                          : selectedLanguage == 'en'
                                              ? 'Open Map'
                                              : selectedLanguage == 'fr'
                                                  ? 'Ouvrir la carte'
                                                  : selectedLanguage == 'ru'
                                                      ? 'Открыть карту'
                                                      : 'Karte öffnen',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Center(
                            child: Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
