import 'combustivel.dart';
import 'tipo_energia.dart';

class Veiculo {
  const Veiculo({
    required this.id,
    required this.apelido,
    required this.marca,
    required this.modelo,
    this.ano,
    this.codigoFipe,
    required this.tipoEnergia,
    required this.combustiveis,
    this.capacidadeTanqueL,
    this.capacidadeBateriaKwh,
    required this.odometroInicial,
  });

  final String id;
  final String apelido;
  final String marca;
  final String modelo;
  final int? ano;
  final String? codigoFipe;
  final TipoEnergia tipoEnergia;
  final List<Combustivel> combustiveis;
  final double? capacidadeTanqueL;
  final double? capacidadeBateriaKwh;
  final int odometroInicial;

  bool get flex => combustiveis.contains(Combustivel.gasolina) && combustiveis.contains(Combustivel.etanol);

  String get descricaoEnergia => descreverEnergia(tipoEnergia, combustiveis);

  static String descreverEnergia(TipoEnergia tipo, List<Combustivel> combustiveis) {
    if (tipo == TipoEnergia.eletrico || combustiveis.isEmpty) return tipo.rotulo;
    return '${tipo.rotulo} · ${rotuloCombustiveis(combustiveis)}';
  }

  static String rotuloCombustiveis(List<Combustivel> combustiveis) {
    final flex = combustiveis.contains(Combustivel.gasolina) && combustiveis.contains(Combustivel.etanol);
    if (flex) return 'Flex';
    if (combustiveis.every((c) => c.diesel)) return 'Diesel';
    return combustiveis.map((c) => c.rotulo).join(' e ');
  }
}
