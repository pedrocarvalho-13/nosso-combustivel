import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/notificacoes/notificacoes_controller.dart';
import '../../data/notificacoes/ponte_notificacoes.dart';

String descreverNotificacoes(EstadoNotificacoes? estado) => switch (estado) {
  null => 'Verificando...',
  EstadoNotificacoes.ativo => 'Ativas neste aparelho',
  EstadoNotificacoes.desativado => 'Desativadas',
  EstadoNotificacoes.bloqueado => 'Bloqueadas no navegador',
  EstadoNotificacoes.instalar => 'Instale o app para receber',
  EstadoNotificacoes.semSuporte => 'Este navegador não recebe',
};

Future<void> mostrarNotificacoes(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (_) => const SafeArea(
    child: Padding(padding: EdgeInsets.fromLTRB(24, 0, 24, 16), child: PainelNotificacoes()),
  ),
);

class PainelNotificacoes extends ConsumerStatefulWidget {
  const PainelNotificacoes({super.key});

  @override
  ConsumerState<PainelNotificacoes> createState() => _PainelNotificacoesState();
}

class _PainelNotificacoesState extends ConsumerState<PainelNotificacoes> {
  var _ocupado = false;
  String? _mensagem;

  Future<void> _executar(Future<String?> Function(NotificacoesController controle) acao) async {
    setState(() {
      _ocupado = true;
      _mensagem = null;
    });
    final mensagem = await acao(ref.read(notificacoesProvider.notifier));
    if (!mounted) return;
    setState(() {
      _ocupado = false;
      _mensagem = mensagem;
    });
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(notificacoesProvider).value;
    final textos = Theme.of(context).textTheme;
    final esquema = Theme.of(context).colorScheme;
    final explicacao = switch (estado) {
      null => '',
      EstadoNotificacoes.desativado =>
        'Receba na barra do celular os lembretes de lavagem, manutenção e contas a vencer, mesmo com o app fechado.',
      EstadoNotificacoes.ativo =>
        'Os lembretes chegam na barra de notificações deste aparelho. Ative também nos outros aparelhos que você usa.',
      EstadoNotificacoes.bloqueado =>
        'As notificações do Pit Garage estão bloqueadas. Libere nas configurações do celular ou do navegador (Notificações › Pit Garage) e volte aqui.',
      EstadoNotificacoes.instalar =>
        'No iPhone, as notificações só funcionam com o app na Tela de Início: toque em Compartilhar › Adicionar à Tela de Início e abra o Pit Garage por lá.',
      EstadoNotificacoes.semSuporte =>
        'Este navegador não recebe notificações. No celular, use o app instalado pelo Chrome (Android) ou pela Tela de Início (iPhone).',
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              estado == EstadoNotificacoes.ativo
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_none_rounded,
              color: esquema.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Notificações', style: textos.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            ),
            Text(descreverNotificacoes(estado), style: textos.bodySmall?.copyWith(color: esquema.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 10),
        Text(explicacao, style: textos.bodyMedium?.copyWith(color: esquema.onSurfaceVariant)),
        const SizedBox(height: 20),
        if (estado == EstadoNotificacoes.desativado)
          FilledButton.icon(
            onPressed: _ocupado ? null : () => _executar((controle) => controle.ativar()),
            icon: const Icon(Icons.notifications_active_outlined),
            label: Text(_ocupado ? 'Ativando...' : 'Ativar notificações'),
          ),
        if (estado == EstadoNotificacoes.ativo) ...[
          FilledButton.icon(
            onPressed: _ocupado ? null : () => _executar((controle) => controle.enviarTeste()),
            icon: const Icon(Icons.send_outlined),
            label: Text(_ocupado ? 'Enviando...' : 'Enviar notificação de teste'),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: _ocupado ? null : () => _executar((controle) => controle.desativar()),
            child: const Text('Desativar neste aparelho'),
          ),
        ],
        if (estado == EstadoNotificacoes.bloqueado)
          OutlinedButton(
            onPressed: () => ref.invalidate(notificacoesProvider),
            child: const Text('Já liberei, verificar de novo'),
          ),
        if (_mensagem != null) ...[
          const SizedBox(height: 12),
          Text(_mensagem!, textAlign: TextAlign.center, style: textos.bodyMedium),
        ],
      ],
    );
  }
}
