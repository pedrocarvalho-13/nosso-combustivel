import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nosso_combustivel/app.dart';
import 'package:nosso_combustivel/data/fipe/fipe_cliente.dart';
import 'package:nosso_combustivel/data/provedores.dart';
import 'package:nosso_combustivel/domain/combustivel.dart';
import 'package:nosso_combustivel/domain/registro_energia.dart';
import 'package:nosso_combustivel/domain/tipo_energia.dart';
import 'package:nosso_combustivel/domain/veiculo.dart';

class FipeFalsa extends FipeCliente {
  FipeFalsa() : super(Dio());

  @override
  Future<List<OpcaoFipe>> marcas() async => const [OpcaoFipe('56', 'Toyota')];
}

const civic = Veiculo(
  id: 'v1',
  apelido: 'Meu Civic',
  marca: 'Honda',
  modelo: 'Civic',
  tipoEnergia: TipoEnergia.combustao,
  combustiveis: [Combustivel.gasolina, Combustivel.etanol],
  odometroInicial: 47000,
);

Abastecimento abastecimento(String id, int dia, int odometro, double litros, int centavos) => Abastecimento(
      id: id,
      veiculoId: 'v1',
      data: DateTime(2026, 10, dia),
      odometro: odometro,
      valorCentavos: centavos,
      combustivel: Combustivel.etanol,
      litros: litros,
      precoLitro: 4.19,
      tanqueCheio: true,
    );

ProviderScope app({List<Veiculo> veiculos = const [], List<RegistroEnergia> registros = const []}) => ProviderScope(
      overrides: [
        veiculosProvider.overrideWith((ref) => Stream.value(veiculos)),
        veiculoAtivoIdProvider.overrideWith((ref) => Stream.value(veiculos.firstOrNull?.id)),
        registrosDoAtivoProvider.overrideWith((ref) => Stream.value(registros)),
        relogioProvider.overrideWithValue(() => DateTime(2026, 10, 29, 12)),
        fipeClienteProvider.overrideWithValue(FipeFalsa()),
      ],
      child: const NossoCombustivelApp(),
    );

void main() {
  testWidgets('início sem carro convida a cadastrar o primeiro', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('Cadastre seu primeiro carro'), findsOneWidget);
  });

  testWidgets('botão do início abre o cadastro com as marcas da FIPE', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Adicionar carro'));
    await tester.pumpAndSettle();

    expect(find.text('Marca'), findsWidgets);
    expect(find.text('Não achou o carro? Cadastrar sem a FIPE'), findsOneWidget);
  });

  testWidgets('início mostra o gasto do mês e o consumo do carro ativo', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app(
      veiculos: [civic],
      registros: [
        abastecimento('b', 27, 47344, 38.2, 16006),
        abastecimento('a', 18, 47000, 40.1, 16802),
      ],
    ));
    await tester.pumpAndSettle();

    expect(find.text('Gasto em outubro'), findsOneWidget);
    expect(find.text('R\$ 328,08'), findsOneWidget);
    expect(find.text('9,0 km/l'), findsOneWidget);
    expect(find.text('Abastecer'), findsNothing);
    expect(find.text('Registrar abastecimento'), findsOneWidget);
  });
}
