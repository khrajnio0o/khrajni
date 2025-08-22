import 'package:flutter/material.dart';
import 'package:khrajni/screens/placeholder_screen.dart';

class DealsScreen extends StatelessWidget {
  final String selectedLanguage;
  final Function(String) updateLanguage;
  final ThemeMode themeMode;
  final VoidCallback toggleTheme;

  const DealsScreen({
    Key? key,
    required this.selectedLanguage,
    required this.updateLanguage,
    required this.themeMode,
    required this.toggleTheme,
  }) : super(key: key);

  String _getTopDealsTitle(String lang) {
    switch (lang) {
      case 'ar':
        return 'أفضل العروض';
      case 'en':
        return 'Top Deals';
      case 'fr':
        return 'Meilleures Offres';
      case 'ru':
        return 'Лучшие Сделки';
      case 'de':
        return 'Top-Angebote';
      default:
        return 'Top Deals';
    }
  }

  String _getViewAll(String lang) {
    switch (lang) {
      case 'ar':
        return 'عرض الكل';
      case 'en':
        return 'View all';
      case 'fr':
        return 'Voir tout';
      case 'ru':
        return 'Посмотреть все';
      case 'de':
        return 'Alle ansehen';
      default:
        return 'View all';
    }
  }

  String _getHotelsTitle(String lang) {
    switch (lang) {
      case 'ar':
        return 'فنادق';
      case 'en':
        return 'Hotels';
      case 'fr':
        return 'Hôtels';
      case 'ru':
        return 'Отели';
      case 'de':
        return 'Hotels';
      default:
        return 'Hotels';
    }
  }

  String _getBookNow(String lang) {
    switch (lang) {
      case 'ar':
        return 'احجز الآن';
      case 'en':
        return 'Book now';
      case 'fr':
        return 'Réservez maintenant';
      case 'ru':
        return 'Забронировать сейчас';
      case 'de':
        return 'Jetzt buchen';
      default:
        return 'Book now';
    }
  }

  String _getToursTitle(String lang) {
    switch (lang) {
      case 'ar':
        return 'جولات';
      case 'en':
        return 'Tours';
      case 'fr':
        return 'Visites';
      case 'ru':
        return 'Туры';
      case 'de':
        return 'Touren';
      default:
        return 'Tours';
    }
  }

  String _getSeeAll(String lang) {
    switch (lang) {
      case 'ar':
        return 'شاهد الكل';
      case 'en':
        return 'See all';
      case 'fr':
        return 'Voir tout';
      case 'ru':
        return 'Посмотреть все';
      case 'de':
        return 'Alle ansehen';
      default:
        return 'See all';
    }
  }

  String _getDiscountsTitle(String lang) {
    switch (lang) {
      case 'ar':
        return 'خصومات';
      case 'en':
        return 'Discounts';
      case 'fr':
        return 'Réductions';
      case 'ru':
        return 'Скидки';
      case 'de':
        return 'Rabatte';
      default:
        return 'Discounts';
    }
  }

  String _getGetCoupons(String lang) {
    switch (lang) {
      case 'ar':
        return 'احصل على كوبونات';
      case 'en':
        return 'Get coupons';
      case 'fr':
        return 'Obtenir des coupons';
      case 'ru':
        return 'Получить купоны';
      case 'de':
        return 'Gutscheine erhalten';
      default:
        return 'Get coupons';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 32; // Full width minus padding
    final gridCardWidth = (screenWidth - 48) / 2; // Two columns with 16px gap

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Deals Card
          InkWell(
            onTap: () {
              print('Tapped Top Deals');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaceholderScreen(
                    title: 'Top Deals',
                    selectedLanguage: selectedLanguage,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: cardWidth,
                height: screenHeight * 0.25, // Dynamic height: 25% of screen
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/deals/beach.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTopDealsTitle(selectedLanguage),
                          style: TextStyle(
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        Text(
                          _getViewAll(selectedLanguage),
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Colors.white70,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Hotels Card
          InkWell(
            onTap: () {
              print('Tapped Hotels');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaceholderScreen(
                    title: 'Hotels',
                    selectedLanguage: selectedLanguage,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: cardWidth,
                height: screenHeight * 0.25, // Dynamic height: 25% of screen
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/deals/hotel_room.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getHotelsTitle(selectedLanguage),
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        Text(
                          _getBookNow(selectedLanguage),
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.white70,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Tours and Discounts Grid
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    print('Tapped Tours');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaceholderScreen(
                          title: 'Tours',
                          selectedLanguage: selectedLanguage,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      width: gridCardWidth,
                      height:
                          screenHeight * 0.15, // Dynamic height: 15% of screen
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: const DecorationImage(
                          image: AssetImage(
                              'assets/images/deals/traveler_backpack.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getToursTitle(selectedLanguage),
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                              Text(
                                _getSeeAll(selectedLanguage),
                                style: TextStyle(
                                  fontSize: screenWidth * 0.03,
                                  color: Colors.white70,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () {
                    print('Tapped Discounts');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaceholderScreen(
                          title: 'Discounts',
                          selectedLanguage: selectedLanguage,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      width: gridCardWidth,
                      height:
                          screenHeight * 0.15, // Dynamic height: 15% of screen
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: const DecorationImage(
                          image: AssetImage(
                              'assets/images/deals/smiling_woman_city.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getDiscountsTitle(selectedLanguage),
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                              Text(
                                _getGetCoupons(selectedLanguage),
                                style: TextStyle(
                                  fontSize: screenWidth * 0.03,
                                  color: Colors.white70,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
