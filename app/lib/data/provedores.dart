import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../domain/cartao.dart';
import '../domain/registro_energia.dart';
import '../domain/veiculo.dart';
import 'banco/banco_local.dart';
import 'fipe/fipe_cliente.dart';
import 'repositorios/cartao_repositorio.dart';
import 'repositorios/preferencias_repositorio.dart';
import 'repositorios/registro_repositorio.dart';
import 'repositorios/veiculo_repositorio.dart';
import 'sessao/sessao_controller.dart';
import '../domain/tipo_gasolina.dart';
import 'repositorios/servico_repositorio.dart';
import '../domain/servico.dart';

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

final servicoRepositorioProvider = Provider<ServicoRepositorio>(
  (ref) => ServicoRepositorio(ref.watch(bancoLocalProvider), ref.watch(relogioProvider)),
);

final manutencoesDoAtivoProvider = StreamProvider<List<Servico>>((ref) {
  final veiculo = ref.watch(veiculoAtivoProvider).value;
  if (veiculo == null) return Stream.value(const []);
  return ref.watch(servicoRepositorioProvider).observarDoVeiculo(veiculo.id, TipoServico.manutencao);
});

final cartaoRepositorioProvider = Provider<CartaoRepositorio>(
  (ref) => CartaoRepositorio(ref.watch(bancoLocalProvider), ref.watch(relogioProvider)),
);

final cartoesProvider = StreamProvider<List<Cartao>>((ref) {
  final usuarioId = ref.watch(sessaoProvider.select((s) => s.value?.usuario.id));
  if (usuarioId == null) return Stream.value(const []);
  return ref.watch(cartaoRepositorioProvider).observarDoUsuario(usuarioId);
});

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

final metaMensalProvider = StreamProvider<int?>(
  (ref) => ref.watch(preferenciasRepositorioProvider).observarMetaMensal(),
);

final periodoMediaProvider = StreamProvider<int>(
  (ref) => ref.watch(preferenciasRepositorioProvider).observarPeriodoMedia(),
);

final temaProvider = StreamProvider<String>(
  (ref) => ref.watch(preferenciasRepositorioProvider).observarTema(),
);

final fotosIaProvider = StreamProvider<bool>(
  (ref) => ref.watch(preferenciasRepositorioProvider).observarFotosIa(),
);

final gasolinaPadraoProvider = StreamProvider<TipoGasolina>(
  (ref) => ref.watch(preferenciasRepositorioProvider).observarGasolinaPadrao(),
);

final pagamentoPadraoProvider = StreamProvider<String?>(
  (ref) => ref.watch(preferenciasRepositorioProvider).observarPagamentoPadrao(),
);

final tarifaCasaProvider = StreamProvider<double?>(
  (ref) => ref.watch(preferenciasRepositorioProvider).observarTarifaCasa(),
);
