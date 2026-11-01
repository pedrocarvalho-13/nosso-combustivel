import 'package:flutter_test/flutter_test.dart';
import 'package:nosso_combustivel/domain/calculos/calculo_manutencao.dart';
import 'package:nosso_combustivel/domain/categoria_manutencao.dart';
import 'package:nosso_combustivel/domain/servico.dart';

Servico manutencao(String id, DateTime data, int? km, List<String> categorias, {Map<String, dynamic> detalhes = const {}}) =>
    Servico(
      id: id,
      veiculoId: 'v',
      tipo: TipoServico.manutencao,
      data: data,
      odometro: km,
      categorias: categorias,
      detalhes: detalhes,
      valorCentavos: 10000,
    );

void main() {
  test('troca de óleo perto do km fica em destaque e usa a última feita', () {
    final trocas = CalculoManutencao.proximas(
      servicos: [
        manutencao('a', DateTime(2025, 5, 10), 77420, ['oleo']),
        manutencao('b', DateTime(2026, 5, 10), 87420, ['oleo', 'filtros']),
      ],
      odometroAtual: 96620,
      agora: DateTime(2026, 11, 1),
    );

    final oleo = trocas.firstWhere((t) => t.categoria == CategoriaManutencao.oleo);
    expect(oleo.proximaKm, 97420);
    expect(oleo.faltaKm, 800);
    expect(oleo.situacao, SituacaoTroca.perto);
    expect(trocas.first.categoria, CategoriaManutencao.oleo);
  });

  test('lembrete desligado não gera próxima troca', () {
    final trocas = CalculoManutencao.proximas(
      servicos: [
        manutencao('a', DateTime(2026, 1, 1), 90000, ['oleo'], detalhes: {
          'oleo': {'lembrete': false},
        }),
      ],
      odometroAtual: 99000,
      agora: DateTime(2026, 11, 1),
    );

    expect(trocas, isEmpty);
  });

  test('sem km, o lembrete vence pelo tempo', () {
    final trocas = CalculoManutencao.proximas(
      servicos: [manutencao('a', DateTime(2025, 9, 1), null, ['arCondicionado'])],
      odometroAtual: 99000,
      agora: DateTime(2026, 11, 1),
    );

    expect(trocas.single.situacao, SituacaoTroca.vencida);
    expect(trocas.single.faltaDias! < 0, isTrue);
  });

  test('intervalo escolhido no registro vale no lugar da média geral', () {
    final trocas = CalculoManutencao.proximas(
      servicos: [
        manutencao('a', DateTime(2026, 6, 1), 90000, ['oleo'], detalhes: {
          'oleo': {'intervaloKm': '7500', 'intervaloMeses': '6'},
        }),
      ],
      odometroAtual: 95000,
      agora: DateTime(2026, 11, 1),
    );

    expect(trocas.single.proximaKm, 97500);
    expect(trocas.single.proximaData, DateTime(2026, 12, 1));
  });
}
