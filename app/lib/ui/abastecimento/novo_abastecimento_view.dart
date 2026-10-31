import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formato.dart';
import '../../data/ia/cliente_ia.dart';
import '../../domain/calculos/calculo_etanol.dart';
import '../../domain/combustivel.dart';
import '../comum/botao_ler_foto.dart';
import '../../data/provedores.dart';
import '../../domain/forma_pagamento.dart';
import '../comum/campo_com_rotulo.dart';
import '../comum/campo_pagamento.dart';
import '../comum/campo_data.dart';
import '../comum/campos_valor.dart';
import '../comum/formulario_registro.dart';
import 'novo_abastecimento_view_model.dart';

class NovoAbastecimentoView extends ConsumerStatefulWidget {
  const NovoAbastecimentoView({super.key, this.registroId});

  final String? registroId;

  @override
  ConsumerState<NovoAbastecimentoView> createState() => _NovoAbastecimentoViewState();
}

class _NovoAbastecimentoViewState extends ConsumerState<NovoAbastecimentoView> {
  final _valores = CamposValor();
  final _odometro = TextEditingController();
  final _posto = TextEditingController();
  var _data = DateTime.now();
  var _tanqueCheio = false;
  FormaPagamento? _forma;
  String? _cartaoId;
  ErrosFormulario _erros = const {};

  bool get _editando => widget.registroId != null;

  NovoAbastecimentoViewModel get _vm => ref.read(novoAbastecimentoViewModelProvider(widget.registroId).notifier);

  @override
  void initState() {
    super.initState();
    _valores.preco.addListener(() => _vm.atualizarPreco(_valores.valorPreco));
    for (final (controle, campo) in [
      (_odometro, CampoRegistro.odometro),
      (_valores.quantidade, CampoRegistro.quantidade),
      (_valores.preco, CampoRegistro.preco),
    ]) {
      controle.addListener(() => _limparErro(campo));
    }
    if (!_editando) {
      WidgetsBinding.instance.addPostFrameCallback((_) => mostrarOnboardingHodometro(context, ref, recarga: false));
      _carregarPagamentoPadrao();
    }
  }

  Future<void> _carregarPagamentoPadrao() async {
    final preferencias = ref.read(preferenciasRepositorioProvider);
    final salvo = await preferencias.pagamentoPadrao() ?? await preferencias.ultimoPagamento();
    if (salvo == null || !mounted || _forma != null) return;
    final partes = salvo.split('|');
    final forma = FormaPagamento.values.where((f) => f.name == partes.first).firstOrNull;
    setState(() {
      _forma = forma;
      _cartaoId = forma == FormaPagamento.credito && partes.length > 1 && partes[1].isNotEmpty ? partes[1] : null;
    });
  }

  @override
  void dispose() {
    _valores.dispose();
    _odometro.dispose();
    _posto.dispose();
    super.dispose();
  }

  void _limparErro(CampoRegistro campo) {
    if (_erros.containsKey(campo)) setState(() => _erros = {..._erros}..remove(campo));
  }

