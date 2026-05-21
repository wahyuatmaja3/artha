import 'package:flutter/material.dart';
import '../theme/neo_tokens.dart';

class NeoCard extends StatelessWidget {
  const NeoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.background,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: background ?? scheme.surface,
        borderRadius: BorderRadius.circular(NeoTokens.radiusMd),
        border: Border.all(color: scheme.onSurface, width: 2),
        boxShadow: [
          BoxShadow(
            color: scheme.onSurface,
            offset: NeoTokens.shadowOffset,
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class NeoSectionTitle extends StatelessWidget {
  const NeoSectionTitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: 1.1,
      ),
    );
  }
}
