import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart' as base;

void main() {
  final registros = [
    base.abastecimento('c', 28, 47700, 39.0, 16341),
    base.abastecimento('b', 18, 47344, 38.2, 16006),
    base.abastecimento('a', 2, 47000, 40.1, 16802),
  ];

  Future<void> abrir(WidgetTester tester, Size tamanho) async {
    tester.view.physicalSize = tamanho;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(base.app(veiculos: [base.civic], registros: registros));
    await tester.pumpAndSettle();
  }

  testWidgets('no celular a navegação fica numa barra flutuante embaixo', (tester) async {
    await abrir(tester, const Size(390, 844));

    expect(find.text('Nosso Combustível'), findsNothing);
    expect(find.text('Relatórios'), findsOneWidget);
    await tester.tap(find.text('Relatórios'));
    await tester.pumpAndSettle();

    expect(find.text('Gasto por mês'), findsOneWidget);
    expect(find.text('Consumo por abastecimento'), findsOneWidget);
    if (const bool.fromEnvironment('CAPTURAR')) {
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('capturas/relatorios_celular.png'));
    }
  });

  testWidgets('no computador a navegação vira uma barra lateral que recolhe', (tester) async {
    await abrir(tester, const Size(1280, 800));

    expect(find.text('Nosso Combustível'), findsOneWidget);
    if (const bool.fromEnvironment('CAPTURAR')) {
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('capturas/inicio_computador.png'));
    }
    await tester.tap(find.byTooltip('Recolher menu'));
    await tester.pumpAndSettle();

    expect(find.text('Nosso Combustível'), findsNothing);
    expect(find.byTooltip('Expandir menu'), findsOneWidget);
    await tester.tap(find.byTooltip('Relatórios'));
    await tester.pumpAndSettle();
    expect(find.text('Gasto por mês'), findsOneWidget);
    if (const bool.fromEnvironment('CAPTURAR')) {
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('capturas/relatorios_computador.png'));
    }
  });
}
