import 'package:flutter_test/flutter_test.dart';
import 'package:nosso_combustivel/core/tema/paleta_energia.dart';
import 'package:nosso_combustivel/domain/tipo_energia.dart';

void main() {
  test('combustão usa a paleta laranja', () {
    expect(PaletaEnergia.de(TipoEnergia.combustao), PaletaEnergia.combustao);
  });

  test('híbrido comum e plug-in usam a paleta azul', () {
    expect(PaletaEnergia.de(TipoEnergia.hibridoComum), PaletaEnergia.hibrido);
    expect(PaletaEnergia.de(TipoEnergia.hibridoPlugin), PaletaEnergia.hibrido);
  });

  test('elétrico usa a paleta verde', () {
    expect(PaletaEnergia.de(TipoEnergia.eletrico), PaletaEnergia.eletrico);
  });
}
