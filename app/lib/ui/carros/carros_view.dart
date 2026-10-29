import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/rotas/rotas.dart';
import '../../core/tema/paleta_energia.dart';
import '../../domain/veiculo.dart';
import '../comum/estado_vazio.dart';
import '../comum/icone_energia.dart';
import 'carros_view_model.dart';

class CarrosView extends ConsumerWidget {
  const CarrosView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(carrosViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus carros'),
        actions: [
          IconButton(
            tooltip: 'Adicionar carro',
            icon: const Icon(Icons.add),
            onPressed: () => context.push(Rotas.novoCarro),
          ),
        ],
      ),
      body: estado.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (erro, _) => Center(child: Text('Não foi possível carregar os carros: $erro')),
        data: (estado) {
          if (estado.veiculos.isEmpty) {
            return EstadoVazio(
              icone: Icons.directions_car_outlined,
              titulo: 'Nenhum carro ainda',
              mensagem: 'Cadastre pela tabela FIPE ou digitando marca e modelo.',
              rotuloAcao: 'Adicionar carro',
              aoAcionar: () => context.push(Rotas.novoCarro),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: estado.veiculos.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, indice) {
              final veiculo = estado.veiculos[indice];
              return _CartaoVeiculo(
                veiculo: veiculo,
                ativo: veiculo.id == estado.ativoId,
                aoTocar: () async {
                  await ref.read(carrosViewModelProvider.notifier).ativar(veiculo);
                  if (context.mounted) context.go(Rotas.inicio);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _CartaoVeiculo extends StatelessWidget {
  const _CartaoVeiculo({required this.veiculo, required this.ativo, required this.aoTocar});

  final Veiculo veiculo;
  final bool ativo;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final cor = PaletaEnergia.de(veiculo.tipoEnergia).principal;
    final textos = Theme.of(context).textTheme;
    final secundaria = Theme.of(context).colorScheme.onSurfaceVariant;
    final descricao = [veiculo.marca, veiculo.modelo, if (veiculo.ano != null) '${veiculo.ano}'].join(' · ');

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: ativo
          ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: cor, width: 2))
          : null,
      child: InkWell(
        onTap: aoTocar,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              IconeEnergia(icone: iconeDoTipo(veiculo.tipoEnergia), tipo: veiculo.tipoEnergia, tamanho: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(veiculo.apelido, style: textos.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    Text(descricao, style: textos.bodySmall?.copyWith(color: secundaria), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(veiculo.descricaoEnergia, style: textos.bodySmall?.copyWith(color: secundaria)),
                  ],
                ),
              ),
              if (ativo)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(999)),
                  child: Text(
                    'Ativo',
                    style: textos.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
