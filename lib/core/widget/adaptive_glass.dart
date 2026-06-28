import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ztime_widget/core/device/launcher_capabilities.dart';

/// Adaptive glass container that renders differently based on launcher support.
///
/// - full:    BackdropFilter blur + semi-transparent overlay
/// - partial: Semi-transparent solid (no blur)
/// - none:    Solid opaque background
class AdaptiveGlass extends StatelessWidget {
  const AdaptiveGlass({
    super.key,
    required this.support,
    required this.child,
    this.borderRadius = 20.0,
    this.blurSigma = 15.0,
    this.opacity = 0.15,
    this.borderColor,
  });

  final TransparencySupport support;
  final Widget child;
  final double borderRadius;
  final double blurSigma;
  final double opacity;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final border = borderColor ?? Colors.white.withValues(alpha: 0.3);

    switch (support) {
      case TransparencySupport.full:
        // Full blur — MIUI / HyperOS
        return ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: opacity),
                borderRadius: radius,
                border: Border.all(color: border, width: 1.5),
              ),
              child: child,
            ),
          ),
        );

      case TransparencySupport.partial:
        // Semi-transparent, no blur — One UI / ColorOS
        return ClipRRect(
          borderRadius: radius,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: radius,
            ),
            child: child,
          ),
        );

      case TransparencySupport.none:
        // Solid background — Stock Android
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E2A3A),
            borderRadius: radius,
          ),
          child: child,
        );
    }
  }
}
