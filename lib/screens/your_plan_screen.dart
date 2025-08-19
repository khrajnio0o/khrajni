import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:khrajni/models/location.dart';
import 'package:khrajni/screens/location_selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlanItem {
  final Location location;
  final double duration; // in hours
  final String time; // e.g., "Friday, 10:00 AM"
  final String day; // e.g., "Friday"

  PlanItem({
    required this.location,
    required this.duration,
    required this.time,
    required this.day,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': location.id,
      'duration': duration,
      'time': time,
      'day': day,
    };
  }

  static PlanItem fromJson(
      Map<String, dynamic> json, List<Location> allLocations) {
    final location = allLocations.firstWhere(
      (loc) => loc.id == json['id'],
      orElse: () => throw Exception('Location not found: ${json['id']}'),
    );
    return PlanItem(
      location: location,
      duration: (json['duration'] as num).toDouble(),
      time: json['time'],
      day: json['day'],
    );
  }
}

class YourPlanScreen extends StatefulWidget {
  final String selectedLanguage;
  final Function(String) updateLanguage;
  final ThemeMode themeMode;
  final VoidCallback toggleTheme;
  final List<Location> allLocations;

  const YourPlanScreen({
    Key? key,
    required this.selectedLanguage,
    required this.updateLanguage,
    required this.themeMode,
    required this.toggleTheme,
    required this.allLocations,
  }) : super(key: key);

  @override
  State<YourPlanScreen> createState() => _YourPlanScreenState();
}

