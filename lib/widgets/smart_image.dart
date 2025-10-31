import 'package:flutter/material.dart';

/// Chooses the right Image widget based on the string:
/// - http/https -> network
/// - empty/null  -> placeholder
/// - anything else -> asset (e.g., "assets/images/eggs.jpg")
class SmartImage extends StatelessWidget {
  final String? src;
  final double size;
  final BoxFit fit;

  const SmartImage(this.src, {super.key, this.size = 96, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    final s = (src ?? '').trim();
    if (s.isEmpty) {
      // Optional placeholder – change or remove as you like
      return Image.asset('assets/images/placeholder.png',
          width: size, height: size, fit: fit);
    }
    if (s.startsWith('http://') || s.startsWith('https://')) {
      return Image.network(s, width: size, height: size, fit: fit);
    }
    // Treat everything else as an asset path
    return Image.asset(s, width: size, height: size, fit: fit);
  }
}

