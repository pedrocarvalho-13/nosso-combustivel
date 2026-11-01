import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formato.dart';
import '../../data/provedores.dart';
import '../../domain/custo.dart';
import '../../domain/forma_pagamento.dart';
import '../../domain/servico.dart';
import '../comum/campo_com_rotulo.dart';
import '../comum/campo_pagamento.dart';
import '../comum/formulario_registro.dart';
import '../comum/saida_com_rascunho.dart';
import 'custos_view.dart';

class NovoCustoView extends ConsumerStatefulWidget {
  const NovoCustoView({super.key, this.custoId});

  final String? custoId;

  @override
  ConsumerState<NovoCustoView> createState() => _NovoCustoViewState();
}

class _NovoCustoViewState extends ConsumerState<NovoCustoView> with SaidaComRascunho<NovoCustoView> {
  final _valor = TextEditingController();
  final _descricao = TextEditingController();
  final _seguradora = TextEditingController();
  final _franquia = TextEditingController();
  final _infracao = TextEditingController();
  final _lugar = TextEditingController();
  final _parcelaAtual = TextEditingController();
  final _totalParcelas = TextEditingController();
  final _observacao = TextEditingController();
  TipoCusto? _tipo;
  var _passo = 0;
  var _ano = DateTime.now().year;
  var _vezes = 1;
  var _data = DateUtils.dateOnly(DateTime.now());
  var _vencimento = DateUtils.dateOnly(DateTime.now());
  DateTime? _vigenciaFim;
  var _versaoCalendario = 0;
  int? _pontos;
  var _desconto = DescontoMulta.nenhum;
  var _parcelas = <ParcelaCusto>[];
  FormaPagamento? _forma;
  String? _cartaoId;
  var _avisar = true;
  var _avisarDias = 3;
  String? _erroValor;
  var _salvando = false;
  Servico? _original;

  bool get _editando => widget.custoId != null;

  List<String> get _passos {
    final tipo = _tipo;
    if (tipo == null) return const ['Que tipo de custo?', 'Detalhes', 'Pagamento'];
    if (tipo.rapido) return const ['Que tipo de custo?', 'Quanto e quando?'];
    return ['Que tipo de custo?', _tituloDetalhes(tipo), 'Pagamento'];
  }

  static String _tituloDetalhes(TipoCusto tipo) => switch (tipo) {
    TipoCusto.multa => 'Detalhes da multa',
    TipoCusto.outro => 'Detalhes do custo',
    _ => 'Detalhes do ${tipo.nomeNaFrase}',
  };

  int get _valorCentavos => ((Formato.lerDecimal(_valor.text) ?? 0) * 100).round();

  int get _valorAPagarCentavos => _tipo == TipoCusto.multa ? _desconto.aplicar(_valorCentavos) : _valorCentavos;

  @override
  String get tipoRascunho => 'custo';

  @override
  String get nomeDoRegistro => 'custo';

  @override
  bool get editandoRegistro => _editando;

  @override
  String? get veiculoIdRascunho => ref.read(veiculoAtivoProvider).value?.id;

  @override
  void initState() {
    super.initState();
    _valor.addListener(() {
      if (_erroValor != null) setState(() => _erroValor = null);
    });
    if (_editando) {
      _carregar();
    } else {
      _carregarPagamento();
      WidgetsBinding.instance.addPostFrameCallback((_) => verificarRascunho());
    }
  }

  @override
  void dispose() {
    for (final controle in [
      _valor,
      _descricao,
      _seguradora,
      _franquia,
      _infracao,
      _lugar,
      _parcelaAtual,
      _totalParcelas,
      _observacao,
    ]) {
      controle.dispose();
    }
    super.dispose();
  }

