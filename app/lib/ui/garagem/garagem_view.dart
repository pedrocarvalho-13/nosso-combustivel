import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formato.dart';
import '../../core/rotas/rotas.dart';
import '../../data/provedores.dart';
import '../../domain/calculos/calculo_manutencao.dart';
import '../../domain/estetica.dart';
import '../../domain/registro_energia.dart';
import '../../domain/servico.dart';
import '../comum/estado_vazio.dart';
import '../comum/icone_energia.dart';
import '../manutencao/icones_manutencao.dart';
import '../../domain/custo.dart';
import '../custos/custos_view.dart';

class GaragemView extends ConsumerWidget {
  const GaragemView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final veiculo = ref.watch(veiculoAtivoProvider).value;
    final veiculos = ref.watch(veiculosProvider).value ?? const [];
    final registros = ref.watch(registrosDoAtivoProvider).value ?? const <RegistroEnergia>[];
    final manutencoes = ref.watch(manutencoesDoAtivoProvider).value ?? const <Servico>[];
    final esteticas = ref.watch(esteticasDoAtivoProvider).value ?? const <Servico>[];
    final custos = ref.watch(custosDoAtivoProvider).value ?? const <Servico>[];
    final agora = ref.watch(relogioProvider)();
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;

    if (veiculo == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Garagem')),
        body: EstadoVazio(
          icone: Icons.garage_outlined,
          titulo: 'Sua garagem está vazia',
          mensagem: 'Cadastre um carro ou moto para acompanhar manutenção e gastos.',
          rotuloAcao: 'Adicionar veículo',
          aoAcionar: () => context.push(Rotas.novoCarro),
        ),
      );
    }

    final odometro = CalculoManutencao.odometroAtual(
      odometroInicial: veiculo.odometroInicial,
      registros: registros,
      servicos: manutencoes,
    );
    final proxima = CalculoManutencao.proximas(servicos: manutencoes, odometroAtual: odometro, agora: agora).firstOrNull;
    final resumoManutencao = proxima != null
        ? '${proxima.categoria.rotulo} ${quandoVence(proxima)}'
        : manutencoes.isEmpty
            ? 'Nenhuma manutenção registrada'
            : 'Última ${haQuantoTempo(manutencoes.first.data, agora)}';
    final corManutencao = switch (proxima?.situacao) {
      SituacaoTroca.vencida => esquema.error,
      SituacaoTroca.perto => const Color(0xFFE8B04A),
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Garagem')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  leading: IconeEnergia(icone: iconeDoVeiculo(veiculo), tipo: veiculo.tipoEnergia, tamanho: 44),
                  title: Text(veiculo.apelido, style: textos.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  subtitle: Text('${veiculo.descricaoEnergia} · ${Formato.km(odometro)}'),
                  trailing: veiculos.length > 1 ? const Icon(Icons.unfold_more) : null,
                  onTap: () => context.push(Rotas.carros),
                ),
              ),
              const SizedBox(height: 16),
              _Item(
                icone: Icons.build_outlined,
                cor: esquema.primary,
                titulo: 'Manutenção',
                descricao: resumoManutencao,
                corDescricao: corManutencao,
                aoTocar: () => context.push(Rotas.manutencao),
              ),
              () {
                final resumo = CalculoEstetica.resumo(esteticas, agora);
                final ultima = resumo.ultimaLavagem;
                final dias = resumo.diasParaLavar;
                return _Item(
                  icone: Icons.local_car_wash_outlined,
                  cor: const Color(0xFF5AAEE8),
                  titulo: 'Estética',
                  descricao: ultima == null
                      ? 'Nenhuma lavagem registrada'
                      : 'Última lavagem ${haQuantoTempo(ultima.data, agora)}${dias != null && dias < 0 ? ' · hora de lavar' : ''}',
                  corDescricao: dias != null && dias < 0 ? const Color(0xFFE8B04A) : null,
                  aoTocar: () => context.push(Rotas.estetica),
                );
              }(),
              () {
                final resumo = CalculoCustos.resumo(custos, agora);
                final proxima = resumo.proximas.firstOrNull;
                final partes = [
                  if (resumo.atrasadas.isNotEmpty)
                    resumo.atrasadas.length == 1 ? '1 atrasada' : '${resumo.atrasadas.length} atrasadas',
                  if (proxima != null) '${TipoCusto.de(proxima.custo).rotulo} ${_quando(proxima, agora)}',
                ];
                return _Item(
                  icone: Icons.receipt_long_outlined,
                  cor: corCustos,
                  titulo: 'Outros custos',
                  descricao: partes.isNotEmpty
                      ? partes.join(' · ')
                      : custos.isEmpty
                          ? 'IPVA, licenciamento, seguro e multas'
                          : 'Nada vencendo nos próximos dias',
                  corDescricao: resumo.atrasadas.isNotEmpty ? corAtrasada : null,
                  aoTocar: () => context.push(Rotas.custos),
                );
              }(),
              _Item(
                icone: Icons.place_outlined,
                cor: const Color(0xFF7FCF8F),
                titulo: 'Lugares',
                descricao: 'Postos, eletropostos, oficinas e estéticas perto',
                aoTocar: () => context.push(Rotas.lugares),
              ),
              _Item(
                icone: Icons.directions_car_outlined,
                cor: esquema.onSurfaceVariant,
                titulo: 'Meus veículos',
                descricao: veiculos.length == 1 ? '1 cadastrado' : '${veiculos.length} cadastrados',
                aoTocar: () => context.push(Rotas.carros),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icone,
    required this.cor,
    required this.titulo,
    required this.descricao,
    this.corDescricao,
    this.aoTocar,
  });

  final IconData icone;
  final Color cor;
  final String titulo;
  final String descricao;
  final Color? corDescricao;
  final VoidCallback? aoTocar;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final ativo = aoTocar != null;
    return Opacity(
      opacity: ativo ? 1 : 0.55,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: cor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
          child: Icon(icone, color: cor),
        ),
        title: Text(titulo),
        subtitle: Text(descricao, style: TextStyle(color: corDescricao ?? esquema.onSurfaceVariant)),
        trailing: ativo ? const Icon(Icons.chevron_right) : null,
        onTap: aoTocar,
      ),
    );
  }
}

String _quando(ContaCusto conta, DateTime agora) {
  final dias = CalculoCustos.diasPara(conta.parcela.vencimento, agora);
  if (dias == 0) return 'vence hoje';
  if (dias == 1) return 'vence amanhã';
  return 'em $dias dias';
}
