import 'package:flutter/material.dart';
import 'package:khrajni/models/location.dart';
import 'package:khrajni/models/state.dart';
import 'package:khrajni/screens/location_detail_screen.dart';
import 'package:khrajni/services/data_service.dart';
import 'package:khrajni/services/similarity_service.dart';
import 'package:khrajni/widgets/location_card.dart';

class StateDetailScreen extends StatefulWidget {
  final StateModel state;
  final String selectedLanguage;
  final Function(String) updateLanguage;

  const StateDetailScreen({
    Key? key,
    required this.state,
    required this.selectedLanguage,
    required this.updateLanguage,
  }) : super(key: key);

  @override
  State<StateDetailScreen> createState() => _StateDetailScreenState();
}

class _StateDetailScreenState extends State<StateDetailScreen> {
  List<Location> allLocations = [];
  List<Location> filteredLocations = [];
  List<Location> recommendedLocations = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    try {
      final locations = await DataService.getLocationsByState(widget.state.id);
      setState(() {
        allLocations = locations;
        filteredLocations = locations;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _searchLocations(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredLocations = allLocations;
        recommendedLocations = [];
      });
      return;
    }

    final similarLocations = SimilarityService.findSimilarLocations(
      query,
      allLocations,
    );

    setState(() {
      recommendedLocations = similarLocations;
      filteredLocations = similarLocations.isEmpty
          ? allLocations
              .where((loc) =>
                  loc
                      .getName(widget.selectedLanguage)
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  loc
                      .getDescription(widget.selectedLanguage)
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  loc.keywords.any((keyword) =>
                      keyword.toLowerCase().contains(query.toLowerCase())))
              .toList()
          : similarLocations;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.state.getName(widget.selectedLanguage)),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          DropdownButton<String>(
            value: widget.selectedLanguage,
            dropdownColor: Colors.blue.shade700,
            style: const TextStyle(color: Colors.white),
            iconEnabledColor: Colors.white,
            items: const {
              'en': 'English',
              'ar': 'العربية',
              'fr': 'Français',
              'ru': 'Русский',
              'de': 'Deutsch',
            }.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                widget.updateLanguage(newValue);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(widget.state.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Text(
                  widget.state.getName(widget.selectedLanguage),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _searchLocations,
              decoration: InputDecoration(
                hintText: widget.selectedLanguage == 'ar'
                    ? 'ابحث عن أماكن الجذب (مثل: متاحف، طبيعة)'
                    : widget.selectedLanguage == 'en'
                        ? 'Search for attractions (e.g., museums, nature)'
                        : widget.selectedLanguage == 'fr'
                            ? 'Recherchez des attractions (ex. musées, nature)'
                            : widget.selectedLanguage == 'ru'
                                ? 'Поиск достопримечательностей (например, музеи, природа)'
                                : 'Suchen Sie Attraktionen (z. B. Museen, Natur)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
              ),
            ),
          ),
          if (recommendedLocations.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                widget.selectedLanguage == 'ar'
                    ? 'التوصيات بناءً على بحثك'
                    : widget.selectedLanguage == 'en'
                        ? 'Recommendations based on your search'
                        : widget.selectedLanguage == 'fr'
                            ? 'Recommandations basées sur votre recherche'
                            : widget.selectedLanguage == 'ru'
                                ? 'Рекомендации на основе вашего поиска'
                                : 'Empfehlungen basierend auf Ihrer Suche',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredLocations.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد أماكن مطابقة لبحثك',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: filteredLocations.length,
                        itemBuilder: (context, index) {
                          final location = filteredLocations[index];
                          return LocationCard(
                            location: location,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LocationDetailScreen(
                                    location: location,
                                    selectedLanguage: widget.selectedLanguage,
                                    updateLanguage: widget.updateLanguage,
                                  ),
                                ),
                              );
                            },
                            selectedLanguage: widget.selectedLanguage,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