  Future<void> _carregarPagamento() async {
    final preferencias = ref.read(preferenciasRepositorioProvider);
    final salvo = await preferencias.pagamentoPadrao() ?? await preferencias.ultimoPagamento();
    if (!mounted || salvo == null || _forma != null) return;
    final partes = salvo.split('|');
    setState(() {
      _forma = FormaPagamento.values.where((f) => f.name == partes.first).firstOrNull;
      _cartaoId = _forma == FormaPagamento.credito && partes.length > 1 && partes[1].isNotEmpty ? partes[1] : null;
    });
  }

  Future<void> _carregar() async {
    final custo = await ref.read(servicoRepositorioProvider).obter(widget.custoId!);
    if (custo == null || !mounted) return;
    _original = custo;
    final d = custo.detalhes;
    final parcelas = CalculoCustos.parcelas(custo);
    final tipo = TipoCusto.de(custo);
    final valorDoCampo = switch (tipo) {
      TipoCusto.multa => (d['valorOriginal'] as num?)?.toInt() ?? custo.valorCentavos,
      TipoCusto.financiamento => (d['valorParcela'] as num?)?.toInt() ?? parcelas.firstOrNull?.valorCentavos ?? 0,
      _ => custo.valorCentavos,
    };
    aplicarRascunho({
      ...dadosDoFormulario(),
      'tipo': tipo.name,
      'valor': Formato.paraCampo(valorDoCampo / 100),
      'descricao': d['descricao'] ?? '',
      'seguradora': d['seguradora'] ?? '',
      'franquia': d['franquia'] == null ? '' : Formato.paraCampo((d['franquia'] as num) / 100),
      'infracao': d['infracao'] ?? '',
      'lugar': custo.lugarNome ?? '',
      'parcelaAtual': '${d['parcelaAtual'] ?? ''}',
      'totalParcelas': '${d['totalParcelas'] ?? ''}',
      'observacao': custo.observacao ?? '',
      'ano': d['ano'] ?? _ano,
      'vezes': parcelas.length,
      'data': custo.data.toIso8601String(),
      'vencimento': (parcelas.firstOrNull?.vencimento ?? custo.data).toIso8601String(),
      'vigenciaFim': d['vigenciaFim'],
      'pontos': d['pontos'],
      'desconto': d['desconto'],
      'parcelas': [for (final p in parcelas) p.paraJson()],
      'forma': custo.formaPagamento?.name,
      'cartaoId': custo.cartaoId,
      'avisar': d['avisarDias'] != null,
      'avisarDias': d['avisarDias'] ?? _avisarDias,
    });
    setState(() => _passo = 1);
    WidgetsBinding.instance.addPostFrameCallback((_) => registrarEstadoDaEdicao());
  }

  @override
  Map<String, dynamic> dadosDoFormulario() => {
    'tipo': _tipo?.name,
    'valor': _valor.text,
    'descricao': _descricao.text,
    'seguradora': _seguradora.text,
    'franquia': _franquia.text,
    'infracao': _infracao.text,
    'lugar': _lugar.text,
    'parcelaAtual': _parcelaAtual.text,
    'totalParcelas': _totalParcelas.text,
    'observacao': _observacao.text,
    'ano': _ano,
    'vezes': _vezes,
    'data': _data.toIso8601String(),
    'vencimento': _vencimento.toIso8601String(),
    'vigenciaFim': _vigenciaFim?.toIso8601String(),
    'pontos': _pontos,
    'desconto': _desconto.name,
    'parcelas': [for (final p in _parcelas) p.paraJson()],
    'forma': _forma?.name,
    'cartaoId': _cartaoId,
    'avisar': _avisar,
    'avisarDias': _avisarDias,
  };

  @override
  List<String> camposPreenchidos() => [
    if (_tipo != null) 'Tipo',
    if (_valor.text.trim().isNotEmpty) 'Valor',
    if (_descricao.text.trim().isNotEmpty || _seguradora.text.trim().isNotEmpty || _infracao.text.trim().isNotEmpty)
      'Detalhes',
  ];

