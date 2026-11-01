import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formato.dart';
import '../../domain/registro_energia.dart';
import '../../data/ia/cliente_ia.dart';
import '../comum/botao_ler_foto.dart';
import '../../data/provedores.dart';
import '../../domain/forma_pagamento.dart';
import '../comum/cabecalho_secao.dart';
import '../comum/campo_com_rotulo.dart';
import '../comum/campo_pagamento.dart';
import '../comum/campo_data.dart';
import '../comum/campos_valor.dart';
import '../comum/formulario_registro.dart';
import '../comum/saida_com_rascunho.dart';
import 'nova_recarga_view_model.dart';

class NovaRecargaView extends ConsumerStatefulWidget {
  const NovaRecargaView({super.key, this.registroId});

  final String? registroId;

  @override
  ConsumerState<NovaRecargaView> createState() => _NovaRecargaViewState();
}

class _NovaRecargaViewState extends ConsumerState<NovaRecargaView> with SaidaComRascunho<NovaRecargaView> {
  final _valores = CamposValor();
  final _odometro = TextEditingController();
  var _data = DateTime.now();
  var _cargaCompleta = false;
  var _contaNaMedia = true;
  FormaPagamento? _forma;
  String? _cartaoId;
  ErrosFormulario _erros = const {};

  bool get _editando => widget.registroId != null;

  NovaRecargaViewModel get _vm => ref.read(novaRecargaViewModelProvider(widget.registroId).notifier);

  @override
  String get tipoRascunho => 'recarga';

  @override
  String get nomeDoRegistro => 'recarga';

  @override
  bool get editandoRegistro => _editando;

  @override
  String? get veiculoIdRascunho => ref.read(novaRecargaViewModelProvider(widget.registroId)).veiculo?.id;

  @override
  Map<String, dynamic> dadosDoFormulario() => {
        'data': _data.toIso8601String(),
        'odometro': _odometro.text,
        'kwh': _valores.quantidade.text,
        'preco': _valores.preco.text,
        'total': _valores.total.text,
        'cargaCompleta': _cargaCompleta,
        'contaNaMedia': _contaNaMedia,
        'forma': _forma?.name,
        'cartaoId': _cartaoId,
        'local': ref.read(novaRecargaViewModelProvider(widget.registroId)).local.name,
      };

  @override
  List<String> camposPreenchidos() => [
        if (_odometro.text.trim().isNotEmpty) 'Hodômetro',
        if (_valores.quantidade.text.trim().isNotEmpty) 'Energia',
        if (_valores.total.text.trim().isNotEmpty) 'Total',
      ];

  @override
  void aplicarRascunho(Map<String, dynamic> dados) {
    final local = LocalRecarga.values.where((l) => l.name == dados['local']).firstOrNull;
    if (local != null) _selecionarLocal(local);
    setState(() {
      _data = DateTime.tryParse(dados['data'] as String? ?? '') ?? _data;
      _cargaCompleta = dados['cargaCompleta'] as bool? ?? false;
      _contaNaMedia = dados['contaNaMedia'] as bool? ?? true;
      _forma = FormaPagamento.values.where((f) => f.name == dados['forma']).firstOrNull;
      _cartaoId = dados['cartaoId'] as String?;
    });
    _odometro.text = dados['odometro'] as String? ?? '';
    _valores.quantidade.text = dados['kwh'] as String? ?? '';
    _valores.preco.text = dados['preco'] as String? ?? '';
    _valores.total.text = dados['total'] as String? ?? '';
  }

