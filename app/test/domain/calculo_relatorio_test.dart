import 'package:flutter_test/flutter_test.dart';
import 'package:nosso_combustivel/domain/calculos/calculo_relatorio.dart';
import 'package:nosso_combustivel/domain/cartao.dart';
import 'package:nosso_combustivel/domain/combustivel.dart';
import 'package:nosso_combustivel/domain/forma_pagamento.dart';
import 'package:nosso_combustivel/domain/registro_energia.dart';

void main() {
  Abastecimento abastecimento(DateTime data, int centavos) => Abastecimento(
    id: '$data',
    veiculoId: 'v',
    data: data,
    odometro: 1000,
    valorCentavos: centavos,
    tanqueCheio: true,
    combustivel: Combustivel.gasolina,
    litros: 10,
    precoLitro: 6,
  );

  Recarga recarga(DateTime data, int centavos) => Recarga(
    id: 'r$data',
    veiculoId: 'v',
    data: data,
    odometro: 1000,
    valorCentavos: centavos,
    cargaCompleta: true,
    local: LocalRecarga.casa,
    kwh: 20,
    precoKwh: 1,
  );

  final agora = DateTime(2026, 10, 30);

  test('separa combustível e energia em cada um dos últimos 12 meses', () {
    final meses = CalculoRelatorio.gastoPorMes([
      abastecimento(DateTime(2026, 10, 2), 20000),
      recarga(DateTime(2026, 10, 5), 4000),
      abastecimento(DateTime(2026, 1, 15), 15000),
      abastecimento(DateTime(2025, 10, 31), 99999),
    ], agora);

    expect(meses, hasLength(12));
    expect(meses.first.mes, DateTime(2025, 11));
    expect(meses.last.mes, DateTime(2026, 10));
    expect(meses.last.combustivelCentavos, 20000);
    expect(meses.last.eletricoCentavos, 4000);
    expect(meses[2].totalCentavos, 15000);
    expect(meses.fold<int>(0, (s, m) => s + m.totalCentavos), 39000);
  });

  test('a média mensal começa no primeiro mês com gasto', () {
    final meses = CalculoRelatorio.gastoPorMes([
      abastecimento(DateTime(2026, 9, 10), 30000),
      abastecimento(DateTime(2026, 10, 10), 10000),
    ], agora);

    expect(CalculoRelatorio.mediaMensal(meses), 20000);
    expect(CalculoRelatorio.mediaMensal(CalculoRelatorio.gastoPorMes([], agora)), isNull);
  });

  test('compra no crédito que cai na fatura seguinte aparece como mês seguinte', () {
    const cartao = Cartao(id: 'c', nome: 'Roxinho', diaFechamento: 31);
    final meses = CalculoRelatorio.gastoPorMes(
      [
        abastecimento(DateTime(2026, 10, 10), 65000),
        Abastecimento(
          id: 'credito',
          veiculoId: 'v',
          data: DateTime(2026, 10, 31),
          odometro: 1000,
          valorCentavos: 14000,
          combustivel: Combustivel.gasolina,
          litros: 20,
          precoLitro: 7,
          tanqueCheio: false,
          formaPagamento: FormaPagamento.credito,
          cartaoId: 'c',
        ),
      ],
      DateTime(2026, 10, 31),
      cartoes: {'c': cartao},
    );

    expect(meses, hasLength(13));
    expect(meses.last.mes, DateTime(2026, 11));
    expect(meses.last.futuro, isTrue);
    expect(meses.last.totalCentavos, 14000);
    expect(CalculoRelatorio.totalFechado(meses), 65000);
    expect(CalculoRelatorio.mediaMensal(meses), 65000);
  });
}
