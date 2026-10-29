import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nosso_combustivel/data/banco/banco_local.dart';
import 'package:nosso_combustivel/data/repositorios/registro_repositorio.dart';
import 'package:nosso_combustivel/data/repositorios/veiculo_repositorio.dart';
import 'package:nosso_combustivel/data/sync/sincronizacao_local.dart';
import 'package:nosso_combustivel/domain/combustivel.dart';
import 'package:nosso_combustivel/domain/registro_energia.dart';
import 'package:nosso_combustivel/domain/tipo_energia.dart';
import 'package:nosso_combustivel/domain/veiculo.dart';

void main() {
  late BancoLocal banco;
  late SincronizacaoLocal sincronizacao;
  late VeiculoRepositorio veiculos;
  late RegistroRepositorio registros;
  var agora = DateTime(2026, 10, 29, 12);

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  setUp(() {
    banco = BancoLocal(NativeDatabase.memory());
    agora = DateTime(2026, 10, 29, 12);
    sincronizacao = SincronizacaoLocal(banco);
    veiculos = VeiculoRepositorio(banco, () => agora);
    registros = RegistroRepositorio(banco, () => agora);
  });

  tearDown(() => banco.close());

  const civic = Veiculo(
    id: 'v1',
    apelido: 'Meu Civic',
    marca: 'Honda',
    modelo: 'Civic',
    tipoEnergia: TipoEnergia.combustao,
    combustiveis: [Combustivel.gasolina, Combustivel.etanol],
    odometroInicial: 47000,
  );

  Abastecimento abastecimento(double litros) => Abastecimento(
        id: 'a1',
        veiculoId: 'v1',
        data: DateTime(2026, 10, 27),
        odometro: 47344,
        valorCentavos: 16006,
        combustivel: Combustivel.etanol,
        litros: litros,
        precoLitro: 4.19,
        tanqueCheio: true,
      );

  Map<String, dynamic> carroDoServidor(String apelido, DateTime atualizadoEm) => {
        'veiculos': [
          {
            'id': 'v1',
            'apelido': apelido,
            'marca': 'Honda',
            'modelo': 'Civic',
            'ano': 2021,
            'codigoFipe': null,
            'tipoEnergia': 'combustao',
            'combustiveis': ['gasolina', 'etanol'],
            'capacidadeTanqueL': 50.0,
            'capacidadeBateriaKwh': null,
            'odometroInicial': 47000,
            'criadoEm': DateTime.utc(2026, 10, 1).toIso8601String(),
            'atualizadoEm': atualizadoEm.toUtc().toIso8601String(),
            'excluidoEm': null,
          },
        ],
        'abastecimentos': <Map<String, dynamic>>[],
        'recargas': <Map<String, dynamic>>[],
      };

  test('o que foi salvo no celular fica pendente e vira JSON para a API', () async {
    await veiculos.salvar(civic, usuarioId: 'u1');
    await registros.salvarAbastecimento(abastecimento(38.2));

    final lote = await sincronizacao.pendentes('u1');
    final json = lote.paraJson();

    expect(lote.veiculos, hasLength(1));
    expect(lote.abastecimentos, hasLength(1));
    expect((json['veiculos'] as List).single['combustiveis'], ['gasolina', 'etanol']);
    expect((json['abastecimentos'] as List).single['litros'], 38.2);
    expect((json['abastecimentos'] as List).single['valorTotal'], 160.06);
  });

  test('depois de enviado deixa de ser pendente, mas uma edição nova volta a ficar', () async {
    await veiculos.salvar(civic, usuarioId: 'u1');
    await registros.salvarAbastecimento(abastecimento(38.2));
    final enviado = await sincronizacao.pendentes('u1');

    agora = agora.add(const Duration(minutes: 1));
    await registros.salvarAbastecimento(abastecimento(40));
    await sincronizacao.marcarEnviados(enviado);
    final restante = await sincronizacao.pendentes('u1');

    expect(restante.veiculos, isEmpty);
    expect(restante.abastecimentos.single.litrosMl, 40000);
  });

  test('carro que vem do servidor aparece para a conta sem ficar pendente', () async {
    await sincronizacao.aplicarDoServidor(carroDoServidor('Civic do servidor', DateTime.utc(2026, 10, 29)), 'u1');

    final lidos = await veiculos.observarDoUsuario('u1').first;

    expect(lidos.single.apelido, 'Civic do servidor');
    expect((await sincronizacao.pendentes('u1')).vazio, isTrue);
  });

  test('edição local mais nova que ainda não subiu não é sobrescrita', () async {
    await veiculos.salvar(civic, usuarioId: 'u1');

    await sincronizacao.aplicarDoServidor(carroDoServidor('Mais antigo', DateTime(2026, 10, 29, 11)), 'u1');
    expect((await veiculos.observarDoUsuario('u1').first).single.apelido, 'Meu Civic');

    await sincronizacao.aplicarDoServidor(carroDoServidor('Mais novo', DateTime(2026, 10, 29, 13)), 'u1');
    expect((await veiculos.observarDoUsuario('u1').first).single.apelido, 'Mais novo');
  });

  test('o cursor da última sincronização fica guardado por conta', () async {
    await sincronizacao.gravarCursor('u1', '2026-10-29T15:00:00.0000000+00:00');

    expect(await sincronizacao.cursor('u1'), DateTime.utc(2026, 10, 29, 15));
    expect(await sincronizacao.cursor('u2'), isNull);
  });
}
