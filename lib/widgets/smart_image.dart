import 'package:flutter/material.dart';

class SmartImage extends StatelessWidget {
  final String? src;
  final double size;
  final BoxFit fit;

  const SmartImage(this.src, {super.key, this.size = 96, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    final s = (src ?? '').trim();

    // 1️⃣ Nothing provided — show placeholder immediately
    if (s.isEmpty) {
      return _placeholder();
    }

    // 2️⃣ Remote image (http/https)
    if (s.startsWith('http://') || s.startsWith('https://')) {
      return Image.network(
        s,
        width: size,
        height: size,
        fit: fit,
        errorBuilder: (context, error, stack) => _placeholder(),
      );
    }

    // 3️⃣ Local asset path
    return Image.asset(
      s,
      width: size,
      height: size,
      fit: fit,
      errorBuilder: (context, error, stack) => _placeholder(),
    );
  }

  /// A simple reusable placeholder (you can customize this)
  Widget _placeholder() {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color:Colors.green.withValues(alpha: 0.1),

        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.local_florist, color: Colors.green, size: 36),
    );
  }
}


