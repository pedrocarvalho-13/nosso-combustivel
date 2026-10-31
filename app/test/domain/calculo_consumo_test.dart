import 'package:flutter_test/flutter_test.dart';
import 'package:nosso_combustivel/domain/calculos/calculo_consumo.dart';
import 'package:nosso_combustivel/domain/combustivel.dart';
import 'package:nosso_combustivel/domain/registro_energia.dart';

Abastecimento abastecimento(
  String id,
  int odometro,
  double litros, {
  bool cheio = false,
  Combustivel combustivel = Combustivel.gasolina,
  int dia = 1,
  int centavos = 0,
}) =>
    Abastecimento(
      id: id,
      veiculoId: 'v1',
      data: DateTime(2026, 10, dia),
      odometro: odometro,
      valorCentavos: centavos,
      combustivel: combustivel,
      litros: litros,
      precoLitro: 6,
      tanqueCheio: cheio,
    );

void main() {
  test('um abastecimento sozinho ainda não tem consumo', () {
    expect(CalculoConsumo.ciclosDeAbastecimento([abastecimento('a', 1000, 40)]), isEmpty);
  });

  test('cada trecho vai de um abastecimento até o seguinte, mesmo parcial', () {
    final ciclos = CalculoConsumo.ciclosDeAbastecimento([
      abastecimento('a', 97128, 14.3, dia: 24),
      abastecimento('b', 97282, 7.2, dia: 29),
    ]);

    expect(ciclos, hasLength(1));
    expect(ciclos.single.registroId, 'a');
    expect(ciclos.single.distanciaKm, 154);
    expect(ciclos.single.rendimento, closeTo(154 / 14.3, 0.0001));
    expect(ciclos.single.exato, isFalse);
  });

  test('média junta os km e os litros dos trechos do mesmo combustível', () {
    final ciclos = CalculoConsumo.ciclosDeAbastecimento([
      abastecimento('a', 1000, 30, combustivel: Combustivel.etanol, dia: 1),
      abastecimento('b', 1300, 40, combustivel: Combustivel.etanol, dia: 8),
      abastecimento('c', 1640, 10, combustivel: Combustivel.gasolina, dia: 15),
    ]);

    expect(CalculoConsumo.media(ciclos, combustivel: Combustivel.etanol), closeTo(640 / 70, 0.0001));
    expect(CalculoConsumo.media(ciclos, combustivel: Combustivel.gasolina), isNull);
  });

  test('média desde uma data considera só os trechos que terminaram depois dela', () {
    final ciclos = CalculoConsumo.ciclosDeAbastecimento([
      abastecimento('a', 1000, 20, dia: 1),
      abastecimento('b', 1200, 10, dia: 10),
      abastecimento('c', 1350, 10, dia: 20),
    ]);

    final janela = CalculoConsumo.mediaDesde(ciclos, DateTime(2026, 10, 15), qualquerCombustivel: true)!;
    expect(janela.km, 150);
    expect(janela.media, closeTo(15, 0.0001));
    expect(CalculoConsumo.mediaDesde(ciclos, DateTime(2026, 11, 1), qualquerCombustivel: true), isNull);
  });

  test('últimos trechos vêm em ordem e limitados à quantidade pedida', () {
    final ciclos = CalculoConsumo.ciclosDeAbastecimento([
      for (var i = 0; i < 8; i++) abastecimento('$i', 1000 + i * 100, 10, dia: i + 1),
    ]);

    final ultimos = CalculoConsumo.ultimos(ciclos, 5, qualquerCombustivel: true);
    expect(ultimos.map((c) => c.registroId), ['2', '3', '4', '5', '6']);
  });

  test('alerta só compara trechos entre dois tanques cheios', () {
    final cheios = CalculoConsumo.ciclosDeAbastecimento([
      abastecimento('a', 1000, 40, cheio: true, dia: 1),
      abastecimento('b', 1480, 40, cheio: true, dia: 8),
      abastecimento('c', 1960, 40, cheio: true, dia: 15),
      abastecimento('d', 2360, 40, cheio: true, dia: 22),
    ]);
    expect(CalculoConsumo.abaixoDaMedia(cheios[1], cheios), isFalse);
    expect(CalculoConsumo.abaixoDaMedia(cheios[2], cheios), isTrue);

    final parciais = CalculoConsumo.ciclosDeAbastecimento([
      abastecimento('a', 1000, 40, dia: 1),
      abastecimento('b', 1480, 40, dia: 8),
      abastecimento('c', 1600, 40, dia: 15),
    ]);
    expect(CalculoConsumo.abaixoDaMedia(parciais[1], parciais), isFalse);
  });

  test('recargas formam trechos em km/kWh', () {
    final ciclos = CalculoConsumo.ciclosDeRecarga([
      Recarga(id: 'r1', veiculoId: 'v1', data: DateTime(2026, 10, 1), odometro: 500, valorCentavos: 0, local: LocalRecarga.casa, kwh: 40, precoKwh: 0.9, cargaCompleta: true),
      Recarga(id: 'r2', veiculoId: 'v1', data: DateTime(2026, 10, 6), odometro: 772, valorCentavos: 0, local: LocalRecarga.casa, kwh: 40, precoKwh: 0.9, cargaCompleta: true),
    ]);

    expect(ciclos.single.rendimento, closeTo(6.8, 0.0001));
    expect(ciclos.single.combustivel, isNull);
  });

  test('custo por km usa o valor pago no início de cada trecho', () {
    final ciclos = CalculoConsumo.ciclosDeAbastecimento([
      abastecimento('a', 15200, 50, centavos: 30000, dia: 1),
      abastecimento('b', 15700, 40, centavos: 24000, dia: 9),
    ]);

    expect(CalculoConsumo.custoPorKm(ciclos), closeTo(300 / 500, 0.0001));
    expect(CalculoConsumo.custoPorKm(const []), isNull);
  });
}
