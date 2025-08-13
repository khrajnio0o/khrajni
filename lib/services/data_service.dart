// lib/services/data_service.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:khrajni/models/location.dart';
import 'package:khrajni/models/state.dart';

class DataService {
  static Future<List<StateModel>> loadStates() async {
    final String response =
        await rootBundle.loadString('assets/data/states.json');
    final List<dynamic> data = jsonDecode(response);
    return data.map((json) => StateModel.fromJson(json)).toList();
  }

  static Future<List<Location>> loadAllLocations() async {
    final String response =
        await rootBundle.loadString('assets/data/locations.json');
    final List<dynamic> data = jsonDecode(response);
    return data.map((json) => Location.fromJson(json)).toList();
  }

  static Future<List<Location>> loadLocationsByState(String stateId) async {
    try {
      final List<Location> allLocations = await loadAllLocations();
      return allLocations
          .where((location) => location.stateId == stateId)
          .toList();
    } catch (e) {
      print('Error loading locations by state: $e');
      return [];
    }
  }
}
