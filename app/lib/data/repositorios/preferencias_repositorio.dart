import '../banco/banco_local.dart';

class PreferenciasRepositorio {
  PreferenciasRepositorio(this._banco);

  static const _veiculoAtivo = 'veiculo_ativo';
  static const _tarifaCasa = 'tarifa_casa_kwh';

  final BancoLocal _banco;

  Stream<String?> observarVeiculoAtivo() => _observar(_veiculoAtivo);

  Future<void> definirVeiculoAtivo(String veiculoId) => _gravar(_veiculoAtivo, veiculoId);

  Stream<double?> observarTarifaCasa() => _observar(_tarifaCasa).map((v) => v == null ? null : double.tryParse(v));

  Future<void> definirTarifaCasa(double tarifa) => _gravar(_tarifaCasa, '$tarifa');

  Stream<String?> _observar(String chave) {
    final consulta = _banco.select(_banco.preferencias)..where((p) => p.chave.equals(chave));
    return consulta.watchSingleOrNull().map((linha) => linha?.valor);
  }

  Future<void> _gravar(String chave, String valor) => _banco
      .into(_banco.preferencias)
      .insertOnConflictUpdate(PreferenciasCompanion.insert(chave: chave, valor: valor));
}
