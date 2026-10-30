import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formato.dart';
import '../../core/tema/paleta_energia.dart';
import '../../domain/calculos/calculo_relatorio.dart';
import '../../domain/tipo_energia.dart';
import '../comum/estado_vazio.dart';
import '../comum/icone_energia.dart';
import 'relatorios_view_model.dart';

class RelatoriosView extends ConsumerWidget {
  const RelatoriosView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios')),
      body: ref
          .watch(relatoriosViewModelProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (erro, _) => Center(child: Text('Não foi possível carregar: $erro')),
            data: (estado) {
              if (estado == null || estado.vazio) {
                return const EstadoVazio(
                  icone: Icons.bar_chart,
                  titulo: 'Sem dados para relatório',
                  mensagem: 'Depois de alguns registros, você vê o gasto por mês e o consumo por tanque.',
                );
              }
              return _Conteudo(estado: estado);
            },
          ),
    );
  }
}

class _Conteudo extends ConsumerWidget {
  const _Conteudo({required this.estado});

  final RelatoriosEstado estado;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparativo = ref.watch(comparativoVeiculosProvider).value ?? const <ComparativoVeiculo>[];
    final resumo = [
      ('Últimos 12 meses', Formato.moeda(estado.totalCentavos)),
      ('Média por mês', estado.mediaMensalCentavos == null ? '—' : Formato.moeda(estado.mediaMensalCentavos!)),
      ('Km rodados', Formato.km(estado.kmRodados)),
      ('Custo por km', estado.custoPorKm == null ? 'após 2 tanques' : Formato.moedaPorKm(estado.custoPorKm!)),
    ];

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            Text(estado.veiculo.apelido, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, limites) {
                final colunas = limites.maxWidth >= 600 ? 4 : 2;
                final largura = (limites.maxWidth - (colunas - 1) * 8) / colunas;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (rotulo, valor) in resumo)
                      SizedBox(
                        width: largura,
                        child: _CartaoNumero(rotulo: rotulo, valor: valor),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            _Secao(
              titulo: 'Gasto por mês',
              child: _GraficoMeses(meses: estado.meses, tipoEnergia: estado.veiculo.tipoEnergia),
            ),
            if (estado.ciclos.isNotEmpty) ...[
              const SizedBox(height: 16),
              _Secao(
                titulo: 'Consumo por tanque',
                subtitulo: 'De um tanque cheio (ou carga completa) até o próximo',
                child: Column(children: [for (final ciclo in estado.ciclos) _LinhaCiclo(item: ciclo)]),
              ),
            ],
            if (comparativo.length > 1) ...[
              const SizedBox(height: 16),
              _Secao(
                titulo: 'Comparativo entre veículos',
                subtitulo: 'Gasto nos últimos 12 meses',
                child: _Comparativo(itens: comparativo),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CartaoNumero extends StatelessWidget {
  const _CartaoNumero({required this.rotulo, required this.valor});

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rotulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textos.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(valor, style: textos.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Secao extends StatelessWidget {
  const _Secao({required this.titulo, this.subtitulo, required this.child});

  final String titulo;
  final String? subtitulo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: textos.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            if (subtitulo != null)
              Text(
                subtitulo!,
                style: textos.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _GraficoMeses extends StatelessWidget {
  const _GraficoMeses({required this.meses, required this.tipoEnergia});

  final List<GastoMensal> meses;
  final TipoEnergia tipoEnergia;

  static const _alturaBarras = 140.0;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final maior = meses.fold<int>(0, (m, g) => g.totalCentavos > m ? g.totalCentavos : m);
    final temCombustivel = meses.any((m) => m.combustivelCentavos > 0);
    final temEletrico = meses.any((m) => m.eletricoCentavos > 0);
    const corCombustivel = Color(0xFFF97316);
    final corEletrico = PaletaEnergia.eletrico.principal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: _alturaBarras + 36,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final mes in meses)
                Expanded(
                  child: Tooltip(
                    message: '${Formato.mesAno(mes.mes)}: ${Formato.moeda(mes.totalCentavos)}',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (maior > 0) ...[
                            _Barra(altura: _alturaBarras * mes.eletricoCentavos / maior, cor: corEletrico, topo: true),
                            _Barra(
                              altura: _alturaBarras * mes.combustivelCentavos / maior,
                              cor: corCombustivel,
                              topo: mes.eletricoCentavos == 0,
                            ),
                          ],
                          const SizedBox(height: 6),
                          FittedBox(
                            child: Text(
                              Formato.mes(mes.mes).substring(0, 3),
                              style: textos.labelSmall?.copyWith(color: esquema.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (temCombustivel && temEletrico) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            children: [
              _Legenda(cor: corCombustivel, texto: 'Combustível'),
              _Legenda(cor: corEletrico, texto: 'Energia elétrica'),
            ],
          ),
        ],
      ],
    );
  }
}

class _Barra extends StatelessWidget {
  const _Barra({required this.altura, required this.cor, required this.topo});

  final double altura;
  final Color cor;
  final bool topo;

  @override
  Widget build(BuildContext context) {
    if (altura <= 0) return const SizedBox.shrink();
    return Container(
      height: altura < 3 ? 3 : altura,
      decoration: BoxDecoration(
        color: cor,
        borderRadius: topo ? const BorderRadius.vertical(top: Radius.circular(6)) : null,
      ),
    );
  }
}

class _Legenda extends StatelessWidget {
  const _Legenda({required this.cor, required this.texto});

  final Color cor;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(texto, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _LinhaCiclo extends StatelessWidget {
  const _LinhaCiclo({required this.item});

  final CicloRelatorio item;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final ciclo = item.ciclo;
    final descricao = [
      Formato.km(ciclo.distanciaKm),
      if (ciclo.misto) 'combustíveis misturados' else if (ciclo.combustivel != null) ciclo.combustivel!.rotulo,
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              Formato.dataCurta(ciclo.fim),
              style: textos.bodyMedium?.copyWith(color: esquema.onSurfaceVariant),
            ),
          ),
          Expanded(child: Text(descricao, overflow: TextOverflow.ellipsis)),
          if (item.abaixoDaMedia) ...[
            Tooltip(
              message: 'Rendeu bem menos que a média dos tanques anteriores',
              child: Icon(Icons.trending_down, size: 18, color: esquema.error),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            '${Formato.decimal(ciclo.rendimento)} ${item.unidade}',
            style: textos.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _Comparativo extends StatelessWidget {
  const _Comparativo({required this.itens});

  final List<ComparativoVeiculo> itens;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final maior = itens.first.gastoCentavos;

    return Column(
      children: [
        for (final item in itens)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                IconeEnergia(icone: iconeDoVeiculo(item.veiculo), tamanho: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(item.veiculo.apelido, overflow: TextOverflow.ellipsis)),
                          Text(
                            Formato.moeda(item.gastoCentavos),
                            style: textos.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: maior == 0 ? 0 : item.gastoCentavos / maior,
                          minHeight: 6,
                          color: PaletaEnergia.de(item.veiculo.tipoEnergia).principal,
                          backgroundColor: esquema.surfaceContainerHighest,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.custoPorKm == null
                            ? 'Custo por km após 2 tanques'
                            : '${Formato.moedaPorKm(item.custoPorKm!)} por km',
                        style: textos.bodySmall?.copyWith(color: esquema.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
