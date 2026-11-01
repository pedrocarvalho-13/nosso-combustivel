import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/tema/cores_base.dart';
import '../../data/provedores.dart';

class RascunhoSalvo {
  const RascunhoSalvo({required this.salvoEm, required this.dados});

  final DateTime salvoEm;
  final Map<String, dynamic> dados;
}

enum _AcaoSaida { rascunho, descartar }

mixin SaidaComRascunho<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  String get tipoRascunho;
  String get nomeDoRegistro;
  bool get editandoRegistro;
  String? get veiculoIdRascunho;
  Map<String, dynamic> dadosDoFormulario();
  List<String> camposPreenchidos();
  void aplicarRascunho(Map<String, dynamic> dados);

  bool tratarVoltar() => false;

  var _liberado = false;
  String? _fotoDaEdicao;
  String? _rascunhoVerificadoPara;
  RascunhoSalvo? rascunhoPendente;

  String? get _chave => veiculoIdRascunho == null ? null : 'rascunho_${tipoRascunho}_$veiculoIdRascunho';

  void registrarEstadoDaEdicao() => _fotoDaEdicao = jsonEncode(dadosDoFormulario());

  bool get _temAlteracoes => editandoRegistro
      ? _fotoDaEdicao != null && _fotoDaEdicao != jsonEncode(dadosDoFormulario())
      : camposPreenchidos().isNotEmpty;

  void verificarRascunho() {
    final chave = _chave;
    if (editandoRegistro || chave == null || _rascunhoVerificadoPara == chave) return;
    _rascunhoVerificadoPara = chave;
    ref.read(preferenciasRepositorioProvider).rascunho(chave).then((bruto) {
      if (bruto == null || !mounted) return;
      try {
        final json = jsonDecode(bruto) as Map<String, dynamic>;
        setState(() => rascunhoPendente = RascunhoSalvo(
              salvoEm: DateTime.parse(json['salvoEm'] as String),
              dados: json['dados'] as Map<String, dynamic>,
            ));
      } catch (_) {
        ref.read(preferenciasRepositorioProvider).apagarRascunho(chave);
      }
    });
  }

  void continuarRascunho() {
    final rascunho = rascunhoPendente;
    if (rascunho == null) return;
    aplicarRascunho(rascunho.dados);
    setState(() => rascunhoPendente = null);
  }

  Future<void> descartarRascunho() async {
    setState(() => rascunhoPendente = null);
    final chave = _chave;
    if (chave != null) await ref.read(preferenciasRepositorioProvider).apagarRascunho(chave);
  }

  Future<void> apagarRascunhoSalvo() async {
    final chave = _chave;
    if (chave != null) await ref.read(preferenciasRepositorioProvider).apagarRascunho(chave);
  }

  void sairLiberado() {
    setState(() => _liberado = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.pop();
    });
  }

  Widget envolverSaida(Widget filho) => PopScope(
        canPop: _liberado,
        onPopInvokedWithResult: (saiu, _) {
          if (!saiu) _aoTentarSair();
        },
        child: filho,
      );

  Future<void> _aoTentarSair() async {
    if (tratarVoltar()) return;
    if (!_temAlteracoes) return sairLiberado();
    final acao = await showModalBottomSheet<_AcaoSaida>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (contexto) => _JanelaSaida(
        editando: editandoRegistro,
        preenchidos: camposPreenchidos(),
        nomeDoRegistro: nomeDoRegistro,
      ),
    );
    if (!mounted || acao == null) return;
    if (acao == _AcaoSaida.rascunho) {
      final chave = _chave;
      if (chave != null) {
        await ref.read(preferenciasRepositorioProvider).definirRascunho(
              chave,
              jsonEncode({'salvoEm': DateTime.now().toIso8601String(), 'dados': dadosDoFormulario()}),
            );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rascunho de $nomeDoRegistro salvo.')));
    }
    sairLiberado();
  }
}

class _JanelaSaida extends StatelessWidget {
  const _JanelaSaida({required this.editando, required this.preenchidos, required this.nomeDoRegistro});

  final bool editando;
  final List<String> preenchidos;
  final String nomeDoRegistro;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final esquema = Theme.of(context).colorScheme;
    final lista = switch (preenchidos.length) {
      0 => '',
      1 => preenchidos.first,
      _ => '${preenchidos.sublist(0, preenchidos.length - 1).join(', ')} e ${preenchidos.last}',
    };
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              editando ? 'Descartar alterações?' : 'Sair sem salvar?',
              style: textos.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              editando
                  ? 'As mudanças neste $nomeDoRegistro ainda não foram salvas.'
                  : 'Você preencheu ${lista.toLowerCase()}.',
              style: textos.bodyMedium?.copyWith(color: esquema.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            if (!editando) ...[
              FilledButton(
                onPressed: () => Navigator.of(context).pop(_AcaoSaida.rascunho),
                child: const Text('Salvar rascunho'),
              ),
              const SizedBox(height: 8),
            ],
            OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Continuar editando')),
            const SizedBox(height: 4),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: CoresBase.alerta),
              onPressed: () => Navigator.of(context).pop(_AcaoSaida.descartar),
              child: Text(editando ? 'Descartar alterações' : 'Descartar'),
            ),
          ],
        ),
      ),
    );
  }
}

class AvisoRascunho extends StatelessWidget {
  const AvisoRascunho({super.key, required this.rascunho, required this.aoContinuar, required this.aoDescartar});

  final RascunhoSalvo rascunho;
  final VoidCallback aoContinuar;
  final VoidCallback aoDescartar;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final quando = rascunho.salvoEm;
    final hoje = DateUtils.isSameDay(quando, DateTime.now());
    final hora = '${quando.hour.toString().padLeft(2, '0')}:${quando.minute.toString().padLeft(2, '0')}';
    final dia = hoje
        ? 'hoje, $hora'
        : '${quando.day.toString().padLeft(2, '0')}/${quando.month.toString().padLeft(2, '0')} às $hora';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 6),
      decoration: BoxDecoration(
        color: esquema.primaryContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: esquema.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note, color: esquema.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Você tem um rascunho de $dia',
                  style: textos.titleSmall?.copyWith(color: esquema.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          Row(
            children: [
              TextButton(onPressed: aoContinuar, child: const Text('Continuar')),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: esquema.onSurfaceVariant),
                onPressed: aoDescartar,
                child: const Text('Descartar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
