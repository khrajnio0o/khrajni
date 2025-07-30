import 'package:flutter/material.dart';
import 'package:khrajni/models/location.dart';

class LocationCard extends StatefulWidget {
  final Location location;
  final VoidCallback onTap;
  final String selectedLanguage;

  const LocationCard({
    Key? key,
    required this.location,
    required this.onTap,
    required this.selectedLanguage,
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
                shadowColor: Colors.blue.withOpacity(0.3),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.grey.shade50,
                      ],
                    ),
                    border: Border.all(
                      color: _isPressed
                          ? Colors.blue.withOpacity(0.3)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: InkWell(
                    onTapDown: _onTapDown,
                    onTapUp: _onTapUp,
                    onTapCancel: _onTapCancel,
                    borderRadius: BorderRadius.circular(20.0),
                    splashColor: Colors.blue.withOpacity(0.1),
                    highlightColor: Colors.blue.withOpacity(0.05),
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
                                borderRadius: BorderRadius.circular(16.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16.0),
                                child: Stack(
                                  children: [
                                    Image.asset(
                                      widget.location.imageUrl,
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.blue.shade300,
                                                Colors.blue.shade600,
                                              ],
                                            ),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.place,
                                              color: Colors.white,
                                              size: 32,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.2),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.location
                                      .getName(widget.selectedLanguage),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  widget.location
                                      .getDescription(widget.selectedLanguage),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 6.0,
                                  runSpacing: 4.0,
                                  children: widget.location.categories
                                      .take(3)
                                      .map((category) {
                                    return AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue.shade100,
                                            Colors.blue.shade50,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.blue.shade200,
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Text(
                                        category,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue.shade700,
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
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.blue.shade600,
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
