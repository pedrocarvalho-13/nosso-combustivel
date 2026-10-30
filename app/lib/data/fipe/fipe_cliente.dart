import 'package:dio/dio.dart';

import '../../domain/tipo_veiculo.dart';

class OpcaoFipe {
  const OpcaoFipe(this.codigo, this.nome);

  final String codigo;
  final String nome;
}

class DetalheFipe {
  const DetalheFipe({
    required this.marca,
    required this.modelo,
    required this.anoModelo,
    required this.combustivel,
    required this.codigoFipe,
  });

  final String marca;
  final String modelo;
  final int? anoModelo;
  final String combustivel;
  final String codigoFipe;
}

class FipeCliente {
  FipeCliente(this._dio);

  static const _anoZeroKm = 32000;

  final Dio _dio;

  static String _base(TipoVeiculo tipo) =>
      'https://parallelum.com.br/fipe/api/v1/${tipo == TipoVeiculo.moto ? 'motos' : 'carros'}/marcas';

  Future<List<OpcaoFipe>> marcas(TipoVeiculo tipo) async {
    final resposta = await _dio.get<List<dynamic>>(_base(tipo));
    return _opcoes(resposta.data!);
  }

  Future<List<OpcaoFipe>> modelos(TipoVeiculo tipo, String marca) async {
    final resposta = await _dio.get<Map<String, dynamic>>('${_base(tipo)}/$marca/modelos');
    return _opcoes(resposta.data!['modelos'] as List<dynamic>);
  }

  Future<List<OpcaoFipe>> anos(TipoVeiculo tipo, String marca, String modelo) async {
    final resposta = await _dio.get<List<dynamic>>('${_base(tipo)}/$marca/modelos/$modelo/anos');
    return _opcoes(resposta.data!)
        .map((a) => OpcaoFipe(a.codigo, a.nome.replaceFirst('$_anoZeroKm', 'Zero km')))
        .toList();
  }

  Future<DetalheFipe> detalhe(TipoVeiculo tipo, String marca, String modelo, String ano) async {
    final resposta = await _dio.get<Map<String, dynamic>>('${_base(tipo)}/$marca/modelos/$modelo/anos/$ano');
    final dados = resposta.data!;
    final anoModelo = dados['AnoModelo'] as int?;
    return DetalheFipe(
      marca: dados['Marca'] as String,
      modelo: dados['Modelo'] as String,
      anoModelo: anoModelo == _anoZeroKm ? DateTime.now().year : anoModelo,
      combustivel: dados['Combustivel'] as String,
      codigoFipe: dados['CodigoFipe'] as String,
    );
  }

  static List<OpcaoFipe> _opcoes(List<dynamic> itens) => [
        for (final item in itens.cast<Map<String, dynamic>>()) OpcaoFipe('${item['codigo']}', item['nome'] as String),
      ];
}
