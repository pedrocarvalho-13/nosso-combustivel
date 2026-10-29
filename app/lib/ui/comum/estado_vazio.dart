import 'package:flutter/material.dart';

class EstadoVazio extends StatelessWidget {
  const EstadoVazio({
    super.key,
    required this.icone,
    required this.titulo,
    required this.mensagem,
    this.rotuloAcao,
    this.aoAcionar,
  });

  final IconData icone;
  final String titulo;
  final String mensagem;
  final String? rotuloAcao;
  final VoidCallback? aoAcionar;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: esquema.primaryContainer,
              child: Icon(icone, size: 32, color: esquema.primary),
            ),
            const SizedBox(height: 16),
            Text(titulo, style: textos.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              mensagem,
              style: textos.bodyMedium?.copyWith(color: esquema.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (rotuloAcao != null) ...[
              const SizedBox(height: 24),
              FilledButton(onPressed: aoAcionar, child: Text(rotuloAcao!)),
            ],
          ],
        ),
      ),
    );
  }
}
