import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formato.dart';
import '../../core/rotas/rotas.dart';
import '../../data/provedores.dart';
import '../../domain/calculos/calculo_manutencao.dart';
import '../../domain/categoria_manutencao.dart';
import '../../domain/registro_energia.dart';
import '../../domain/servico.dart';
import 'icones_manutencao.dart';

class ManutencaoView extends ConsumerWidget {
  const ManutencaoView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final veiculo = ref.watch(veiculoAtivoProvider).value;
    final registros = ref.watch(registrosDoAtivoProvider).value ?? const <RegistroEnergia>[];
    final manutencoes = ref.watch(manutencoesDoAtivoProvider).value ?? const <Servico>[];
    final agora = ref.watch(relogioProvider)();
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;

    final odometro = veiculo == null
        ? 0
        : CalculoManutencao.odometroAtual(
            odometroInicial: veiculo.odometroInicial,
            registros: registros,
            servicos: manutencoes,
          );
    final proximas = CalculoManutencao.proximas(servicos: manutencoes, odometroAtual: odometro, agora: agora);
    final ultima = manutencoes.firstOrNull;
    final doAno = manutencoes.where((s) => s.data.year == agora.year);
    final gastoAno = doAno.fold(0, (soma, s) => soma + s.valorCentavos);
    final kmAno = _kmNoAno(registros, agora.year);
    final porKm = kmAno == null || kmAno <= 0 || gastoAno == 0 ? null : gastoAno / 100 / kmAno;

    return Scaffold(
      appBar: AppBar(title: const Text('Manutenção')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Registrar manutenção',
        onPressed: () => context.push(Rotas.novaManutencao),
        child: const Icon(Icons.add),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Última manutenção', style: textos.bodySmall?.copyWith(color: esquema.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Text(
                        ultima == null ? 'Nenhuma ainda' : haQuantoTempo(ultima.data, agora),
                        style: textos.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (ultima != null)
                        Text(
                          [
                            rotulosDosServicos(ultima),
                            Formato.dataCurta(ultima.data),
                            if (ultima.odometro != null) Formato.km(ultima.odometro!),
                          ].join(' · '),
                          style: textos.bodySmall?.copyWith(color: esquema.onSurfaceVariant),
                        )
                      else
                        Text(
                          'Toque no + para registrar a primeira.',
                          style: textos.bodySmall?.copyWith(color: esquema.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
              ),
              for (final troca in proximas.take(3)) ...[
                const SizedBox(height: 10),
                _CartaoTroca(troca: troca),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _Numero(rotulo: 'Gasto em ${agora.year}', valor: Formato.moeda(gastoAno))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Numero(rotulo: 'Por km rodado', valor: porKm == null ? '—' : Formato.moedaPorKm(porKm)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Histórico', style: textos.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              if (manutencoes.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'As manutenções que você registrar aparecem aqui.',
                    style: textos.bodyMedium?.copyWith(color: esquema.onSurfaceVariant),
                  ),
                )
              else
                for (final servico in manutencoes)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: esquema.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        iconeDaCategoria(
                          CategoriaManutencao.porNome(servico.categorias.firstOrNull ?? '') ?? CategoriaManutencao.outro,
                        ),
                        color: esquema.primary,
                      ),
                    ),
                    title: Text(rotulosDosServicos(servico), maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      [Formato.dataCurta(servico.data), ?servico.lugarNome].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(Formato.moeda(servico.valorCentavos), style: textos.titleSmall),
                    onTap: () => context.push('/manutencao/${servico.id}'),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  static int? _kmNoAno(List<RegistroEnergia> registros, int ano) {
    final doAno = registros.where((r) => r.data.year == ano).map((r) => r.odometro).toList();
    if (doAno.length < 2) return null;
    doAno.sort();
    return doAno.last - doAno.first;
  }
}

class _CartaoTroca extends StatelessWidget {
  const _CartaoTroca({required this.troca});

  final ProximaTroca troca;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final cor = switch (troca.situacao) {
      SituacaoTroca.vencida => esquema.error,
      SituacaoTroca.perto => const Color(0xFFE8B04A),
      SituacaoTroca.emDia => esquema.primary,
    };
    final detalhe = [
      'Feita ${Formato.dataCurta(troca.feitaEm)}',
      if (troca.feitaKm != null) 'aos ${Formato.km(troca.feitaKm!)}',
      if (troca.proximaKm != null) '· próxima aos ${Formato.km(troca.proximaKm!)}',
    ].join(' ');
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: troca.situacao == SituacaoTroca.emDia ? esquema.outlineVariant : cor),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(iconeDaCategoria(troca.categoria), size: 18, color: cor),
                const SizedBox(width: 8),
                Expanded(child: Text(troca.categoria.rotulo, style: textos.titleSmall)),
                Text(quandoVence(troca), style: textos.labelMedium?.copyWith(color: cor, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: troca.fracao.clamp(0.0, 1.0),
                minHeight: 6,
                color: cor,
                backgroundColor: esquema.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 6),
            Text(detalhe, style: textos.bodySmall?.copyWith(color: esquema.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _Numero extends StatelessWidget {
  const _Numero({required this.rotulo, required this.valor});

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(rotulo, style: textos.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 2),
            Text(valor, style: textos.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
