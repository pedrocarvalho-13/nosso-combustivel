import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formato.dart';
import '../../domain/calculos/calculo_etanol.dart';
import '../../domain/combustivel.dart';
import '../comum/campo_com_rotulo.dart';
import '../comum/campo_data.dart';
import '../comum/campos_valor.dart';
import 'novo_abastecimento_view_model.dart';

class NovoAbastecimentoView extends ConsumerStatefulWidget {
  const NovoAbastecimentoView({super.key});

  @override
  ConsumerState<NovoAbastecimentoView> createState() => _NovoAbastecimentoViewState();
}

class _NovoAbastecimentoViewState extends ConsumerState<NovoAbastecimentoView> {
  final _valores = CamposValor();
  final _odometro = TextEditingController();
  final _posto = TextEditingController();
  var _data = DateTime.now();
  var _tanqueCheio = true;

  NovoAbastecimentoViewModel get _vm => ref.read(novoAbastecimentoViewModelProvider.notifier);

  @override
  void initState() {
    super.initState();
    _valores.preco.addListener(() => _vm.atualizarPreco(_valores.valorPreco));
  }

  @override
  void dispose() {
    _valores.dispose();
    _odometro.dispose();
    _posto.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final erro = await _vm.salvar(
      data: _data,
      odometro: Formato.lerInteiro(_odometro.text),
      litros: _valores.valorQuantidade,
      preco: _valores.valorPreco,
      total: _valores.valorTotal,
      tanqueCheio: _tanqueCheio,
      posto: _posto.text,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro ?? 'Abastecimento salvo.')));
    if (erro == null) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(novoAbastecimentoViewModelProvider);
    final veiculo = estado.veiculo;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Novo abastecimento'),
            if (veiculo != null)
              Text(veiculo.apelido, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (veiculo != null && veiculo.combustiveis.length > 1) ...[
              SegmentedButton<Combustivel>(
                segments: [
                  for (final combustivel in veiculo.combustiveis)
                    ButtonSegment(value: combustivel, label: Text(combustivel.rotulo)),
                ],
                selected: {if (estado.combustivel != null) estado.combustivel!},
                showSelectedIcon: false,
                onSelectionChanged: (selecao) => _vm.selecionarCombustivel(selecao.first),
              ),
              const SizedBox(height: 16),
            ],
            if (estado.comparacao != null) ...[
              _AvisoEtanol(comparacao: estado.comparacao!, combustivel: estado.combustivel!),
              const SizedBox(height: 16),
            ],
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
                    rotulo: 'Litros',
                    child: TextField(
                      controller: _valores.quantidade,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CampoComRotulo(
                    rotulo: 'Preço por litro (R\$)',
                    child: TextField(
                      controller: _valores.preco,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                decoration: const InputDecoration(helperText: 'Se digitar o total, os litros se ajustam.'),
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Encheu o tanque?'),
              subtitle: const Text('Tanque cheio fecha o cálculo do consumo'),
              value: _tanqueCheio,
              onChanged: (valor) => setState(() => _tanqueCheio = valor),
            ),
            const SizedBox(height: 8),
            CampoComRotulo(
              rotulo: 'Posto (opcional)',
              child: TextField(
                controller: _posto,
                textCapitalization: TextCapitalization.words,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: estado.salvando || veiculo == null ? null : _salvar,
              child: const Text('Salvar abastecimento'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvisoEtanol extends StatelessWidget {
  const _AvisoEtanol({required this.comparacao, required this.combustivel});

  final ComparacaoEtanol comparacao;
  final Combustivel combustivel;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final razao = (comparacao.razaoPreco * 100).round();
    final limite = (comparacao.limite * 100).round();
    final titulo = comparacao.etanolCompensa ? 'Etanol compensa hoje' : 'Gasolina compensa hoje';
    final regra = comparacao.limiteDoCarro ? 'No seu carro, o etanol compensa até $limite%.' : 'A regra geral é até $limite%.';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: esquema.primaryContainer,
        border: Border.all(color: esquema.primary),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(comparacao.etanolCompensa ? Icons.check : Icons.info_outline, color: esquema.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: textos.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('O etanol custa $razao% do preço da gasolina. $regra', style: textos.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
