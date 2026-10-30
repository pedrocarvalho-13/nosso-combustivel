import 'package:flutter/material.dart';

import 'cores_base.dart';
import 'paleta_energia.dart';

abstract final class TemaApp {
  static ThemeData escuro(PaletaEnergia paleta) => _montar(
        brilho: Brightness.dark,
        paleta: paleta,
        fundo: CoresBase.fundoEscuro,
        superficie: CoresBase.superficieEscura,
        borda: CoresBase.bordaEscura,
        texto: CoresBase.textoEscuro,
        textoSecundario: CoresBase.textoSecundarioEscuro,
        destaqueSuave: paleta.principal.withValues(alpha: 0.14),
      );

  static ThemeData claro(PaletaEnergia paleta) => _montar(
        brilho: Brightness.light,
        paleta: paleta,
        fundo: CoresBase.fundoClaro,
        superficie: CoresBase.superficieClara,
        borda: CoresBase.bordaClara,
        texto: CoresBase.textoClaro,
        textoSecundario: CoresBase.textoSecundarioClaro,
        destaqueSuave: paleta.clara,
      );

  static ThemeData _montar({
    required Brightness brilho,
    required PaletaEnergia paleta,
    required Color fundo,
    required Color superficie,
    required Color borda,
    required Color texto,
    required Color textoSecundario,
    required Color destaqueSuave,
  }) {
    final esquema = ColorScheme(
      brightness: brilho,
      primary: paleta.principal,
      onPrimary: CoresBase.fundoEscuro,
      primaryContainer: destaqueSuave,
      onPrimaryContainer: texto,
      secondary: paleta.principal,
      onSecondary: CoresBase.fundoEscuro,
      error: CoresBase.alerta,
      onError: CoresBase.superficieClara,
      surface: fundo,
      onSurface: texto,
      onSurfaceVariant: textoSecundario,
      surfaceContainer: superficie,
      surfaceContainerHigh: superficie,
      outline: borda,
      outlineVariant: borda,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: fundo,
      cardTheme: CardThemeData(
        color: superficie,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borda),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: superficie,
        helperMaxLines: 2,
        errorMaxLines: 2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borda),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borda),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: paleta.principal, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CoresBase.alerta, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CoresBase.alerta, width: 2),
        ),
        errorStyle: const TextStyle(color: CoresBase.alerta),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: superficie,
        indicatorColor: destaqueSuave,
      ),
    );
  }
}
