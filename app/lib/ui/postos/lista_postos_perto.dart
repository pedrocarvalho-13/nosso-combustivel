import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/formato.dart';
import '../../data/postos/cliente_postos.dart';
import '../comum/campo_com_rotulo.dart';

String distanciaLegivel(int metros) {
  if (metros < 1000) return '$metros m';
  if (metros % 1000 == 0) return '${metros ~/ 1000} km';
  if (metros >= 10000) return '${(metros / 1000).round()} km';
  return '${(metros / 1000).toStringAsFixed(1).replaceAll('.', ',')} km';
}

String precoLegivel(double preco) => 'R\$ ${Formato.paraCampo(preco, casas: 2)}';

String idadeDoPreco(DateTime data) {
  final dias = DateTime.now().difference(data).inDays;
  return switch (dias) {
    <= 0 => 'hoje',
    1 => 'ontem',
    _ => 'há $dias dias',
  };
}

IconData iconeDoLugar(TipoPosto tipo) => switch (tipo) {
  TipoPosto.combustivel => Icons.local_gas_station_outlined,
  TipoPosto.eletroposto => Icons.ev_station_outlined,
  TipoPosto.oficina => Icons.build_outlined,
  TipoPosto.estetica => Icons.local_car_wash_outlined,
};

String nomeDoTipo(TipoPosto tipo, {bool plural = false}) => switch (tipo) {
  TipoPosto.combustivel => plural ? 'Postos' : 'posto',
  TipoPosto.eletroposto => plural ? 'Eletropostos' : 'eletroposto',
  TipoPosto.oficina => plural ? 'Oficinas' : 'oficina',
  TipoPosto.estetica => plural ? 'Estéticas' : 'estética',
};

Future<Position> localizarUsuario() async {
  var permissao = await Geolocator.checkPermission();
  if (permissao == LocationPermission.denied) permissao = await Geolocator.requestPermission();
  if (permissao == LocationPermission.denied || permissao == LocationPermission.deniedForever) {
    throw const ErroPostos('Permita o acesso à localização para ver os lugares perto de você.');
  }
  try {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 15)),
    );
  } catch (_) {
    throw const ErroPostos('Não deu para descobrir onde você está. Tente de novo.');
  }
}

Future<(String, String?)?> pedirNovoLugar(BuildContext context, {required TipoPosto tipo, required String onde}) =>
    showModalBottomSheet<(String, String?)>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _NovoLugar(tipo: tipo, onde: onde),
    );

class _NovoLugar extends StatefulWidget {
  const _NovoLugar({required this.tipo, required this.onde});

  final TipoPosto tipo;
  final String onde;

  @override
  State<_NovoLugar> createState() => _NovoLugarState();
}

class _NovoLugarState extends State<_NovoLugar> {
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
    if (nome.isEmpty) return setState(() => _erro = 'Informe o nome.');
    final bandeira = _bandeira.text.trim();
    Navigator.of(context).pop((nome, bandeira.isEmpty ? null : bandeira));
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final nome = nomeDoTipo(widget.tipo);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 16 + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Cadastrar $nome', style: textos.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              'Ele fica salvo ${widget.onde}.',
              style: textos.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            CampoComRotulo(
              rotulo: 'Nome do $nome',
              child: TextField(
                controller: _nome,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(errorText: _erro),
              ),
            ),
            const SizedBox(height: 12),
            CampoComRotulo(
              rotulo: widget.tipo == TipoPosto.combustivel ? 'Bandeira (opcional)' : 'Rede (opcional)',
              child: TextField(
                controller: _bandeira,
                textCapitalization: TextCapitalization.words,
                onSubmitted: (_) => _confirmar(),
                decoration: InputDecoration(
                  hintText: widget.tipo == TipoPosto.eletroposto
                      ? 'Shell Recharge, Zletric...'
                      : 'Shell, Ipiranga, BR...',
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: _confirmar, child: const Text('Cadastrar')),
          ],
        ),
      ),
    );
  }
}

class LadoPreco extends StatelessWidget {
  const LadoPreco({super.key, required this.distancia, required this.mostrarPreco, this.preco});

  final String distancia;
  final bool mostrarPreco;
  final PrecoInformado? preco;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final preco = this.preco;
    if (!mostrarPreco) return Text(distancia, style: textos.labelMedium);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (preco != null) ...[
          Text(
            precoLegivel(preco.precoLitro),
            style: textos.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: esquema.primary),
          ),
          Text(
            '${idadeDoPreco(preco.data)} · $distancia',
            style: textos.labelSmall?.copyWith(color: esquema.onSurfaceVariant),
          ),
        ] else ...[
          Text('R\$ --,--', style: textos.titleSmall?.copyWith(color: esquema.outline)),
          Text('sem preço · $distancia', style: textos.labelSmall?.copyWith(color: esquema.onSurfaceVariant)),
        ],
      ],
    );
  }
}
