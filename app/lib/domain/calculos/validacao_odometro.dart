import 'dart:math';

import '../registro_energia.dart';

abstract final class ValidacaoOdometro {
  static String? validar({
    required List<RegistroEnergia> registros,
    required int odometroInicial,
    required DateTime data,
    required int odometro,
    String? ignorarId,
  }) {
    final outros = registros.where((r) => r.id != ignorarId);
    final antes = outros.where((r) => !r.data.isAfter(data)).map((r) => r.odometro);
    final depois = outros.where((r) => r.data.isAfter(data)).map((r) => r.odometro);
    final minimo = antes.isEmpty ? odometroInicial : max(odometroInicial, antes.reduce(max));

    if (odometro < minimo) {
      return 'O odômetro não pode ser menor que $minimo km, a leitura anterior.';
    }
    if (depois.isNotEmpty && odometro > depois.reduce(min)) {
      return 'O odômetro não pode ser maior que ${depois.reduce(min)} km, de um registro mais novo.';
    }
    return null;
  }
}
