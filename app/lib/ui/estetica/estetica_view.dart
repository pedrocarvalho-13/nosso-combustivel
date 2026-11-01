import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formato.dart';
import '../../core/rotas/rotas.dart';
import '../../data/provedores.dart';
import '../../domain/estetica.dart';
import '../../domain/servico.dart';
import '../manutencao/icones_manutencao.dart';

const corEstetica = Color(0xFF5AAEE8);

IconData iconeDaModalidade(ModalidadeEstetica modalidade) => switch (modalidade) {
  ModalidadeEstetica.estetica => Icons.local_car_wash_outlined,
  ModalidadeEstetica.casa => Icons.home_outlined,
  ModalidadeEstetica.produtos => Icons.shopping_bag_outlined,
};

class EsteticaView extends ConsumerWidget {
  const EsteticaView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final esteticas = ref.watch(esteticasDoAtivoProvider).value ?? const <Servico>[];
    final agora = ref.watch(relogioProvider)();
    final resumo = CalculoEstetica.resumo(esteticas, agora);
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final ultima = resumo.ultimaLavagem;
    final dias = resumo.diasParaLavar;
    final fracao = ultima == null ? 0.0 : (1 - (dias ?? 0) / resumo.intervaloDias).clamp(0.0, 1.0);
    final passou = dias != null && dias < 0;
    final custoCasa = resumo.custoPorLavagemEmCasaCentavos;
    final compra = resumo.ultimaCompra;

    return Scaffold(
      appBar: AppBar(title: const Text('Estética')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Registrar estética',
        onPressed: () => context.push(Rotas.novaEstetica),
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
                      Text('Última lavagem', style: textos.bodySmall?.copyWith(color: esquema.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Text(
                        ultima == null ? 'Nenhuma ainda' : haQuantoTempo(ultima.data, agora),
                        style: textos.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: fracao,
                          minHeight: 6,
                          color: passou ? const Color(0xFFE8B04A) : corEstetica,
                          backgroundColor: esquema.surfaceContainerHighest,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ultima == null
                            ? 'Toque no + para registrar a primeira.'
                            : passou
                            ? 'Passou ${-dias} ${-dias == 1 ? 'dia' : 'dias'} do intervalo de ${resumo.intervaloDias} dias'
                            : dias == 0
                            ? 'Hora de lavar de novo'
                            : 'Lavar de novo em $dias ${dias == 1 ? 'dia' : 'dias'} · a cada ${resumo.intervaloDias} dias',
                        style: textos.bodySmall?.copyWith(
                          color: passou ? const Color(0xFFE8B04A) : esquema.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _Numero(
                        icone: Icons.local_car_wash_outlined,
                        rotulo: 'Estética em ${agora.year}',
                        valor: Formato.moeda(resumo.gastoEsteticaCentavos),
                        detalhe: resumo.servicosEstetica == 1 ? '1 serviço' : '${resumo.servicosEstetica} serviços',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Numero(
                        icone: Icons.home_outlined,
                        rotulo: 'Em casa em ${agora.year}',
                        valor: Formato.moeda(resumo.gastoProdutosCentavos),
                        detalhe: [
                          resumo.lavagensEmCasa == 1 ? '1 lavagem' : '${resumo.lavagensEmCasa} lavagens',
                          if (custoCasa != null) '${Formato.moeda(custoCasa)} cada',
                        ].join(' · '),
                      ),
                    ),
                  ],
                ),
              ),
              if (compra != null) ...[
                const SizedBox(height: 10),
                Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: const Icon(Icons.shopping_bag_outlined, color: corEstetica),
                    title: const Text('Produtos em uso'),
                    subtitle: Text(
                      '${CalculoEstetica.rotulos(compra).replaceFirst('Produtos: ', '')} · comprados ${haQuantoTempo(compra.data, agora)}',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Text('Histórico', style: textos.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              if (esteticas.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Lavagens na estética, em casa e as compras de produtos aparecem aqui.',
                    style: textos.bodyMedium?.copyWith(color: esquema.onSurfaceVariant),
                  ),
                )
              else
                for (final servico in esteticas)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: corEstetica.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(iconeDaModalidade(ModalidadeEstetica.de(servico)), color: corEstetica),
                    ),
                    title: Text(CalculoEstetica.rotulos(servico), maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      [Formato.dataCurta(servico.data), ?servico.lugarNome].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      ModalidadeEstetica.de(servico) == ModalidadeEstetica.casa
                          ? 'produtos'
                          : servico.detalhes['planoMensal'] == true
                          ? 'plano'
                          : Formato.moeda(servico.valorCentavos),
                      style: textos.titleSmall,
                    ),
                    onTap: () => context.push('/estetica/${servico.id}'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Numero extends StatelessWidget {
  const _Numero({required this.icone, required this.rotulo, required this.valor, required this.detalhe});

  final IconData icone;
  final String rotulo;
  final String valor;
  final String detalhe;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final esquema = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icone, size: 14, color: esquema.onSurfaceVariant),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(rotulo, style: textos.bodySmall?.copyWith(color: esquema.onSurfaceVariant)),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(valor, style: textos.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            Text(detalhe, style: textos.bodySmall?.copyWith(color: esquema.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
