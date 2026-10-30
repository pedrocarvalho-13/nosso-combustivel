import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formato.dart';
import '../../domain/calculos/identificacao_energia.dart';
import '../../domain/veiculo.dart';
import '../comum/campo_com_rotulo.dart';
import '../comum/formulario_registro.dart';
import '../comum/icone_energia.dart';
import 'editar_veiculo_view_model.dart';
import 'seletor_energia.dart';

class EditarVeiculoView extends ConsumerStatefulWidget {
  const EditarVeiculoView({super.key, required this.veiculoId});

  final String veiculoId;

  @override
  ConsumerState<EditarVeiculoView> createState() => _EditarVeiculoViewState();
}

class _EditarVeiculoViewState extends ConsumerState<EditarVeiculoView> {
  final _apelido = TextEditingController();
  final _marca = TextEditingController();
  final _modelo = TextEditingController();
  final _ano = TextEditingController();
  final _tanque = TextEditingController();
  final _bateria = TextEditingController();
  final _odometro = TextEditingController();
  Map<CampoVeiculo, String> _erros = const {};

  EditarVeiculoViewModel get _vm => ref.read(editarVeiculoViewModelProvider(widget.veiculoId).notifier);

  @override
  void initState() {
    super.initState();
    for (final (controle, campo) in [
      (_apelido, CampoVeiculo.apelido),
      (_marca, CampoVeiculo.marca),
      (_modelo, CampoVeiculo.modelo),
      (_odometro, CampoVeiculo.odometro),
    ]) {
      controle.addListener(() {
        if (_erros.containsKey(campo)) setState(() => _erros = {..._erros}..remove(campo));
      });
    }
  }

  @override
  void dispose() {
    for (final controle in [_apelido, _marca, _modelo, _ano, _tanque, _bateria, _odometro]) {
      controle.dispose();
    }
    super.dispose();
  }

  void _preencher(Veiculo veiculo) {
    _apelido.text = veiculo.apelido;
    _marca.text = veiculo.marca;
    _modelo.text = veiculo.modelo;
    _ano.text = veiculo.ano?.toString() ?? '';
    _tanque.text = veiculo.capacidadeTanqueL == null ? '' : Formato.paraCampo(veiculo.capacidadeTanqueL!, casas: 0);
    _bateria.text = veiculo.capacidadeBateriaKwh == null ? '' : Formato.paraCampo(veiculo.capacidadeBateriaKwh!, casas: 1);
    _odometro.text = '${veiculo.odometroInicial}';
  }

  Future<void> _salvar() async {
    final erros = await _vm.salvar(
      apelido: _apelido.text,
      marca: _marca.text,
      modelo: _modelo.text,
      ano: Formato.lerInteiro(_ano.text),
      tanqueL: Formato.lerDecimal(_tanque.text),
      bateriaKwh: Formato.lerDecimal(_bateria.text),
      odometro: Formato.lerInteiro(_odometro.text),
    );
    if (!mounted) return;
    setState(() => _erros = erros);
    if (erros.isNotEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veículo atualizado.')));
    context.pop();
  }

  Future<void> _excluir(Veiculo veiculo) async {
    final confirmou = await confirmarExclusao(
      context,
      titulo: 'Excluir ${veiculo.apelido}?',
      mensagem: 'Todos os abastecimentos e recargas deste veículo também serão excluídos.',
    );
    if (!confirmou) return;
    await _vm.excluir();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veículo excluído.')));
    context.pop();
  }

  Future<void> _corrigirEnergia(EnergiaIdentificada atual) async {
    final escolhida = await mostrarSeletorEnergia(context, atual);
    if (escolhida != null) _vm.corrigirEnergia(escolhida);
  }

  @override
  Widget build(BuildContext context) {
    final provider = editarVeiculoViewModelProvider(widget.veiculoId);
    final estado = ref.watch(provider);
    ref.listen(provider.select((e) => e.veiculo), (anterior, veiculo) {
      if (anterior == null && veiculo != null) _preencher(veiculo);
    });
    final veiculo = estado.veiculo;
    final energia = estado.energia;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar veículo'),
        actions: [
          if (veiculo != null)
            IconButton(tooltip: 'Excluir veículo', icon: const Icon(Icons.delete_outline), onPressed: () => _excluir(veiculo)),
        ],
      ),
      body: veiculo == null || energia == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  CampoComRotulo(
                    rotulo: 'Apelido',
                    child: TextField(
                      controller: _apelido,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(errorText: _erros[CampoVeiculo.apelido]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CampoComRotulo(
                    rotulo: 'Marca',
                    child: TextField(
                      controller: _marca,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(errorText: _erros[CampoVeiculo.marca]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CampoComRotulo(
                    rotulo: 'Modelo',
                    child: TextField(
                      controller: _modelo,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(errorText: _erros[CampoVeiculo.modelo]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CampoComRotulo(
                    rotulo: 'Ano (opcional)',
                    child: TextField(
                      controller: _ano,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                      child: Row(
                        children: [
                          IconeEnergia(icone: iconeDoTipo(energia.tipo), tipo: energia.tipo),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              Veiculo.descreverEnergia(energia.tipo, energia.combustiveis),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          TextButton(onPressed: () => _corrigirEnergia(energia), child: const Text('Corrigir')),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (energia.tipo.abastece)
                        Expanded(
                          child: CampoComRotulo(
                            rotulo: 'Tanque (litros)',
                            child: TextField(
                              controller: _tanque,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                        ),
                      if (energia.tipo.abastece && energia.tipo.recarrega) const SizedBox(width: 12),
                      if (energia.tipo.recarrega)
                        Expanded(
                          child: CampoComRotulo(
                            rotulo: 'Bateria (kWh)',
                            child: TextField(
                              controller: _bateria,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CampoComRotulo(
                    rotulo: 'Hodômetro no cadastro (km)',
                    child: TextField(
                      controller: _odometro,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        helperText: 'O km que o veículo tinha quando você começou a usar o app.',
                        errorText: _erros[CampoVeiculo.odometro],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(onPressed: _salvar, child: const Text('Salvar alterações')),
                ],
              ),
            ),
    );
  }
}
