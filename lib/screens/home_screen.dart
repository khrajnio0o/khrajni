// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:khrajni/models/location.dart';
import 'package:khrajni/models/state.dart';
import 'package:khrajni/screens/settings_screen.dart';
import 'package:khrajni/screens/state_detail_screen.dart';
import 'package:khrajni/services/data_service.dart';
import 'package:khrajni/widgets/state_card.dart';
import 'package:khrajni/widgets/location_card.dart';

class HomeScreen extends StatefulWidget {
  final String selectedLanguage;
  final Function(String) updateLanguage;
  final ThemeMode themeMode;
  final VoidCallback toggleTheme;

  const HomeScreen({
    Key? key,
    required this.selectedLanguage,
    required this.updateLanguage,
    required this.themeMode,
    required this.toggleTheme,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<StateModel> states = [];
  List<Location> allLocations = [];
  bool isLoading = true;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final TextEditingController _searchController = TextEditingController();
  List<StateModel> filteredStates = [];
  List<Location> filteredLocations = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  Future<void> _loadData() async {
    try {
      final loadedStates = await DataService.loadStates();
      final allLocs = await DataService.loadAllLocations();
      setState(() {
        states = loadedStates;
        allLocations = allLocs;
        filteredStates = loadedStates;
        filteredLocations = allLocs;
        isLoading = false;
      });
      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError(e.toString());
    }
  }

  void _searchData(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredStates = states;
        filteredLocations = allLocations;
      });
      return;
    }

