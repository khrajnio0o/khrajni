import 'dart:math';
import 'package:khrajni/models/location.dart';
import 'package:khrajni/models/state.dart';

class SimilarityService {
  // Tokenize text, handling Arabic and other languages
  static List<String> tokenize(String text, String language) {
    String normalizedText = text.toLowerCase();
    // Simplified Arabic normalization: remove specific diacritics
    if (language == 'ar') {
      normalizedText = normalizedText.replaceAll(
          RegExp(r'[\u064B-\u065F]'), ''); // Remove Arabic diacritics
    }
    // Split on spaces, commas, and other delimiters, include partial matches
    return normalizedText
        .split(RegExp(r'[,\s\-\.]+'))
        .where((token) => token.isNotEmpty && token.length > 1)
        .toList();
  }

  // Create a vocabulary from both states and locations
  static Map<String, int> createVocabulary(
      List<StateModel> states, List<Location> locations, String language) {
    final vocabulary = <String, int>{};
    int index = 0;

    // Add state tokens
    for (final state in states) {
      final name = state.getName(language);
      final description = state.getDescription(language);
      final tokens = tokenize('$name $description', language);
      for (final token in tokens) {
        if (!vocabulary.containsKey(token)) {
          vocabulary[token] = index++;
        }
      }
    }

    // Add location tokens
    for (final location in locations) {
      final name = location.getName(language);
      final description = location.getDescription(language) ?? '';
      final keywords = location.keywords.join(' ');
      final categories =
          location.categoriesTranslations[language]?.join(' ') ?? '';
      final recommendations =
          location.recommendationsTranslations[language]?.join(' ') ?? '';
      final tokens = tokenize(
          '$name $description $keywords $categories $recommendations',
          language);
      for (final token in tokens) {
        if (!vocabulary.containsKey(token)) {
          vocabulary[token] = index++;
        }
      }
    }
    print(
        'Vocabulary size: ${vocabulary.length}, tokens: ${vocabulary.keys.take(10).toList()}'); // Debugging
    return vocabulary;
  }

  // Convert text to a binary vector for simplicity
  static List<double> textToVector(
      String text, Map<String, int> vocabulary, String language) {
    final vector = List<double>.filled(vocabulary.length, 0.0);
    final tokens = tokenize(text, language);
    for (final token in tokens) {
      if (vocabulary.containsKey(token)) {
        vector[vocabulary[token]!] = 1.0; // Binary vector for better matching
      }
    }
    print('Query tokens: $tokens'); // Debugging
    return vector;
  }

  // Calculate cosine similarity between two vectors
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

  // Fallback string matching for states
  static List<StateModel> stringMatchStates(
      String query, List<StateModel> states, String language) {
    final normalizedQuery = query.toLowerCase();
    return states.where((state) {
      final name = state.getName(language).toLowerCase();
      final description = state.getDescription(language).toLowerCase();
      return name.contains(normalizedQuery) ||
          description.contains(normalizedQuery);
    }).toList();
  }

  // Fallback string matching for locations
  static List<Location> stringMatchLocations(
      String query, List<Location> locations, String language) {
    final normalizedQuery = query.toLowerCase();
    return locations.where((location) {
      final name = location.getName(language).toLowerCase();
      final description =
          location.getDescription(language)?.toLowerCase() ?? '';
      final keywords = location.keywords.join(' ').toLowerCase();
      final categories =
          location.categoriesTranslations[language]?.join(' ').toLowerCase() ??
              '';
      final recommendations = location.recommendationsTranslations[language]
              ?.join(' ')
              .toLowerCase() ??
          '';
      return name.contains(normalizedQuery) ||
          description.contains(normalizedQuery) ||
          keywords.contains(normalizedQuery) ||
          categories.contains(normalizedQuery) ||
          recommendations.contains(normalizedQuery);
    }).toList();
  }

  // Unified search for states and locations
  static Map<String, List<dynamic>> findSimilarItems({
    required String query,
    required List<StateModel> states,
    required List<Location> locations,
    required String language,
  }) {
    if (query.isEmpty || (states.isEmpty && locations.isEmpty)) {
      print(
          'Empty query or no data, returning all: ${states.length} states, ${locations.length} locations');
      return {
        'states': states,
        'locations': locations,
      };
    }

    final vocabulary = createVocabulary(states, locations, language);
    final queryVector = textToVector(query, vocabulary, language);

    // Search states with cosine similarity
    final stateSimilarities = <StateModel, double>{};
    for (final state in states) {
      final text =
          '${state.getName(language)} ${state.getDescription(language)}';
      final stateVector = textToVector(text, vocabulary, language);
      final similarity = cosineSimilarity(queryVector, stateVector);
      stateSimilarities[state] = similarity;
    }

    // Search locations with cosine similarity
    final locationSimilarities = <Location, double>{};
    for (final location in locations) {
      final text =
          '${location.getName(language)} ${location.getDescription(language) ?? ''} ${location.keywords.join(' ')} ${location.categoriesTranslations[language]?.join(' ') ?? ''} ${location.recommendationsTranslations[language]?.join(' ') ?? ''}';
      final locationVector = textToVector(text, vocabulary, language);
      final similarity =
          cosineSimilarity(queryVector, locationVector); // Fixed bug
      locationSimilarities[location] = similarity;
    }

    // Sort and filter results
    final sortedStates = stateSimilarities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final sortedLocations = locationSimilarities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Log similarity scores
    print(
        'State similarities: ${sortedStates.map((e) => '${e.key.getName(language)}: ${e.value.toStringAsFixed(4)}').toList()}');
    print(
        'Location similarities: ${sortedLocations.map((e) => '${e.key.getName(language)}: ${e.value.toStringAsFixed(4)}').toList()}');

    // Get cosine similarity results (threshold 0.0 for debugging)
    List<StateModel> matchedStates = sortedStates
        .where((entry) => entry.value > 0.0)
        .map((entry) => entry.key)
        .toList();
    List<Location> matchedLocations = sortedLocations
        .where((entry) => entry.value > 0.0)
        .map((entry) => entry.key)
        .toList();

    // Fallback to string matching if no results
    if (matchedStates.isEmpty) {
      matchedStates = stringMatchStates(query, states, language);
      print(
          'State fallback results: ${matchedStates.map((s) => s.getName(language)).toList()}');
    }
    if (matchedLocations.isEmpty) {
      matchedLocations = stringMatchLocations(query, locations, language);
      print(
          'Location fallback results: ${matchedLocations.map((l) => l.getName(language)).toList()}');
    }

    return {
      'states': matchedStates,
      'locations': matchedLocations,
    };
  }

  // Preserve original method for backward compatibility
  static List<Location> findSimilarLocations(
      String query, List<Location> locations) {
    if (locations.isEmpty) return [];
    final vocabulary = createVocabulary([], locations, 'en');
    final queryVector = textToVector(query, vocabulary, 'en');
    final similarities = <Location, double>{};
    for (final location in locations) {
      final locationText = location.keywords.join(' ');
      final locationVector = textToVector(locationText, vocabulary, 'en');
      final similarity = cosineSimilarity(queryVector, locationVector);
      similarities[location] = similarity;
    }
    final sortedLocations = similarities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedLocations
        .where((entry) => entry.value > 0.0)
        .map((entry) => entry.key)
        .toList();
  }
}
