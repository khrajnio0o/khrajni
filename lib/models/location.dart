import 'package:equatable/equatable.dart';

class Location extends Equatable {
  final String id;
  final Map<String, Map<String, String>> translations;
  final List<String> keywords;
  final String imageUrl;
  final Map<String, List<String>>
      categoriesTranslations; // New field for translated categories
  final String stateId;
  final String mapUrl;
  final List<TransportOption> transportOptions;

  const Location({
    required this.id,
    required this.translations,
    required this.keywords,
    required this.imageUrl,
    required this.categoriesTranslations,
    required this.stateId,
    required this.mapUrl,
    required this.transportOptions,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    List<TransportOption> transportList = [];
    if (json['transportOptions'] != null) {
      transportList = (json['transportOptions'] as List)
          .map((e) => TransportOption.fromJson(e))
          .toList();
    }

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
              {'en': []}, // Default to empty list for 'en' if missing
      stateId: json['stateId'] ?? '',
      mapUrl: json['mapUrl'] ?? '',
      transportOptions: transportList,
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

  @override
  List<Object?> get props => [id];
}

class TransportOption extends Equatable {
  final String type;
  final String description;
  final double estimatedCost;
  final int estimatedTime;

  const TransportOption({
    required this.type,
    required this.description,
    required this.estimatedCost,
    required this.estimatedTime,
  });

  factory TransportOption.fromJson(Map<String, dynamic> json) {
    return TransportOption(
      type: json['type'] ?? 'Unknown',
      description: json['description'] ?? '',
      estimatedCost: json['estimatedCost']?.toDouble() ?? 0.0,
      estimatedTime: json['estimatedTime'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [type];
}
