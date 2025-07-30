import 'dart:math';
import 'package:khrajni/models/location.dart';

class SimilarityService {
  static List<String> tokenize(String text) {
    return text
        .toLowerCase()
        .split(RegExp(r'[,\s]+'))
        .where((token) => token.isNotEmpty)
        .toList();
  }

  static Map<String, int> createVocabulary(List<Location> locations) {
    final vocabulary = <String, int>{};
    int index = 0;
    for (final location in locations) {
      for (final keyword in location.keywords) {
        final tokens = tokenize(keyword);
        for (final token in tokens) {
          if (!vocabulary.containsKey(token)) {
            vocabulary[token] = index++;
          }
        }
      }
    }
    return vocabulary;
  }

  static List<double> textToVector(String text, Map<String, int> vocabulary) {
    final vector = List<double>.filled(vocabulary.length, 0.0);
    final tokens = tokenize(text);
    for (final token in tokens) {
      if (vocabulary.containsKey(token)) {
        vector[vocabulary[token]!] += 1.0;
      }
    }
    return vector;
  }

  static double cosineSimilarity(List<double> vectorA, List<double> vectorB) {
    if (vectorA.length != vectorB.length) return 0.0;
    double dotProduct = 0.0;
    double magnitudeA = 0.0;
    double magnitudeB = 0.0;
    for (int i = 0; i < vectorA.length; i++) {
      dotProduct += vectorA[i] * vectorB[i];
      magnitudeA += vectorA[i] * vectorA[i];
      magnitudeB += vectorB[i] * vectorB[i];
    }
    magnitudeA = sqrt(magnitudeA);
    magnitudeB = sqrt(magnitudeB);
    if (magnitudeA == 0 || magnitudeB == 0) return 0.0;
    return dotProduct / (magnitudeA * magnitudeB);
  }

  static List<Location> findSimilarLocations(
      String query, List<Location> locations) {
    if (locations.isEmpty) return [];
    final vocabulary = createVocabulary(locations);
    final queryVector = textToVector(query, vocabulary);
    final similarities = <Location, double>{};
    for (final location in locations) {
      final locationText = location.keywords.join(' ');
      final locationVector = textToVector(locationText, vocabulary);
      final similarity = cosineSimilarity(queryVector, locationVector);
      similarities[location] = similarity;
    }
    final sortedLocations = similarities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedLocations
        .where((entry) => entry.value > 0.1)
        .map((entry) => entry.key)
        .toList();
  }
}
