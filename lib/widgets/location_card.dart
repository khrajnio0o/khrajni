import 'package:flutter/material.dart';
import 'package:khrajni/models/location.dart';
import 'package:khrajni/services/favorites_service.dart';

class LocationCard extends StatefulWidget {
  final Location location;
  final VoidCallback onTap;
  final String selectedLanguage;
  final bool isDarkMode;

  const LocationCard({
    Key? key,
    required this.location,
    required this.onTap,
    required this.selectedLanguage,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends State<LocationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isPressed = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.01,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _checkFavoriteStatus();
  }

  void _checkFavoriteStatus() async {
    final isFavorite = await FavoritesService.isFavorite(widget.location.id);
    setState(() {
      _isFavorite = isFavorite;
    });
  }

  void _toggleFavorite() async {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    if (_isFavorite) {
      await FavoritesService.addFavorite(widget.location.id);
    } else {
      await FavoritesService.removeFavorite(widget.location.id);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final cardBackgroundColors = widget.isDarkMode
        ? [Colors.grey[850]!, Colors.grey[900]!]
        : [Colors.white, Colors.grey[50]!];
    final textColor = widget.isDarkMode ? Colors.white70 : Colors.black87;
    final subTextColor = widget.isDarkMode ? Colors.white54 : Colors.grey[600]!;
    final categoryGradient = widget.isDarkMode
        ? [Colors.blueGrey[700]!, Colors.blueGrey[800]!]
        : [Colors.blue[100]!, Colors.blue[50]!];

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Material(
                elevation: _isPressed ? 2 : 8,
                borderRadius: BorderRadius.circular(20.0),
                shadowColor:
                    Colors.blue.withOpacity(widget.isDarkMode ? 0.5 : 0.3),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: cardBackgroundColors,
                    ),
                    border: Border.all(
                      color: _isPressed
                          ? Colors.blue
                              .withOpacity(widget.isDarkMode ? 0.5 : 0.3)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: InkWell(
                    onTapDown: _onTapDown,
                    onTapUp: _onTapUp,
                    onTapCancel: _onTapCancel,
                    borderRadius: BorderRadius.circular(20.0),
                    splashColor:
                        Colors.blue.withOpacity(widget.isDarkMode ? 0.2 : 0.1),
                    highlightColor:
                        Colors.blue.withOpacity(widget.isDarkMode ? 0.1 : 0.05),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Hero(
                            tag: 'location_${widget.location.id}',
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                image: DecorationImage(
                                  image: AssetImage(widget.location.imageUrl),
                                  fit: BoxFit.cover,
                                  onError: (exception, stackTrace) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.location
                                            .getName(widget.selectedLanguage),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        _isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: _isFavorite
                                            ? Colors.red
                                            : textColor,
                                      ),
                                      onPressed: _toggleFavorite,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  widget.location
                                      .getDescription(widget.selectedLanguage),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: subTextColor,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 6.0,
                                  runSpacing: 4.0,
                                  children: widget.location
                                      .getCategories(widget.selectedLanguage)
                                      .take(3)
                                      .map((category) {
                                    return AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            colors: categoryGradient),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: widget.isDarkMode
                                              ? Colors.blueGrey[600]!
                                              : Colors.blue[200]!,
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Text(
                                        category,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: widget.isDarkMode
                                              ? Colors.blueGrey[200]!
                                              : Colors.blue[700]!,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          AnimatedRotation(
                            turns: _isPressed ? 0.1 : 0,
                            duration: const Duration(milliseconds: 150),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: widget.isDarkMode
                                    ? Colors.blueGrey[700]!
                                    : Colors.blue[50]!,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: widget.isDarkMode
                                    ? Colors.blueGrey[200]!
                                    : Colors.blue[600]!,
                              ),
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
        );
      },
    );
  }
}
