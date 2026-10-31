import 'package:flutter_test/flutter_test.dart';
import 'package:nosso_combustivel/domain/calculos/calculo_fatura.dart';
import 'package:nosso_combustivel/domain/cartao.dart';
import 'package:nosso_combustivel/domain/combustivel.dart';
import 'package:nosso_combustivel/domain/forma_pagamento.dart';
import 'package:nosso_combustivel/domain/registro_energia.dart';

void main() {
  const fechaDia31 = Cartao(id: 'c31', nome: 'Nubank', diaFechamento: 31);
  const fechaDia10 = Cartao(id: 'c10', nome: 'Itaú', diaFechamento: 10);
  final cartoes = {fechaDia31.id: fechaDia31, fechaDia10.id: fechaDia10};

  Abastecimento abastecimento(DateTime data, int centavos, {FormaPagamento? forma, String? cartao}) => Abastecimento(
        id: '$data$centavos',
        veiculoId: 'v',
        data: data,
        odometro: 1000,
        valorCentavos: centavos,
        combustivel: Combustivel.gasolina,
        litros: 10,
        precoLitro: 7,
        tanqueCheio: false,
        formaPagamento: forma,
        cartaoId: cartao,
      );

  test('no dia do fechamento o crédito já cai na fatura do mês seguinte', () {
    final hoje = abastecimento(DateTime(2026, 10, 31, 12), 14000, forma: FormaPagamento.credito, cartao: 'c31');
    final antes = abastecimento(DateTime(2026, 10, 29, 12), 5000, forma: FormaPagamento.credito, cartao: 'c31');

    expect(CalculoFatura.mesDoGasto(hoje, cartoes), DateTime(2026, 11));
    expect(CalculoFatura.mesDoGasto(antes, cartoes), DateTime(2026, 10));
  });

  test('fechamento no dia 31 vale como último dia nos meses mais curtos', () {
    final ultimoDeNovembro = abastecimento(DateTime(2026, 11, 30, 12), 100, forma: FormaPagamento.credito, cartao: 'c31');

    expect(CalculoFatura.mesDoGasto(ultimoDeNovembro, cartoes), DateTime(2026, 12));
  });

  test('débito, Pix, dinheiro e registros antigos contam no dia do abastecimento', () {
    for (final forma in [FormaPagamento.debito, FormaPagamento.pix, FormaPagamento.dinheiro, null]) {
      expect(CalculoFatura.mesDoGasto(abastecimento(DateTime(2026, 10, 31), 100, forma: forma), cartoes), DateTime(2026, 10));
    }
  });

  test('gasto do mês separa o que cai em outubro do que vai para novembro', () {
    final registros = [
      abastecimento(DateTime(2026, 10, 5), 65000, forma: FormaPagamento.pix),
      abastecimento(DateTime(2026, 10, 31), 14000, forma: FormaPagamento.credito, cartao: 'c31'),
      abastecimento(DateTime(2026, 10, 12), 3000, forma: FormaPagamento.credito, cartao: 'c10'),
    ];

    expect(CalculoFatura.gastoDoMes(registros, cartoes, DateTime(2026, 10)), 65000);
    expect(CalculoFatura.gastoDoMes(registros, cartoes, DateTime(2026, 11)), 17000);
  });
}
