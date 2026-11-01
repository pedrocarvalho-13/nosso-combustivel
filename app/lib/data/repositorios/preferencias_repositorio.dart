import '../banco/banco_local.dart';
import '../../domain/tipo_gasolina.dart';

class PreferenciasRepositorio {
  PreferenciasRepositorio(this._banco);

  static const _veiculoAtivo = 'veiculo_ativo';
  static const _tarifaCasa = 'tarifa_casa_kwh';
  static const _onboardingHodometro = 'onboarding_hodometro';
  static const _ultimoPagamento = 'ultimo_pagamento';
  static const _pagamentoPadrao = 'pagamento_padrao';
  static const _gasolinaPadrao = 'gasolina_padrao';
  static const _metaMensal = 'meta_mensal_centavos';
  static const _periodoMedia = 'periodo_media_dias';
  static const _tema = 'tema';
  static const _fotosIa = 'fotos_ia';

  final BancoLocal _banco;

  Stream<String?> observarVeiculoAtivo() => _observar(_veiculoAtivo);

  Future<void> definirVeiculoAtivo(String veiculoId) => _gravar(_veiculoAtivo, veiculoId);

  Stream<double?> observarTarifaCasa() => _observar(_tarifaCasa).map((v) => v == null ? null : double.tryParse(v));

  Future<void> definirTarifaCasa(double tarifa) => _gravar(_tarifaCasa, '$tarifa');

  Future<bool> onboardingHodometroVisto() async => await _ler(_onboardingHodometro) != null;

  Future<void> marcarOnboardingHodometroVisto() => _gravar(_onboardingHodometro, 'sim');

  Future<String?> ultimoPagamento() => _ler(_ultimoPagamento);

  Future<void> definirUltimoPagamento(String valor) => _gravar(_ultimoPagamento, valor);

  Stream<String?> observarPagamentoPadrao() => _observar(_pagamentoPadrao);

  Stream<TipoGasolina> observarGasolinaPadrao() => _observar(_gasolinaPadrao).map(_lerGasolina);

  Future<TipoGasolina> gasolinaPadrao() async => _lerGasolina(await _ler(_gasolinaPadrao));

  Future<void> definirGasolinaPadrao(TipoGasolina tipo) => _gravar(_gasolinaPadrao, tipo.name);

  static TipoGasolina _lerGasolina(String? valor) =>
      TipoGasolina.values.where((t) => t.name == valor).firstOrNull ?? TipoGasolina.comum;

  Future<String?> pagamentoPadrao() => _ler(_pagamentoPadrao);

  Future<void> definirPagamentoPadrao(String? valor) =>
      valor == null ? _apagar(_pagamentoPadrao) : _gravar(_pagamentoPadrao, valor);

  Stream<int?> observarMetaMensal() => _observar(_metaMensal).map((v) => v == null ? null : int.tryParse(v));

  Future<void> definirMetaMensal(int? centavos) =>
      centavos == null ? _apagar(_metaMensal) : _gravar(_metaMensal, '$centavos');

  Stream<int> observarPeriodoMedia() => _observar(_periodoMedia).map((v) => int.tryParse(v ?? '') ?? 30);

  Future<void> definirPeriodoMedia(int dias) => _gravar(_periodoMedia, '$dias');

  Stream<String> observarTema() => _observar(_tema).map((v) => v ?? 'escuro');

  Future<void> definirTema(String tema) => _gravar(_tema, tema);

  Stream<bool> observarFotosIa() => _observar(_fotosIa).map((v) => v != 'nao');

  Future<void> definirFotosIa(bool ligado) => _gravar(_fotosIa, ligado ? 'sim' : 'nao');

  Future<void> _apagar(String chave) => (_banco.delete(_banco.preferencias)..where((p) => p.chave.equals(chave))).go();

  Future<String?> _ler(String chave) async =>
      (await (_banco.select(_banco.preferencias)..where((p) => p.chave.equals(chave))).getSingleOrNull())?.valor;

  Stream<String?> _observar(String chave) {
    final consulta = _banco.select(_banco.preferencias)..where((p) => p.chave.equals(chave));
    return consulta.watchSingleOrNull().map((linha) => linha?.valor);
  }

  Future<void> _gravar(String chave, String valor) => _banco
      .into(_banco.preferencias)
      .insertOnConflictUpdate(PreferenciasCompanion.insert(chave: chave, valor: valor));
}
