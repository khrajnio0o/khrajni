import 'package:flutter/material.dart';
import 'package:khrajni/models/location.dart';
import 'package:khrajni/screens/location_detail_screen.dart';
import 'package:khrajni/widgets/location_card.dart';

class CategoriesScreen extends StatelessWidget {
  final String selectedLanguage;
  final Function(String) updateLanguage;
  final List<Location> allLocations;

  const CategoriesScreen({
    Key? key,
    required this.selectedLanguage,
    required this.updateLanguage,
    required this.allLocations,
  }) : super(key: key);

  String _getCategoriesTitle() {
    switch (selectedLanguage) {
      case 'ar':
        return 'الفئات';
      case 'en':
        return 'Categories';
      case 'fr':
        return 'Catégories';
      case 'ru':
        return 'Категории';
      case 'de':
        return 'Kategorien';
      default:
        return 'Categories';
    }
  }

  String _getNoCategoriesMessage() {
    switch (selectedLanguage) {
      case 'ar':
        return 'لا توجد فئات متاحة';
      case 'en':
        return 'No categories available';
      case 'fr':
        return 'Aucune catégorie disponible';
      case 'ru':
        return 'Нет доступных категорий';
      case 'de':
        return 'Keine Kategorien verfügbar';
      default:
        return 'No categories available';
    }
  }

  IconData _getCategoryIcon(String category) {
    // Map categories to icons (customize as needed)
    switch (category.toLowerCase()) {
      case 'آثار':
      case 'antiquities':
      case 'antiquités':
      case 'древности':
      case 'antiken':
        return Icons.account_balance;
      case 'تاريخ':
      case 'history':
      case 'histoire':
      case 'история':
      case 'geschichte':
        return Icons.history;
      case 'ترفيه':
      case 'entertainment':
      case 'divertissement':
      case 'развлечения':
      case 'unterhaltung':
        return Icons.local_activity;
      case 'ثقافة':
      case 'culture':
      case 'culture':
      case 'культура':
      case 'kultur':
        return Icons.museum;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Set<String> uniqueCategories = allLocations
        .expand((loc) => loc.getCategories(selectedLanguage))
        .toSet();
    final List<String> sortedCategories = uniqueCategories.toList()..sort();

    final List<Color> categoryColors = [
      Colors.amber[100]!, // Subtle gold for Pharaonic aesthetic
      Colors.orange[100]!, // Subtle light orange for Pharaonic aesthetic
    ];

    if (sortedCategories.isEmpty) {
      return Center(
        child: Text(
          _getNoCategoriesMessage(),
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Tajawal',
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0), // Minimal padding for compactness
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getCategoriesTitle(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 columns for mobile
                childAspectRatio: 1, // Square cards
                crossAxisSpacing: 8, // Tight spacing
                mainAxisSpacing: 8, // Tight spacing
              ),
              itemCount: sortedCategories.length,
              itemBuilder: (context, index) {
                final category = sortedCategories[index];
                final color = categoryColors[index % categoryColors.length];
                return GestureDetector(
                  onTap: () {
                    final filteredLocations = allLocations
                        .where((loc) => loc
                            .getCategories(selectedLanguage)
                            .contains(category))
                        .toList();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(
                            title: Text(
                              category,
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            backgroundColor: isDarkMode
                                ? Colors.grey[900]
                                : Colors.amber[50],
                          ),
                          body: ListView.builder(
                            padding: const EdgeInsets.all(10.0),
                            itemCount: filteredLocations.length,
                            itemBuilder: (context, locIndex) {
                              final location = filteredLocations[locIndex];
                              return LocationCard(
                                location: location,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          LocationDetailScreen(
                                        location: location,
                                        selectedLanguage: selectedLanguage,
                                        updateLanguage: updateLanguage,
                                      ),
                                    ),
                                  );
                                },
                                selectedLanguage: selectedLanguage,
                                isDarkMode: isDarkMode,
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 2, // Subtle elevation for a lightweight look
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Rounded corners
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            color,
                            color.withOpacity(0.8), // Subtle gradient
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getCategoryIcon(category),
                            size: 24, // Small, thin icon
                            color:
                                isDarkMode ? Colors.amber[700] : Colors.black54,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            category,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12, // Small but readable
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w500,
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
