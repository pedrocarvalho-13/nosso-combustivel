import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/provedores.dart';
import '../../domain/tipo_energia.dart';

final tipoEnergiaAtivoProvider = Provider<TipoEnergia>(
  (ref) => ref.watch(veiculoAtivoProvider).value?.tipoEnergia ?? TipoEnergia.combustao,
);
