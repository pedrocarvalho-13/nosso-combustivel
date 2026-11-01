import 'package:flutter_test/flutter_test.dart';
import 'package:nosso_combustivel/domain/horario_posto.dart';

void main() {
  test('traduz o horario do OpenStreetMap', () {
    expect(HorarioPosto.legivel('24/7'), 'Aberto 24 horas');
    expect(HorarioPosto.legivel('Mo-Fr 06:00-22:00; Sa,Su 07:00-20:00'), 'Seg-Sex 06:00-22:00 · Sáb, Dom 07:00-20:00');
    expect(HorarioPosto.legivel('Mo-Sa 06:00-22:00; Su off'), 'Seg-Sáb 06:00-22:00 · Dom fechado');
    expect(HorarioPosto.legivel(null), isNull);
  });
}
