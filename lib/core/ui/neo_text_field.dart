import 'package:flutter/material.dart';

class NeoTextFieldFrame extends StatelessWidget {
  const NeoTextFieldFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: scheme.onSurface.withValues(alpha: 0.9),
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
