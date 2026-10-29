import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/rotas/rotas.dart';
import 'core/tema/paleta_energia.dart';
import 'core/tema/tema_app.dart';
import 'core/tema/tipo_energia_ativo.dart';

class NossoCombustivelApp extends ConsumerWidget {
  const NossoCombustivelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paleta = PaletaEnergia.de(ref.watch(tipoEnergiaAtivoProvider));

    return MaterialApp.router(
      title: 'Nosso Combustível',
      debugShowCheckedModeBanner: false,
      theme: TemaApp.claro(paleta),
      darkTheme: TemaApp.escuro(paleta),
      themeMode: ThemeMode.dark,
      routerConfig: ref.watch(rotasProvider),
    );
  }
}
