import 'package:flutter/material.dart';
import 'package:khrajni/models/location.dart';
import 'package:khrajni/models/state.dart';
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
                      ? 'Erreur: $message'
                      : widget.selectedLanguage == 'ru'
                          ? 'Ошибка: $message'
                          : 'Fehler: $message',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.themeMode == ThemeMode.dark;
    final appBarBackgroundColor = isDarkMode ? Colors.grey[850] : Colors.blue;
    final appBarForegroundColor = Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'خرجني',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: appBarBackgroundColor,
        foregroundColor: appBarForegroundColor,
        actions: [
          Row(
            children: [
              DropdownButton<String>(
                value: widget.selectedLanguage,
                dropdownColor: appBarBackgroundColor,
                style: TextStyle(color: appBarForegroundColor),
                iconEnabledColor: appBarForegroundColor,
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
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  widget.themeMode == ThemeMode.light
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  color: appBarForegroundColor,
                ),
                onPressed: widget.toggleTheme,
                tooltip: widget.selectedLanguage == 'ar'
                    ? 'تبديل الوضع'
                    : widget.selectedLanguage == 'en'
                        ? 'Toggle Theme'
                        : widget.selectedLanguage == 'fr'
                            ? 'Changer de thème'
                            : widget.selectedLanguage == 'ru'
                                ? 'Переключить тему'
                                : 'Thema wechseln',
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(child: _buildBackground()),
          SafeArea(
            child: Column(
              children: [
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode
                                ? Colors.black.withOpacity(0.3)
                                : Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.selectedLanguage == 'ar'
                            ? 'اختر المحافظة التي تزورها واكتشف أماكن الجذب المميزة في مصر الحبيبة'
                            : widget.selectedLanguage == 'en'
                                ? 'Choose a governorate to visit and discover the unique attractions in beloved Egypt'
                                : widget.selectedLanguage == 'fr'
                                    ? 'Choisissez un gouvernorat à visiter et découvrez les attractions uniques de l\'Égypte bien-aimée'
                                    : widget.selectedLanguage == 'ru'
                                        ? 'Выберите мухафазат для посещения и откройте уникальные достопримечательности любимого Египта'
                                        : 'Wählen Sie ein Gouvernement zum Besuch und entdecken Sie die einzigartigen Attraktionen des geliebten Ägypten',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _searchData,
                    decoration: InputDecoration(
                      hintText: widget.selectedLanguage == 'ar'
                          ? 'ابحث عن محافظات أو أماكن الجذب (مثل: القاهرة، المتحف)'
                          : widget.selectedLanguage == 'en'
                              ? 'Search for governorates or attractions (e.g., Cairo, Museum)'
                              : widget.selectedLanguage == 'fr'
                                  ? 'Recherchez des gouvernorats ou attractions (ex. Le Caire, Musée)'
                                  : widget.selectedLanguage == 'ru'
                                      ? 'Поиск мухафазатов или достопримечательностей (например, Каир, Музей)'
                                      : 'Suchen Sie Gouvernements oder Attraktionen (z. B. Kairo, Museum)',
                      prefixIcon: Icon(Icons.search,
                          color:
                              isDarkMode ? Colors.white70 : Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20.0),
                      filled: true,
                      fillColor:
                          isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    ),
                  ),
                ),
                Expanded(
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDarkMode
                                  ? Colors.white70
                                  : Theme.of(context).primaryColor,
                            ),
                          ),
                        )
                      : filteredStates.isEmpty && filteredLocations.isEmpty
                          ? Center(
                              child: Text(
                                widget.selectedLanguage == 'ar'
                                    ? 'لا توجد نتائج مطابقة لبحثك'
                                    : widget.selectedLanguage == 'en'
                                        ? 'No results match your search'
                                        : widget.selectedLanguage == 'fr'
                                            ? 'Aucun résultat ne correspond à votre recherche'
                                            : widget.selectedLanguage == 'ru'
                                                ? 'Нет результатов, соответствующих вашему поиску'
                                                : 'Keine Ergebnisse entsprechen Ihrer Suche',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                              ),
                            )
                          : ListView(
                              padding: const EdgeInsets.all(16.0),
                              children: [
                                if (filteredStates.isNotEmpty)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.selectedLanguage == 'ar'
                                            ? 'المحافظات'
                                            : widget.selectedLanguage == 'en'
                                                ? 'Governorates'
                                                : widget.selectedLanguage ==
                                                        'fr'
                                                    ? 'Gouvernorats'
                                                    : widget.selectedLanguage ==
                                                            'ru'
                                                        ? 'Мухафазаты'
                                                        : 'Gouvernements',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode
                                              ? Colors.white70
                                              : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ...filteredStates.map((state) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom:
                                                  16.0), // Added spacing between states
                                          child: StateCard(
                                            state: state,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  pageBuilder: (context,
                                                          animation,
                                                          secondaryAnimation) =>
                                                      StateDetailScreen(
                                                    state: state,
                                                    selectedLanguage:
                                                        widget.selectedLanguage,
                                                    updateLanguage:
                                                        widget.updateLanguage,
                                                  ),
                                                  transitionsBuilder: (context,
                                                      animation,
                                                      secondaryAnimation,
                                                      child) {
                                                    return SlideTransition(
                                                      position: Tween<Offset>(
                                                        begin: const Offset(
                                                            1.0, 0.0),
                                                        end: Offset.zero,
                                                      ).animate(animation),
                                                      child: child,
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                            selectedLanguage:
                                                widget.selectedLanguage,
                                            isDarkMode: isDarkMode,
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                if (filteredLocations.isNotEmpty)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 16),
                                      Text(
                                        widget.selectedLanguage == 'ar'
                                            ? 'أماكن الجذب'
                                            : widget.selectedLanguage == 'en'
                                                ? 'Attractions'
                                                : widget.selectedLanguage ==
                                                        'fr'
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
                                                  state: states.firstWhere(
                                                      (s) =>
                                                          s.id ==
                                                          location.stateId),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
