import 'package:flutter_test/flutter_test.dart';
import 'package:nosso_combustivel/domain/calculos/calculo_fatura.dart';
import 'package:nosso_combustivel/domain/cartao.dart';
import 'package:nosso_combustivel/domain/forma_pagamento.dart';
import 'package:nosso_combustivel/domain/servico.dart';

void main() {
  test('compra parcelada no crédito entra uma parcela em cada fatura', () {
    const cartao = Cartao(id: 'c', nome: 'Roxinho', diaFechamento: 25);
    final servico = Servico(
      id: 's',
      veiculoId: 'v',
      tipo: TipoServico.manutencao,
      data: DateTime(2026, 10, 28),
      categorias: const ['pneus'],
      valorCentavos: 100000,
      formaPagamento: FormaPagamento.credito,
      cartaoId: 'c',
      detalhes: const {'parcelas': 3},
    );
    final cartoes = {'c': cartao};

    expect(CalculoFatura.gastoDoMes([servico], cartoes, DateTime(2026, 10)), 0);
    expect(CalculoFatura.gastoDoMes([servico], cartoes, DateTime(2026, 11)), 33334);
    expect(CalculoFatura.gastoDoMes([servico], cartoes, DateTime(2026, 12)), 33333);
    expect(CalculoFatura.gastoDoMes([servico], cartoes, DateTime(2027, 1)), 33333);
    expect(CalculoFatura.gastoDoMes([servico], cartoes, DateTime(2027, 2)), 0);
  });

  test('parcelas só valem no crédito', () {
    final servico = Servico(
      id: 's',
      veiculoId: 'v',
      tipo: TipoServico.manutencao,
      data: DateTime(2026, 10, 28),
      categorias: const ['pneus'],
      valorCentavos: 100000,
      formaPagamento: FormaPagamento.pix,
      detalhes: const {'parcelas': 3},
    );

    expect(CalculoFatura.gastoDoMes([servico], const {}, DateTime(2026, 10)), 100000);
  });
}
