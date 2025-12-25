import 'package:flutter/material.dart';

/// Custom page transitions for beautiful navigation
class PageTransitions {
  /// Slide from right transition
  static Route slideFromRight(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Slide from bottom transition
  static Route slideFromBottom(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Fade transition
  static Route fade(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }

  /// Scale transition
  static Route scale(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;

        var scaleTween = Tween(begin: 0.8, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return ScaleTransition(
          scale: animation.drive(scaleTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Rotation transition
  static Route rotate(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;

        var rotationTween = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        var scaleTween = Tween(begin: 0.8, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return RotationTransition(
          turns: animation.drive(rotationTween),
          child: ScaleTransition(
            scale: animation.drive(scaleTween),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  /// Slide and fade transition
  static Route slideAndFade(Widget page, {AxisDirection direction = AxisDirection.right}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        Offset begin;
        switch (direction) {
          case AxisDirection.up:
            begin = const Offset(0.0, 1.0);
            break;
          case AxisDirection.down:
            begin = const Offset(0.0, -1.0);
            break;
          case AxisDirection.left:
            begin = const Offset(-1.0, 0.0);
            break;
          case AxisDirection.right:
            begin = const Offset(1.0, 0.0);
            break;
        }

        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var slideTween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(slideTween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Shared axis transition
  static Route sharedAxis(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;

        // Exit animation for previous page
        var exitSlide = Tween(
          begin: Offset.zero,
          end: const Offset(-0.3, 0.0),
        ).chain(CurveTween(curve: curve));

        var exitFade = Tween(begin: 1.0, end: 0.0).chain(
          CurveTween(curve: curve),
        );

        // Enter animation for new page
        var enterSlide = Tween(
          begin: const Offset(0.3, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: curve));

        var enterFade = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return Stack(
          children: [
            SlideTransition(
              position: secondaryAnimation.drive(exitSlide),
              child: FadeTransition(
                opacity: secondaryAnimation.drive(exitFade),
                child: child,
              ),
            ),
            SlideTransition(
              position: animation.drive(enterSlide),
              child: FadeTransition(
                opacity: animation.drive(enterFade),
                child: child,
              ),
            ),
          ],
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  /// No transition
  static Route none(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration.zero,
    );
  }
}

/// Hero image widget for smooth transitions
class HeroImage extends StatelessWidget {
  final String tag;
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const HeroImage({
    super.key,
    required this.tag,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Image.network(
          imageUrl,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              color: Colors.grey[300],
              child: const Icon(Icons.error_outline),
            );
          },
        ),
      ),
    );
  }
}

/// Hero icon widget
class HeroIcon extends StatelessWidget {
  final String tag;
  final IconData icon;
  final double size;
  final Color? color;

  const HeroIcon({
    super.key,
    required this.tag,
    required this.icon,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Icon(
        icon,
        size: size,
        color: color,
      ),
    );
  }
}

/// Animated list item
class AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.delay = const Duration(milliseconds: 50),
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Delay based on index
    Future.delayed(widget.delay * widget.index, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
