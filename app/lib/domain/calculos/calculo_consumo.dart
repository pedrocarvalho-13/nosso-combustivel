import '../combustivel.dart';
import '../registro_energia.dart';

class CicloConsumo {
  const CicloConsumo({
    required this.registroId,
    required this.fim,
    required this.distanciaKm,
    required this.quantidade,
    this.valorCentavos = 0,
    this.combustivel,
    this.misto = false,
  });

  final String registroId;
  final DateTime fim;
  final int distanciaKm;
  final double quantidade;
  final int valorCentavos;
  final Combustivel? combustivel;
  final bool misto;

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
    int ultimos = 5,
  }) {
    final validos = ciclos
        .where((c) => !c.misto && (qualquerCombustivel || c.combustivel == combustivel))
        .toList()
      ..sort((a, b) => a.fim.compareTo(b.fim));
    if (validos.isEmpty) return null;
    final janela = validos.skip(validos.length > ultimos ? validos.length - ultimos : 0);
    final distancia = janela.fold<int>(0, (soma, c) => soma + c.distanciaKm);
    final quantidade = janela.fold<double>(0, (soma, c) => soma + c.quantidade);
    return distancia / quantidade;
  }

  static double? custoPorKm(List<CicloConsumo> ciclos, {int ultimos = 5}) {
    if (ciclos.isEmpty) return null;
    final ordenados = [...ciclos]..sort((a, b) => a.fim.compareTo(b.fim));
    final janela = ordenados.skip(ordenados.length > ultimos ? ordenados.length - ultimos : 0);
    final distancia = janela.fold<int>(0, (soma, c) => soma + c.distanciaKm);
    final valor = janela.fold<int>(0, (soma, c) => soma + c.valorCentavos);
    return distancia == 0 ? null : valor / 100 / distancia;
  }

  static bool abaixoDaMedia(CicloConsumo ciclo, List<CicloConsumo> todos) {
    if (ciclo.misto) return false;
    final anteriores = todos.where((c) => c.fim.isBefore(ciclo.fim)).toList();
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
    T? ultimoCompleto;
    var quantidade = 0.0;
    var valor = 0;
    final combustiveis = <Combustivel?>{};

    for (final registro in ordenados) {
      if (ultimoCompleto == null) {
        if (registro.completo) ultimoCompleto = registro;
        continue;
      }
      quantidade += registro.quantidade;
      valor += registro.valorCentavos;
      combustiveis.add(combustivelDe(registro));
      if (!registro.completo) continue;

      final distancia = registro.odometro - ultimoCompleto.odometro;
      if (distancia > 0 && quantidade > 0) {
        ciclos.add(CicloConsumo(
          registroId: registro.id,
          fim: registro.data,
          distanciaKm: distancia,
          quantidade: quantidade,
          valorCentavos: valor,
          combustivel: combustiveis.length == 1 ? combustiveis.first : null,
          misto: combustiveis.length > 1,
        ));
      }
      ultimoCompleto = registro;
      quantidade = 0;
      valor = 0;
      combustiveis.clear();
    }
    return ciclos;
  }
}
