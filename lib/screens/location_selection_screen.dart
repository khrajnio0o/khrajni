import 'package:flutter/material.dart';
import 'package:khrajni/models/location.dart';
import 'package:khrajni/models/state.dart';
import 'package:khrajni/screens/your_plan_screen.dart';
import 'package:khrajni/services/data_service.dart';

class LocationSelectionScreen extends StatefulWidget {
  final List<Location> allLocations;
  final String selectedLanguage;
  final List<PlanItem> selectedPlanItems;

  const LocationSelectionScreen({
    Key? key,
    required this.allLocations,
    required this.selectedLanguage,
    required this.selectedPlanItems,
  }) : super(key: key);

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  List<StateModel> allStates = [];
  StateModel? selectedState;
  Location? selectedLocation;
  final TextEditingController _durationController = TextEditingController();
  String? selectedDay;
  TimeOfDay? selectedTime;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  Future<void> _loadStates() async {
    try {
      final states = await DataService.loadStates();
      setState(() {
        allStates = states;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading states: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.selectedLanguage == 'ar'
                ? 'خطأ في تحميل المحافظات'
                : 'Error loading states',
            style: const TextStyle(fontFamily: 'Tajawal'),
          ),
        ),
      );
    }
  }

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

  String _getStateLabel() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'المحافظة';
      case 'en':
        return 'State';
      case 'fr':
        return 'État';
      case 'ru':
        return 'Штат';
      case 'de':
        return 'Staat';
      default:
        return 'State';
    }
  }

  String _getLocationLabel() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'المكان';
      case 'en':
        return 'Place';
      case 'fr':
        return 'Lieu';
      case 'ru':
        return 'Место';
      case 'de':
        return 'Ort';
      default:
        return 'Place';
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

  String _getDayLabel() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'اليوم';
      case 'en':
        return 'Day';
      case 'fr':
        return 'Jour';
      case 'ru':
        return 'День';
      case 'de':
        return 'Tag';
      default:
        return 'Day';
    }
  }

  String _getTimeLabel() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'الوقت';
      case 'en':
        return 'Time';
      case 'fr':
        return 'Heure';
      case 'ru':
        return 'Время';
      case 'de':
        return 'Zeit';
      default:
        return 'Time';
    }
  }

  List<String> _getDays() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return [
          'الإثنين',
          'الثلاثاء',
          'الأربعاء',
          'الخميس',
          'الجمعة',
          'السبت',
          'الأحد'
        ];
      case 'en':
        return [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday'
        ];
      case 'fr':
        return [
          'Lundi',
          'Mardi',
          'Mercredi',
          'Jeudi',
          'Vendredi',
          'Samedi',
          'Dimanche'
        ];
      case 'ru':
        return [
          'Понедельник',
          'Вторник',
          'Среда',
          'Четверг',
          'Пятница',
          'Суббота',
          'Воскресенье'
        ];
      case 'de':
        return [
          'Montag',
          'Dienstag',
          'Mittwoch',
          'Donnerstag',
          'Freitag',
          'Samstag',
          'Sonntag'
        ];
      default:
        return [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday'
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87;
    final fillColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[800]!
        : Colors.grey[200]!;
    final filteredLocations = selectedState != null
        ? widget.allLocations
            .where((loc) => loc.stateId == selectedState!.id)
            .toList()
        : widget.allLocations;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _getTitle(),
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // State Dropdown
                  DropdownButtonFormField<StateModel>(
                    value: selectedState,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: fillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      labelText: _getStateLabel(),
                      labelStyle: TextStyle(
                        fontFamily: 'Tajawal',
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                    dropdownColor: fillColor,
                    items: allStates.map((state) {
                      return DropdownMenuItem<StateModel>(
                        value: state,
                        child: Text(
                          state.getName(widget.selectedLanguage),
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 16,
                            color: textColor,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedState = value;
                        selectedLocation =
                            null; // Reset location when state changes
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Location Dropdown
                  DropdownButtonFormField<Location>(
                    value: selectedLocation,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: fillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      labelText: _getLocationLabel(),
                      labelStyle: TextStyle(
                        fontFamily: 'Tajawal',
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                    dropdownColor: fillColor,
                    items: filteredLocations.map((location) {
                      return DropdownMenuItem<Location>(
                        value: location,
                        child: Text(
                          location.getName(widget.selectedLanguage),
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 16,
                            color: textColor,
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
                  // Duration Input
                  TextField(
                    controller: _durationController,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      color: textColor,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: fillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      hintText: _getDurationHint(),
                      hintStyle: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        color: textColor.withOpacity(0.5),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  // Day and Time Pickers (only for first location)
                  if (widget.selectedPlanItems.isEmpty) ...[
                    DropdownButtonFormField<String>(
                      value: selectedDay,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: fillColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        labelText: _getDayLabel(),
                        labelStyle: TextStyle(
                          fontFamily: 'Tajawal',
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                      dropdownColor: fillColor,
                      items: _getDays().map((day) {
                        return DropdownMenuItem<String>(
                          value: day,
                          child: Text(
                            day,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 16,
                              color: textColor,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDay = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedTime != null
                                ? selectedTime!.format(context)
                                : _getTimeLabel(),
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 14,
                              color: textColor.withOpacity(0.7),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              setState(() {
                                selectedTime = time;
                              });
                            }
                          },
                          child: Text(
                            widget.selectedLanguage == 'ar'
                                ? 'اختر الوقت'
                                : 'Select Time',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Add Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (selectedLocation != null &&
                            _durationController.text.isNotEmpty) {
                          final duration =
                              double.tryParse(_durationController.text) ?? 0.0;
                          if (duration <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  widget.selectedLanguage == 'ar'
                                      ? 'يرجى إدخال مدة صالحة'
                                      : 'Please enter a valid duration',
                                  style: const TextStyle(fontFamily: 'Tajawal'),
                                ),
                              ),
                            );
                            return;
                          }
                          String day;
                          String time;
                          if (widget.selectedPlanItems.isEmpty) {
                            // First location: use user-selected day and time
                            if (selectedDay == null || selectedTime == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    widget.selectedLanguage == 'ar'
                                        ? 'يرجى اختيار اليوم والوقت'
                                        : 'Please select day and time',
                                    style:
                                        const TextStyle(fontFamily: 'Tajawal'),
                                  ),
                                ),
                              );
                              return;
                            }
                            day = selectedDay!;
                            time = selectedTime!.format(context);
                          } else {
                            // Subsequent locations: calculate based on previous
                            final prevItems = widget.selectedPlanItems;
                            if (prevItems.isEmpty) {
                              day = _getDays()[0]; // Default to first day
                              time = '10:00 AM';
                            } else {
                              final lastItem = prevItems.last;
                              final lastTime =
                                  _parseTime(lastItem.time, lastItem.day);
                              final newTime = lastTime.add(
                                  Duration(hours: lastItem.duration.ceil()));
                              day = _getDayFromDate(
                                  newTime, widget.selectedLanguage);
                              time = _formatTime(newTime);
                            }
                          }
                          Navigator.pop(context, {
                            'location': selectedLocation,
                            'duration': duration,
                            'day': day,
                            'time': time,
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.selectedLanguage == 'ar' ? 'إضافة' : 'Add',
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
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

  DateTime _parseTime(String timeStr, String day) {
    final days = _getDays();
    final dayIndex = days.indexOf(day);
    final timeParts = timeStr.split(' ');
    final isPM = timeParts[1].toLowerCase() == 'pm';
    final hourMinute = timeParts[0].split(':');
    int hour = int.parse(hourMinute[0]);
    final minute = int.parse(hourMinute[1]);
    if (isPM && hour != 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;
    return DateTime(
        2025, 1, 6 + dayIndex, hour, minute); // Arbitrary base date (Monday)
  }

  String _getDayFromDate(DateTime date, String language) {
    final days = _getDays();
    final dayIndex = date.weekday - 1; // DateTime.weekday: 1=Monday, 7=Sunday
    return days[dayIndex % 7];
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }
}
