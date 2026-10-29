import '../combustivel.dart';
import '../tipo_energia.dart';

class EnergiaIdentificada {
  const EnergiaIdentificada(this.tipo, this.combustiveis);

  final TipoEnergia tipo;
  final List<Combustivel> combustiveis;
}

abstract final class IdentificacaoEnergia {
  static const _termosPlugin = ['plug-in', 'plugin', 'phev', 'dm-i', 'dmi'];
  static const _termosHibrido = ['hibrido', 'hybrid', 'hev'];
  static const _termosEletrico = ['eletrico', 'electric', 'ev', 'bev'];

  static EnergiaIdentificada identificar({required String modelo, required String combustivelFipe}) {
    final nome = ' ${_normalizar(modelo).replaceAll(RegExp(r'[()/,.]'), ' ')} ';
    final combustivel = _normalizar(combustivelFipe);
    bool tem(List<String> termos) => termos.any((t) => nome.contains(' $t ') || (t.length > 3 && nome.contains(t)));

    if (combustivel.contains('eletrico') || tem(_termosEletrico)) {
      return const EnergiaIdentificada(TipoEnergia.eletrico, []);
    }

    final flex = tem(['flex']);
    final combustiveisHibrido = flex ? const [Combustivel.gasolina, Combustivel.etanol] : const [Combustivel.gasolina];
    if (tem(_termosPlugin)) return EnergiaIdentificada(TipoEnergia.hibridoPlugin, combustiveisHibrido);
    if (combustivel.contains('hibrido') || tem(_termosHibrido)) {
      return EnergiaIdentificada(TipoEnergia.hibridoComum, combustiveisHibrido);
    }

    if (combustivel.contains('diesel') || tem(['diesel'])) {
      return const EnergiaIdentificada(TipoEnergia.combustao, [Combustivel.dieselS10, Combustivel.dieselS500]);
    }
    if (flex) return const EnergiaIdentificada(TipoEnergia.combustao, [Combustivel.gasolina, Combustivel.etanol]);
    if (combustivel.contains('alcool') || combustivel.contains('etanol')) {
      return const EnergiaIdentificada(TipoEnergia.combustao, [Combustivel.etanol]);
    }
    return const EnergiaIdentificada(TipoEnergia.combustao, [Combustivel.gasolina]);
  }

  static String _normalizar(String texto) {
    const deParaAcentos = {
      'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'é': 'e', 'ê': 'e', 'í': 'i',
      'ó': 'o', 'ô': 'o', 'õ': 'o', 'ú': 'u', 'ç': 'c',
    };
    return texto.toLowerCase().split('').map((c) => deParaAcentos[c] ?? c).join();
  }
}
