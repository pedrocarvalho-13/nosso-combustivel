import 'tipo_energia.dart';
import 'tipo_veiculo.dart';

enum TipoCampo { escolha, multipla, texto, numero }

class CampoDetalhe {
  const CampoDetalhe(this.chave, this.rotulo, this.tipo, {this.opcoes = const []});

  final String chave;
  final String rotulo;
  final TipoCampo tipo;
  final List<String> opcoes;
}

enum CategoriaManutencao {
  oleo('Troca de óleo', intervaloKm: 10000, intervaloMeses: 12, combustao: true, campos: [
    CampoDetalhe('tipo', 'Tipo', TipoCampo.escolha, opcoes: ['Mineral', 'Semissintético', 'Sintético']),
    CampoDetalhe('viscosidade', 'Viscosidade', TipoCampo.escolha,
        opcoes: ['0W-20', '5W-30', '5W-40', '10W-40', '15W-40', '20W-50']),
    CampoDetalhe('marca', 'Marca', TipoCampo.texto),
    CampoDetalhe('litros', 'Litros', TipoCampo.numero),
  ]),
  filtros('Filtros', intervaloKm: 10000, intervaloMeses: 12, campos: [
    CampoDetalhe('quais', 'Quais', TipoCampo.multipla, opcoes: ['De óleo', 'De ar', 'De combustível', 'De cabine']),
  ]),
  pneus('Pneus', intervaloKm: 10000, campos: [
    CampoDetalhe('servicos', 'O que foi feito', TipoCampo.multipla,
        opcoes: ['Troca', 'Rodízio', 'Alinhamento', 'Balanceamento', 'Conserto']),
    CampoDetalhe('quantidade', 'Pneus trocados', TipoCampo.escolha, opcoes: ['1', '2', '4']),
    CampoDetalhe('medida', 'Medida', TipoCampo.texto),
    CampoDetalhe('marca', 'Marca', TipoCampo.texto),
  ]),
  freios('Freios', campos: [
    CampoDetalhe('itens', 'O que foi trocado', TipoCampo.multipla, opcoes: ['Pastilhas', 'Discos', 'Fluido', 'Lonas']),
    CampoDetalhe('eixo', 'Eixo', TipoCampo.escolha, opcoes: ['Dianteiro', 'Traseiro', 'Os dois']),
  ]),
  correias('Correias', intervaloKm: 50000, intervaloMeses: 60, combustao: true, campos: [
    CampoDetalhe('quais', 'Quais', TipoCampo.multipla, opcoes: ['Dentada', 'Alternador', 'Tensor']),
  ]),
  velas('Velas', intervaloKm: 30000, intervaloMeses: 24, combustao: true),
  bateria('Bateria', intervaloMeses: 36, campos: [
    CampoDetalhe('amperagem', 'Amperagem (Ah)', TipoCampo.numero),
    CampoDetalhe('marca', 'Marca', TipoCampo.texto),
  ]),
  eletrica('Elétrica', campos: [
    CampoDetalhe('itens', 'O que foi feito', TipoCampo.multipla,
        opcoes: ['Lâmpadas', 'Alternador', 'Motor de arranque', 'Fiação']),
  ]),
  suspensao('Suspensão', campos: [
    CampoDetalhe('itens', 'O que foi trocado', TipoCampo.multipla,
        opcoes: ['Amortecedores', 'Molas', 'Buchas', 'Pivôs', 'Terminais', 'Direção']),
  ]),
  arCondicionado('Ar-condicionado', intervaloMeses: 12, campos: [
    CampoDetalhe('itens', 'O que foi feito', TipoCampo.multipla, opcoes: ['Higienização', 'Gás', 'Filtro de cabine', 'Conserto']),
  ]),
  arrefecimento('Arrefecimento', intervaloKm: 40000, intervaloMeses: 24, combustao: true),
  cambio('Câmbio e embreagem', campos: [
    CampoDetalhe('itens', 'O que foi feito', TipoCampo.multipla, opcoes: ['Óleo do câmbio', 'Embreagem', 'Conserto']),
  ]),
  lataria('Lataria e vidros', campos: [
    CampoDetalhe('itens', 'O que foi feito', TipoCampo.multipla,
        opcoes: ['Funilaria', 'Chaparia', 'Pintura', 'Vidros', 'Insulfilm']),
  ]),
  tapecaria('Tapeçaria'),
  relacao('Relação', intervaloKm: 15000, soMoto: true, campos: [
    CampoDetalhe('itens', 'O que foi trocado', TipoCampo.multipla, opcoes: ['Corrente', 'Coroa', 'Pinhão']),
  ]),
  bateriaAltaTensao('Bateria de alta tensão', soEletrico: true),
  revisao('Revisão', intervaloKm: 10000, intervaloMeses: 12),
  outro('Outro');

  const CategoriaManutencao(
    this.rotulo, {
    this.intervaloKm,
    this.intervaloMeses,
    this.campos = const [],
    this.combustao = false,
    this.soMoto = false,
    this.soEletrico = false,
  });

  final String rotulo;
  final int? intervaloKm;
  final int? intervaloMeses;
  final List<CampoDetalhe> campos;
  final bool combustao;
  final bool soMoto;
  final bool soEletrico;

  bool get temLembrete => intervaloKm != null || intervaloMeses != null;

  bool serveParaVeiculo(TipoEnergia energia, TipoVeiculo tipo) {
    if (combustao && !energia.abastece) return false;
    if (soMoto && tipo != TipoVeiculo.moto) return false;
    if (soEletrico && !energia.recarrega) return false;
    return true;
  }

  static CategoriaManutencao? porNome(String nome) => values.where((c) => c.name == nome).firstOrNull;

  String intervaloLegivel() {
    final partes = [
      if (intervaloKm != null) 'a cada ${_milhar(intervaloKm!)} km',
      if (intervaloMeses != null) '${intervaloKm == null ? 'a cada ' : ''}$intervaloMeses meses',
    ];
    return partes.join(' ou ');
  }

  static String _milhar(int valor) {
    final texto = '$valor';
    final grupos = <String>[];
    for (var i = texto.length; i > 0; i -= 3) {
      grupos.insert(0, texto.substring(i - 3 < 0 ? 0 : i - 3, i));
    }
    return grupos.join('.');
  }
}
