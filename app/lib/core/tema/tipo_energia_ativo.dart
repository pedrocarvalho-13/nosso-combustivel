import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/tipo_energia.dart';

class TipoEnergiaAtivo extends Notifier<TipoEnergia> {
  @override
  TipoEnergia build() => TipoEnergia.combustao;

  void definir(TipoEnergia tipo) => state = tipo;
}

final tipoEnergiaAtivoProvider =
    NotifierProvider<TipoEnergiaAtivo, TipoEnergia>(TipoEnergiaAtivo.new);
