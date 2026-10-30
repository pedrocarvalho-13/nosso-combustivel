import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/provedores.dart';

enum CampoRegistro { odometro, quantidade, preco, total }

typedef ErrosFormulario = Map<CampoRegistro, String>;

class ResultadoSalvar {
  const ResultadoSalvar.ok() : erros = const {}, mensagem = null;

  const ResultadoSalvar.erros(this.erros) : mensagem = null;

  const ResultadoSalvar.mensagem(String this.mensagem) : erros = const {};

  final ErrosFormulario erros;
  final String? mensagem;

  bool get sucesso => erros.isEmpty && mensagem == null;
}

Future<void> mostrarOnboardingHodometro(BuildContext context, WidgetRef ref, {required bool recarga}) async {
  final preferencias = ref.read(preferenciasRepositorioProvider);
  if (await preferencias.onboardingHodometroVisto()) return;
  if (!context.mounted) return;
  await preferencias.marcarOnboardingHodometroVisto();
  if (!context.mounted) return;

  final textos = Theme.of(context).textTheme;
  final esquema = Theme.of(context).colorScheme;
  final completo = recarga ? 'carga completa' : 'tanque cheio';
  await showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    builder: (contexto) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.speed, color: esquema.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Como o consumo é calculado', style: textos.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Passo(numero: '1', texto: 'Anote o hodômetro na hora de ${recarga ? 'recarregar' : 'abastecer'}. Ele é o ponto de partida desta ${recarga ? 'carga' : 'energia'}.'),
            _Passo(numero: '2', texto: 'Rode normalmente até a próxima vez.'),
            _Passo(
              numero: '3',
              texto: 'No próximo $completo, o app divide os km rodados desde aqui pelo que entrou, e mostra o consumo e o custo por km.',
            ),
            const SizedBox(height: 8),
            Text(
              'Por isso, o primeiro registro ainda não mostra consumo: ele só marca o começo.',
              style: textos.bodyMedium?.copyWith(color: esquema.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: () => Navigator.of(contexto).pop(), child: const Text('Entendi')),
          ],
        ),
      ),
    ),
  );
}

class _Passo extends StatelessWidget {
  const _Passo({required this.numero, required this.texto});

  final String numero;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: esquema.primaryContainer,
            child: Text(numero, style: TextStyle(color: esquema.primary, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(texto, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

Future<bool> confirmarExclusao(BuildContext context, {required String titulo, required String mensagem}) async {
  final confirmou = await showDialog<bool>(
    context: context,
    builder: (contexto) => AlertDialog(
      title: Text(titulo),
      content: Text(mensagem),
      actions: [
        TextButton(onPressed: () => Navigator.of(contexto).pop(false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.of(contexto).pop(true), child: const Text('Excluir')),
      ],
    ),
  );
  return confirmou ?? false;
}
