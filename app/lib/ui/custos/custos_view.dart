import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formato.dart';
import '../../core/rotas/rotas.dart';
import '../../data/provedores.dart';
import '../../domain/custo.dart';
import '../../domain/servico.dart';

const corCustos = Color(0xFFA98BE8);
const corAtrasada = Color(0xFFE86A5A);

IconData iconeDoCusto(TipoCusto tipo) => switch (tipo) {
  TipoCusto.ipva => Icons.receipt_long_outlined,
  TipoCusto.licenciamento => Icons.assignment_outlined,
  TipoCusto.seguro => Icons.shield_outlined,
  TipoCusto.multa => Icons.report_outlined,
  TipoCusto.financiamento => Icons.account_balance_outlined,
  TipoCusto.estacionamento => Icons.local_parking,
  TipoCusto.pedagio => Icons.toll_outlined,
  TipoCusto.despachante => Icons.description_outlined,
  TipoCusto.outro => Icons.more_horiz,
};

String vencimentoDaConta(DateTime vencimento, DateTime agora) {
  final dias = CalculoCustos.diasPara(vencimento, agora);
  if (dias < 0) return 'venceu ${Formato.dataCurta(vencimento)}';
  if (dias == 0) return 'vence hoje';
  if (dias == 1) return 'vence amanhã';
  return 'vence ${Formato.dataCurta(vencimento)}';
}

String situacaoDoCusto(Servico custo) {
  final parcelas = CalculoCustos.parcelas(custo);
  final pagas = parcelas.where((p) => p.paga).length;
  if (parcelas.length > 1) {
    if (pagas == parcelas.length) return '${parcelas.length}x · todas pagas';
    return '${parcelas.length}x · ${switch (pagas) {
      0 => 'nenhuma paga',
      1 => '1 paga',
      _ => '$pagas pagas',
    }}';
  }
  return pagas == parcelas.length ? 'paga' : 'a pagar';
}

Future<void> pagarConta(BuildContext context, WidgetRef ref, ContaCusto conta) async {
  final repositorio = ref.read(servicoRepositorioProvider);
  final hoje = DateUtils.dateOnly(ref.read(relogioProvider)());
  await repositorio.salvar(CalculoCustos.marcarPaga(conta.custo, conta.parcela.numero, hoje));
  if (!context.mounted) return;
  final mensageiro = ScaffoldMessenger.of(context);
  mensageiro.hideCurrentSnackBar();
  mensageiro.showSnackBar(
    SnackBar(
      content: Text('${conta.titulo} marcada como paga.'),
      duration: const Duration(seconds: 6),
      action: SnackBarAction(
        label: 'Desfazer',
        onPressed: () => repositorio.salvar(CalculoCustos.marcarPaga(conta.custo, conta.parcela.numero, null)),
      ),
    ),
  );
}

class CustosView extends ConsumerWidget {
  const CustosView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final custos = ref.watch(custosDoAtivoProvider).value ?? const <Servico>[];
    final agora = ref.watch(relogioProvider)();
    final resumo = CalculoCustos.resumo(custos, agora);
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Outros custos')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Registrar custo',
        onPressed: () => context.push(Rotas.novoCusto),
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
                      Text(
                        'A pagar em ${CalculoCustos.diasDoPainel} dias',
                        style: textos.bodySmall?.copyWith(color: esquema.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formato.moeda(resumo.aPagarCentavos),
                        style: textos.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        resumo.quantidade == 0
                            ? 'Nada vencendo nos próximos dias'
                            : [
                                resumo.quantidade == 1 ? '1 conta' : '${resumo.quantidade} contas',
                                if (resumo.atrasadas.isNotEmpty)
                                  resumo.atrasadas.length == 1 ? '1 atrasada' : '${resumo.atrasadas.length} atrasadas',
                              ].join(' · '),
                        style: textos.bodySmall?.copyWith(
                          color: resumo.atrasadas.isNotEmpty ? corAtrasada : esquema.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (resumo.atrasadas.isNotEmpty) ...[
                _Secao('Atrasadas'),
                for (final conta in resumo.atrasadas) _LinhaConta(conta: conta, agora: agora, atrasada: true),
              ],
              if (resumo.proximas.isNotEmpty) ...[
                _Secao('Próximos dias'),
                for (final conta in resumo.proximas) _LinhaConta(conta: conta, agora: agora, atrasada: false),
              ],
              _Secao('Histórico'),
              if (custos.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'IPVA, licenciamento, seguro, multas, financiamento, estacionamento e pedágio aparecem aqui.',
                    style: textos.bodyMedium?.copyWith(color: esquema.onSurfaceVariant),
                  ),
                )
              else
                for (final custo in custos)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    leading: _Icone(tipo: TipoCusto.de(custo), cor: corCustos),
                    title: Text(CalculoCustos.titulo(custo), maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      '${Formato.dataCurta(custo.data)} · ${situacaoDoCusto(custo)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(Formato.moeda(custo.valorCentavos), style: textos.titleSmall),
                    onTap: () => context.push(Rotas.editarCusto(custo.id)),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Secao extends StatelessWidget {
  const _Secao(this.titulo);

  final String titulo;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 20, 0, 4),
    child: Text(titulo, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
  );
}

class _Icone extends StatelessWidget {
  const _Icone({required this.tipo, required this.cor});

  final TipoCusto tipo;
  final Color cor;

  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(color: cor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
    child: Icon(iconeDoCusto(tipo), color: cor),
  );
}

class _LinhaConta extends ConsumerWidget {
  const _LinhaConta({required this.conta, required this.agora, required this.atrasada});

  final ContaCusto conta;
  final DateTime agora;
  final bool atrasada;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final esquema = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: _Icone(tipo: conta.tipo, cor: atrasada ? corAtrasada : corCustos),
      title: Text(conta.titulo, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${Formato.moeda(conta.parcela.valorCentavos)} · ${vencimentoDaConta(conta.parcela.vencimento, agora)}',
        style: TextStyle(color: atrasada ? corAtrasada : esquema.onSurfaceVariant),
      ),
      trailing: FilledButton.tonal(
        onPressed: () => pagarConta(context, ref, conta),
        style: FilledButton.styleFrom(
          visualDensity: VisualDensity.compact,
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
        child: const Text('Pagar'),
      ),
      onTap: () => context.push(Rotas.editarCusto(conta.custo.id)),
    );
  }
}
