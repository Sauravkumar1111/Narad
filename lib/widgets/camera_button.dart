import 'package:flutter/material.dart';
import '../utils/theme.dart';

class CameraButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isActive;

  const CameraButton({
    super.key,
    this.onPressed,
    this.isActive = false,
  });

  @override
  State<CameraButton> createState() => _CameraButtonState();
}

class _CameraButtonState extends State<CameraButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _animationController.forward();
      },
      onTapUp: (_) {
        _animationController.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () {
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isActive 
                    ? AppTheme.cameraButtonColor 
                    : AppTheme.cameraButtonInactiveColor,
                boxShadow: [
                  BoxShadow(
                    color: (widget.isActive 
                        ? AppTheme.cameraButtonColor 
                        : AppTheme.cameraButtonInactiveColor).withOpacity(0.3),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                widget.isActive ? Icons.camera_alt : Icons.camera_alt_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
          );
        },
      ),
    );
  }
}
