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

  const HomeScreen({
    Key? key,
    required this.selectedLanguage,
    required this.updateLanguage,
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
      final allLocs =
          await DataService.loadAllLocations(); // Assume this method exists
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
    final String backgroundType = 'gradient';
    final String backgroundImage = 'assets/images/egypt_background.jpg';
    final List<Color> gradientColors = [
      const Color(0xFF1E3A8A),
      const Color(0xFF3B82F6),
      const Color(0xFF06B6D4),
    ];

    switch (backgroundType) {
      case 'gradient':
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
          ),
        );
      case 'image':
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(backgroundImage),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
        );
      case 'pattern':
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
          ),
          child: CustomPaint(
            painter: PatternPainter(),
            size: Size.infinite,
          ),
        );
      default:
        return Container(color: Colors.blue.shade700);
    }
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
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: _buildBackground()),
          SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: const Text(
                          'خرجني',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(2, 2),
                                blurRadius: 4,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                        ),
                      ),
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
                ),
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
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
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20.0),
                    ),
                  ),
                ),
                Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
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
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
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
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ...filteredStates.map((state) {
                                        return StateCard(
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
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
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

class PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    const spacing = 40.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
