// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
  List<Location> nearbyLocations = [];
  int _selectedIndex = 0;
  Position? _currentPosition;
  bool _locationPermissionGranted = false;
  String? currentStateId;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
    _requestLocationPermission();
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
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _determineCurrentState();
      _filterNearbyLocations();
    } catch (e) {
      _showError('Error getting location: $e');
    }
  }

  void _determineCurrentState() {
    if (_currentPosition == null || states.isEmpty) {
      setState(() {
        currentStateId = states.isNotEmpty ? states.first.id : null;
      });
      return;
    }
    final double userLat = _currentPosition!.latitude;
    final double userLon = _currentPosition!.longitude;
    StateModel? nearestState = states.firstWhere(
      (state) {
        final String? coords = state.imageUrl.split('/@').length > 1
            ? state.imageUrl.split('/@')[1].split('/')[0]
            : null;
        if (coords == null) return false;
        final List<String> latLon = coords.split(',');
        final double stateLat = double.tryParse(latLon[0]) ?? 0.0;
        final double stateLon = double.tryParse(latLon[1]) ?? 0.0;
        final double distance =
            Geolocator.distanceBetween(userLat, userLon, stateLat, stateLon);
        return distance <= 50000; // 50 km radius
      },
      orElse: () => states.first, // Default to first state if no match
    );
    setState(() {
      currentStateId = nearestState.id;
    });
  }

  void _filterNearbyLocations() {
    if (_currentPosition == null || currentStateId == null) return;
    final double userLat = _currentPosition!.latitude;
    final double userLon = _currentPosition!.longitude;
    setState(() {
      nearbyLocations = allLocations.where((location) {
        final String? coords = location.mapUrl.split('/@').length > 1
            ? location.mapUrl.split('/@')[1].split('/')[0]
            : null;
        if (coords == null) return false;
        final List<String> latLon = coords.split(',');
        final double locLat = double.tryParse(latLon[0]) ?? 0.0;
        final double locLon = double.tryParse(latLon[1]) ?? 0.0;
        final double distance =
            Geolocator.distanceBetween(userLat, userLon, locLat, locLon);
        return distance <= 50000 &&
            location.stateId == currentStateId; // Same governorate
      }).toList();
      filteredLocations = allLocations
          .where((location) => !nearbyLocations.contains(location))
          .toList();
      filteredStates =
          states.where((state) => state.id == currentStateId).toList();
    });
  }

  void _searchData(String query) {
    if (query.isEmpty) {
      setState(() {
        if (_locationPermissionGranted && _currentPosition != null) {
          _filterNearbyLocations();
        } else {
          filteredStates = states;
          filteredLocations = allLocations;
          nearbyLocations = [];
        }
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
      nearbyLocations = []; // Clear nearby on search
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

  String _getAppTitle() {
    return 'KHRAJNI';
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
                              if (_locationPermissionGranted &&
                                  nearbyLocations.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 16),
                                    Text(
                                      widget.selectedLanguage == 'ar'
                                          ? 'أماكن قريبة'
                                          : widget.selectedLanguage == 'en'
                                              ? 'Nearby Attractions'
                                              : widget.selectedLanguage == 'fr'
                                                  ? 'Attractions à proximité'
                                                  : widget.selectedLanguage ==
                                                          'ru'
                                                      ? 'Близкие достопримечательности'
                                                      : 'Nahegelegene Attraktionen',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? Colors.white70
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...nearbyLocations.map((location) {
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
                              if (_locationPermissionGranted &&
                                  filteredLocations.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 16),
                                    Text(
                                      widget.selectedLanguage == 'ar'
                                          ? 'أماكن جذب أخرى'
                                          : widget.selectedLanguage == 'en'
                                              ? 'Other Attractions'
                                              : widget.selectedLanguage == 'fr'
                                                  ? 'Autres attractions'
                                                  : widget.selectedLanguage ==
                                                          'ru'
                                                      ? 'Другие достопримечательности'
                                                      : 'Andere Attraktionen',
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
                              if (!_locationPermissionGranted ||
                                  (nearbyLocations.isEmpty &&
                                      filteredLocations.isEmpty))
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
                                    ...allLocations.map((location) {
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
        backgroundColor: isDarkMode ? Colors.transparent : null,
        elevation: isDarkMode ? 0 : 4,
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
        backgroundColor: Colors.transparent,
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