    setState(() {
      filteredStates = states
          .where((state) =>
              state
                  .getName(widget.selectedLanguage)
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              state
                  .getDescription(widget.selectedLanguage)
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();

      filteredLocations = allLocations
          .where((location) =>
              location
                  .getName(widget.selectedLanguage)
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              location
                  .getDescription(widget.selectedLanguage)
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              location.keywords.any((keyword) =>
                  keyword.toLowerCase().contains(query.toLowerCase())))
          .toList();
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.selectedLanguage == 'ar'
              ? 'خطأ: $message'
              : widget.selectedLanguage == 'en'
                  ? 'Error: $message'
                  : widget.selectedLanguage == 'fr'
                      ? 'Erreur : $message'
                      : widget.selectedLanguage == 'ru'
                          ? 'Ошибка: $message'
                          : 'Fehler: $message',
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getAppTitle(String lang) {
    switch (lang) {
      case 'ar':
        return 'خرجني';
      case 'en':
        return 'Khrajni';
      case 'fr':
        return 'Khrajni';
      case 'ru':
        return 'Khrajni';
      case 'de':
        return 'Khrajni';
      default:
        return 'Khrajni';
    }
  }

  String _getHomeLabel(String lang) {
    switch (lang) {
      case 'ar':
        return 'الرئيسية';
      case 'en':
        return 'Home';
      case 'fr':
        return 'Accueil';
      case 'ru':
        return 'Главная';
      case 'de':
        return 'Startseite';
      default:
        return 'Home';
    }
  }

  String _getCategoriesLabel(String lang) {
    switch (lang) {
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

  String _getFavoritesLabel(String lang) {
    switch (lang) {
      case 'ar':
        return 'المفضلة';
      case 'en':
        return 'Favorites';
      case 'fr':
        return 'Favoris';
      case 'ru':
        return 'Избранное';
      case 'de':
        return 'Favoriten';
      default:
        return 'Favorites';
    }
  }

  String _getPlanLabel(String lang) {
    switch (lang) {
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

  String _getSectionTitle(int index, String lang) {
    switch (index) {
      case 1:
        return lang == 'ar'
            ? 'الفئات قيد التطوير'
            : lang == 'en'
                ? 'Categories under development'
                : lang == 'fr'
                    ? 'Catégories en développement'
                    : lang == 'ru'
                        ? 'Категории в разработке'
                        : 'Kategorien in Entwicklung';
      case 2:
        return lang == 'ar'
            ? 'المفضلة قيد التطوير'
            : lang == 'en'
                ? 'Favorites under development'
                : lang == 'fr'
                    ? 'Favoris en développement'
                    : lang == 'ru'
                        ? 'Избранное в разработке'
                        : 'Favoriten in Entwicklung';
      case 3:
        return lang == 'ar'
            ? 'خطتك قيد التطوير'
            : lang == 'en'
                ? 'Your Plan under development'
                : lang == 'fr'
                    ? 'Votre Plan en développement'
                    : lang == 'ru'
                        ? 'Ваш План в разработке'
                        : 'Ihr Plan in Entwicklung';
      default:
        return '';
    }
  }

  Widget _buildHomeContent() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _searchData,
              decoration: InputDecoration(
                hintText: widget.selectedLanguage == 'ar'
                    ? 'ابحث عن وجهة (مثل القاهرة، الهرم)'
                    : widget.selectedLanguage == 'en'
                        ? 'Search for a destination (e.g. Cairo, Pyramids)'
                        : widget.selectedLanguage == 'fr'
                            ? 'Rechercher une destination (ex. Le Caire, Pyramides)'
                            : widget.selectedLanguage == 'ru'
                                ? 'Поиск места (например, Каир, Пирамиды)'
                                : 'Suche nach einem Ziel (z.B. Kairo, Pyramiden)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (filteredStates.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.selectedLanguage == 'ar'
                                          ? 'المحافظات'
                                          : widget.selectedLanguage == 'en'
                                              ? 'States'
                                              : widget.selectedLanguage == 'fr'
                                                  ? 'États'
                                                  : widget.selectedLanguage ==
                                                          'ru'
                                                      ? 'Штаты'
                                                      : 'Staaten',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? Colors.white70
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      height: 250,
                                      child: PageView.builder(
                                        itemCount: filteredStates.length,
                                        itemBuilder: (context, index) {
                                          final state = filteredStates[index];
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: StateCard(
                                              state: state,
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        StateDetailScreen(
                                                      state: state,
                                                      selectedLanguage: widget
                                                          .selectedLanguage,
                                                      updateLanguage:
                                                          widget.updateLanguage,
                                                    ),
                                                  ),
                                                );
                                              },
                                              selectedLanguage:
                                                  widget.selectedLanguage,
                                              isDarkMode: isDarkMode,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              if (filteredLocations.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 16),
                                    Text(
                                      widget.selectedLanguage == 'ar'
                                          ? 'أماكن الجذب'
                                          : widget.selectedLanguage == 'en'
                                              ? 'Attractions'
                                              : widget.selectedLanguage == 'fr'
                                                  ? 'Attractions'
                                                  : widget.selectedLanguage ==
                                                          'ru'
                                                      ? 'Достопримечательности'
                                                      : 'Attraktionen',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? Colors.white70
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...filteredLocations.map((location) {
                                      return LocationCard(
                                        location: location,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  StateDetailScreen(
                                                state: states.firstWhere((s) =>
                                                    s.id == location.stateId),
                                                selectedLanguage:
                                                    widget.selectedLanguage,
                                                updateLanguage:
                                                    widget.updateLanguage,
                                              ),
                                            ),
                                          );
                                        },
                                        selectedLanguage:
                                            widget.selectedLanguage,
                                        isDarkMode: isDarkMode,
                                      );
                                    }).toList(),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(_getAppTitle(widget.selectedLanguage)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    selectedLanguage: widget.selectedLanguage,
                    updateLanguage: widget.updateLanguage,
                    themeMode: widget.themeMode,
                    toggleTheme: widget.toggleTheme,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? _buildHomeContent()
          : Center(
              child: Text(
                _getSectionTitle(_selectedIndex, widget.selectedLanguage),
                style: TextStyle(
                  fontSize: 20,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: _getHomeLabel(widget.selectedLanguage),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.category),
            label: _getCategoriesLabel(widget.selectedLanguage),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite),
            label: _getFavoritesLabel(widget.selectedLanguage),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.assignment),
            label: _getPlanLabel(widget.selectedLanguage),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
