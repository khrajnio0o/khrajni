import 'package:equatable/equatable.dart';

class Location extends Equatable {
  final String id;
  final Map<String, Map<String, String>> translations;
  final List<String> keywords;
  final String imageUrl;
  final Map<String, List<String>> categoriesTranslations;
  final String stateId;
  final String mapUrl;
  final Map<String, List<String>> recommendationsTranslations;
  final Map<String, String> openTimeTranslations;
  final Map<String, String> pricesTranslations;
  final Map<String, Map<String, String>> nearestMetroStationTranslations;
  final Map<String, List<String>> advantagesTranslations;
  final Map<String, List<String>> adviceTranslations;

  const Location({
    required this.id,
    required this.translations,
    required this.keywords,
    required this.imageUrl,
    required this.categoriesTranslations,
    required this.stateId,
    required this.mapUrl,
    required this.recommendationsTranslations,
    required this.openTimeTranslations,
    required this.pricesTranslations,
    required this.nearestMetroStationTranslations,
    required this.advantagesTranslations,
    required this.adviceTranslations,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      translations: (json['translations'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, {
          'name': value['name'] ?? 'Unknown',
          'description': value['description'] ?? 'No description',
        }),
      ),
      keywords: List<String>.from(json['keywords'] ?? []),
      imageUrl: json['imageUrl'] ?? '',
      categoriesTranslations:
          (json['categoriesTranslations'] as Map<String, dynamic>?)?.map(
                (key, value) => MapEntry(key, List<String>.from(value ?? [])),
              ) ??
              {'en': []},
      stateId: json['stateId'] ?? '',
      mapUrl: json['mapUrl'] ?? '',
      recommendationsTranslations:
          (json['recommendationsTranslations'] as Map<String, dynamic>?)?.map(
                (key, value) => MapEntry(key, List<String>.from(value ?? [])),
              ) ??
              {'en': []},
      openTimeTranslations:
          (json['openTimeTranslations'] as Map<String, dynamic>?)?.map(
                (key, value) => MapEntry(key, value?.toString() ?? ''),
              ) ??
              {'en': ''},
      pricesTranslations:
          (json['pricesTranslations'] as Map<String, dynamic>?)?.map(
                (key, value) => MapEntry(key, value?.toString() ?? ''),
              ) ??
              {'en': ''},
      nearestMetroStationTranslations:
          (json['nearestMetroStationTranslations'] as Map<String, dynamic>?)
                  ?.map(
                (key, value) => MapEntry(key, {
                  'name': value['name'] ?? '',
                  'description': value['description'] ?? '',
                }),
              ) ??
              {
                'en': {'name': '', 'description': ''}
              },
      advantagesTranslations:
          (json['advantagesTranslations'] as Map<String, dynamic>?)?.map(
                (key, value) => MapEntry(key, List<String>.from(value ?? [])),
              ) ??
              {'en': []},
      adviceTranslations:
          (json['adviceTranslations'] as Map<String, dynamic>?)?.map(
                (key, value) => MapEntry(key, List<String>.from(value ?? [])),
              ) ??
              {'en': []},
    );
  }

  String getName(String lang) =>
      translations[lang]?['name'] ?? translations['en']?['name'] ?? id;
  String getDescription(String lang) =>
      translations[lang]?['description'] ??
      translations['en']?['description'] ??
      '';
  List<String> getCategories(String lang) =>
      categoriesTranslations[lang] ?? categoriesTranslations['en'] ?? [];
  List<String> getRecommendations(String lang) =>
      recommendationsTranslations[lang] ??
      recommendationsTranslations['en'] ??
      [];
  String getOpenTime(String lang) =>
      openTimeTranslations[lang] ?? openTimeTranslations['en'] ?? '';
  String getPrices(String lang) =>
      pricesTranslations[lang] ?? pricesTranslations['en'] ?? '';
  Map<String, String> getNearestMetroStation(String lang) =>
      nearestMetroStationTranslations[lang] ??
      nearestMetroStationTranslations['en'] ??
      {'name': '', 'description': ''};
  List<String> getAdvantages(String lang) =>
      advantagesTranslations[lang] ?? advantagesTranslations['en'] ?? [];
  List<String> getAdvice(String lang) =>
      adviceTranslations[lang] ?? adviceTranslations['en'] ?? [];

  @override
  List<Object?> get props => [id];
}
