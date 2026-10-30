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
      return 'Precisa ser pelo menos ${_km(minimo)}, a leitura anterior.';
    }
    if (depois.isNotEmpty && odometro > depois.reduce(min)) {
      return 'Precisa ser no máximo ${_km(depois.reduce(min))}, de um registro mais novo.';
    }
    return null;
  }

  static String _km(int valor) => '${valor.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.')} km';
}
