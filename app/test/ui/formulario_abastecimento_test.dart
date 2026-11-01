import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nosso_combustivel/data/banco/banco_local.dart';
import 'package:nosso_combustivel/data/provedores.dart';
import 'package:nosso_combustivel/domain/combustivel.dart';
import 'package:nosso_combustivel/domain/tipo_energia.dart';
import 'package:nosso_combustivel/domain/veiculo.dart';
import 'package:nosso_combustivel/ui/abastecimento/novo_abastecimento_view.dart';

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  testWidgets('salvar com campos vazios mostra o erro embaixo de cada campo', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final banco = BancoLocal(NativeDatabase.memory());
    addTearDown(banco.close);
    await banco.into(banco.preferencias).insert(PreferenciasCompanion.insert(chave: 'onboarding_hodometro', valor: 'sim'));

    const hilux = Veiculo(
      id: 'v1',
      apelido: 'Meu Hilux',
      marca: 'Toyota',
      modelo: 'Hilux',
      tipoEnergia: TipoEnergia.combustao,
      combustiveis: [Combustivel.dieselS10, Combustivel.dieselS500],
      odometroInicial: 32540,
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [
        bancoLocalProvider.overrideWithValue(banco),
        veiculoAtivoProvider.overrideWithValue(const AsyncData(hilux)),
        cartoesProvider.overrideWith((ref) => Stream.value(const [])),
        fotosIaProvider.overrideWith((ref) => Stream.value(true)),
      ],
      child: const MaterialApp(home: NovoAbastecimentoView()),
    ));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Salvar abastecimento'), 300, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar abastecimento'));
    await tester.pumpAndSettle();

    for (final erro in ['Informe o hodômetro.', 'Informe os litros.', 'Informe o preço.']) {
      await tester.scrollUntilVisible(find.text(erro), -200, scrollable: find.byType(Scrollable).first);
      expect(find.text(erro), findsOneWidget);
    }
  });
}
