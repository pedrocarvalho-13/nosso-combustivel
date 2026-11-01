import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../data/postos/cliente_postos.dart';
import '../../domain/combustivel.dart';
import '../../domain/horario_posto.dart';
import '../../domain/tipo_gasolina.dart';
import 'lista_postos_perto.dart';

class LugaresView extends ConsumerStatefulWidget {
  const LugaresView({
    super.key,
    required this.tipoInicial,
    required this.combustiveis,
    this.combustivelInicial,
    this.tipoGasolinaInicial = TipoGasolina.comum,
    this.tiposPermitidos = const [TipoPosto.combustivel, TipoPosto.eletroposto],
    this.aoEscolher,
    this.aoIrAte,
  });

  final TipoPosto tipoInicial;
  final List<Combustivel> combustiveis;
  final Combustivel? combustivelInicial;
  final TipoGasolina tipoGasolinaInicial;
  final List<TipoPosto> tiposPermitidos;
  final void Function(PostoProximo posto)? aoEscolher;
  final void Function(PostoProximo posto)? aoIrAte;

  @override
  ConsumerState<LugaresView> createState() => _LugaresViewState();
}

class _LugaresViewState extends ConsumerState<LugaresView> {
  static const _raios = [1500, 3000, 5000];

  final _mapa = MapController();
  final _cartoes = PageController(viewportFraction: 0.86);
  late var _tipo = widget.tipoInicial;
  late var _combustivel = widget.combustivelInicial ?? widget.combustiveis.firstOrNull;
  late var _tipoGasolina = widget.tipoGasolinaInicial;
  Position? _posicao;
  PostosProximos? _resultado;
  String? _erro;
  var _carregando = true;
  var _raio = 1500;
  var _maisBarato = false;
  var _modoMapa = true;
  var _selecionado = 0;

  bool get _comPreco => _tipo == TipoPosto.combustivel;

  @override
  void initState() {
    super.initState();
    _buscar();
  }

  @override
  void dispose() {
    _cartoes.dispose();
    super.dispose();
  }

  double get _zoom => switch (_raio) {
    <= 1500 => 15,
    <= 3000 => 14,
    _ => 13,
  };

