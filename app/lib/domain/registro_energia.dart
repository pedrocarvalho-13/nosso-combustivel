import 'combustivel.dart';

enum LocalRecarga {
  casa('Casa'),
  trabalho('Trabalho'),
  eletroposto('Eletroposto');

  const LocalRecarga(this.rotulo);

  final String rotulo;
}

sealed class RegistroEnergia {
  const RegistroEnergia({
    required this.id,
    required this.veiculoId,
    required this.data,
    required this.odometro,
    required this.valorCentavos,
    required this.completo,
  });

  final String id;
  final String veiculoId;
  final DateTime data;
  final int odometro;
  final int valorCentavos;
  final bool completo;

  double get quantidade;
}

class Abastecimento extends RegistroEnergia {
  const Abastecimento({
    required super.id,
    required super.veiculoId,
    required super.data,
    required super.odometro,
    required super.valorCentavos,
    required this.combustivel,
    required this.litros,
    required this.precoLitro,
    required bool tanqueCheio,
    this.posto,
  }) : super(completo: tanqueCheio);

  final Combustivel combustivel;
  final double litros;
  final double precoLitro;
  final String? posto;

  bool get tanqueCheio => completo;

  @override
  double get quantidade => litros;
}

class Recarga extends RegistroEnergia {
  const Recarga({
    required super.id,
    required super.veiculoId,
    required super.data,
    required super.odometro,
    required super.valorCentavos,
    required this.local,
    required this.kwh,
    required this.precoKwh,
    required bool cargaCompleta,
  }) : super(completo: cargaCompleta);

  final LocalRecarga local;
  final double kwh;
  final double precoKwh;

  bool get cargaCompleta => completo;

  @override
  double get quantidade => kwh;
}
