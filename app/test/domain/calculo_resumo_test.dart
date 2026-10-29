import 'package:flutter_test/flutter_test.dart';
import 'package:nosso_combustivel/domain/calculos/calculo_resumo.dart';
import 'package:nosso_combustivel/domain/combustivel.dart';
import 'package:nosso_combustivel/domain/registro_energia.dart';

Abastecimento abastecimento(DateTime data, int odometro, int valorCentavos) => Abastecimento(
      id: '$data',
      veiculoId: 'v1',
      data: data,
      odometro: odometro,
      valorCentavos: valorCentavos,
      combustivel: Combustivel.gasolina,
      litros: 30,
      precoLitro: 6,
      tanqueCheio: true,
    );

void main() {
  final registros = [
    abastecimento(DateTime(2026, 9, 28), 47000, 15000),
    abastecimento(DateTime(2026, 10, 10), 47500, 16000),
    abastecimento(DateTime(2026, 10, 27), 48284, 16006),
  ];

  test('resumo do mês usa a última leitura antes do mês como base dos km', () {
    final resumo = CalculoResumo.doPeriodo(
      registros: registros,
      odometroInicial: 46000,
      inicio: DateTime(2026, 10),
      fim: DateTime(2026, 11),
    );

    expect(resumo.gastoCentavos, 32006);
    expect(resumo.kmRodados, 1284);
    expect(resumo.custoPorKm, closeTo(320.06 / 1284, 0.0001));
  });

  test('sem registro anterior, a base é o odômetro do cadastro', () {
    final resumo = CalculoResumo.doPeriodo(
      registros: registros,
      odometroInicial: 46000,
      inicio: DateTime(2026, 9),
      fim: DateTime(2026, 10),
    );

    expect(resumo.kmRodados, 1000);
  });

  test('semana começa na segunda-feira', () {
    expect(CalculoResumo.inicioDaSemana(DateTime(2026, 10, 29, 18)), DateTime(2026, 10, 26));
  });

  test('sem uma semana de histórico não há projeção', () {
    final projecao = CalculoResumo.projecaoDoMes(
      registros: [abastecimento(DateTime(2026, 10, 25), 1000, 10000)],
      agora: DateTime(2026, 10, 29),
    );

    expect(projecao, isNull);
  });

  test('projeção soma o gasto do mês com a média diária pelos dias que faltam', () {
    final projecao = CalculoResumo.projecaoDoMes(registros: registros, agora: DateTime(2026, 10, 29, 12));

    expect(projecao, 32006 + (32006 / 30 * 2).round());
  });
}
