import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../domain/combustivel.dart';
import '../../domain/registro_energia.dart';
import '../../domain/tipo_energia.dart';

part 'banco_local.g.dart';

mixin Sincronizavel on Table {
  TextColumn get id => text()();
  DateTimeColumn get criadoEm => dateTime()();
  DateTimeColumn get atualizadoEm => dateTime()();
  DateTimeColumn get excluidoEm => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('VeiculoLinha')
class Veiculos extends Table with Sincronizavel {
  TextColumn get usuarioId => text().nullable()();
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
}

@DataClassName('PreferenciaLinha')
class Preferencias extends Table {
  TextColumn get chave => text()();
  TextColumn get valor => text()();

  @override
  Set<Column> get primaryKey => {chave};
}

@DriftDatabase(tables: [Veiculos, Abastecimentos, Recargas, Preferencias])
class BancoLocal extends _$BancoLocal {
  BancoLocal([QueryExecutor? executor]) : super(executor ?? _abrir());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrador, de, para) async {
          if (de < 2) await migrador.addColumn(veiculos, veiculos.usuarioId);
        },
      );

  static QueryExecutor _abrir() => driftDatabase(
        name: 'nosso_combustivel',
        web: DriftWebOptions(
          sqlite3Wasm: Uri.parse('sqlite3.wasm'),
          driftWorker: Uri.parse('drift_worker.js'),
        ),
      );
}
