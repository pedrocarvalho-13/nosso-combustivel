import '../categoria_manutencao.dart';
import '../registro_energia.dart';
import '../servico.dart';

enum SituacaoTroca { emDia, perto, vencida }

class ProximaTroca {
  const ProximaTroca({
    required this.categoria,
    required this.feitaEm,
    required this.fracao,
    this.feitaKm,
    this.proximaKm,
    this.proximaData,
    this.faltaKm,
    this.faltaDias,
  });

  final CategoriaManutencao categoria;
  final DateTime feitaEm;
  final int? feitaKm;
  final int? proximaKm;
  final DateTime? proximaData;
  final int? faltaKm;
  final int? faltaDias;
  final double fracao;

  SituacaoTroca get situacao => fracao >= 1
      ? SituacaoTroca.vencida
      : fracao >= 0.85
          ? SituacaoTroca.perto
          : SituacaoTroca.emDia;
}

abstract final class CalculoManutencao {
  static int odometroAtual({
    required int odometroInicial,
    required Iterable<RegistroEnergia> registros,
    required Iterable<Servico> servicos,
  }) {
    var maior = odometroInicial;
    for (final r in registros) {
      if (r.odometro > maior) maior = r.odometro;
    }
    for (final s in servicos) {
      if ((s.odometro ?? 0) > maior) maior = s.odometro!;
    }
    return maior;
  }

  static double? kmPorDia(Iterable<RegistroEnergia> registros) {
    final ordenados = [...registros]..sort((a, b) => a.data.compareTo(b.data));
    if (ordenados.length < 2) return null;
    final dias = ordenados.last.data.difference(ordenados.first.data).inHours / 24;
    final km = ordenados.last.odometro - ordenados.first.odometro;
    if (dias < 3 || km <= 0) return null;
    return km / dias;
  }

  static bool lembreteLigado(Servico servico, CategoriaManutencao categoria) =>
      categoria.temLembrete && (servico.detalhesDe(categoria.name)['lembrete'] as bool? ?? true);

  static (int?, int?) intervaloDe(Servico servico, CategoriaManutencao categoria) {
    final detalhes = servico.detalhesDe(categoria.name);
    final km = int.tryParse('${detalhes['intervaloKm'] ?? ''}'.replaceAll('.', ''));
    final meses = int.tryParse('${detalhes['intervaloMeses'] ?? ''}');
    if (km == null && meses == null) return (categoria.intervaloKm, categoria.intervaloMeses);
    return (km, meses);
  }

  static List<ProximaTroca> proximas({
    required List<Servico> servicos,
    required int odometroAtual,
    required DateTime agora,
  }) {
    final ultimoPorCategoria = <CategoriaManutencao, Servico>{};
    final ordenados = [...servicos]..sort((a, b) => b.data.compareTo(a.data));
    for (final servico in ordenados) {
      for (final nome in servico.categorias) {
        final categoria = CategoriaManutencao.porNome(nome);
        if (categoria == null || ultimoPorCategoria.containsKey(categoria)) continue;
        ultimoPorCategoria[categoria] = servico;
      }
    }

    final trocas = <ProximaTroca>[];
    ultimoPorCategoria.forEach((categoria, servico) {
      if (!lembreteLigado(servico, categoria)) return;
      final feitaKm = servico.odometro;
      final (intervaloKm, intervaloMeses) = intervaloDe(servico, categoria);
      final proximaKm = intervaloKm == null || feitaKm == null ? null : feitaKm + intervaloKm;
      final proximaData = intervaloMeses == null
          ? null
          : DateTime(servico.data.year, servico.data.month + intervaloMeses, servico.data.day);
      if (proximaKm == null && proximaData == null) return;

      final fracaoKm = proximaKm == null ? 0.0 : (odometroAtual - feitaKm!) / (proximaKm - feitaKm);
      final fracaoTempo = proximaData == null
          ? 0.0
          : agora.difference(servico.data).inHours / proximaData.difference(servico.data).inHours;
      trocas.add(ProximaTroca(
        categoria: categoria,
        feitaEm: servico.data,
        feitaKm: feitaKm,
        proximaKm: proximaKm,
        proximaData: proximaData,
        faltaKm: proximaKm == null ? null : proximaKm - odometroAtual,
        faltaDias: proximaData?.difference(agora).inDays,
        fracao: fracaoKm > fracaoTempo ? fracaoKm : fracaoTempo,
      ));
    });
    trocas.sort((a, b) => b.fracao.compareTo(a.fracao));
    return trocas;
  }
}