class _YourPlanScreenState extends State<YourPlanScreen> {
  List<PlanItem> selectedPlanItems = [];
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPlanData();
    _notesController.addListener(_saveNotes);
  }

  Future<void> _loadPlanData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = prefs.getStringList('selected_plan_items') ?? [];
      setState(() {
        selectedPlanItems = itemsJson.map((jsonStr) {
          final jsonData = jsonDecode(jsonStr) as Map<String, dynamic>;
          return PlanItem.fromJson(jsonData, widget.allLocations);
        }).toList();
      });
      _notesController.text =
          prefs.getString('plan_notes_${widget.selectedLanguage}') ?? '';
    } catch (e) {
      debugPrint('Error loading plan data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.selectedLanguage == 'ar'
                ? 'خطأ في تحميل الخطة'
                : 'Error loading plan',
            style: const TextStyle(fontFamily: 'Tajawal'),
          ),
        ),
      );
    }
  }

  Future<void> _savePlanData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson =
          selectedPlanItems.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList('selected_plan_items', itemsJson);
    } catch (e) {
      debugPrint('Error saving plan data: $e');
    }
  }

  Future<void> _saveNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'plan_notes_${widget.selectedLanguage}', _notesController.text);
    } catch (e) {
      debugPrint('Error saving notes: $e');
    }
  }

  String _getPlanTitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'خطتك';
      case 'en':
        return 'Your Plan';
      case 'fr':
        return 'Votre Plan';
      case 'ru':
        return 'Ваш План';
      case 'de':
        return 'Ihr Plan';
      default:
        return 'Your Plan';
    }
  }

  String _getSelectedPlacesTitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'الأماكن المختارة';
      case 'en':
        return 'Selected Places';
      case 'fr':
        return 'Lieux Sélectionnés';
      case 'ru':
        return 'Выбранные Места';
      case 'de':
        return 'Ausgewählte Orte';
      default:
        return 'Selected Places';
    }
  }

  String _getAddPlaceButtonText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'إضافة مكان';
      case 'en':
        return 'Add Place';
      case 'fr':
        return 'Ajouter un Lieu';
      case 'ru':
        return 'Добавить Место';
      case 'de':
        return 'Ort Hinzufügen';
      default:
        return 'Add Place';
    }
  }

  String _getScheduleTitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'الجدول';
      case 'en':
        return 'Schedule';
      case 'fr':
        return 'Programme';
      case 'ru':
        return 'Расписание';
      case 'de':
        return 'Zeitplan';
      default:
        return 'Schedule';
    }
  }

  String _getMapTitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'الخريطة';
      case 'en':
        return 'Map';
      case 'fr':
        return 'Carte';
      case 'ru':
        return 'Карта';
      case 'de':
        return 'Karte';
      default:
        return 'Map';
    }
  }

  String _getDurationLabel() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'المدة';
      case 'en':
        return 'Duration';
      case 'fr':
        return 'Durée';
      case 'ru':
        return 'Продолжительность';
      case 'de':
        return 'Dauer';
      default:
        return 'Duration';
    }
  }

  String _getCostLabel() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'التكلفة المقدرة';
      case 'en':
        return 'Estimated Cost';
      case 'fr':
        return 'Coût Estimé';
      case 'ru':
        return 'Оценочная Стоимость';
      case 'de':
        return 'Geschätzte Kosten';
      default:
        return 'Estimated Cost';
    }
  }

  String _getNotesLabel() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'ملاحظات';
      case 'en':
        return 'Notes';
      case 'fr':
        return 'Notes';
      case 'ru':
        return 'Заметки';
      case 'de':
        return 'Notizen';
      default:
        return 'Notes';
    }
  }

  void _removePlanItem(PlanItem item) {
    setState(() {
      selectedPlanItems.remove(item);
      debugPrint(
          'Removed ${item.location.getName(widget.selectedLanguage)} at ${DateTime.now()}');
    });
    _savePlanData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.selectedLanguage == 'ar'
              ? 'تم إزالة ${item.location.getName(widget.selectedLanguage)}'
              : '${item.location.getName(widget.selectedLanguage)} removed',
          style: const TextStyle(fontFamily: 'Tajawal'),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  double _calculateTotalDuration() {
    return selectedPlanItems.fold(0.0, (sum, item) => sum + item.duration);
  }

  double _extractPrice(String priceStr) {
    // Extract first number from strings like "General: 240 EGP, Students: 120 EGP"
    final regex = RegExp(r'\d+');
    final match = regex.firstMatch(priceStr);
    return double.tryParse(match?.group(0) ?? '0') ?? 0.0;
  }

  double _calculateTotalCost() {
    return selectedPlanItems.fold(0.0, (sum, item) {
      final priceStr =
          item.location.pricesTranslations[widget.selectedLanguage] ?? '0 EGP';
      return sum + _extractPrice(priceStr);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? Colors.grey[850]! : Colors.grey[100]!;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87;
    final chipColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
    final fillColor = isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          _getPlanTitle(),
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selected Places Section
              Card(
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getSelectedPlacesTitle(),
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: selectedPlanItems.map((item) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 6.0),
                            decoration: BoxDecoration(
                              color: chipColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    item.location
                                        .getName(widget.selectedLanguage),
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 14,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    size: 18,
                                    color: textColor.withOpacity(0.7),
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () => _removePlanItem(item),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      if (selectedPlanItems.isEmpty)
                        Text(
                          widget.selectedLanguage == 'ar'
                              ? 'لا توجد أماكن مختارة'
                              : 'No places selected',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            color: textColor.withOpacity(0.7),
                          ),
                        ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LocationSelectionScreen(
                                allLocations: widget.allLocations,
                                selectedLanguage: widget.selectedLanguage,
                                selectedPlanItems: selectedPlanItems,
                              ),
                            ),
                          );
                          if (result != null &&
                              result is Map<String, dynamic>) {
                            final newItem = PlanItem(
                              location: result['location'],
                              duration: result['duration'],
                              time: result['time'],
                              day: result['day'],
                            );
                            if (selectedPlanItems.any((item) =>
                                item.location.id == newItem.location.id)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    widget.selectedLanguage == 'ar'
                                        ? 'المكان موجود بالفعل'
                                        : 'Place already added',
                                    style:
                                        const TextStyle(fontFamily: 'Tajawal'),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              return;
                            }
                            setState(() {
                              selectedPlanItems.add(newItem);
                            });
                            _savePlanData();
                          }
                        },
                        child: Text(
                          _getAddPlaceButtonText(),
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Schedule Section
              Card(
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getScheduleTitle(),
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (selectedPlanItems.isEmpty)
                        Text(
                          widget.selectedLanguage == 'ar'
                              ? 'لا يوجد جدول'
                              : 'No schedule',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            color: textColor.withOpacity(0.7),
                          ),
                        ),
                      ...selectedPlanItems.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: _buildScheduleItem(
                              day: item.day,
                              time: item.time,
                              location: item.location
                                  .getName(widget.selectedLanguage),
                              duration: '${item.duration} h',
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Map Section
              Card(
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getMapTitle(),
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: fillColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: selectedPlanItems.isEmpty
                              ? Text(
                                  widget.selectedLanguage == 'ar'
                                      ? 'لا توجد أماكن في الخريطة'
                                      : 'No places on map',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 14,
                                    color: textColor.withOpacity(0.7),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(8.0),
                                  itemCount: selectedPlanItems.length,
                                  itemBuilder: (context, index) {
                                    final item = selectedPlanItems[index];
                                    return ListTile(
                                      leading: Icon(
                                        Icons.location_on,
                                        color: textColor.withOpacity(0.7),
                                      ),
                                      title: Text(
                                        item.location
                                            .getName(widget.selectedLanguage),
                                        style: TextStyle(
                                          fontFamily: 'Tajawal',
                                          fontSize: 14,
                                          color: textColor,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Summary Information
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryRow(
                      _getDurationLabel(), '${_calculateTotalDuration()} h'),
                  const SizedBox(height: 8),
                  _buildSummaryRow(_getCostLabel(),
                      '${_calculateTotalCost().toStringAsFixed(0)} EGP'),
                ],
              ),
              const SizedBox(height: 8),
              _buildNotesField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleItem({
    required String day,
    required String time,
    required String location,
    required String duration,
  }) {
    final textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87;
    final fillColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[800]!
        : Colors.grey[200]!;
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$day, $time',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                color: textColor.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              location,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              duration,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                color: textColor.withOpacity(0.7),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    final textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 16,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    final textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87;
    final fillColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[800]!
        : Colors.grey[200]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getNotesLabel(),
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _notesController,
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
            hintText: widget.selectedLanguage == 'ar'
                ? 'أدخل ملاحظاتك هنا'
                : 'Enter your notes here',
            hintStyle: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              color: textColor.withOpacity(0.5),
            ),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _notesController.removeListener(_saveNotes);
    _notesController.dispose();
    super.dispose();
  }
}
