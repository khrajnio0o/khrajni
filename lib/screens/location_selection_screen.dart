import 'package:flutter/material.dart';
import 'package:khrajni/models/location.dart';

class LocationSelectionScreen extends StatefulWidget {
  final List<Location> allLocations;
  final String selectedLanguage;

  const LocationSelectionScreen({
    Key? key,
    required this.allLocations,
    required this.selectedLanguage,
  }) : super(key: key);

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  Location? selectedLocation;
  final TextEditingController _durationController = TextEditingController();

  String _getTitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'اختر مكانًا';
      case 'en':
        return 'Select a Place';
      case 'fr':
        return 'Sélectionner un Lieu';
      case 'ru':
        return 'Выберите Место';
      case 'de':
        return 'Ort Auswählen';
      default:
        return 'Select a Place';
    }
  }

  String _getDurationHint() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'أدخل المدة (بالساعات)';
      case 'en':
        return 'Enter duration (hours)';
      case 'fr':
        return 'Entrez la durée (heures)';
      case 'ru':
        return 'Введите продолжительность (часы)';
      case 'de':
        return 'Dauer eingeben (Stunden)';
      default:
        return 'Enter duration (hours)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(
          _getTitle(),
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.grey[900],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<Location>(
              value: selectedLocation,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                labelText: widget.selectedLanguage == 'ar' ? 'المكان' : 'Place',
                labelStyle: const TextStyle(
                  fontFamily: 'Roboto',
                  color: Colors.white70,
                ),
              ),
              dropdownColor: Colors.grey[800],
              items: widget.allLocations.map((location) {
                return DropdownMenuItem<Location>(
                  value: location,
                  child: Text(
                    location.getName(widget.selectedLanguage),
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedLocation = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _durationController,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                hintText: _getDurationHint(),
                hintStyle: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: Colors.white54,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (selectedLocation != null &&
                      _durationController.text.isNotEmpty) {
                    final duration =
                        double.tryParse(_durationController.text) ?? 0.0;
                    if (duration > 0) {
                      Navigator.pop(context, {
                        'location': selectedLocation,
                        'duration': duration,
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            widget.selectedLanguage == 'ar'
                                ? 'يرجى إدخال مدة صالحة'
                                : 'Please enter a valid duration',
                            style: const TextStyle(fontFamily: 'Roboto'),
                          ),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.selectedLanguage == 'ar' ? 'إضافة' : 'Add',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }
}
