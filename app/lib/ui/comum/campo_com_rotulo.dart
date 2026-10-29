import 'package:flutter/material.dart';

class CampoComRotulo extends StatelessWidget {
  const CampoComRotulo({super.key, required this.rotulo, required this.child});

  final String rotulo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(rotulo, style: estilo),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
