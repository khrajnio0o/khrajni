import 'package:equatable/equatable.dart';

class StateModel extends Equatable {
  final String id;
  final Map<String, Map<String, String>>
      translations; // Language codes to name/description
  final String imageUrl;
  final int locationCount;

  const StateModel({
    required this.id,
    required this.translations,
    required this.imageUrl,
    required this.locationCount,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'],
      translations: (json['translations'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, {
          'name': value['name'],
          'description': value['description'],
        }),
      ),
      imageUrl: json['imageUrl'],
      locationCount: json['locationCount'],
    );
  }

  String getName(String lang) =>
      translations[lang]?['name'] ?? translations['en']?['name'] ?? id;
  String getDescription(String lang) =>
      translations[lang]?['description'] ??
      translations['en']?['description'] ??
      '';

  @override
  List<Object?> get props => [id];
}
