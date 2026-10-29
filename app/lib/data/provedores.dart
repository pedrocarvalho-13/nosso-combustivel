import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../domain/registro_energia.dart';
import '../domain/veiculo.dart';
import 'banco/banco_local.dart';
import 'fipe/fipe_cliente.dart';
import 'repositorios/preferencias_repositorio.dart';
import 'repositorios/registro_repositorio.dart';
import 'repositorios/veiculo_repositorio.dart';
import 'sessao/sessao_controller.dart';

final relogioProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final geradorIdProvider = Provider<String Function()>((ref) => const Uuid().v7);

final bancoLocalProvider = Provider<BancoLocal>((ref) {
  final banco = BancoLocal();
  ref.onDispose(banco.close);
  return banco;
});

final veiculoRepositorioProvider = Provider<VeiculoRepositorio>(
  (ref) => VeiculoRepositorio(ref.watch(bancoLocalProvider), ref.watch(relogioProvider)),
);

final registroRepositorioProvider = Provider<RegistroRepositorio>(
  (ref) => RegistroRepositorio(ref.watch(bancoLocalProvider), ref.watch(relogioProvider)),
);

final preferenciasRepositorioProvider = Provider<PreferenciasRepositorio>(
  (ref) => PreferenciasRepositorio(ref.watch(bancoLocalProvider)),
);

final fipeClienteProvider = Provider<FipeCliente>(
  (ref) => FipeCliente(Dio(BaseOptions(connectTimeout: const Duration(seconds: 10)))),
);

final veiculosProvider = StreamProvider<List<Veiculo>>((ref) {
  final usuarioId = ref.watch(sessaoProvider.select((s) => s.value?.usuario.id));
  if (usuarioId == null) return Stream.value(const []);
  return ref.watch(veiculoRepositorioProvider).observarDoUsuario(usuarioId);
});

final veiculoAtivoIdProvider = StreamProvider<String?>(
  (ref) => ref.watch(preferenciasRepositorioProvider).observarVeiculoAtivo(),
);

final veiculoAtivoProvider = Provider<AsyncValue<Veiculo?>>((ref) {
  final ativoId = ref.watch(veiculoAtivoIdProvider).value;
  return ref.watch(veiculosProvider).whenData(
        (veiculos) => veiculos.where((v) => v.id == ativoId).firstOrNull ?? veiculos.firstOrNull,
      );
});

final registrosDoAtivoProvider = StreamProvider<List<RegistroEnergia>>((ref) {
  final veiculo = ref.watch(veiculoAtivoProvider).value;
  if (veiculo == null) return Stream.value(const []);
  return ref.watch(registroRepositorioProvider).observarDoVeiculo(veiculo.id);
});

final tarifaCasaProvider = StreamProvider<double?>(
  (ref) => ref.watch(preferenciasRepositorioProvider).observarTarifaCasa(),
);