  @override
  void initState() {
    super.initState();
    for (final (controle, campo) in [
      (_odometro, CampoRegistro.odometro),
      (_valores.quantidade, CampoRegistro.quantidade),
      (_valores.preco, CampoRegistro.preco),
    ]) {
      controle.addListener(() => _limparErro(campo));
    }
    if (!_editando) {
      WidgetsBinding.instance.addPostFrameCallback((_) => mostrarOnboardingHodometro(context, ref, recarga: true));
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
    super.dispose();
  }

  void _limparErro(CampoRegistro campo) {
    if (_erros.containsKey(campo)) setState(() => _erros = {..._erros}..remove(campo));
  }

  void _selecionarLocal(LocalRecarga local) {
    _vm.selecionarLocal(local);
    final tarifa = ref.read(novaRecargaViewModelProvider(widget.registroId)).tarifaCasa;
    if (local == LocalRecarga.casa && tarifa != null) _valores.preco.text = Formato.paraCampo(tarifa);
  }

  Future<void> _salvar() async {
    final resultado = await _vm.salvar(
      data: _data,
      odometro: Formato.lerInteiro(_odometro.text),
      kwh: _valores.valorQuantidade,
      preco: _valores.valorPreco,
      total: _valores.valorTotal,
      cargaCompleta: _cargaCompleta,
      formaPagamento: _forma,
      contaNaMedia: _contaNaMedia,
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
    ).showSnackBar(SnackBar(content: Text(_editando ? 'Recarga atualizada.' : 'Recarga salva.')));
    await apagarRascunhoSalvo();
    sairLiberado();
  }

  void _preencherDaFoto(LeituraFoto leitura) {
    if (leitura.odometro != null) _odometro.text = '${leitura.odometro}';
    _valores.preencher(quantidadeLida: leitura.kwh, precoLido: leitura.precoKwh, totalLido: leitura.valorTotal);
  }

  Future<void> _excluir() async {
    final confirmou = await confirmarExclusao(
      context,
      titulo: 'Excluir esta recarga?',
      mensagem: 'O consumo e os gastos serão recalculados sem ela.',
    );
    if (!confirmou) return;
    final registro = ref.read(novaRecargaViewModelProvider(widget.registroId)).editando;
    await _vm.excluir();
    if (!mounted) return;
    final repositorio = ref.read(registroRepositorioProvider);
    avisarExclusao(context, 'Recarga excluída.', () async {
      if (registro != null) await repositorio.restaurar(registro);
    });
    sairLiberado();
  }

  @override
  Widget build(BuildContext context) {
    final provider = novaRecargaViewModelProvider(widget.registroId);
    final estado = ref.watch(provider);
    final veiculo = estado.veiculo;
    ref.listen(provider, (anterior, atual) {
      final editando = atual.editando;
      if (anterior?.editando == null && editando != null) {
        setState(() {
          _data = editando.data;
          _cargaCompleta = editando.cargaCompleta;
          _contaNaMedia = editando.contaNaMedia;
          _forma = editando.formaPagamento;
          _cartaoId = editando.cartaoId;
        });
        _odometro.text = '${editando.odometro}';
        _valores.preco.text = Formato.paraCampo(editando.precoKwh, casas: 3);
        _valores.quantidade.text = Formato.paraCampo(editando.kwh, casas: 3);
        _valores.total.text = Formato.paraCampo(editando.valorCentavos / 100);
        WidgetsBinding.instance.addPostFrameCallback((_) => registrarEstadoDaEdicao());
        return;
      }
      final carregouTarifa = anterior?.tarifaCasa == null && atual.tarifaCasa != null;
      if (carregouTarifa && !_editando && atual.local == LocalRecarga.casa && _valores.preco.text.isEmpty) {
        _valores.preco.text = Formato.paraCampo(atual.tarifaCasa!);
      }
    });

    if (veiculo != null) WidgetsBinding.instance.addPostFrameCallback((_) => verificarRascunho());
    return envolverSaida(Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_editando ? 'Editar recarga' : 'Nova recarga'),
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
            if (rascunhoPendente != null)
              AvisoRascunho(rascunho: rascunhoPendente!, aoContinuar: continuarRascunho, aoDescartar: descartarRascunho),
            if (ref.watch(fotosIaProvider).value ?? true) ...[
              Row(
                children: [
                  Expanded(child: BotaoLerFoto(tipo: TipoLeitura.recarga, aoLer: _preencherDaFoto)),
                  const SizedBox(width: 8),
                  Expanded(child: BotaoLerFoto(tipo: TipoLeitura.hodometro, aoLer: _preencherDaFoto)),
                ],
              ),
              const SizedBox(height: 16),
            ],
            const CabecalhoSecao(numero: 1, titulo: 'O quê'),
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
                Expanded(
                  child: CampoComRotulo(
                    rotulo: 'Energia (kWh)',
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
                    rotulo: 'Preço por kWh (R\$)',
                    child: TextField(
                      controller: _valores.preco,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        helperText: estado.local == LocalRecarga.casa ? 'Tarifa da conta de luz' : null,
                        errorText: _erros[CampoRegistro.preco],
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
              subtitle: const Text('Opcional. Deixa a média mais precisa'),
              value: _cargaCompleta,
              onChanged: (valor) => setState(() => _cargaCompleta = valor),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Contar na média de consumo'),
              subtitle: const Text('Desligue quando abastecer pouco antes da hora, só para durar uns dias'),
              value: _contaNaMedia,
              onChanged: (valor) => setState(() => _contaNaMedia = valor),
            ),
            const SizedBox(height: 16),
            const CabecalhoSecao(numero: 2, titulo: 'Quando e onde'),
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
            const SizedBox(height: 16),
            const CabecalhoSecao(numero: 3, titulo: 'Pagamento'),
            CampoPagamento(
              forma: _forma,
              cartaoId: _cartaoId,
              aoMudar: (forma, cartaoId) => setState(() {
                _forma = forma;
                _cartaoId = cartaoId;
              }),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: estado.salvando || veiculo == null ? null : _salvar,
              child: Text(_editando ? 'Salvar alterações' : 'Salvar recarga'),
            ),
          ],
        ),
      ),
    ));
  }
}
