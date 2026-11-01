import 'package:flutter_test/flutter_test.dart';
import 'package:nosso_combustivel/domain/calculos/calculo_fatura.dart';
import 'package:nosso_combustivel/domain/custo.dart';
import 'package:nosso_combustivel/domain/forma_pagamento.dart';
import 'package:nosso_combustivel/domain/servico.dart';

Servico custo(String id, TipoCusto tipo, List<ParcelaCusto> parcelas, {Map<String, dynamic> detalhes = const {}}) =>
    Servico(
      id: id,
      veiculoId: 'v',
      tipo: TipoServico.custo,
      data: DateTime(2026, 9, 1, 12),
      categorias: [tipo.name],
      valorCentavos: parcelas.fold(0, (soma, p) => soma + p.valorCentavos),
      detalhes: {
        ...detalhes,
        'contas': [for (final p in parcelas) p.paraJson()],
      },
      formaPagamento: FormaPagamento.pix,
    );

void main() {
  test('dividir reparte o total em parcelas mensais sem perder centavos', () {
    final parcelas = CalculoCustos.dividir(totalCentavos: 123601, vezes: 3, primeiroVencimento: DateTime(2026, 1, 31));

    expect(parcelas.map((p) => p.valorCentavos), [41201, 41200, 41200]);
    expect(parcelas.map((p) => p.vencimento), [DateTime(2026, 1, 31), DateTime(2026, 2, 28), DateTime(2026, 3, 31)]);
  });

  test('só a parcela paga entra no gasto, no mês em que foi paga', () {
    final ipva = custo(
      'i',
      TipoCusto.ipva,
      [
        ParcelaCusto(numero: 1, vencimento: DateTime(2026, 9, 5), valorCentavos: 41200, pagaEm: DateTime(2026, 9, 4)),
        ParcelaCusto(numero: 2, vencimento: DateTime(2026, 10, 5), valorCentavos: 41200, pagaEm: DateTime(2026, 10, 5)),
        ParcelaCusto(numero: 3, vencimento: DateTime(2026, 11, 5), valorCentavos: 41200),
      ],
      detalhes: {'ano': 2026},
    );
    final gastos = CalculoCustos.gastos([ipva]);

    expect(gastos, hasLength(2));
    expect(CalculoFatura.gastoDoMes(gastos, const {}, DateTime(2026, 10)), 41200);
    expect(CalculoFatura.gastoDoMes(gastos, const {}, DateTime(2026, 11)), 0);
  });

  test('o painel mostra atrasadas primeiro e o que vence nos próximos 30 dias', () {
    final agora = DateTime(2026, 11, 1, 9);
    final multa = custo(
      'm',
      TipoCusto.multa,
      [ParcelaCusto(numero: 1, vencimento: DateTime(2026, 10, 28), valorCentavos: 10412)],
      detalhes: {'infracao': 'velocidade'},
    );
    final ipva = custo(
      'i',
      TipoCusto.ipva,
      [
        ParcelaCusto(numero: 1, vencimento: DateTime(2026, 11, 5), valorCentavos: 41200),
        ParcelaCusto(numero: 2, vencimento: DateTime(2026, 12, 5), valorCentavos: 41200),
      ],
      detalhes: {'ano': 2026},
    );
    final resumo = CalculoCustos.resumo([multa, ipva], agora);

    expect(resumo.atrasadas.single.titulo, 'Multa · velocidade');
    expect(resumo.proximas.single.titulo, 'IPVA 2026 · 1/2');
    expect(resumo.aPagarCentavos, 51612);
    expect(CalculoCustos.diasPara(resumo.proximas.single.parcela.vencimento, agora), 4);
  });

  test('marcar como paga e desfazer mexe só na parcela escolhida', () {
    final seguro = custo(
      's',
      TipoCusto.seguro,
      CalculoCustos.dividir(totalCentavos: 296000, vezes: 10, primeiroVencimento: DateTime(2026, 7, 15)),
    );

    final paga = CalculoCustos.marcarPaga(seguro, 5, DateTime(2026, 11, 15));
    expect(CalculoCustos.parcelas(paga).where((p) => p.paga).map((p) => p.numero), [5]);

    final desfeita = CalculoCustos.marcarPaga(paga, 5, null);
    expect(CalculoCustos.parcelas(desfeita).any((p) => p.paga), isFalse);
  });

  test('financiamento gera da parcela atual até a última e mostra o total no título', () {
    final parcelas = CalculoCustos.financiamento(
      valorParcelaCentavos: 89000,
      parcelaAtual: 46,
      totalParcelas: 48,
      proximoVencimento: DateTime(2026, 11, 10),
    );
    final financiamento = custo('f', TipoCusto.financiamento, parcelas, detalhes: {'totalParcelas': 48});

    expect(parcelas.map((p) => p.numero), [46, 47, 48]);
    expect(CalculoCustos.contas(financiamento).last.titulo, 'Financiamento · 48/48');
  });

  test('desconto da multa: 20% até o vencimento e 40% pelo SNE', () {
    expect(DescontoMulta.vinte.aplicar(13016), 10413);
    expect(DescontoMulta.sne.aplicar(13016), 7810);
    expect(DescontoMulta.de('qualquer'), DescontoMulta.nenhum);
  });
}
