import 'package:flutter/material.dart';
import 'package:khrajni/models/state.dart';

class StateCard extends StatefulWidget {
  final StateModel state;
  final VoidCallback onTap;
  final String selectedLanguage;

  const StateCard({
    Key? key,
    required this.state,
    required this.onTap,
    required this.selectedLanguage,
  }) : super(key: key);

  @override
  State<StateCard> createState() => _StateCardState();
}

class _StateCardState extends State<StateCard> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(_isHovered ? 0.3 : 0.15),
                      blurRadius: _isHovered ? 20 : 10,
                      offset: Offset(0, _isHovered ? 8 : 4),
                      spreadRadius: _isHovered ? 2 : 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            widget.state.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.blue.shade400,
                                      Colors.blue.shade700,
                                    ],
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.location_city,
                                    size: 60,
                                    color: Colors.white70,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (_isHovered)
                          AnimatedBuilder(
                            animation: _shimmerAnimation,
                            builder: (context, child) {
                              return Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      stops: [
                                        (_shimmerAnimation.value - 0.3)
                                            .clamp(0.0, 1.0),
                                        _shimmerAnimation.value.clamp(0.0, 1.0),
                                        (_shimmerAnimation.value + 0.3)
                                            .clamp(0.0, 1.0),
                                      ],
                                      colors: [
                                        Colors.transparent,
                                        Colors.white.withOpacity(0.3),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.3),
                                  Colors.black.withOpacity(0.8),
                                ],
                                stops: const [0.0, 0.6, 1.0],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.state.getName(widget.selectedLanguage),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(1, 1),
                                        blurRadius: 3,
                                        color: Colors.black54,
                                      ),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Colors.white70,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${widget.state.locationCount} ${widget.selectedLanguage == 'ar' ? 'مكان جذب' : widget.selectedLanguage == 'en' ? 'attractions' : widget.selectedLanguage == 'fr' ? 'attractions' : widget.selectedLanguage == 'ru' ? 'достопримечательностей' : 'Attraktionen'}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: _isHovered ? null : 0,
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 300),
                                    opacity: _isHovered ? 1.0 : 0.0,
                                    child: Text(
                                      widget.state.getDescription(
                                          widget.selectedLanguage),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white60,
                                        height: 1.3,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_scaleController.isAnimating)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                        if (widget.state.locationCount > 15)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'مميز',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
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
        );
      },
    );
  }
}