  @override
  void aplicarRascunho(Map<String, dynamic> dados) {
    DateTime? lerData(Object? valor) => valor is String ? DateTime.tryParse(valor) : null;
    setState(() {
      _tipo = TipoCusto.values.where((t) => t.name == dados['tipo']).firstOrNull;
      _ano = (dados['ano'] as num?)?.toInt() ?? _ano;
      _vezes = (dados['vezes'] as num?)?.toInt() ?? 1;
      _data = DateUtils.dateOnly(lerData(dados['data']) ?? _data);
      _vencimento = DateUtils.dateOnly(lerData(dados['vencimento']) ?? _vencimento);
      _vigenciaFim = lerData(dados['vigenciaFim']);
      _versaoCalendario++;
      _pontos = (dados['pontos'] as num?)?.toInt();
      _desconto = DescontoMulta.de(dados['desconto']);
      _parcelas = [
        for (final item in (dados['parcelas'] as List?) ?? const [])
          if (item is Map) ParcelaCusto.deJson(item.cast<String, dynamic>()),
      ];
      _forma = FormaPagamento.values.where((f) => f.name == dados['forma']).firstOrNull;
      _cartaoId = dados['cartaoId'] as String?;
      _avisar = dados['avisar'] as bool? ?? true;
      _avisarDias = (dados['avisarDias'] as num?)?.toInt() ?? 3;
    });
    _valor.text = dados['valor'] as String? ?? '';
    _descricao.text = dados['descricao'] as String? ?? '';
    _seguradora.text = dados['seguradora'] as String? ?? '';
    _franquia.text = dados['franquia'] as String? ?? '';
    _infracao.text = dados['infracao'] as String? ?? '';
    _lugar.text = dados['lugar'] as String? ?? '';
    _parcelaAtual.text = dados['parcelaAtual'] as String? ?? '';
    _totalParcelas.text = dados['totalParcelas'] as String? ?? '';
    _observacao.text = dados['observacao'] as String? ?? '';
  }

  @override
  bool tratarVoltar() {
    if (_passo == 0 || (_editando && _passo == 1)) return false;
    setState(() => _passo--);
    return true;
  }

  void _regerarParcelas() {
    final tipo = _tipo;
    if (tipo == null || tipo.rapido) return;
    final novas = tipo == TipoCusto.financiamento
        ? CalculoCustos.financiamento(
            valorParcelaCentavos: _valorCentavos,
            parcelaAtual: Formato.lerInteiro(_parcelaAtual.text) ?? 1,
            totalParcelas: Formato.lerInteiro(_totalParcelas.text) ?? 1,
            proximoVencimento: _vencimento,
          )
        : CalculoCustos.dividir(
            totalCentavos: _valorAPagarCentavos,
            vezes: tipo.temParcelas ? _vezes : 1,
            primeiroVencimento: _vencimento,
          );
    final pagas = {for (final p in _parcelas) p.numero: p.pagaEm};
    _parcelas = [for (final p in novas) p.copiar(pagaEm: pagas[p.numero])];
  }

  void _mudar(VoidCallback mudanca) => setState(() {
    mudanca();
    _regerarParcelas();
  });

  String? _validarDetalhes() {
    final tipo = _tipo!;
    if (_valorCentavos <= 0) {
      setState(() => _erroValor = tipo == TipoCusto.financiamento ? 'Informe o valor da parcela.' : 'Informe o valor.');
      return null;
    }
    if (tipo == TipoCusto.financiamento) {
      final atual = Formato.lerInteiro(_parcelaAtual.text);
      final total = Formato.lerInteiro(_totalParcelas.text);
      if (atual == null || total == null || atual < 1 || total < atual) {
        return 'Informe a parcela atual e o total de parcelas.';
      }
      if (total - atual >= 120) return 'Até 120 parcelas por financiamento.';
    }
    return '';
  }

