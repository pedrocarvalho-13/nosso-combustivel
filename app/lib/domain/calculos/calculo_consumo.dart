import '../combustivel.dart';
import '../registro_energia.dart';

class CicloConsumo {
  const CicloConsumo({
    required this.registroId,
    required this.inicio,
    required this.fim,
    required this.distanciaKm,
    required this.quantidade,
    this.valorCentavos = 0,
    this.combustivel,
    this.exato = false,
  });

  final String registroId;
  final DateTime inicio;
  final DateTime fim;
  final int distanciaKm;
  final double quantidade;
  final int valorCentavos;
  final Combustivel? combustivel;
  final bool exato;

  double get rendimento => distanciaKm / quantidade;
}

abstract final class CalculoConsumo {
  static const quedaParaAlerta = 0.15;

  static List<CicloConsumo> ciclosDeAbastecimento(Iterable<Abastecimento> abastecimentos) =>
      _ciclos(abastecimentos.toList(), (a) => a.combustivel);

  static List<CicloConsumo> ciclosDeRecarga(Iterable<Recarga> recargas) =>
      _ciclos(recargas.toList(), (_) => null);

  static double? media(
    List<CicloConsumo> ciclos, {
    Combustivel? combustivel,
    bool qualquerCombustivel = false,
    int ultimos = 10,
  }) {
    final validos = ciclos.where((c) => qualquerCombustivel || c.combustivel == combustivel).toList()
      ..sort((a, b) => a.fim.compareTo(b.fim));
    if (validos.isEmpty) return null;
    final janela = validos.skip(validos.length > ultimos ? validos.length - ultimos : 0);
    final distancia = janela.fold<int>(0, (soma, c) => soma + c.distanciaKm);
    final quantidade = janela.fold<double>(0, (soma, c) => soma + c.quantidade);
    return distancia / quantidade;
  }

  static double? custoPorKm(List<CicloConsumo> ciclos, {int ultimos = 10}) {
    if (ciclos.isEmpty) return null;
    final ordenados = [...ciclos]..sort((a, b) => a.fim.compareTo(b.fim));
    final janela = ordenados.skip(ordenados.length > ultimos ? ordenados.length - ultimos : 0);
    final distancia = janela.fold<int>(0, (soma, c) => soma + c.distanciaKm);
    final valor = janela.fold<int>(0, (soma, c) => soma + c.valorCentavos);
    return distancia == 0 ? null : valor / 100 / distancia;
  }

  static ({int km, double quantidade, double media})? mediaDesde(
    List<CicloConsumo> ciclos,
    DateTime desde, {
    Combustivel? combustivel,
    bool qualquerCombustivel = false,
  }) {
    final janela = ciclos.where(
      (c) => !c.fim.isBefore(desde) && (qualquerCombustivel || c.combustivel == combustivel),
    );
    if (janela.isEmpty) return null;
    final km = janela.fold<int>(0, (soma, c) => soma + c.distanciaKm);
    final quantidade = janela.fold<double>(0, (soma, c) => soma + c.quantidade);
    return (km: km, quantidade: quantidade, media: km / quantidade);
  }

  static List<CicloConsumo> ultimos(
    List<CicloConsumo> ciclos,
    int quantos, {
    Combustivel? combustivel,
    bool qualquerCombustivel = false,
  }) {
    final filtrados = ciclos.where((c) => qualquerCombustivel || c.combustivel == combustivel).toList()
      ..sort((a, b) => a.fim.compareTo(b.fim));
    return filtrados.skip(filtrados.length > quantos ? filtrados.length - quantos : 0).toList();
  }

  static bool abaixoDaMedia(CicloConsumo ciclo, List<CicloConsumo> todos) {
    if (!ciclo.exato) return false;
    final anteriores = todos.where((c) => c.exato && c.fim.isBefore(ciclo.fim)).toList();
    final referencia = media(anteriores, combustivel: ciclo.combustivel);
    if (referencia == null) return false;
    return ciclo.rendimento < referencia * (1 - quedaParaAlerta);
  }

  static List<CicloConsumo> _ciclos<T extends RegistroEnergia>(
    List<T> registros,
    Combustivel? Function(T) combustivelDe,
  ) {
    final ordenados = [...registros]..sort((a, b) {
        final porOdometro = a.odometro.compareTo(b.odometro);
        return porOdometro != 0 ? porOdometro : a.data.compareTo(b.data);
      });
    final ciclos = <CicloConsumo>[];
    for (var i = 0; i + 1 < ordenados.length; i++) {
      final atual = ordenados[i];
      final proximo = ordenados[i + 1];
      if (!atual.contaNaMedia) continue;
      final distancia = proximo.odometro - atual.odometro;
      if (distancia <= 0 || atual.quantidade <= 0) continue;
      ciclos.add(CicloConsumo(
        registroId: atual.id,
        inicio: atual.data,
        fim: proximo.data,
        distanciaKm: distancia,
        quantidade: atual.quantidade,
        valorCentavos: atual.valorCentavos,
        combustivel: combustivelDe(atual),
        exato: atual.completo && proximo.completo,
      ));
    }
    return ciclos;
  }
}
