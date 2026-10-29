import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formato.dart';
import '../../core/rotas/rotas.dart';
import '../comum/estado_vazio.dart';
import '../comum/icone_energia.dart';
import '../comum/registro_tile.dart';
import '../conta/menu_perfil.dart';
import 'inicio_view_model.dart';

class InicioView extends ConsumerWidget {
  const InicioView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(inicioViewModelProvider).when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (erro, _) => Center(child: Text('Não foi possível carregar: $erro')),
          data: (estado) {
            if (estado == null) {
              return Stack(
                children: [
                  EstadoVazio(
                    icone: Icons.local_gas_station_outlined,
                    titulo: 'Cadastre seu primeiro carro',
                    mensagem:
                        'Com o carro cadastrado, você acompanha o gasto da semana, do mês e quanto ele faz por litro ou por kWh.',
                    rotuloAcao: 'Adicionar carro',
                    aoAcionar: () => context.push(Rotas.novoCarro),
                  ),
                  const Positioned(top: 12, right: 16, child: BotaoPerfil()),
                ],
              );
            }
            return _Painel(estado: estado);
          },
        );
  }
}

class _Painel extends StatelessWidget {
  const _Painel({required this.estado});

  final InicioEstado estado;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final veiculo = estado.veiculo;
    final secundario = textos.bodyMedium?.copyWith(color: esquema.onSurfaceVariant);
    final abastece = veiculo.tipoEnergia.abastece;
    final recarrega = veiculo.tipoEnergia.recarrega;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  color: esquema.surfaceContainer,
                  shape: StadiumBorder(side: BorderSide(color: esquema.outline)),
                  child: InkWell(
                    customBorder: const StadiumBorder(),
                    onTap: () => context.go(Rotas.carros),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconeEnergia(icone: iconeDoTipo(veiculo.tipoEnergia), tamanho: 32),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  veiculo.apelido,
                                  overflow: TextOverflow.ellipsis,
                                  style: textos.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  veiculo.descricaoEnergia,
                                  overflow: TextOverflow.ellipsis,
                                  style: textos.bodySmall?.copyWith(color: esquema.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.expand_more, size: 18, color: esquema.onSurfaceVariant),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const BotaoPerfil(),
          ],
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Gasto em ${estado.nomeMes}', style: secundario),
                const SizedBox(height: 4),
                Text(
                  Formato.moeda(estado.mes.gastoCentavos),
                  style: textos.displaySmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        estado.projecaoCentavos == null
                            ? 'Projeção após 7 dias de uso'
                            : 'Projeção do mês: ${Formato.moeda(estado.projecaoCentavos!)}',
                        style: secundario,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${Formato.km(estado.mes.kmRodados)} rodados', style: secundario),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < estado.indicadores.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _CartaoIndicador(indicador: estado.indicadores[i])),
                  const SizedBox(width: 10),
                  Expanded(
                    child: i + 1 < estado.indicadores.length
                        ? _CartaoIndicador(indicador: estado.indicadores[i + 1])
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (abastece)
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.push(Rotas.novoAbastecimento),
                  icon: const Icon(Icons.local_gas_station),
                  label: Text(recarrega ? 'Abastecer' : 'Registrar abastecimento'),
                ),
              ),
            if (abastece && recarrega) const SizedBox(width: 10),
            if (recarrega)
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.push(Rotas.novaRecarga),
                  icon: const Icon(Icons.bolt),
                  label: Text(abastece ? 'Recarregar' : 'Registrar recarga'),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text('Últimos registros', style: textos.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ),
            if (estado.ultimos.isNotEmpty)
              TextButton(onPressed: () => context.go(Rotas.historico), child: const Text('Ver tudo')),
          ],
        ),
        const SizedBox(height: 4),
        if (estado.ultimos.isEmpty)
          Text('Nenhum registro ainda. Use o botão acima no próximo abastecimento.', style: secundario)
        else
          for (final registro in estado.ultimos)
            Padding(padding: const EdgeInsets.only(bottom: 8), child: RegistroTile(registro: registro)),
      ],
    );
  }
}

class _CartaoIndicador extends StatelessWidget {
  const _CartaoIndicador({required this.indicador});

  final Indicador indicador;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              indicador.rotulo,
              style: textos.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(indicador.valor, style: textos.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
