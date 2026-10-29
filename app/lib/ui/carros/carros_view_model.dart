import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/provedores.dart';
import '../../domain/veiculo.dart';

class CarrosEstado {
  const CarrosEstado({required this.veiculos, this.ativoId});

  final List<Veiculo> veiculos;
  final String? ativoId;
}

class CarrosViewModel extends Notifier<AsyncValue<CarrosEstado>> {
  @override
  AsyncValue<CarrosEstado> build() {
    final ativo = ref.watch(veiculoAtivoProvider).value;
    return ref.watch(veiculosProvider).whenData((veiculos) => CarrosEstado(veiculos: veiculos, ativoId: ativo?.id));
  }

  Future<void> ativar(Veiculo veiculo) =>
      ref.read(preferenciasRepositorioProvider).definirVeiculoAtivo(veiculo.id);
}

final carrosViewModelProvider =
    NotifierProvider<CarrosViewModel, AsyncValue<CarrosEstado>>(CarrosViewModel.new);
