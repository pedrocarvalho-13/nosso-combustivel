import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formato.dart';
import '../../domain/registro_energia.dart';
import '../comum/campo_com_rotulo.dart';
import '../comum/campo_data.dart';
import '../comum/campos_valor.dart';
import 'nova_recarga_view_model.dart';

class NovaRecargaView extends ConsumerStatefulWidget {
  const NovaRecargaView({super.key});

  @override
  ConsumerState<NovaRecargaView> createState() => _NovaRecargaViewState();
}

class _NovaRecargaViewState extends ConsumerState<NovaRecargaView> {
  final _valores = CamposValor();
  final _odometro = TextEditingController();
  var _data = DateTime.now();
  var _cargaCompleta = true;

  NovaRecargaViewModel get _vm => ref.read(novaRecargaViewModelProvider.notifier);

  @override
  void dispose() {
    _valores.dispose();
    _odometro.dispose();
    super.dispose();
  }

  void _selecionarLocal(LocalRecarga local) {
    _vm.selecionarLocal(local);
    final tarifa = ref.read(novaRecargaViewModelProvider).tarifaCasa;
    if (local == LocalRecarga.casa && tarifa != null) _valores.preco.text = Formato.paraCampo(tarifa);
  }

  Future<void> _salvar() async {
    final erro = await _vm.salvar(
      data: _data,
      odometro: Formato.lerInteiro(_odometro.text),
      kwh: _valores.valorQuantidade,
      preco: _valores.valorPreco,
      total: _valores.valorTotal,
      cargaCompleta: _cargaCompleta,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro ?? 'Recarga salva.')));
    if (erro == null) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(novaRecargaViewModelProvider);
    final veiculo = estado.veiculo;
    ref.listen(novaRecargaViewModelProvider, (anterior, atual) {
      final carregouTarifa = anterior?.tarifaCasa == null && atual.tarifaCasa != null;
      if (carregouTarifa && atual.local == LocalRecarga.casa && _valores.preco.text.isEmpty) {
        _valores.preco.text = Formato.paraCampo(atual.tarifaCasa!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nova recarga'),
            if (veiculo != null) Text(veiculo.apelido, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<LocalRecarga>(
              segments: [
                for (final local in LocalRecarga.values) ButtonSegment(value: local, label: Text(local.rotulo)),
              ],
              selected: {estado.local},
              showSelectedIcon: false,
              onSelectionChanged: (selecao) => _selecionarLocal(selecao.first),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: CampoData(data: _data, aoMudar: (data) => setState(() => _data = data))),
                const SizedBox(width: 12),
                Expanded(
                  child: CampoComRotulo(
                    rotulo: 'Odômetro (km)',
                    child: TextField(
                      controller: _odometro,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(helperText: 'Última: ${Formato.km(estado.ultimoOdometro)}'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CampoComRotulo(
                    rotulo: 'Energia (kWh)',
                    child: TextField(
                      controller: _valores.quantidade,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CampoComRotulo(
                    rotulo: 'Preço por kWh (R\$)',
                    child: TextField(
                      controller: _valores.preco,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        helperText: estado.local == LocalRecarga.casa ? 'Tarifa da conta de luz' : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CampoComRotulo(
              rotulo: 'Total (R\$)',
              child: TextField(
                controller: _valores.total,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Carregou até 100%?'),
              subtitle: const Text('Carga completa fecha o cálculo do consumo'),
              value: _cargaCompleta,
              onChanged: (valor) => setState(() => _cargaCompleta = valor),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: estado.salvando || veiculo == null ? null : _salvar,
              child: const Text('Salvar recarga'),
            ),
          ],
        ),
      ),
    );
  }
}
