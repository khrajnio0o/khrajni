import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:khrajni/models/location.dart';
import 'package:khrajni/models/state.dart';
import 'package:khrajni/screens/categories_screen.dart';
import 'package:khrajni/screens/deals_screen.dart';
import 'package:khrajni/screens/favorites_screen.dart';
import 'package:khrajni/screens/location_detail_screen.dart';
import 'package:khrajni/screens/settings_screen.dart';
import 'package:khrajni/screens/state_detail_screen.dart';
import 'package:khrajni/screens/your_plan_screen.dart';
import 'package:khrajni/services/data_service.dart';
import 'package:khrajni/services/similarity_service.dart';
import 'package:khrajni/widgets/state_card.dart';
import 'package:khrajni/widgets/location_card.dart';
import 'dart:async';

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
  List<Location> nearbyLocations = [];
  List<Location> popularLocations = [];
  int _selectedIndex = 0;
  Position? _currentPosition;
  bool _locationPermissionGranted = false;
  String? currentStateId;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
    _requestLocationPermission();
    _searchController.addListener(_onSearchChanged);
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
        currentStateId = states.isNotEmpty
            ? states
                .firstWhere((state) => state.id == 'cairo',
                    orElse: () => states.first)
                .id
            : null;
        popularLocations = allLocs.take(5).toList();
        isLoading = false;
      });
      print(
          'Loaded ${loadedStates.length} states, ${allLocs.length} locations');
      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError(e.toString());
    }
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationPermissionGranted = false;
        });
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationPermissionGranted = false;
      });
      return;
    }
    setState(() {
      _locationPermissionGranted = true;
    });
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final query = _searchController.text.trim();
      setState(() {
        final results = SimilarityService.findSimilarItems(
          query: query,
          states: states,
          locations: allLocations,
          language: widget.selectedLanguage,
        );
        filteredStates = results['states'] as List<StateModel>;
        filteredLocations = results['locations'] as List<Location>;
        print(
            'Search results: ${filteredStates.length} states, ${filteredLocations.length} locations');
      });
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.selectedLanguage == 'ar' ? 'خطأ: $message' : 'Error: $message',
          style: const TextStyle(fontFamily: 'Tajawal'),
        ),
      ),
    );
  }

  String _getAppTitle() {
    switch (widget.selectedLanguage) {
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

  String _getDealsLabel(String lang) {
    switch (lang) {
      case 'ar':
        return 'عروض وأساسيات';
      case 'en':
        return 'Deals & Essentials';
      case 'fr':
        return 'Offres et Essentiels';
      case 'ru':
        return 'Сделки и Основы';
      case 'de':
        return 'Angebote und Essentials';
      default:
        return 'Deals & Essentials';
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildHomeContent() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: widget.selectedLanguage == 'ar'
                      ? 'ابحث عن وجهة...'
                      : 'Search for a destination...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                ),
                onChanged: (_) => _onSearchChanged(),
              ),
              const SizedBox(height: 16),
              if (_searchController.text.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.selectedLanguage == 'ar'
                          ? 'نتائج البحث'
                          : 'Search Results',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (filteredStates.isEmpty && filteredLocations.isEmpty)
                      Center(
                        child: Text(
                          widget.selectedLanguage == 'ar'
                              ? 'لا توجد نتائج مطابقة'
                              : 'No matching results',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Tajawal',
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (filteredStates.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.selectedLanguage == 'ar'
                                      ? 'المحافظات'
                                      : 'States',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 220,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: filteredStates.length,
                                    itemBuilder: (context, index) {
                                      final state = filteredStates[index];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: SizedBox(
                                          width: 300,
                                          child: StateCard(
                                            state: state,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      StateDetailScreen(
                                                    state: state,
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
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 16),
                          if (filteredLocations.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.selectedLanguage == 'ar'
                                      ? 'الأماكن'
                                      : 'Locations',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: filteredLocations.length,
                                  itemBuilder: (context, index) {
                                    final location = filteredLocations[index];
                                    return LocationCard(
                                      location: location,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                LocationDetailScreen(
                                              location: location,
                                              selectedLanguage:
                                                  widget.selectedLanguage,
                                              updateLanguage:
                                                  widget.updateLanguage,
                                            ),
                                          ),
                                        );
                                      },
                                      selectedLanguage: widget.selectedLanguage,
                                      isDarkMode: isDarkMode,
                                    );
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.selectedLanguage == 'ar'
                          ? 'اكتشف المحافظات'
                          : 'Discover States',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (filteredStates.isEmpty)
                      Center(
                        child: Text(
                          widget.selectedLanguage == 'ar'
                              ? 'لا توجد محافظات متاحة'
                              : 'No states available',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Tajawal',
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: filteredStates.length,
                          itemBuilder: (context, index) {
                            final state = filteredStates[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: SizedBox(
                                width: 300,
                                child: StateCard(
                                  state: state,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => StateDetailScreen(
                                          state: state,
                                          selectedLanguage:
                                              widget.selectedLanguage,
                                          updateLanguage: widget.updateLanguage,
                                        ),
                                      ),
                                    );
                                  },
                                  selectedLanguage: widget.selectedLanguage,
                                  isDarkMode: isDarkMode,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (_locationPermissionGranted && _currentPosition != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.selectedLanguage == 'ar'
                                ? 'أماكن قريبة'
                                : 'Nearby Locations',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (nearbyLocations.isEmpty)
                            Center(
                              child: Text(
                                widget.selectedLanguage == 'ar'
                                    ? 'لا توجد أماكن قريبة متاحة'
                                    : 'No nearby locations available',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Tajawal',
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: nearbyLocations.length,
                              itemBuilder: (context, index) {
                                final location = nearbyLocations[index];
                                return LocationCard(
                                  location: location,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            LocationDetailScreen(
                                          location: location,
                                          selectedLanguage:
                                              widget.selectedLanguage,
                                          updateLanguage: widget.updateLanguage,
                                        ),
                                      ),
                                    );
                                  },
                                  selectedLanguage: widget.selectedLanguage,
                                  isDarkMode: isDarkMode,
                                );
                              },
                            ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    Text(
                      widget.selectedLanguage == 'ar'
                          ? 'أماكن شائعة'
                          : 'Popular Locations',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (popularLocations.isEmpty)
                      Center(
                        child: Text(
                          widget.selectedLanguage == 'ar'
                              ? 'لا توجد أماكن شائعة متاحة'
                              : 'No popular locations available',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Tajawal',
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: popularLocations.length,
                        itemBuilder: (context, index) {
                          final location = popularLocations[index];
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
                            isDarkMode: isDarkMode,
                          );
                        },
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(_getAppTitle()),
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
        backgroundColor: isDarkMode ? Colors.grey[900] : null,
        elevation: isDarkMode ? 0 : 4,
      ),
      body: _selectedIndex == 0
          ? _buildHomeContent()
          : _selectedIndex == 1
              ? CategoriesScreen(
                  selectedLanguage: widget.selectedLanguage,
                  updateLanguage: widget.updateLanguage,
                  allLocations: allLocations,
                )
              : _selectedIndex == 2
                  ? FavoritesScreen(
                      selectedLanguage: widget.selectedLanguage,
                      updateLanguage: widget.updateLanguage,
                      allLocations: allLocations,
                    )
                  : _selectedIndex == 3
                      ? YourPlanScreen(
                          selectedLanguage: widget.selectedLanguage,
                          updateLanguage: widget.updateLanguage,
                          themeMode: widget.themeMode,
                          toggleTheme: widget.toggleTheme,
                          allLocations: allLocations,
                        )
                      : DealsScreen(
                          selectedLanguage: widget.selectedLanguage,
                          updateLanguage: widget.updateLanguage,
                          themeMode: widget.themeMode,
                          toggleTheme: widget.toggleTheme,
                        ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        elevation: 0,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/icons/custom_home.png',
                width: 24, height: 24),
            label: _getHomeLabel(widget.selectedLanguage),
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/icons/custom_categories.png',
                width: 24, height: 24),
            label: _getCategoriesLabel(widget.selectedLanguage),
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/icons/custom_favorites.png',
                width: 24, height: 24),
            label: _getFavoritesLabel(widget.selectedLanguage),
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/icons/custom_plan.png',
                width: 24, height: 24),
            label: _getPlanLabel(widget.selectedLanguage),
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/icons/custom_deals.png',
                width: 24, height: 24),
            label: _getDealsLabel(widget.selectedLanguage),
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
    _debounce?.cancel();
    super.dispose();
  }
}
