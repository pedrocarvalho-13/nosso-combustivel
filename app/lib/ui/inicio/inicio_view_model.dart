import 'package:flutter_riverpod/flutter_riverpod.dart';

class InicioEstado {
  const InicioEstado({this.apelidoCarroAtivo});

  final String? apelidoCarroAtivo;

  bool get semCarro => apelidoCarroAtivo == null;
}

class InicioViewModel extends Notifier<InicioEstado> {
  @override
  InicioEstado build() => const InicioEstado();
}

final inicioViewModelProvider =
    NotifierProvider<InicioViewModel, InicioEstado>(InicioViewModel.new);
