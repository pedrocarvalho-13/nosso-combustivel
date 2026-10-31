import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nosso_combustivel/data/banco/banco_local.dart';

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  test('atualizar o banco não falha quando a coluna já existe', () async {
    final pasta = await Directory.systemTemp.createTemp('migracao');
    final arquivo = File('${pasta.path}/banco.sqlite');

    final primeiro = BancoLocal(NativeDatabase(arquivo));
    await primeiro.customStatement('PRAGMA user_version = 3');
    await primeiro.close();

    final segundo = BancoLocal(NativeDatabase(arquivo));
    final colunas = await segundo.customSelect('PRAGMA table_info("veiculos")').get();
    expect(colunas.where((c) => c.read<String>('name') == 'tipo_veiculo'), hasLength(1));
    await segundo.close();
    await pasta.delete(recursive: true);
  });

  test('abrir o banco recria a coluna que sumiu mesmo com a versão já atualizada', () async {
    final pasta = await Directory.systemTemp.createTemp('migracao');
    final arquivo = File('${pasta.path}/banco.sqlite');

    final primeiro = BancoLocal(NativeDatabase(arquivo));
    await primeiro.customStatement('ALTER TABLE "veiculos" DROP COLUMN "tipo_veiculo"');
    await primeiro.close();

    final segundo = BancoLocal(NativeDatabase(arquivo));
    final colunas = await segundo.customSelect('PRAGMA table_info("veiculos")').get();
    expect(colunas.where((c) => c.read<String>('name') == 'tipo_veiculo'), hasLength(1));
    await segundo.close();
    await pasta.delete(recursive: true);
  });
}
