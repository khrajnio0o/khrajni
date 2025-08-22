import 'package:flutter/material.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String selectedLanguage;

  const PlaceholderScreen({
    Key? key,
    required this.title,
    required this.selectedLanguage,
  }) : super(key: key);

  String _getTitle(String title, String lang) {
    switch (title.toLowerCase()) {
      case 'top deals':
        switch (lang) {
          case 'ar':
            return 'أفضل العروض';
          case 'fr':
            return 'Meilleures Offres';
          case 'ru':
            return 'Лучшие Сделки';
          case 'de':
            return 'Top-Angebote';
          default:
            return 'Top Deals';
        }
      case 'hotels':
        switch (lang) {
          case 'ar':
            return 'فنادق';
          case 'fr':
            return 'Hôtels';
          case 'ru':
            return 'Отели';
          case 'de':
            return 'Hotels';
          default:
            return 'Hotels';
        }
      case 'tours':
        switch (lang) {
          case 'ar':
            return 'جولات';
          case 'fr':
            return 'Visites';
          case 'ru':
            return 'Туры';
          case 'de':
            return 'Touren';
          default:
            return 'Tours';
        }
      case 'discounts':
        switch (lang) {
          case 'ar':
            return 'خصومات';
          case 'fr':
            return 'Réductions';
          case 'ru':
            return 'Скидки';
          case 'de':
            return 'Rabatte';
          default:
            return 'Discounts';
        }
      default:
        return title;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getTitle(title, selectedLanguage),
          style: const TextStyle(fontFamily: 'Tajawal'),
        ),
        backgroundColor:
            isDarkMode ? Theme.of(context).scaffoldBackgroundColor : null,
        elevation: isDarkMode ? 0 : 4,
      ),
      body: Center(
        child: Text(
          selectedLanguage == 'ar'
              ? 'هذه صفحة مؤقتة لـ ${_getTitle(title, selectedLanguage)}'
              : 'This is a placeholder screen for ${_getTitle(title, selectedLanguage)}',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Tajawal',
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
      ),
    );
  }
}
