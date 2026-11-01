import 'package:flutter/material.dart';

class CabecalhoSecao extends StatelessWidget {
  const CabecalhoSecao({super.key, required this.numero, required this.titulo});

  final int numero;
  final String titulo;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: esquema.primaryContainer, shape: BoxShape.circle),
            child: Text(
              '$numero',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: esquema.primary, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            titulo,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: esquema.primary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
