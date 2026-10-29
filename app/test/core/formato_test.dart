import 'package:flutter_test/flutter_test.dart';
import 'package:nosso_combustivel/core/formato.dart';

void main() {
  test('moeda no padrão brasileiro', () {
    expect(Formato.moeda(160006), 'R\$ 1.600,06');
    expect(Formato.moeda(5), 'R\$ 0,05');
  });

  test('km com separador de milhar', () {
    expect(Formato.km(48326), '48.326 km');
  });

  test('lê decimal com vírgula ou ponto', () {
    expect(Formato.lerDecimal('38,2'), 38.2);
    expect(Formato.lerDecimal('4.19'), 4.19);
    expect(Formato.lerDecimal('1.234,5'), 1234.5);
    expect(Formato.lerDecimal(''), isNull);
  });

  test('lê inteiro ignorando pontos', () {
    expect(Formato.lerInteiro('48.326'), 48326);
  });
}
