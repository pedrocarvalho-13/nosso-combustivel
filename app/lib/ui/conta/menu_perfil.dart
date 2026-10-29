import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/sessao/sessao_controller.dart';

Future<void> mostrarMenuPerfil(BuildContext context, WidgetRef ref) {
  final usuario = ref.read(sessaoProvider).value?.usuario;
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    builder: (contexto) {
      final textos = Theme.of(contexto).textTheme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(usuario?.nome ?? '', style: textos.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(
                usuario?.email ?? '',
                style: textos.bodyMedium?.copyWith(color: Theme.of(contexto).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                icon: const Icon(Icons.logout),
                label: const Text('Sair'),
                onPressed: () {
                  Navigator.of(contexto).pop();
                  ref.read(sessaoProvider.notifier).sair();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

class BotaoPerfil extends ConsumerWidget {
  const BotaoPerfil({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final esquema = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: 'Perfil',
      style: IconButton.styleFrom(
        backgroundColor: esquema.surfaceContainer,
        side: BorderSide(color: esquema.outline),
        minimumSize: const Size(44, 44),
      ),
      icon: Icon(Icons.person_outline, color: esquema.onSurfaceVariant),
      onPressed: () => mostrarMenuPerfil(context, ref),
    );
  }
}