  void _avancar() {
    FocusScope.of(context).unfocus();
    if (_passo == 0) {
      if (_tipo == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Escolha o tipo de custo.')));
        return;
      }
      setState(() {
        _regerarParcelas();
        _passo++;
      });
      return;
    }
    if (_passo == 1 && !_tipo!.rapido) {
      final erro = _validarDetalhes();
      if (erro == null) return;
      if (erro.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
        return;
      }
      setState(() {
        if (_parcelas.isEmpty) _regerarParcelas();
        _passo++;
      });
      return;
    }
    _salvar();
  }

  Future<void> _salvar() async {
    final veiculo = ref.read(veiculoAtivoProvider).value;
    final tipo = _tipo;
    if (veiculo == null || tipo == null) return;
    if (_valorCentavos <= 0) {
      setState(() => _erroValor = 'Informe o valor.');
      return;
    }
    if (_forma == FormaPagamento.credito && _cartaoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Escolha o cartão de crédito usado.')));
      return;
    }
    setState(() => _salvando = true);
    final parcelas = tipo.rapido
        ? [ParcelaCusto(numero: 1, vencimento: _data, valorCentavos: _valorCentavos, pagaEm: _data)]
        : _parcelas;
    final todasPagas = parcelas.every((p) => p.paga);
    String? texto(TextEditingController controle) => controle.text.trim().isEmpty ? null : controle.text.trim();
    final franquia = Formato.lerDecimal(_franquia.text);
    final detalhes = <String, dynamic>{
      if (tipo.temAno) 'ano': _ano,
      if (tipo == TipoCusto.seguro) ...{
        'seguradora': ?texto(_seguradora),
        'vigenciaFim': ?_vigenciaFim?.toIso8601String().substring(0, 10),
        if (franquia != null) 'franquia': (franquia * 100).round(),
      },
      if (tipo == TipoCusto.multa) ...{
        'infracao': ?texto(_infracao),
        'pontos': ?_pontos,
        'desconto': _desconto.name,
        'valorOriginal': _valorCentavos,
      },
      if (tipo == TipoCusto.financiamento) ...{
        'valorParcela': _valorCentavos,
        'parcelaAtual': Formato.lerInteiro(_parcelaAtual.text),
        'totalParcelas': Formato.lerInteiro(_totalParcelas.text),
      },
      if (tipo == TipoCusto.financiamento || tipo == TipoCusto.despachante || tipo == TipoCusto.outro)
        'descricao': ?texto(_descricao),
      if (_avisar && !todasPagas) 'avisarDias': _avisarDias,
      'contas': [for (final p in parcelas) p.paraJson()],
    };
    final data = switch (tipo) {
      TipoCusto.multa || TipoCusto.estacionamento || TipoCusto.pedagio => _data,
      _ => parcelas.firstOrNull?.vencimento ?? _data,
    };
    await ref
        .read(servicoRepositorioProvider)
        .salvar(
          Servico(
            id: _original?.id ?? ref.read(geradorIdProvider)(),
            veiculoId: _original?.veiculoId ?? veiculo.id,
            tipo: TipoServico.custo,
            data: DateTime(data.year, data.month, data.day, 12),
            categorias: [tipo.name],
            detalhes: detalhes,
            valorCentavos: parcelas.fold(0, (soma, p) => soma + p.valorCentavos),
            lugarNome: tipo.rapido ? texto(_lugar) : null,
            formaPagamento: _forma,
            cartaoId: _forma == FormaPagamento.credito ? _cartaoId : null,
            observacao: texto(_observacao),
          ),
        );
    if (_forma != null) {
      await ref.read(preferenciasRepositorioProvider).definirUltimoPagamento('${_forma!.name}|${_cartaoId ?? ''}');
    }
    await apagarRascunhoSalvo();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_editando ? 'Custo atualizado.' : 'Custo salvo.')));
    sairLiberado();
  }

  Future<void> _excluir() async {
    final confirmou = await confirmarExclusao(
      context,
      titulo: 'Excluir este custo?',
      mensagem: 'As parcelas saem do painel e o gasto do mês é recalculado sem elas.',
    );
    if (!confirmou || !mounted) return;
    final repositorio = ref.read(servicoRepositorioProvider);
    final id = widget.custoId!;
    await repositorio.excluir(id);
    if (!mounted) return;
    avisarExclusao(context, 'Custo excluído.', () => repositorio.restaurar(id));
    sairLiberado();
  }

  Future<DateTime?> _escolherData(DateTime inicial, {DateTime? ate}) => showModalBottomSheet<DateTime>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    builder: (contexto) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
        child: CalendarDatePicker(
          initialDate: ate != null && inicial.isAfter(ate) ? ate : inicial,
          firstDate: DateTime(2000),
          lastDate: ate ?? DateTime(DateTime.now().year + 10),
          onDateChanged: (data) => Navigator.of(contexto).pop(DateUtils.dateOnly(data)),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final passos = _passos;
    final ultimo = _passo == passos.length - 1;
    final corpo = switch (_passo) {
      0 => _passoTipo(),
      1 when _tipo!.rapido => _passoRapido(),
      1 => _passoDetalhes(),
      _ => _passoPagamento(),
    };
    final rotuloBotao = ultimo
        ? (_editando ? 'Salvar alterações' : 'Salvar ${_tipo?.rotulo ?? ''}'.trim())
        : 'Continuar';

    return envolverSaida(
      Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: _passo == 0 || (_editando && _passo == 1) ? 'Fechar' : 'Voltar',
            icon: Icon(_passo == 0 || (_editando && _passo == 1) ? Icons.close : Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(_editando ? 'Editar custo' : (_passo == 0 ? 'Novo custo' : _tipo!.rotulo)),
          actions: [
            if (_editando) IconButton(tooltip: 'Excluir', icon: const Icon(Icons.delete_outline), onPressed: _excluir),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(child: Text('${_passo + 1} de ${passos.length}', style: textos.labelMedium)),
            ),
          ],
        ),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(
                      children: [
                        for (var i = 0; i < passos.length; i++) ...[
                          if (i > 0) const SizedBox(width: 4),
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 4,
                              decoration: BoxDecoration(
                                color: i <= _passo ? corCustos : esquema.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (rascunhoPendente != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AvisoRascunho(
                        rascunho: rascunhoPendente!,
                        aoContinuar: continuarRascunho,
                        aoDescartar: descartarRascunho,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(passos[_passo], style: textos.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  Expanded(child: corpo),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: FilledButton(
                      onPressed: _salvando ? null : _avancar,
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                      child: Text(rotuloBotao),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _passoTipo() {
    final esquema = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.05,
          children: [
            for (final tipo in TipoCusto.values)
              () {
                final marcado = _tipo == tipo;
                return Material(
                  color: marcado ? corCustos.withValues(alpha: 0.14) : esquema.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: marcado ? corCustos : esquema.outlineVariant, width: marcado ? 1.5 : 1),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => setState(() {
                      if (_tipo != tipo) _parcelas = [];
                      _tipo = tipo;
                    }),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(iconeDoCusto(tipo), color: corCustos, size: 26),
                          const SizedBox(height: 6),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(tipo.rotulo, maxLines: 1, style: Theme.of(context).textTheme.labelMedium),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }(),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _campoValor(String rotulo) => CampoComRotulo(
    rotulo: rotulo,
    child: TextField(
      controller: _valor,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => _mudar(() {}),
      decoration: InputDecoration(prefixText: 'R\$ ', errorText: _erroValor),
    ),
  );

  Widget _campoTexto(String rotulo, TextEditingController controle, String dica, {VoidCallback? aoMudar}) =>
      CampoComRotulo(
        rotulo: rotulo,
        child: TextField(
          controller: controle,
          textCapitalization: TextCapitalization.sentences,
          onChanged: aoMudar == null ? null : (_) => aoMudar(),
          decoration: InputDecoration(hintText: dica),
        ),
      );

  Widget _campoData(String rotulo, DateTime? data, ValueChanged<DateTime> aoMudar, {DateTime? ate}) => CampoComRotulo(
    rotulo: rotulo,
    child: Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final escolhida = await _escolherData(data ?? DateUtils.dateOnly(DateTime.now()), ate: ate);
          if (escolhida != null) aoMudar(escolhida);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Expanded(child: Text(data == null ? 'Escolher data' : Formato.dataCompleta(data))),
              const Icon(Icons.calendar_today_outlined, size: 18),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _chips<T>(String rotulo, List<(T, String)> opcoes, T selecionado, ValueChanged<T> aoEscolher) =>
      CampoComRotulo(
        rotulo: rotulo,
        child: Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            for (final (valor, texto) in opcoes)
              ChoiceChip(label: Text(texto), selected: selecionado == valor, onSelected: (_) => aoEscolher(valor)),
          ],
        ),
      );

  Widget _linha(List<Widget> filhos) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var i = 0; i < filhos.length; i++) ...[if (i > 0) const SizedBox(width: 10), Expanded(child: filhos[i])],
    ],
  );

  Widget _passoDetalhes() {
    final tipo = _tipo!;
    final anoAtual = DateTime.now().year;
    final hoje = DateUtils.dateOnly(DateTime.now());
    final espaco = const SizedBox(height: 12);
    final campos = <Widget>[
      switch (tipo) {
        TipoCusto.ipva || TipoCusto.licenciamento => _chips(
          'Ano',
          [
            for (final ano in [anoAtual - 1, anoAtual, anoAtual + 1]) (ano, '$ano'),
          ],
          _ano,
          (ano) => setState(() => _ano = ano),
        ),
        TipoCusto.seguro => _campoTexto('Seguradora (opcional)', _seguradora, 'Porto, Azul, Allianz...'),
        TipoCusto.multa => _campoTexto('Infração (opcional)', _infracao, 'Velocidade, estacionamento...'),
        TipoCusto.financiamento => _campoTexto('Banco ou consórcio (opcional)', _descricao, 'Ex.: Banco do Brasil'),
        _ => _campoTexto('Descrição (opcional)', _descricao, 'Ex.: transferência, vistoria'),
      },
      espaco,
      if (tipo == TipoCusto.multa) ...[
        _campoData('Data da infração', _data, (data) => setState(() => _data = data), ate: hoje),
        espaco,
      ],
      if (tipo == TipoCusto.financiamento) ...[
        _linha([
          _campoValor('Valor da parcela'),
          CampoComRotulo(
            rotulo: 'Parcela atual',
            child: TextField(
              controller: _parcelaAtual,
              keyboardType: TextInputType.number,
              onChanged: (_) => _mudar(() {}),
              decoration: const InputDecoration(hintText: '12'),
            ),
          ),
          CampoComRotulo(
            rotulo: 'De quantas',
            child: TextField(
              controller: _totalParcelas,
              keyboardType: TextInputType.number,
              onChanged: (_) => _mudar(() {}),
              decoration: const InputDecoration(hintText: '48'),
            ),
          ),
        ]),
      ] else if (tipo == TipoCusto.seguro) ...[
        _linha([
          _campoValor('Valor total'),
          CampoComRotulo(
            rotulo: 'Franquia (opcional)',
            child: TextField(
              controller: _franquia,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(prefixText: 'R\$ '),
            ),
          ),
        ]),
        espaco,
        _campoData('Fim da vigência', _vigenciaFim, (data) => setState(() => _vigenciaFim = data)),
      ] else
        _campoValor(tipo == TipoCusto.multa ? 'Valor da multa' : (tipo.temParcelas ? 'Valor total' : 'Valor')),
      espaco,
      if (tipo == TipoCusto.multa) ...[
        _chips<int?>(
          'Pontos na carteira',
          const [(null, 'Não sei'), (3, '3'), (4, '4'), (5, '5'), (7, '7')],
          _pontos,
          (pontos) => setState(() => _pontos = pontos),
        ),
        espaco,
        _chips(
          'Desconto',
          [for (final d in DescontoMulta.values) (d, d.rotulo)],
          _desconto,
          (desconto) => _mudar(() => _desconto = desconto),
        ),
        if (_desconto != DescontoMulta.nenhum && _valorCentavos > 0)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Valor a pagar: ${Formato.moeda(_valorAPagarCentavos)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: corCustos),
            ),
          ),
        espaco,
      ],
      if (tipo.temParcelas) ...[
        _chips(
          'Como vai pagar',
          [
            (1, 'À vista'),
            for (final vezes in tipo == TipoCusto.seguro ? const [2, 3, 4, 5, 6, 8, 10, 12] : const [2, 3, 4, 5])
              (vezes, '${vezes}x'),
          ],
          _vezes,
          (vezes) => _mudar(() => _vezes = vezes),
        ),
        espaco,
      ],
      _campoData(
        switch (tipo) {
          TipoCusto.financiamento => 'Vencimento da parcela atual',
          _ when tipo.temParcelas && _vezes > 1 => 'Vencimento da 1ª parcela',
          _ => 'Vencimento',
        },
        _vencimento,
        (data) => _mudar(() => _vencimento = data),
      ),
      espaco,
      _parcelasEditaveis(),
      const SizedBox(height: 12),
    ];
    return ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: campos);
  }

  Widget _parcelasEditaveis() {
    final textos = Theme.of(context).textTheme;
    final esquema = Theme.of(context).colorScheme;
    if (_parcelas.isEmpty || _valorCentavos <= 0) return const SizedBox.shrink();
    if (_parcelas.length == 1) {
      final parcela = _parcelas.single;
      return SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Já está pago'),
        subtitle: Text(
          parcela.paga ? 'Pago em ${Formato.dataCompleta(parcela.pagaEm!)}' : 'Fica no painel até você pagar',
        ),
        value: parcela.paga,
        onChanged: (paga) => setState(
          () => _parcelas = [
            parcela.copiar(pagaEm: paga ? DateUtils.dateOnly(DateTime.now()) : null, limparPagamento: !paga),
          ],
        ),
      );
    }
    final mostradas = _parcelas.take(12).toList();
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            for (final parcela in mostradas)
              CheckboxListTile(
                dense: true,
                controlAffinity: ListTileControlAffinity.trailing,
                title: Text('${parcela.numero}ª · ${Formato.dataCompleta(parcela.vencimento)}'),
                subtitle: Text(
                  '${Formato.moeda(parcela.valorCentavos)}${parcela.paga ? ' · paga' : ''}',
                  style: textos.bodySmall?.copyWith(color: esquema.onSurfaceVariant),
                ),
                value: parcela.paga,
                onChanged: (paga) => setState(
                  () => _parcelas = [
                    for (final p in _parcelas)
                      p.numero == parcela.numero
                          ? p.copiar(
                              pagaEm: paga == true ? DateUtils.dateOnly(p.vencimento) : null,
                              limparPagamento: paga != true,
                            )
                          : p,
                  ],
                ),
              ),
            if (_parcelas.length > mostradas.length)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'e mais ${_parcelas.length - mostradas.length} até ${Formato.dataCompleta(_parcelas.last.vencimento)}',
                  style: textos.bodySmall?.copyWith(color: esquema.onSurfaceVariant),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _calendario() {
    final hoje = DateUtils.dateOnly(DateTime.now());
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
        child: Column(
          children: [
            CalendarDatePicker(
              key: ValueKey(_versaoCalendario),
              initialDate: _data.isAfter(hoje) ? hoje : _data,
              firstDate: DateTime(2000),
              lastDate: hoje,
              onDateChanged: (data) => setState(() => _data = data),
            ),
            Wrap(
              spacing: 8,
              children: [
                for (final (dias, rotulo) in [(0, 'Hoje'), (1, 'Ontem')])
                  ChoiceChip(
                    label: Text(rotulo),
                    selected: _data == hoje.subtract(Duration(days: dias)),
                    onSelected: (_) => setState(() {
                      _data = hoje.subtract(Duration(days: dias));
                      _versaoCalendario++;
                    }),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _passoRapido() => ListView(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    children: [
      _campoValor('Valor'),
      const SizedBox(height: 12),
      _calendario(),
      const SizedBox(height: 12),
      _campoTexto(
        _tipo == TipoCusto.pedagio ? 'Praça ou rodovia (opcional)' : 'Onde (opcional)',
        _lugar,
        _tipo == TipoCusto.pedagio ? 'Ex.: Rodovia dos Bandeirantes' : 'Ex.: Shopping, centro',
      ),
      const SizedBox(height: 12),
      _pagamento(),
      const SizedBox(height: 12),
    ],
  );

  Widget _pagamento() => CampoPagamento(
    forma: _forma,
    cartaoId: _cartaoId,
    aoMudar: (forma, cartaoId) => setState(() {
      _forma = forma;
      _cartaoId = cartaoId;
    }),
  );

  Widget _passoPagamento() {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final pagas = _parcelas.where((p) => p.paga).length;
    final abertas = _parcelas.where((p) => !p.paga).toList();
    final total = _parcelas.fold(0, (soma, p) => soma + p.valorCentavos);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _pagamento(),
        const SizedBox(height: 12),
        if (abertas.isNotEmpty) ...[
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Avisar antes de vencer'),
            subtitle: Text(
              _parcelas.length > 1 ? '$_avisarDias dias antes de cada parcela' : '$_avisarDias dias antes',
            ),
            value: _avisar,
            onChanged: (valor) => setState(() => _avisar = valor),
          ),
          if (_avisar)
            Wrap(
              spacing: 6,
              children: [
                for (final dias in const [1, 3, 7, 15])
                  ChoiceChip(
                    label: Text(dias == 1 ? '1 dia' : '$dias dias'),
                    selected: _avisarDias == dias,
                    onSelected: (_) => setState(() => _avisarDias = dias),
                  ),
              ],
            ),
          const SizedBox(height: 12),
        ],
        _campoTexto('Observação (opcional)', _observacao, 'Algo para lembrar depois'),
        const SizedBox(height: 12),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Resumo', style: textos.bodySmall?.copyWith(color: esquema.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text(
                  [
                    _tituloResumo(),
                    Formato.moeda(total),
                    if (_parcelas.length > 1) 'em ${_parcelas.length}x',
                  ].join(' · '),
                  style: textos.bodyMedium,
                ),
                Text(
                  abertas.isEmpty
                      ? (_parcelas.length > 1 ? 'Todas pagas' : 'Pago')
                      : _parcelas.length == 1
                      ? 'A pagar até ${Formato.dataCompleta(abertas.first.vencimento)}'
                      : [
                          if (pagas > 0) pagas == 1 ? '1 paga' : '$pagas pagas',
                          '${abertas.length == 1 ? '1 a pagar' : '${abertas.length} a pagar'}, a próxima em ${Formato.dataCompleta(abertas.first.vencimento)}',
                        ].join(' · '),
                  style: textos.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  String _tituloResumo() {
    final tipo = _tipo!;
    final complemento = switch (tipo) {
      TipoCusto.ipva || TipoCusto.licenciamento => '$_ano',
      TipoCusto.seguro => _seguradora.text.trim(),
      TipoCusto.multa => _infracao.text.trim(),
      _ => _descricao.text.trim(),
    };
    if (complemento.isEmpty) return tipo.rotulo;
    return tipo.temAno ? '${tipo.rotulo} $complemento' : '${tipo.rotulo} · $complemento';
  }
}