  Future<void> _buscar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final posicao = _posicao ?? await localizarUsuario();
      final resultado = await ref
          .read(clientePostosProvider)
          .proximos(latitude: posicao.latitude, longitude: posicao.longitude, raioMetros: _raio, tipo: _tipo);
      if (!mounted) return;
      setState(() {
        _posicao = posicao;
        _resultado = resultado;
        _selecionado = 0;
      });
      if (_cartoes.hasClients) _cartoes.jumpToPage(0);
      _centralizar();
    } on ErroPostos catch (erro) {
      if (mounted) setState(() => _erro = erro.mensagem);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _centralizar() {
    final posicao = _posicao;
    if (posicao == null || !_modoMapa) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _mapa.move(LatLng(posicao.latitude, posicao.longitude), _zoom);
      } catch (_) {}
    });
  }

  PrecoInformado? _preco(PostoProximo posto) =>
      _comPreco ? posto.precoDe(_combustivel, tipoGasolina: _tipoGasolina) : null;

  List<PostoProximo> get _lugares {
    final lista = [...?_resultado?.postos];
    if (_maisBarato) {
      lista.sort((a, b) {
        final precoA = _preco(a)?.precoLitro ?? double.infinity;
        final precoB = _preco(b)?.precoLitro ?? double.infinity;
        return precoA != precoB ? precoA.compareTo(precoB) : a.distanciaMetros.compareTo(b.distanciaMetros);
      });
    }
    return lista;
  }

  void _selecionar(int indice, {bool moverCartao = true}) {
    final lugares = _lugares;
    if (indice < 0 || indice >= lugares.length) return;
    setState(() => _selecionado = indice);
    final lugar = lugares[indice];
    try {
      _mapa.move(LatLng(lugar.latitude, lugar.longitude), _mapa.camera.zoom < 15 ? 15 : _mapa.camera.zoom);
    } catch (_) {}
    if (moverCartao && _cartoes.hasClients) {
      _cartoes.animateToPage(indice, duration: const Duration(milliseconds: 250), curve: Curves.easeOutCubic);
    }
  }

  void _abrirNoMapa(int indice) {
    setState(() {
      _modoMapa = true;
      _selecionado = indice;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_cartoes.hasClients) _cartoes.jumpToPage(indice);
      final lugar = _lugares[indice];
      try {
        _mapa.move(LatLng(lugar.latitude, lugar.longitude), 16);
      } catch (_) {}
    });
  }

  Future<void> _cadastrar() async {
    final posicao = _posicao;
    if (posicao == null) return;
    LatLng ponto = LatLng(posicao.latitude, posicao.longitude);
    var onde = 'no lugar onde você está agora';
    if (_modoMapa) {
      try {
        ponto = _mapa.camera.center;
        onde = 'no ponto do centro do mapa';
      } catch (_) {}
    }
    final dados = await pedirNovoLugar(context, tipo: _tipo, onde: onde);
    if (dados == null || !mounted) return;
    try {
      final novo = await ref
          .read(clientePostosProvider)
          .cadastrar(
            nome: dados.$1,
            bandeira: dados.$2,
            latitude: ponto.latitude,
            longitude: ponto.longitude,
            tipo: _tipo,
          );
      if (!mounted) return;
      final aoEscolher = widget.aoEscolher;
      if (aoEscolher != null) return aoEscolher(novo);
      await _buscar();
    } on ErroPostos catch (erro) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro.mensagem)));
    }
  }

  Future<void> _abrirFiltros() async {
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (contexto) => StatefulBuilder(
        builder: (contexto, atualizar) {
          void mudar(VoidCallback mudanca) {
            setState(mudanca);
            atualizar(() {});
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Filtros',
                    style: Theme.of(contexto).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (widget.tiposPermitidos.length > 1) ...[
                    const SizedBox(height: 16),
                    SegmentedButton<TipoPosto>(
                      segments: [
                        for (final tipo in widget.tiposPermitidos)
                          ButtonSegment(
                            value: tipo,
                            label: Text(nomeDoTipo(tipo, plural: true)),
                            icon: Icon(iconeDoLugar(tipo)),
                          ),
                      ],
                      selected: {_tipo},
                      showSelectedIcon: false,
                      onSelectionChanged: (selecao) {
                        mudar(() {
                          _tipo = selecao.first;
                          _maisBarato = false;
                        });
                        _buscar();
                      },
                    ),
                  ],
                  if (_tipo == TipoPosto.combustivel && widget.combustiveis.length > 1) ...[
                    const SizedBox(height: 12),
                    SegmentedButton<Combustivel>(
                      segments: [for (final c in widget.combustiveis) ButtonSegment(value: c, label: Text(c.rotulo))],
                      selected: {?_combustivel},
                      showSelectedIcon: false,
                      onSelectionChanged: (selecao) => mudar(() => _combustivel = selecao.first),
                    ),
                  ],
                  if (_tipo == TipoPosto.combustivel && _combustivel == Combustivel.gasolina) ...[
                    const SizedBox(height: 12),
                    SegmentedButton<TipoGasolina>(
                      segments: [for (final t in TipoGasolina.values) ButtonSegment(value: t, label: Text(t.rotulo))],
                      selected: {_tipoGasolina},
                      showSelectedIcon: false,
                      onSelectionChanged: (selecao) => mudar(() => _tipoGasolina = selecao.first),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(onPressed: () => Navigator.of(contexto).pop(), child: const Text('Pronto')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final titulo = '${nomeDoTipo(_tipo, plural: true)} perto';

    final cabecalho = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: esquema.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).maybePop()),
              Expanded(child: Text(titulo, style: Theme.of(context).textTheme.titleMedium)),
              IconButton(
                tooltip: 'Cadastrar aqui',
                icon: const Icon(Icons.add_location_alt_outlined),
                onPressed: _cadastrar,
              ),
              IconButton(
                tooltip: 'Filtros',
                icon: Icon(Icons.tune, color: esquema.primary),
                onPressed: _abrirFiltros,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Lista'), icon: Icon(Icons.view_list_outlined)),
            ButtonSegment(value: true, label: Text('Mapa'), icon: Icon(Icons.map_outlined)),
          ],
          selected: {_modoMapa},
          showSelectedIcon: false,
          style: SegmentedButton.styleFrom(backgroundColor: esquema.surfaceContainer),
          onSelectionChanged: (selecao) {
            setState(() => _modoMapa = selecao.first);
            if (_modoMapa) _selecionar(_selecionado.clamp(0, _lugares.isEmpty ? 0 : _lugares.length - 1));
          },
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final raio in _raios) ...[
                ChoiceChip(
                  label: Text(distanciaLegivel(raio)),
                  selected: _raio == raio,
                  onSelected: (_) {
                    if (_carregando || _raio == raio) return;
                    setState(() => _raio = raio);
                    _buscar();
                  },
                ),
                const SizedBox(width: 6),
              ],
              if (_comPreco && _lugares.any((p) => _preco(p) != null))
                FilterChip(
                  avatar: const Icon(Icons.savings_outlined, size: 18),
                  label: const Text('Mais barato'),
                  selected: _maisBarato,
                  onSelected: (valor) {
                    setState(() => _maisBarato = valor);
                    _selecionar(0);
                  },
                ),
            ],
          ),
        ),
      ],
    );

    return Scaffold(body: _modoMapa ? _corpoMapa(cabecalho) : _corpoLista(cabecalho));
  }

  Widget _estado() {
    if (_carregando) {
      return Center(
        heightFactor: 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text('Procurando ${nomeDoTipo(_tipo, plural: true).toLowerCase()}...'),
          ],
        ),
      );
    }
    final erro = _erro;
    if (erro != null) {
      return Center(
        heightFactor: 1,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(erro, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: _buscar, child: const Text('Tentar de novo')),
            ],
          ),
        ),
      );
    }
    return Center(
      heightFactor: 1,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Nenhum ${nomeDoTipo(_tipo)} encontrado neste raio. Tente um raio maior ou cadastre um.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _corpoLista(Widget cabecalho) {
    final lugares = _lugares;
    final esquema = Theme.of(context).colorScheme;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(padding: const EdgeInsets.fromLTRB(12, 12, 12, 4), child: cabecalho),
          if (_resultado?.buscaCompleta == false)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'A busca está lenta agora. Mostrando só os que já conhecemos.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: esquema.onSurfaceVariant),
              ),
            ),
          Expanded(
            child: _carregando || _erro != null || lugares.isEmpty
                ? _estado()
                : ListView.builder(
                    itemCount: lugares.length,
                    itemBuilder: (context, indice) {
                      final lugar = lugares[indice];
                      final detalhes = [
                        if (lugar.bandeira != null && lugar.bandeira != lugar.nome) lugar.bandeira!,
                        if (lugar.endereco != null) lugar.endereco!,
                      ].join(' · ');
                      final horario = HorarioPosto.legivel(lugar.horario);
                      return ListTile(
                        selected: indice == _selecionado,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        leading: Icon(iconeDoLugar(_tipo), color: esquema.primary),
                        title: Text(lugar.nome),
                        subtitle: Text(
                          [if (detalhes.isNotEmpty) detalhes, ?horario].join('\n'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: LadoPreco(
                          distancia: distanciaLegivel(lugar.distanciaMetros),
                          preco: _preco(lugar),
                          mostrarPreco: _comPreco,
                        ),
                        onTap: () => _abrirNoMapa(indice),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _corpoMapa(Widget cabecalho) {
    final esquema = Theme.of(context).colorScheme;
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final posicao = _posicao;
    final lugares = _lugares;
    final centro = posicao == null ? const LatLng(-14.235, -51.925) : LatLng(posicao.latitude, posicao.longitude);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapa,
          options: MapOptions(
            initialCenter: centro,
            initialZoom: posicao == null ? 4 : _zoom,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'nosso_combustivel',
              tileBuilder: escuro ? darkModeTileBuilder : null,
            ),
            MarkerLayer(
              markers: [
                if (posicao != null)
                  Marker(
                    point: LatLng(posicao.latitude, posicao.longitude),
                    width: 22,
                    height: 22,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A9BE8),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
                for (final (indice, lugar) in lugares.indexed)
                  Marker(
                    point: LatLng(lugar.latitude, lugar.longitude),
                    width: 84,
                    height: 34,
                    alignment: Alignment.topCenter,
                    child: _Pino(
                      texto: _comPreco
                          ? (_preco(lugar) == null ? '--' : precoLegivel(_preco(lugar)!.precoLitro))
                          : null,
                      icone: iconeDoLugar(_tipo),
                      selecionado: indice == _selecionado,
                      aoTocar: () => _selecionar(indice),
                    ),
                  ),
              ],
            ),
            const SimpleAttributionWidget(source: Text('OpenStreetMap'), alignment: Alignment.bottomLeft),
          ],
        ),
        SafeArea(
          child: Padding(padding: const EdgeInsets.fromLTRB(12, 12, 12, 0), child: cabecalho),
        ),
        if (_carregando || _erro != null || lugares.isEmpty)
          Positioned(
            left: 16,
            right: 16,
            bottom: 32,
            child: Material(
              color: esquema.surfaceContainer,
              borderRadius: BorderRadius.circular(18),
              child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: _estado()),
            ),
          )
        else ...[
          Positioned(
            right: 16,
            bottom: 196,
            child: FloatingActionButton.small(
              heroTag: 'centralizar',
              tooltip: 'Voltar para onde estou',
              backgroundColor: esquema.surfaceContainer,
              onPressed: () {
                final p = _posicao;
                if (p != null) _mapa.move(LatLng(p.latitude, p.longitude), _zoom);
              },
              child: const Icon(Icons.my_location),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            height: 164,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad}),
              child: PageView.builder(
                controller: _cartoes,
                itemCount: lugares.length,
                onPageChanged: (indice) => _selecionar(indice, moverCartao: false),
                itemBuilder: (context, indice) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _CartaoLugar(
                    lugar: lugares[indice],
                    tipo: _tipo,
                    preco: _preco(lugares[indice]),
                    selecionado: indice == _selecionado,
                    aoEscolher: widget.aoEscolher,
                    aoIrAte: widget.aoIrAte,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Pino extends StatelessWidget {
  const _Pino({required this.texto, required this.icone, required this.selecionado, required this.aoTocar});

  final String? texto;
  final IconData icone;
  final bool selecionado;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final fundo = selecionado ? esquema.primary : esquema.surfaceContainerHigh;
    final frente = selecionado ? esquema.onPrimary : esquema.primary;
    return Align(
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        onTap: aoTocar,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: fundo,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: esquema.primary, width: 1.5),
            boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: texto == null
              ? Icon(icone, size: 16, color: frente)
              : Text(
                  texto!,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: frente, fontWeight: FontWeight.w700),
                ),
        ),
      ),
    );
  }
}

class _CartaoLugar extends StatelessWidget {
  const _CartaoLugar({
    required this.lugar,
    required this.tipo,
    required this.preco,
    required this.selecionado,
    this.aoEscolher,
    this.aoIrAte,
  });

  final PostoProximo lugar;
  final TipoPosto tipo;
  final PrecoInformado? preco;
  final bool selecionado;
  final void Function(PostoProximo posto)? aoEscolher;
  final void Function(PostoProximo posto)? aoIrAte;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final horario = HorarioPosto.legivel(lugar.horario);
    final linha = [distanciaLegivel(lugar.distanciaMetros), ?horario].join(' · ');
    final preco = this.preco;
    final escolher = aoEscolher;
    final irAte = aoIrAte;

    return Material(
      color: esquema.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: selecionado ? esquema.primary : esquema.outlineVariant, width: selecionado ? 1.5 : 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lugar.nome, maxLines: 1, overflow: TextOverflow.ellipsis, style: textos.titleMedium),
                      Text(linha, maxLines: 1, overflow: TextOverflow.ellipsis, style: textos.bodySmall),
                    ],
                  ),
                ),
                if (tipo == TipoPosto.combustivel)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        preco == null ? 'R\$ --,--' : precoLegivel(preco.precoLitro),
                        style: textos.titleMedium?.copyWith(
                          color: preco == null ? esquema.outline : esquema.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(preco == null ? 'sem preço' : idadeDoPreco(preco.data), style: textos.labelSmall),
                    ],
                  ),
              ],
            ),
            if (lugar.endereco != null) ...[
              const SizedBox(height: 4),
              Text(lugar.endereco!, maxLines: 1, overflow: TextOverflow.ellipsis, style: textos.bodySmall),
            ],
            const Spacer(),
            Row(
              children: [
                if (escolher != null) ...[
                  Expanded(
                    child: FilledButton(onPressed: () => escolher(lugar), child: const Text('Escolher este')),
                  ),
                  if (irAte != null) const SizedBox(width: 8),
                ],
                if (irAte != null)
                  Expanded(
                    child: escolher == null
                        ? FilledButton.icon(
                            onPressed: () => irAte(lugar),
                            icon: const Icon(Icons.navigation_outlined, size: 18),
                            label: const Text('Ir até lá'),
                          )
                        : OutlinedButton(onPressed: () => irAte(lugar), child: const Text('Ir até lá')),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
