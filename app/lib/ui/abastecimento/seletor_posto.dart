import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/formato.dart';
import '../../data/postos/cliente_postos.dart';
import '../../domain/combustivel.dart';

class PostoEscolhido {
  const PostoEscolhido({required this.id, required this.nome});

  final String id;
  final String nome;
}

Future<PostoEscolhido?> escolherPosto(BuildContext context, {Combustivel? combustivel}) =>
    showModalBottomSheet<PostoEscolhido>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _SeletorPosto(combustivel: combustivel),
    );

class _SeletorPosto extends ConsumerStatefulWidget {
  const _SeletorPosto({this.combustivel});

  final Combustivel? combustivel;

  @override
  ConsumerState<_SeletorPosto> createState() => _SeletorPostoState();
}

class _SeletorPostoState extends ConsumerState<_SeletorPosto> {
  Position? _posicao;
  PostosProximos? _resultado;
  String? _erro;
  var _carregando = true;
  var _cadastrando = false;
  var _raio = 1500;
  var _maisBarato = false;

  static const _raios = [1500, 3000, 5000];

  @override
  void initState() {
    super.initState();
    _buscar();
  }

  Future<void> _buscar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final posicao = _posicao ?? await _localizar();
      final resultado = await ref
          .read(clientePostosProvider)
          .proximos(latitude: posicao.latitude, longitude: posicao.longitude, raioMetros: _raio);
      if (!mounted) return;
      setState(() {
        _posicao = posicao;
        _resultado = resultado;
      });
    } on ErroPostos catch (erro) {
      if (mounted) setState(() => _erro = erro.mensagem);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<Position> _localizar() async {
    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) permissao = await Geolocator.requestPermission();
    if (permissao == LocationPermission.denied || permissao == LocationPermission.deniedForever) {
      throw const ErroPostos('Permita o acesso à localização para ver os postos perto de você.');
    }
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 15)),
      );
    } catch (_) {
      throw const ErroPostos('Não deu para descobrir onde você está. Tente de novo.');
    }
  }

  Future<void> _cadastrar() async {
    final posicao = _posicao;
    if (posicao == null) return;
    final dados = await showDialog<(String, String?)>(context: context, builder: (_) => const _DialogoNovoPosto());
    if (dados == null || !mounted) return;
    setState(() => _cadastrando = true);
    try {
      final posto = await ref.read(clientePostosProvider).cadastrar(
            nome: dados.$1,
            bandeira: dados.$2,
            latitude: posicao.latitude,
            longitude: posicao.longitude,
          );
      if (mounted) Navigator.of(context).pop(PostoEscolhido(id: posto.id, nome: posto.nome));
    } on ErroPostos catch (erro) {
      if (!mounted) return;
      setState(() => _cadastrando = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro.mensagem)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final combustivel = widget.combustivel;
    final postos = [...?_resultado?.postos];
    if (_maisBarato) {
      postos.sort((a, b) {
        final precoA = a.precoDe(combustivel)?.precoLitro ?? double.infinity;
        final precoB = b.precoDe(combustivel)?.precoLitro ?? double.infinity;
        return precoA != precoB ? precoA.compareTo(precoB) : a.distanciaMetros.compareTo(b.distanciaMetros);
      });
    }
    final algumPreco = combustivel != null && postos.any((p) => p.precoDe(combustivel) != null);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.75),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text('Postos perto de você', style: textos.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final raio in _raios)
                    ChoiceChip(
                      label: Text('Até ${_distancia(raio)}'),
                      selected: _raio == raio,
                      onSelected: _carregando || _raio == raio
                          ? null
                          : (_) {
                              setState(() => _raio = raio);
                              _buscar();
                            },
                    ),
                  if (algumPreco)
                    FilterChip(
                      avatar: const Icon(Icons.savings_outlined, size: 18),
                      label: Text('Mais barato (${combustivel.rotulo.toLowerCase()})'),
                      selected: _maisBarato,
                      onSelected: (valor) => setState(() => _maisBarato = valor),
                    ),
                ],
              ),
            ),
            if (_carregando)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [CircularProgressIndicator(), SizedBox(height: 12), Text('Procurando postos...')],
                ),
              )
            else if (_erro != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  children: [
                    Text(_erro!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    OutlinedButton(onPressed: _buscar, child: const Text('Tentar de novo')),
                  ],
                ),
              )
            else ...[
              if (_resultado?.buscaCompleta == false)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  child: Text(
                    'A busca de postos está lenta agora. Mostrando só os que já conhecemos.',
                    style: textos.bodySmall?.copyWith(color: esquema.onSurfaceVariant),
                  ),
                ),
              if (postos.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Text('Nenhum posto encontrado neste raio. Tente um raio maior.', textAlign: TextAlign.center),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: postos.length,
                    itemBuilder: (context, indice) {
                      final posto = postos[indice];
                      final detalhes = [
                        if (posto.bandeira != null && posto.bandeira != posto.nome) posto.bandeira!,
                        if (posto.endereco != null) posto.endereco!,
                      ].join(' · ');
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                        leading: Icon(Icons.local_gas_station_outlined, color: esquema.primary),
                        title: Text(posto.nome),
                        subtitle: detalhes.isEmpty ? null : Text(detalhes, maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: _Lado(
                          distancia: _distancia(posto.distanciaMetros),
                          preco: posto.precoDe(combustivel),
                        ),
                        onTap: () => Navigator.of(context).pop(PostoEscolhido(id: posto.id, nome: posto.nome)),
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: TextButton.icon(
                  onPressed: _cadastrando ? null : _cadastrar,
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Text('Não está na lista? Cadastrar este posto'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _distancia(int metros) =>
      metros < 1000 ? '$metros m' : '${(metros / 1000).toStringAsFixed(1).replaceAll('.', ',')} km';
}

class _DialogoNovoPosto extends StatefulWidget {
  const _DialogoNovoPosto();

  @override
  State<_DialogoNovoPosto> createState() => _DialogoNovoPostoState();
}

class _DialogoNovoPostoState extends State<_DialogoNovoPosto> {
  final _nome = TextEditingController();
  final _bandeira = TextEditingController();
  String? _erro;

  @override
  void dispose() {
    _nome.dispose();
    _bandeira.dispose();
    super.dispose();
  }

  void _confirmar() {
    final nome = _nome.text.trim();
    if (nome.isEmpty) return setState(() => _erro = 'Informe o nome do posto.');
    final bandeira = _bandeira.text.trim();
    Navigator.of(context).pop((nome, bandeira.isEmpty ? null : bandeira));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cadastrar posto'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Ele fica salvo no lugar onde você está agora.'),
          const SizedBox(height: 12),
          TextField(
            controller: _nome,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: 'Nome do posto', errorText: _erro),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _bandeira,
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => _confirmar(),
            decoration: const InputDecoration(labelText: 'Bandeira (opcional)', hintText: 'Shell, Ipiranga, BR...'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        FilledButton(onPressed: _confirmar, child: const Text('Cadastrar')),
      ],
    );
  }
}

class _Lado extends StatelessWidget {
  const _Lado({required this.distancia, this.preco});

  final String distancia;
  final PrecoInformado? preco;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final preco = this.preco;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (preco != null) ...[
          Text(
            'R\$ ${Formato.paraCampo(preco.precoLitro, casas: 2)}',
            style: textos.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: esquema.primary),
          ),
          Text('${_idade(preco.data)} · $distancia', style: textos.labelSmall?.copyWith(color: esquema.onSurfaceVariant)),
        ] else ...[
          Text('R\$ --,--', style: textos.titleSmall?.copyWith(color: esquema.outline)),
          Text('sem preço · $distancia', style: textos.labelSmall?.copyWith(color: esquema.onSurfaceVariant)),
        ],
      ],
    );
  }

  static String _idade(DateTime data) {
    final dias = DateTime.now().difference(data).inDays;
    return switch (dias) {
      <= 0 => 'hoje',
      1 => 'ontem',
      _ => 'há $dias dias',
    };
  }
}