  Future<void> _salvar() async {
    final resultado = await _vm.salvar(
      data: _data,
      odometro: Formato.lerInteiro(_odometro.text),
      litros: _valores.valorQuantidade,
      preco: _valores.valorPreco,
      total: _valores.valorTotal,
      tanqueCheio: _tanqueCheio,
      posto: _posto.text,
      formaPagamento: _forma,
      cartaoId: _cartaoId,
    );
    if (!mounted) return;
    setState(() => _erros = resultado.erros);
    if (resultado.mensagem != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resultado.mensagem!)));
    }
    if (!resultado.sucesso) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_editando ? 'Abastecimento atualizado.' : 'Abastecimento salvo.')));
    context.pop();
  }

  void _preencherDaFoto(LeituraFoto leitura) {
    final combustiveis =
        ref.read(novoAbastecimentoViewModelProvider(widget.registroId)).veiculo?.combustiveis ?? const [];
    if (leitura.combustivel != null && combustiveis.contains(leitura.combustivel)) {
      _vm.selecionarCombustivel(leitura.combustivel!);
    }
    if (leitura.odometro != null) _odometro.text = '${leitura.odometro}';
    _valores.preencher(quantidadeLida: leitura.litros, precoLido: leitura.precoLitro, totalLido: leitura.valorTotal);
  }

  Future<void> _excluir() async {
    final confirmou = await confirmarExclusao(
      context,
      titulo: 'Excluir este abastecimento?',
      mensagem: 'O consumo e os gastos serão recalculados sem ele.',
    );
    if (!confirmou) return;
    await _vm.excluir();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Abastecimento excluído.')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(novoAbastecimentoViewModelProvider(widget.registroId));
    final veiculo = estado.veiculo;
    ref.listen(novoAbastecimentoViewModelProvider(widget.registroId).select((e) => e.editando), (anterior, editando) {
      if (anterior != null || editando == null) return;
      setState(() {
        _data = editando.data;
        _tanqueCheio = editando.tanqueCheio;
        _forma = editando.formaPagamento;
        _cartaoId = editando.cartaoId;
      });
      _odometro.text = '${editando.odometro}';
      _valores.preco.text = Formato.paraCampo(editando.precoLitro, casas: 3);
      _valores.quantidade.text = Formato.paraCampo(editando.litros, casas: 3);
      _valores.total.text = Formato.paraCampo(editando.valorCentavos / 100);
      _posto.text = editando.posto ?? '';
    });

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_editando ? 'Editar abastecimento' : 'Novo abastecimento'),
            if (veiculo != null) Text(veiculo.apelido, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        actions: [
          if (_editando) IconButton(tooltip: 'Excluir', icon: const Icon(Icons.delete_outline), onPressed: _excluir),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (ref.watch(fotosIaProvider).value ?? true) ...[
              Row(
                children: [
                  Expanded(child: BotaoLerFoto(tipo: TipoLeitura.abastecimento, aoLer: _preencherDaFoto)),
                  const SizedBox(width: 8),
                  Expanded(child: BotaoLerFoto(tipo: TipoLeitura.hodometro, aoLer: _preencherDaFoto)),
                ],
              ),
              const SizedBox(height: 16),
            ],
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
                Expanded(
                  child: CampoData(data: _data, aoMudar: (data) => setState(() => _data = data)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CampoComRotulo(
                    rotulo: 'Hodômetro (km)',
                    child: TextField(
                      controller: _odometro,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        helperText: 'Último: ${Formato.km(estado.ultimoOdometro)}',
                        errorText: _erros[CampoRegistro.odometro],
                      ),
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
                      decoration: InputDecoration(errorText: _erros[CampoRegistro.quantidade]),
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
                      decoration: InputDecoration(errorText: _erros[CampoRegistro.preco]),
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
              subtitle: const Text('Opcional. Deixa a média mais precisa'),
              value: _tanqueCheio,
              onChanged: (valor) => setState(() => _tanqueCheio = valor),
            ),
            const SizedBox(height: 8),
            CampoPagamento(
              forma: _forma,
              cartaoId: _cartaoId,
              aoMudar: (forma, cartaoId) => setState(() {
                _forma = forma;
                _cartaoId = cartaoId;
              }),
            ),
            const SizedBox(height: 8),
            CampoComRotulo(
              rotulo: 'Posto (opcional)',
              child: TextField(controller: _posto, textCapitalization: TextCapitalization.words),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: estado.salvando || veiculo == null ? null : _salvar,
              child: Text(_editando ? 'Salvar alterações' : 'Salvar abastecimento'),
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
    final regra = comparacao.limiteDoCarro
        ? 'No seu veículo, o etanol compensa até $limite%.'
        : 'A regra geral é até $limite%.';

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
