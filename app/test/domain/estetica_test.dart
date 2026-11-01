import 'package:flutter_test/flutter_test.dart';
import 'package:nosso_combustivel/domain/estetica.dart';
import 'package:nosso_combustivel/domain/servico.dart';

Servico estetica(String id, DateTime data, ModalidadeEstetica modalidade, int centavos,
        {List<String> categorias = const ['lavagemCompleta'], int? lembreteDias}) =>
    Servico(
      id: id,
      veiculoId: 'v',
      tipo: TipoServico.estetica,
      data: data,
      categorias: categorias,
      valorCentavos: centavos,
      detalhes: {'modalidade': modalidade.name, 'lembreteDias': ?lembreteDias},
    );

void main() {
  test('em casa, o custo por lavagem divide os produtos do ano pelas lavagens', () {
    final resumo = CalculoEstetica.resumo([
      estetica('p', DateTime(2026, 9, 1), ModalidadeEstetica.produtos, 10080, categorias: ['shampoo', 'cera']),
      estetica('c1', DateTime(2026, 9, 10), ModalidadeEstetica.casa, 0, categorias: ['externa']),
      estetica('c2', DateTime(2026, 10, 1), ModalidadeEstetica.casa, 0, categorias: ['externa']),
      estetica('e', DateTime(2026, 10, 20), ModalidadeEstetica.estetica, 6000, lembreteDias: 20),
    ], DateTime(2026, 11, 1));

    expect(resumo.custoPorLavagemEmCasaCentavos, 5040);
    expect(resumo.gastoEsteticaCentavos, 6000);
    expect(resumo.ultimaLavagem!.id, 'e');
    expect(resumo.diasParaLavar, 8);
    expect(resumo.ultimaCompra!.id, 'p');
  });

  test('compra de produtos não conta como lavagem', () {
    final resumo = CalculoEstetica.resumo(
      [estetica('p', DateTime(2026, 10, 30), ModalidadeEstetica.produtos, 3290, categorias: ['shampoo'])],
      DateTime(2026, 11, 1),
    );

    expect(resumo.ultimaLavagem, isNull);
    expect(CalculoEstetica.rotulos(resumo.ultimaCompra!), 'Produtos: Shampoo');
  });
}
