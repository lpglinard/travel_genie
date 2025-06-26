import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A custom magic animation overlay that displays while the AI optimization is in progress.
/// Features a translucent background with animated magical elements.
class MagicAnimationOverlay extends StatefulWidget {
  /// The optimization strategy being used (for display purposes)
  final String strategyName;
  
  /// Callback function called when the animation should be dismissed
  final VoidCallback? onAnimationComplete;

  const MagicAnimationOverlay({
    super.key,
    required this.strategyName,
    this.onAnimationComplete,
  });

  @override
  State<MagicAnimationOverlay> createState() => _MagicAnimationOverlayState();
}

class _MagicAnimationOverlayState extends State<MagicAnimationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _sparkleController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  
  late Animation<double> _sparkleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Initialize animations
    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    
    // Start animations
    _fadeController.forward();
    _sparkleController.repeat();
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
    
    // Auto-dismiss after 3 seconds (simulating API call completion)
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _dismissOverlay();
      }
    });
  }

  void _dismissOverlay() async {
    await _fadeController.reverse();
    if (widget.onAnimationComplete != null) {
      widget.onAnimationComplete!();
    }
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            width: size.width,
            height: size.height,
            color: Colors.black.withOpacity(0.7),
            child: Stack(
              children: [
                // Animated sparkles
                ...List.generate(12, (index) => _buildSparkle(index, size)),
                
                // Center content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Main magic icon with pulse and rotation
                      AnimatedBuilder(
                        animation: Listenable.merge([_pulseAnimation, _rotationAnimation]),
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Transform.rotate(
                              angle: _rotationAnimation.value,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      theme.colorScheme.primary.withOpacity(0.8),
                                      theme.colorScheme.secondary.withOpacity(0.6),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  Icons.auto_fix_high,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Loading text
                      Text(
                        'Magic AI is optimizing...',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        'Using ${widget.strategyName} strategy',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Animated progress indicator
                      SizedBox(
                        width: 200,
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSparkle(int index, Size screenSize) {
    final random = math.Random(index);
    final x = random.nextDouble() * screenSize.width;
    final y = random.nextDouble() * screenSize.height;
    final delay = random.nextDouble() * 2000;
    
    return AnimatedBuilder(
      animation: _sparkleAnimation,
      builder: (context, child) {
        final progress = (_sparkleAnimation.value + delay / 2000) % 1.0;
        final opacity = math.sin(progress * math.pi);
        final scale = 0.5 + (math.sin(progress * math.pi) * 0.5);
        
        return Positioned(
          left: x,
          top: y,
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Icon(
                Icons.star,
                size: 16 + (random.nextDouble() * 8),
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}