import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formato.dart';
import '../../core/rotas/rotas.dart';
import '../../core/tema/cores_base.dart';
import '../../data/provedores.dart';
import '../../data/sessao/sessao_controller.dart';
import '../../data/sync/sincronizacao_controller.dart';
import '../../domain/forma_pagamento.dart';

class AjustesView extends ConsumerWidget {
  const AjustesView({super.key});

  static const _versao = String.fromEnvironment('VERSAO', defaultValue: 'local');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(sessaoProvider).value?.usuario;
    final cartoes = ref.watch(cartoesProvider).value ?? const [];
    final pagamento = ref.watch(pagamentoPadraoProvider).value;
    final meta = ref.watch(metaMensalProvider).value;
    final dias = ref.watch(periodoMediaProvider).value ?? 30;
    final tema = ref.watch(temaProvider).value ?? 'escuro';
    final fotos = ref.watch(fotosIaProvider).value ?? true;
    final tarifa = ref.watch(tarifaCasaProvider).value;
    final temRecarga = (ref.watch(veiculosProvider).value ?? const []).any((v) => v.tipoEnergia.recarrega);
    final sincronizacao = ref.watch(sincronizacaoProvider);
    final preferencias = ref.read(preferenciasRepositorioProvider);
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              _Grupo(children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: esquema.surfaceContainerHighest,
                    child: Text(_iniciais(usuario?.nome ?? ''), style: textos.titleSmall),
                  ),
                  title: Text(usuario?.nome ?? '', style: textos.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  subtitle: Text(usuario?.email ?? ''),
                ),
              ]),
              const _Secao('Gastos'),
              _Grupo(children: [
                _Item(
                  icone: Icons.credit_card,
                  titulo: 'Meus cartões',
                  descricao: 'Banco, nome e fechamento da fatura',
                  valor: cartoes.isEmpty ? null : '${cartoes.length}',
                  aoTocar: () => context.push(Rotas.cartoes),
                ),
                _Item(
                  icone: Icons.account_balance_wallet_outlined,
                  titulo: 'Pagamento padrão',
                  descricao: 'Já vem marcado no abastecimento',
                  valor: _rotuloPagamento(pagamento, cartoes.map((c) => (c.id, c.nome)).toList()),
                  aoTocar: () async {
                    final escolha = await _escolher<String>(
                      context,
                      titulo: 'Pagamento padrão',
                      atual: pagamento ?? '',
                      opcoes: [
                        ('', 'Último usado'),
                        for (final c in cartoes) ('${FormaPagamento.credito.name}|${c.id}', 'Crédito · ${c.nome}'),
                        for (final f in FormaPagamento.values.where((f) => f != FormaPagamento.credito)) ('${f.name}|', f.rotulo),
                      ],
                    );
                    if (escolha != null) await preferencias.definirPagamentoPadrao(escolha.isEmpty ? null : escolha);
                  },
                ),
                _Item(
                  icone: Icons.flag_outlined,
                  titulo: 'Meta de gasto mensal',
                  descricao: 'A barra do mês fica amarela em 80% e vermelha ao passar',
                  valor: meta == null ? 'Sem meta' : Formato.moeda(meta),
                  aoTocar: () async {
                    final valor = await _pedirValor(
                      context,
                      titulo: 'Meta de gasto mensal',
                      rotulo: 'Valor por mês (R\$)',
                      inicial: meta == null ? null : meta / 100,
                      casas: 2,
                    );
                    if (valor == null) return;
                    await preferencias.definirMetaMensal(valor.$1 == null ? null : (valor.$1! * 100).round());
                  },
                ),
              ]),
              const _Secao('Consumo e recarga'),
              _Grupo(children: [
                _Item(
                  icone: Icons.calendar_month_outlined,
                  titulo: 'Período da média',
                  descricao: 'Usado no card de consumo médio',
                  valor: '$dias dias',
                  aoTocar: () async {
                    final escolha = await _escolher<int>(
                      context,
                      titulo: 'Período da média',
                      atual: dias,
                      opcoes: const [(30, 'Últimos 30 dias'), (60, 'Últimos 60 dias'), (90, 'Últimos 90 dias')],
                    );
                    if (escolha != null) await preferencias.definirPeriodoMedia(escolha);
                  },
                ),
                if (temRecarga)
                  _Item(
                    icone: Icons.electrical_services,
                    titulo: 'Tarifa de energia em casa',
                    descricao: 'Preenche o preço das recargas em casa',
                    valor: tarifa == null ? 'Não informada' : '${Formato.moedaPorKm(tarifa)}/kWh',
                    aoTocar: () async {
                      final valor = await _pedirValor(
                        context,
                        titulo: 'Tarifa de energia em casa',
                        rotulo: 'Preço por kWh (R\$)',
                        inicial: tarifa,
                        casas: 3,
                        permitirApagar: false,
                      );
                      if (valor?.$1 != null) await preferencias.definirTarifaCasa(valor!.$1!);
                    },
                  ),
              ]),
              const _Secao('Aplicativo'),
              _Grupo(children: [
                _Item(
                  icone: Icons.dark_mode_outlined,
                  titulo: 'Tema',
                  valor: const {'escuro': 'Escuro', 'claro': 'Claro', 'sistema': 'Igual ao celular'}[tema],
                  aoTocar: () async {
                    final escolha = await _escolher<String>(
                      context,
                      titulo: 'Tema',
                      atual: tema,
                      opcoes: const [('escuro', 'Escuro'), ('claro', 'Claro'), ('sistema', 'Igual ao celular')],
                    );
                    if (escolha != null) await preferencias.definirTema(escolha);
                  },
                ),
                _Item(
                  icone: Icons.sync,
                  titulo: 'Sincronização',
                  descricao: switch (sincronizacao.situacao) {
                    SituacaoSync.sincronizando => 'Sincronizando...',
                    SituacaoSync.semConexao => 'Sem conexão. Os registros ficam guardados no aparelho',
                    SituacaoSync.erro => 'Não foi possível sincronizar',
                    SituacaoSync.ocioso => sincronizacao.ultimaEm == null
                        ? 'Ainda não sincronizou'
                        : 'Sincronizado às ${_hora(sincronizacao.ultimaEm!)}',
                  },
                  acao: TextButton(
                    onPressed: sincronizacao.situacao == SituacaoSync.sincronizando
                        ? null
                        : () => ref.read(sincronizacaoProvider.notifier).sincronizar(),
                    child: const Text('Agora'),
                  ),
                ),
                SwitchListTile(
                  secondary: Icon(Icons.document_scanner_outlined, color: esquema.primary),
                  title: const Text('Leitura de fotos por IA'),
                  subtitle: const Text('Botões de foto da bomba e do hodômetro'),
                  value: fotos,
                  onChanged: preferencias.definirFotosIa,
                ),
              ]),
              const _Secao('Sobre'),
              _Grupo(children: [
                const _Item(icone: Icons.info_outline, titulo: 'Versão', valor: _versao),
                ListTile(
                  leading: const Icon(Icons.logout, color: CoresBase.alerta),
                  title: Text('Sair da conta', style: textos.bodyLarge?.copyWith(color: CoresBase.alerta)),
                  onTap: () => ref.read(sessaoProvider.notifier).sair(),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  static String _iniciais(String nome) {
    final partes = nome.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (partes.isEmpty) return '';
    final primeira = partes.first[0];
    final ultima = partes.length > 1 ? partes.last[0] : '';
    return (primeira + ultima).toUpperCase();
  }

  static String _hora(DateTime data) =>
      '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';

  static String _rotuloPagamento(String? salvo, List<(String, String)> cartoes) {
    if (salvo == null || salvo.isEmpty) return 'Último usado';
    final partes = salvo.split('|');
    final forma = FormaPagamento.values.where((f) => f.name == partes.first).firstOrNull;
    if (forma == null) return 'Último usado';
    if (forma != FormaPagamento.credito) return forma.rotulo;
    final nome = cartoes.where((c) => c.$1 == partes.last).firstOrNull?.$2;
    return nome == null ? 'Crédito' : 'Crédito · $nome';
  }

  static Future<T?> _escolher<T>(
    BuildContext context, {
    required String titulo,
    required T atual,
    required List<(T, String)> opcoes,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (contexto) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(titulo, style: Theme.of(contexto).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
              ),
              for (final (valor, rotulo) in opcoes)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  title: Text(rotulo),
                  trailing: valor == atual ? Icon(Icons.check, color: Theme.of(contexto).colorScheme.primary) : null,
                  onTap: () => Navigator.of(contexto).pop(valor),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<(double?,)?> _pedirValor(
    BuildContext context, {
    required String titulo,
    required String rotulo,
    required double? inicial,
    required int casas,
    bool permitirApagar = true,
    String rotuloApagar = 'Remover meta',
  }) {
    final controle = TextEditingController(text: inicial == null ? '' : Formato.paraCampo(inicial, casas: casas));
    return showModalBottomSheet<(double?,)>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (contexto) {
        String? erro;
        return StatefulBuilder(
          builder: (contexto, atualizar) {
            void salvar() {
              final valor = Formato.lerDecimal(controle.text);
              if (valor == null || valor <= 0) return atualizar(() => erro = 'Informe um valor maior que zero.');
              Navigator.of(contexto).pop((valor,));
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 16 + MediaQuery.viewInsetsOf(contexto).bottom),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(titulo, style: Theme.of(contexto).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controle,
                      autofocus: true,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                      onSubmitted: (_) => salvar(),
                      decoration: InputDecoration(labelText: rotulo, errorText: erro),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(onPressed: salvar, child: const Text('Salvar')),
                    if (permitirApagar && inicial != null) ...[
                      const SizedBox(height: 4),
                      TextButton(
                        style: TextButton.styleFrom(foregroundColor: CoresBase.alerta),
                        onPressed: () => Navigator.of(contexto).pop((null,)),
                        child: Text(rotuloApagar),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _Secao extends StatelessWidget {
  const _Secao(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 6),
      child: Text(
        texto,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _Grupo extends StatelessWidget {
  const _Grupo({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final divisoria = Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (indice, filho) in children.indexed) ...[
            if (indice > 0) divisoria,
            filho,
          ],
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.icone, required this.titulo, this.descricao, this.valor, this.aoTocar, this.acao});

  final IconData icone;
  final String titulo;
  final String? descricao;
  final String? valor;
  final VoidCallback? aoTocar;
  final Widget? acao;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    return ListTile(
      leading: Icon(icone, color: esquema.primary),
      title: Text(titulo),
      subtitle: descricao == null ? null : Text(descricao!),
      onTap: aoTocar,
      trailing: acao ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (valor != null)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 140),
                  child: Text(
                    valor!,
                    overflow: TextOverflow.ellipsis,
                    style: textos.bodyMedium?.copyWith(color: esquema.onSurfaceVariant),
                  ),
                ),
              if (aoTocar != null) Icon(Icons.chevron_right, color: esquema.onSurfaceVariant),
            ],
          ),
    );
  }
}
