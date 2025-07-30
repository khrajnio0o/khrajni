import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:khrajni/models/location.dart';
import 'package:khrajni/models/state.dart';

class DataService {
  static Future<List<StateModel>> loadStates() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/states.json');
      final data = await json.decode(response);
      return (data as List).map((e) => StateModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Location>> loadLocations() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/locations.json');
      final data = await json.decode(response);
      return (data as List).map((e) => Location.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Location>> getLocationsByState(String stateId) async {
    final locations = await loadLocations();
    return locations.where((location) => location.stateId == stateId).toList();
  }

  static Future<List<Location>> loadAllLocations() async {
    final String response =
        await rootBundle.loadString('assets/data/locations.json');
    final List<dynamic> data = jsonDecode(response);
    return data.map((json) => Location.fromJson(json)).toList();
  }
}
