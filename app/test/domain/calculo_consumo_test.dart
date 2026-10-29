import 'package:flutter_test/flutter_test.dart';
import 'package:nosso_combustivel/domain/calculos/calculo_consumo.dart';
import 'package:nosso_combustivel/domain/combustivel.dart';
import 'package:nosso_combustivel/domain/registro_energia.dart';

Abastecimento abastecimento(
  String id,
  int odometro,
  double litros, {
  bool cheio = true,
  Combustivel combustivel = Combustivel.gasolina,
  int dia = 1,
}) =>
    Abastecimento(
      id: id,
      veiculoId: 'v1',
      data: DateTime(2026, 10, dia),
      odometro: odometro,
      valorCentavos: 0,
      combustivel: combustivel,
      litros: litros,
      precoLitro: 6,
      tanqueCheio: cheio,
    );

void main() {
  test('o primeiro tanque cheio só marca o ponto de partida', () {
    final ciclos = CalculoConsumo.ciclosDeAbastecimento([abastecimento('a', 1000, 40)]);

    expect(ciclos, isEmpty);
  });

  test('ciclo entre dois tanques cheios soma os parciais do meio', () {
    final ciclos = CalculoConsumo.ciclosDeAbastecimento([
      abastecimento('a', 1000, 40, dia: 1),
      abastecimento('b', 1200, 10, cheio: false, dia: 5),
      abastecimento('c', 1480, 30, dia: 9),
    ]);

    expect(ciclos, hasLength(1));
    expect(ciclos.single.distanciaKm, 480);
    expect(ciclos.single.quantidade, 40);
    expect(ciclos.single.rendimento, 12);
    expect(ciclos.single.registroId, 'c');
  });

  test('ciclo com etanol e gasolina misturados fica de fora da média por combustível', () {
    final ciclos = CalculoConsumo.ciclosDeAbastecimento([
      abastecimento('a', 1000, 40, dia: 1),
      abastecimento('b', 1100, 10, cheio: false, combustivel: Combustivel.etanol, dia: 3),
      abastecimento('c', 1400, 30, dia: 8),
    ]);

    expect(ciclos.single.misto, isTrue);
    expect(CalculoConsumo.media(ciclos, combustivel: Combustivel.gasolina), isNull);
  });

  test('média ponderada pela distância dos ciclos do mesmo combustível', () {
    final ciclos = CalculoConsumo.ciclosDeAbastecimento([
      abastecimento('a', 1000, 40, combustivel: Combustivel.etanol, dia: 1),
      abastecimento('b', 1300, 30, combustivel: Combustivel.etanol, dia: 8),
      abastecimento('c', 1640, 40, combustivel: Combustivel.etanol, dia: 15),
    ]);

    expect(CalculoConsumo.media(ciclos, combustivel: Combustivel.etanol), closeTo(640 / 70, 0.0001));
  });

  test('alerta quando o ciclo fica 15% abaixo da média dos anteriores', () {
    final ciclos = CalculoConsumo.ciclosDeAbastecimento([
      abastecimento('a', 1000, 40, dia: 1),
      abastecimento('b', 1480, 40, dia: 8),
      abastecimento('c', 1960, 40, dia: 15),
      abastecimento('d', 2360, 40, dia: 22),
    ]);

    expect(CalculoConsumo.abaixoDaMedia(ciclos[1], ciclos), isFalse);
    expect(CalculoConsumo.abaixoDaMedia(ciclos[2], ciclos), isTrue);
  });

  test('recargas até 100% formam ciclos em km/kWh', () {
    final ciclos = CalculoConsumo.ciclosDeRecarga([
      Recarga(id: 'r1', veiculoId: 'v1', data: DateTime(2026, 10, 1), odometro: 500, valorCentavos: 0, local: LocalRecarga.casa, kwh: 40, precoKwh: 0.9, cargaCompleta: true),
      Recarga(id: 'r2', veiculoId: 'v1', data: DateTime(2026, 10, 6), odometro: 772, valorCentavos: 0, local: LocalRecarga.casa, kwh: 40, precoKwh: 0.9, cargaCompleta: true),
    ]);

    expect(ciclos.single.rendimento, closeTo(6.8, 0.0001));
    expect(ciclos.single.combustivel, isNull);
  });
}
