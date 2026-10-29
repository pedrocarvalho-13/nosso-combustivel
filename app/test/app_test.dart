import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nosso_combustivel/app.dart';

void main() {
  testWidgets('início sem carro convida a cadastrar o primeiro', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: NossoCombustivelApp()));
    await tester.pumpAndSettle();

    expect(find.text('Cadastre seu primeiro carro'), findsOneWidget);
  });

  testWidgets('botão do início leva para a aba de carros', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: NossoCombustivelApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Adicionar carro'));
    await tester.pumpAndSettle();

    expect(find.text('Nenhum carro ainda'), findsOneWidget);
  });
}
