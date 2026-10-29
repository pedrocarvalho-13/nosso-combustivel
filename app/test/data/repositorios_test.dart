import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nosso_combustivel/data/banco/banco_local.dart';
import 'package:nosso_combustivel/data/repositorios/registro_repositorio.dart';
import 'package:nosso_combustivel/data/repositorios/veiculo_repositorio.dart';
import 'package:nosso_combustivel/domain/combustivel.dart';
import 'package:nosso_combustivel/domain/registro_energia.dart';
import 'package:nosso_combustivel/domain/tipo_energia.dart';
import 'package:nosso_combustivel/domain/veiculo.dart';

void main() {
  late BancoLocal banco;
  late VeiculoRepositorio veiculos;
  late RegistroRepositorio registros;

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  setUp(() {
    banco = BancoLocal(NativeDatabase.memory());
    DateTime agora() => DateTime(2026, 10, 29);
    veiculos = VeiculoRepositorio(banco, agora);
    registros = RegistroRepositorio(banco, agora);
  });

  tearDown(() => banco.close());

  test('salva e lê o carro com os combustíveis', () async {
    await veiculos.salvar(const Veiculo(
      id: 'v1',
      apelido: 'Hilux do trabalho',
      marca: 'Toyota',
      modelo: 'Hilux CD SRX 2.8 4x4 Diesel Aut.',
      ano: 2024,
      tipoEnergia: TipoEnergia.combustao,
      combustiveis: [Combustivel.dieselS10, Combustivel.dieselS500],
      capacidadeTanqueL: 80,
      odometroInicial: 32540,
    ), usuarioId: 'u1');

    final lidos = await veiculos.observarDoUsuario('u1').first;

    expect(lidos.single.apelido, 'Hilux do trabalho');
    expect(lidos.single.combustiveis, [Combustivel.dieselS10, Combustivel.dieselS500]);
    expect(lidos.single.capacidadeTanqueL, 80);
  });

  test('guarda valores sem perder centavos e esconde o que foi excluído', () async {
    await veiculos.salvar(const Veiculo(
      id: 'v1',
      apelido: 'Dolphin',
      marca: 'BYD',
      modelo: 'Dolphin',
      tipoEnergia: TipoEnergia.eletrico,
      combustiveis: [],
      odometroInicial: 0,
    ), usuarioId: 'u1');
    final recarga = Recarga(
      id: 'r1',
      veiculoId: 'v1',
      data: DateTime(2026, 10, 28),
      odometro: 1412,
      valorCentavos: 3864,
      local: LocalRecarga.casa,
      kwh: 42,
      precoKwh: 0.92,
      cargaCompleta: true,
    );
    await registros.salvarRecarga(recarga);

    final lidos = await registros.observarDoVeiculo('v1').first;
    final lida = lidos.single as Recarga;
    expect(lida.precoKwh, 0.92);
    expect(lida.valorCentavos, 3864);

    await registros.excluir(recarga);
    expect(await registros.observarDoVeiculo('v1').first, isEmpty);
  });

  test('cada conta vê só os próprios carros e o primeiro login adota os carros sem dono', () async {
    const carro = Veiculo(
      id: 'v1',
      apelido: 'Civic',
      marca: 'Honda',
      modelo: 'Civic',
      tipoEnergia: TipoEnergia.combustao,
      combustiveis: [Combustivel.gasolina],
      odometroInicial: 0,
    );
    await veiculos.salvar(carro, usuarioId: 'u1');
    await banco.customStatement("UPDATE veiculos SET usuario_id = NULL WHERE id = 'v1'");

    expect(await veiculos.observarDoUsuario('u2').first, isEmpty);

    await veiculos.adotarSemDono('u2');

    expect((await veiculos.observarDoUsuario('u2').first).single.id, 'v1');
  });
}
