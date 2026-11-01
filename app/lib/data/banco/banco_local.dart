import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../domain/combustivel.dart';
import '../../domain/forma_pagamento.dart';
import '../../domain/tipo_gasolina.dart';
import '../../domain/registro_energia.dart';
import '../../domain/tipo_energia.dart';
import '../../domain/tipo_veiculo.dart';

part 'banco_local.g.dart';

mixin Sincronizavel on Table {
  TextColumn get id => text()();
  DateTimeColumn get criadoEm => dateTime()();
  DateTimeColumn get atualizadoEm => dateTime()();
  DateTimeColumn get excluidoEm => dateTime().nullable()();
  BoolColumn get pendente => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('VeiculoLinha')
class Veiculos extends Table with Sincronizavel {
  TextColumn get usuarioId => text().nullable()();
  TextColumn get tipoVeiculo => textEnum<TipoVeiculo>().withDefault(const Constant('carro'))();
  TextColumn get apelido => text()();
  TextColumn get marca => text()();
  TextColumn get modelo => text()();
  IntColumn get ano => integer().nullable()();
  TextColumn get codigoFipe => text().nullable()();
  TextColumn get tipoEnergia => textEnum<TipoEnergia>()();
  TextColumn get combustiveis => text()();
  IntColumn get capacidadeTanqueMl => integer().nullable()();
  IntColumn get capacidadeBateriaWh => integer().nullable()();
  IntColumn get odometroInicial => integer()();
}

@DataClassName('AbastecimentoLinha')
class Abastecimentos extends Table with Sincronizavel {
  TextColumn get veiculoId => text().references(Veiculos, #id)();
  DateTimeColumn get data => dateTime()();
  IntColumn get odometro => integer()();
  TextColumn get combustivel => textEnum<Combustivel>()();
  IntColumn get litrosMl => integer()();
  IntColumn get precoLitroMilesimos => integer()();
  IntColumn get valorCentavos => integer()();
  BoolColumn get tanqueCheio => boolean()();
  TextColumn get posto => text().nullable()();
  TextColumn get postoId => text().nullable()();
  TextColumn get tipoGasolina => textEnum<TipoGasolina>().nullable()();
  TextColumn get formaPagamento => textEnum<FormaPagamento>().nullable()();
  TextColumn get cartaoId => text().nullable()();
  BoolColumn get contaNaMedia => boolean().withDefault(const Constant(true))();
}

@DataClassName('RecargaLinha')
class Recargas extends Table with Sincronizavel {
  TextColumn get veiculoId => text().references(Veiculos, #id)();
  DateTimeColumn get data => dateTime()();
  IntColumn get odometro => integer()();
  TextColumn get local => textEnum<LocalRecarga>()();
  IntColumn get energiaWh => integer()();
  IntColumn get precoKwhMilesimos => integer()();
  IntColumn get valorCentavos => integer()();
  BoolColumn get cargaCompleta => boolean()();
  TextColumn get formaPagamento => textEnum<FormaPagamento>().nullable()();
  TextColumn get cartaoId => text().nullable()();
  BoolColumn get contaNaMedia => boolean().withDefault(const Constant(true))();
}

@DataClassName('CartaoLinha')
class Cartoes extends Table with Sincronizavel {
  TextColumn get usuarioId => text()();
  TextColumn get nome => text()();
  TextColumn get banco => text().nullable()();
  IntColumn get diaFechamento => integer()();
}

@DataClassName('ServicoLinha')
class Servicos extends Table with Sincronizavel {
  TextColumn get veiculoId => text().references(Veiculos, #id)();
  TextColumn get tipo => text()();
  DateTimeColumn get data => dateTime()();
  IntColumn get odometro => integer().nullable()();
  TextColumn get categorias => text()();
  TextColumn get detalhes => text().nullable()();
  IntColumn get valorCentavos => integer()();
  IntColumn get pecasCentavos => integer().nullable()();
  IntColumn get maoDeObraCentavos => integer().nullable()();
  TextColumn get lugarId => text().nullable()();
  TextColumn get lugarNome => text().nullable()();
  TextColumn get formaPagamento => textEnum<FormaPagamento>().nullable()();
  TextColumn get cartaoId => text().nullable()();
  TextColumn get observacao => text().nullable()();
}

@DataClassName('PreferenciaLinha')
class Preferencias extends Table {
  TextColumn get chave => text()();
  TextColumn get valor => text()();

  @override
  Set<Column> get primaryKey => {chave};
}

@DriftDatabase(tables: [Veiculos, Abastecimentos, Recargas, Cartoes, Servicos, Preferencias])
class BancoLocal extends _$BancoLocal {
  BancoLocal([QueryExecutor? executor]) : super(executor ?? _abrir());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrador, de, para) => _garantirColunas(migrador),
        beforeOpen: (detalhes) async {
          if (!detalhes.wasCreated) await _garantirColunas(createMigrator());
        },
      );

  Future<void> _garantirColunas(Migrator migrador) async {
    await _adicionarSeFaltar(migrador, veiculos, veiculos.usuarioId);
    await _adicionarSeFaltar(migrador, veiculos, veiculos.pendente);
    await _adicionarSeFaltar(migrador, abastecimentos, abastecimentos.pendente);
    await _adicionarSeFaltar(migrador, recargas, recargas.pendente);
    await _adicionarSeFaltar(migrador, veiculos, veiculos.tipoVeiculo);
    await _adicionarSeFaltar(migrador, abastecimentos, abastecimentos.formaPagamento);
    await _adicionarSeFaltar(migrador, abastecimentos, abastecimentos.cartaoId);
    await _adicionarSeFaltar(migrador, recargas, recargas.formaPagamento);
    await _adicionarSeFaltar(migrador, recargas, recargas.cartaoId);
    await _adicionarSeFaltar(migrador, abastecimentos, abastecimentos.contaNaMedia);
    await _adicionarSeFaltar(migrador, recargas, recargas.contaNaMedia);
    await _adicionarSeFaltar(migrador, abastecimentos, abastecimentos.postoId);
    await _adicionarSeFaltar(migrador, abastecimentos, abastecimentos.tipoGasolina);
    await _criarSeFaltar(migrador, cartoes);
    await _criarSeFaltar(migrador, servicos);
  }

  Future<void> _criarSeFaltar(Migrator migrador, TableInfo tabela) async {
    final tabelas = await customSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      variables: [Variable.withString(tabela.actualTableName)],
    ).get();
    if (tabelas.isEmpty) await migrador.createTable(tabela);
  }

  Future<void> _adicionarSeFaltar(Migrator migrador, TableInfo tabela, GeneratedColumn coluna) async {
    final existentes = await customSelect('PRAGMA table_info("${tabela.actualTableName}")').get();
    if (existentes.any((linha) => linha.read<String>('name') == coluna.name)) return;
    try {
      await migrador.addColumn(tabela, coluna);
    } on Object catch (erro) {
      if (!erro.toString().contains('duplicate column name')) rethrow;
    }
  }

  static QueryExecutor _abrir() => driftDatabase(
        name: 'nosso_combustivel',
        web: DriftWebOptions(
          sqlite3Wasm: Uri.parse('sqlite3.wasm'),
          driftWorker: Uri.parse('drift_worker.js'),
        ),
      );
}
