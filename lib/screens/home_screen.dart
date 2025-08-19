// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:khrajni/models/location.dart';
import 'package:khrajni/models/state.dart';
import 'package:khrajni/screens/categories_screen.dart';
import 'package:khrajni/screens/favorites_screen.dart';
import 'package:khrajni/screens/location_detail_screen.dart';
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
  List<Location> popularLocations = [];
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
        // Set default state to Cairo or first available state
        currentStateId = states.isNotEmpty
            ? states
                .firstWhere((state) => state.id == 'cairo',
                    orElse: () => states.first)
                .id
            : null;
        // Set popular locations (e.g., top 5 by some criteria or random)
        popularLocations = allLocs.take(5).toList();
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
        currentStateId = states.isNotEmpty
            ? states
                .firstWhere((state) => state.id == 'cairo',
                    orElse: () => states.first)
                .id
            : null;
      });
      return;
    }
    // TODO: Implement actual state determination based on coordinates
    setState(() {
      currentStateId = states
          .firstWhere((state) => state.id == 'cairo',
              orElse: () => states.first)
          .id;
    });
  }

  void _filterNearbyLocations() {
    if (_currentPosition == null || allLocations.isEmpty) return;
    setState(() {
      nearbyLocations = allLocations.take(5).toList();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
        return 'الخطة';
      case 'en':
        return 'Plan';
      case 'fr':
        return 'Plan';
      case 'ru':
        return 'План';
      case 'de':
        return 'Plan';
      default:
        return 'Plan';
    }
  }

  String _getSectionTitle(int index, String lang) {
    switch (index) {
      case 1:
        return _getCategoriesLabel(lang);
      case 2:
        return _getFavoritesLabel(lang);
      case 3:
        return _getPlanLabel(lang);
      default:
        return '';
    }
  }

  Widget _buildHomeContent() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        filteredStates = states
                            .where((state) => state
                                .getName(widget.selectedLanguage)
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                        filteredLocations = allLocations
                            .where((location) => location
                                .getName(widget.selectedLanguage)
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                    decoration: InputDecoration(
                      labelText: widget.selectedLanguage == 'ar'
                          ? 'ابحث عن مكان أو محافظة'
                          : widget.selectedLanguage == 'en'
                              ? 'Search for a place or state'
                              : widget.selectedLanguage == 'fr'
                                  ? 'Rechercher un lieu ou un état'
                                  : widget.selectedLanguage == 'ru'
                                      ? 'Поиск места или штата'
                                      : 'Suche nach einem Ort oder Staat',
                      suffixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_searchController.text.isNotEmpty) _buildSearchResults(),
              if (_searchController.text.isEmpty) _buildDefaultContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (filteredStates.isNotEmpty) ...[
          Text(
            widget.selectedLanguage == 'ar'
                ? 'المحافظات'
                : widget.selectedLanguage == 'en'
                    ? 'States'
                    : widget.selectedLanguage == 'fr'
                        ? 'États'
                        : widget.selectedLanguage == 'ru'
                            ? 'Штаты'
                            : 'Staaten',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filteredStates.length,
              itemBuilder: (context, index) {
                final state = filteredStates[index];
                return StateCard(
                  state: state,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StateDetailScreen(
                          state: state,
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
          ),
          const SizedBox(height: 24),
        ],
        if (filteredLocations.isNotEmpty) ...[
          Text(
            widget.selectedLanguage == 'ar'
                ? 'الأماكن'
                : widget.selectedLanguage == 'en'
                    ? 'Locations'
                    : widget.selectedLanguage == 'fr'
                        ? 'Emplacements'
                        : widget.selectedLanguage == 'ru'
                            ? 'Места'
                            : 'Orte',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
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
        if (filteredStates.isEmpty && filteredLocations.isEmpty)
          Center(
            child: Text(
              widget.selectedLanguage == 'ar'
                  ? 'لا توجد نتائج'
                  : widget.selectedLanguage == 'en'
                      ? 'No results found'
                      : widget.selectedLanguage == 'fr'
                          ? 'Aucun résultat trouvé'
                          : widget.selectedLanguage == 'ru'
                              ? 'Результаты не найдены'
                              : 'Keine Ergebnisse gefunden',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDefaultContent() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_locationPermissionGranted) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Card(
              color: isDarkMode ? Colors.grey[800] : Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_off,
                      color: isDarkMode ? Colors.white70 : Colors.blue[700],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.selectedLanguage == 'ar'
                            ? 'تمكين الموقع لعرض الأماكن القريبة'
                            : widget.selectedLanguage == 'en'
                                ? 'Enable location to see nearby places'
                                : widget.selectedLanguage == 'fr'
                                    ? 'Activez la localisation pour voir les lieux à proximité'
                                    : widget.selectedLanguage == 'ru'
                                        ? 'Включите геолокацию, чтобы видеть ближайшие места'
                                        : 'Aktivieren Sie den Standort, um nahegelegene Orte zu sehen',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _requestLocationPermission,
                      child: Text(
                        widget.selectedLanguage == 'ar'
                            ? 'تمكين'
                            : widget.selectedLanguage == 'en'
                                ? 'Enable'
                                : widget.selectedLanguage == 'fr'
                                    ? 'Activer'
                                    : widget.selectedLanguage == 'ru'
                                        ? 'Включить'
                                        : 'Aktivieren',
                        style: TextStyle(
                          color:
                              isDarkMode ? Colors.blue[300] : Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        if (currentStateId != null) _buildCurrentStateSection(isDarkMode),
        const SizedBox(height: 24),
        if (_locationPermissionGranted && nearbyLocations.isNotEmpty)
          _buildNearbySection(isDarkMode)
        else
          _buildPopularSection(isDarkMode),
        const SizedBox(height: 24),
        Text(
          widget.selectedLanguage == 'ar'
              ? 'اكتشف المحافظات'
              : widget.selectedLanguage == 'en'
                  ? 'Discover States'
                  : widget.selectedLanguage == 'fr'
                      ? 'Découvrir les États'
                      : widget.selectedLanguage == 'ru'
                          ? 'Откройте штаты'
                          : 'Entdecken Sie Staaten',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: states.length,
            itemBuilder: (context, index) {
              final state = states[index];
              return StateCard(
                state: state,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StateDetailScreen(
                        state: state,
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
        ),
      ],
    );
  }

  Widget _buildCurrentStateSection(bool isDarkMode) {
    final currentState = states.firstWhere((s) => s.id == currentStateId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.selectedLanguage == 'ar'
              ? 'محافظتك الحالية'
              : widget.selectedLanguage == 'en'
                  ? 'Your Current State'
                  : widget.selectedLanguage == 'fr'
                      ? 'Votre État Actuel'
                      : widget.selectedLanguage == 'ru'
                          ? 'Ваш текущий штат'
                          : 'Ihr Aktueller Staat',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StateDetailScreen(
                  state: currentState,
                  selectedLanguage: widget.selectedLanguage,
                  updateLanguage: widget.updateLanguage,
                ),
              ),
            );
          },
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: AssetImage(currentState.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(20)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
                child: Text(
                  currentState.getName(widget.selectedLanguage),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNearbySection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.selectedLanguage == 'ar'
              ? 'أماكن قريبة'
              : widget.selectedLanguage == 'en'
                  ? 'Nearby Places'
                  : widget.selectedLanguage == 'fr'
                      ? 'Lieux à Proximité'
                      : widget.selectedLanguage == 'ru'
                          ? 'Ближайшие места'
                          : 'Nahegelegene Orte',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
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
    );
  }

  Widget _buildPopularSection(bool isDarkMode) {
    if (popularLocations.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.selectedLanguage == 'ar'
              ? 'أماكن شهيرة'
              : widget.selectedLanguage == 'en'
                  ? 'Popular Attractions'
                  : widget.selectedLanguage == 'fr'
                      ? 'Attractions Populaires'
                      : widget.selectedLanguage == 'ru'
                          ? 'Популярные достопримечательности'
                          : 'Beliebte Attraktionen',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
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
                  : Center(
                      child: Text(
                        _getSectionTitle(
                            _selectedIndex, widget.selectedLanguage),
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
