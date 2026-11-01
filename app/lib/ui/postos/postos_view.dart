import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/postos/cliente_postos.dart';
import '../../data/provedores.dart';
import '../../domain/combustivel.dart';
import '../../domain/horario_posto.dart';
import '../../domain/tipo_gasolina.dart';
import 'lista_postos_perto.dart';

class PostosView extends ConsumerStatefulWidget {
  const PostosView({super.key});

  @override
  ConsumerState<PostosView> createState() => _PostosViewState();
}

class _PostosViewState extends ConsumerState<PostosView> {
  TipoPosto? _tipo;
  Combustivel? _combustivel;
  TipoGasolina? _tipoGasolina;

  @override
  Widget build(BuildContext context) {
    final veiculo = ref.watch(veiculoAtivoProvider).value;
    final abastece = veiculo?.tipoEnergia.abastece ?? true;
    final recarrega = veiculo?.tipoEnergia.recarrega ?? false;
    final tipo = _tipo ?? (abastece ? TipoPosto.combustivel : TipoPosto.eletroposto);
    final combustiveis = veiculo?.combustiveis ?? const <Combustivel>[];
    final combustivel = _combustivel ?? combustiveis.firstOrNull;
    final tipoGasolina = _tipoGasolina ?? ref.watch(gasolinaPadraoProvider).value ?? TipoGasolina.comum;

    return Scaffold(
      appBar: AppBar(title: Text(tipo == TipoPosto.eletroposto ? 'Eletropostos perto' : 'Postos perto')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SegmentedButton<TipoPosto>(
                        segments: const [
                          ButtonSegment(
                            value: TipoPosto.combustivel,
                            label: Text('Combustível'),
                            icon: Icon(Icons.local_gas_station_outlined),
                          ),
                          ButtonSegment(
                            value: TipoPosto.eletroposto,
                            label: Text('Eletroposto'),
                            icon: Icon(Icons.ev_station_outlined),
                          ),
                        ],
                        selected: {tipo},
                        showSelectedIcon: false,
                        onSelectionChanged: (selecao) => setState(() => _tipo = selecao.first),
                      ),
                      if (tipo == TipoPosto.combustivel && combustiveis.length > 1) ...[
                        const SizedBox(height: 10),
                        SegmentedButton<Combustivel>(
                          segments: [
                            for (final c in combustiveis) ButtonSegment(value: c, label: Text(c.rotulo)),
                          ],
                          selected: {?combustivel},
                          showSelectedIcon: false,
                          onSelectionChanged: (selecao) => setState(() => _combustivel = selecao.first),
                        ),
                      ],
                      if (tipo == TipoPosto.combustivel && combustivel == Combustivel.gasolina) ...[
                        const SizedBox(height: 10),
                        SegmentedButton<TipoGasolina>(
                          segments: [
                            for (final t in TipoGasolina.values) ButtonSegment(value: t, label: Text(t.rotulo)),
                          ],
                          selected: {tipoGasolina},
                          showSelectedIcon: false,
                          onSelectionChanged: (selecao) => setState(() => _tipoGasolina = selecao.first),
                        ),
                      ],
                      if (tipo == TipoPosto.eletroposto && !recarrega && veiculo != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Seu veículo ativo não recarrega na tomada.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                Expanded(
                  child: ListaPostosPerto(
                    tipo: tipo,
                    combustivel: combustivel,
                    tipoGasolina: tipoGasolina,
                    ocuparEspaco: true,
                    aoEscolher: (posto) => _abrirRota(context, posto),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _abrirRota(BuildContext context, PostoProximo posto) => showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (contexto) {
        final textos = Theme.of(contexto).textTheme;
        final destino = '${posto.latitude},${posto.longitude}';
        final android = defaultTargetPlatform == TargetPlatform.android;
        Future<void> abrir(Uri endereco) async {
          Navigator.of(contexto).pop();
          final abriu = await launchUrl(endereco, mode: LaunchMode.externalApplication);
          if (!abriu && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não deu para abrir o app de mapas.')));
          }
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(posto.nome, style: textos.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                if (posto.endereco != null) ...[
                  const SizedBox(height: 4),
                  Text(posto.endereco!, style: textos.bodyMedium),
                ],
                if (HorarioPosto.legivel(posto.horario) case final horario?) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 16),
                      const SizedBox(width: 6),
                      Expanded(child: Text(horario, style: textos.bodyMedium)),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Text('${distanciaLegivel(posto.distanciaMetros)} de você', style: textos.bodySmall),
                const SizedBox(height: 20),
                if (android) ...[
                  FilledButton.icon(
                    onPressed: () => abrir(
                      Uri.parse('geo:$destino?q=$destino(${Uri.encodeComponent(posto.nome)})'),
                    ),
                    icon: const Icon(Icons.navigation_outlined),
                    label: const Text('Ir até lá'),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mostra os apps de mapa instalados no celular.',
                    textAlign: TextAlign.center,
                    style: textos.bodySmall,
                  ),
                  const SizedBox(height: 12),
                ],
                if (android)
                  OutlinedButton.icon(
                    onPressed: () => abrir(Uri.parse('https://waze.com/ul?ll=$destino&navigate=yes')),
                    icon: const Icon(Icons.navigation_outlined),
                    label: const Text('Ir com Waze'),
                  )
                else
                  FilledButton.icon(
                    onPressed: () => abrir(Uri.parse('https://waze.com/ul?ll=$destino&navigate=yes')),
                    icon: const Icon(Icons.navigation_outlined),
                    label: const Text('Ir com Waze'),
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => abrir(Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$destino')),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Ir com Google Maps'),
                ),
                if (defaultTargetPlatform == TargetPlatform.iOS) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => abrir(Uri.parse('maps://?daddr=$destino')),
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Ir com Apple Mapas'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
