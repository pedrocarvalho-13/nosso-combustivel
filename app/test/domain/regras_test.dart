import 'package:flutter_test/flutter_test.dart';
import 'package:nosso_combustivel/domain/calculos/calculo_etanol.dart';
import 'package:nosso_combustivel/domain/calculos/identificacao_energia.dart';
import 'package:nosso_combustivel/domain/calculos/validacao_odometro.dart';
import 'package:nosso_combustivel/domain/combustivel.dart';
import 'package:nosso_combustivel/domain/registro_energia.dart';
import 'package:nosso_combustivel/domain/tipo_energia.dart';

void main() {
  group('etanol x gasolina', () {
    test('sem histórico usa a regra dos 70%', () {
      final comparacao = CalculoEtanol.comparar(precoEtanol: 4.19, precoGasolina: 6.29)!;

      expect(comparacao.limite, 0.70);
      expect(comparacao.etanolCompensa, isTrue);
    });

    test('com histórico usa o rendimento real do carro', () {
      final comparacao = CalculoEtanol.comparar(precoEtanol: 4.50, precoGasolina: 6.29, kmlEtanol: 8.9, kmlGasolina: 12.1)!;

      expect(comparacao.limiteDoCarro, isTrue);
      expect(comparacao.limite, closeTo(0.7355, 0.0001));
      expect(comparacao.etanolCompensa, isTrue);
    });
  });

  group('identificação da energia pela FIPE', () {
    EnergiaIdentificada identificar(String modelo, String combustivel) =>
        IdentificacaoEnergia.identificar(modelo: modelo, combustivelFipe: combustivel);

    test('elétrico', () {
      expect(identificar('Dolphin EV GS (Elétrico)', 'Elétrico').tipo, TipoEnergia.eletrico);
    });

    test('híbrido comum', () {
      final energia = identificar('Song Plus 1.5 16V Aut. (Hibrido)', 'Híbrido');

      expect(energia.tipo, TipoEnergia.hibridoComum);
      expect(energia.combustiveis, [Combustivel.gasolina]);
    });

    test('híbrido plug-in pelo nome', () {
      expect(identificar('Song Plus DM-i 1.5 Aut.', 'Híbrido').tipo, TipoEnergia.hibridoPlugin);
    });

    test('híbrido flex', () {
      final energia = identificar('Corolla Cross XRX Hybrid 1.8 Flex Aut.', 'Gasolina');

      expect(energia.tipo, TipoEnergia.hibridoComum);
      expect(energia.combustiveis, [Combustivel.gasolina, Combustivel.etanol]);
    });

    test('diesel', () {
      final energia = identificar('Hilux CD SRX 2.8 4x4 Diesel Aut.', 'Diesel');

      expect(energia.tipo, TipoEnergia.combustao);
      expect(energia.combustiveis.every((c) => c.diesel), isTrue);
    });

    test('flex aparece como gasolina na FIPE', () {
      final energia = identificar('Civic Sedan EXL 2.0 Flex 16V Aut.', 'Gasolina');

      expect(energia.combustiveis, [Combustivel.gasolina, Combustivel.etanol]);
    });
  });

  group('odômetro', () {
    final registros = [
      Abastecimento(id: 'a', veiculoId: 'v', data: DateTime(2026, 10, 10), odometro: 48000, valorCentavos: 1, combustivel: Combustivel.gasolina, litros: 1, precoLitro: 1, tanqueCheio: true),
      Abastecimento(id: 'b', veiculoId: 'v', data: DateTime(2026, 10, 20), odometro: 48300, valorCentavos: 1, combustivel: Combustivel.gasolina, litros: 1, precoLitro: 1, tanqueCheio: true),
    ];

    String? validar(DateTime data, int odometro) =>
        ValidacaoOdometro.validar(registros: registros, odometroInicial: 47000, data: data, odometro: odometro);

    test('aceita leitura depois da última', () {
      expect(validar(DateTime(2026, 10, 29), 48326), isNull);
    });

    test('recusa leitura menor que a anterior', () {
      expect(validar(DateTime(2026, 10, 29), 48200), isNotNull);
    });

    test('registro antigo precisa caber entre os vizinhos', () {
      expect(validar(DateTime(2026, 10, 15), 48100), isNull);
      expect(validar(DateTime(2026, 10, 15), 48400), isNotNull);
    });
  });
}
