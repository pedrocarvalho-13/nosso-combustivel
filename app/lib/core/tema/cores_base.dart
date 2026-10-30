import 'package:flutter/material.dart';

abstract final class CoresBase {
  static const fundoEscuro = Color(0xFF0F1115);
  static const superficieEscura = Color(0xFF171A21);
  static const bordaEscura = Color(0xFF262A33);
  static const textoEscuro = Color(0xFFE6E8EC);
  static const textoSecundarioEscuro = Color(0xFF9AA1AD);

  static const fundoClaro = Color(0xFFF7F8FA);
  static const superficieClara = Color(0xFFFFFFFF);
  static const bordaClara = Color(0xFFE5E7EB);
  static const textoClaro = Color(0xFF111827);
  static const textoSecundarioClaro = Color(0xFF6B7280);

  static const alerta = Color(0xFFEF4444);
  static const atencao = Color(0xFFFACC15);
}

abstract final class CoresMarca {
  static const laranja = Color(0xFFF97316);
  static const azul = Color(0xFF3B82F6);
  static const verde = Color(0xFF10B981);
  static const degrade = [laranja, azul, verde];
}
