import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/combustivel.dart';
import '../../domain/tipo_energia.dart';
import '../../domain/tipo_veiculo.dart';
import '../sync/cliente_sync.dart';

enum TipoLeitura { abastecimento, recarga }

class CapacidadeSugerida {
  const CapacidadeSugerida({this.tanqueL, this.bateriaKwh});

  final double? tanqueL;
  final double? bateriaKwh;
}

class LeituraFoto {
  const LeituraFoto({
    this.litros,
    this.precoLitro,
    this.kwh,
    this.precoKwh,
    this.valorTotal,
    this.odometro,
    this.combustivel,
  });

  final double? litros;
  final double? precoLitro;
  final double? kwh;
  final double? precoKwh;
  final double? valorTotal;
  final int? odometro;
  final Combustivel? combustivel;
}

class ErroIa implements Exception {
  const ErroIa(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

class ClienteIa {
  ClienteIa(this._dio);

  final Dio _dio;

  Future<CapacidadeSugerida> estimarCapacidade({
    required TipoVeiculo tipoVeiculo,
    required String marca,
    required String modelo,
    int? ano,
    String? codigoFipe,
    required TipoEnergia tipoEnergia,
  }) async {
    final dados = await _enviar('/ia/capacidade', {
      'tipoVeiculo': tipoVeiculo.name,
      'marca': marca,
      'modelo': modelo,
      'ano': ano,
      'codigoFipe': codigoFipe,
      'tipoEnergia': tipoEnergia.name,
    });
    return CapacidadeSugerida(
      tanqueL: _numero(dados['capacidadeTanqueL']),
      bateriaKwh: _numero(dados['capacidadeBateriaKwh']),
    );
  }

  Future<LeituraFoto> lerFoto(Uint8List imagem, String tipoMime, TipoLeitura tipo) async {
    final dados = await _enviar('/ia/leitura', {
      'tipo': tipo.name,
      'imagemBase64': base64Encode(imagem),
      'tipoMime': tipoMime,
    });
    final combustivel = dados['combustivel'] as String?;
    return LeituraFoto(
      litros: _numero(dados['litros']),
      precoLitro: _numero(dados['precoLitro']),
      kwh: _numero(dados['kwh']),
      precoKwh: _numero(dados['precoKwh']),
      valorTotal: _numero(dados['valorTotal']),
      odometro: (dados['odometro'] as num?)?.toInt(),
      combustivel: Combustivel.values.where((c) => c.name == combustivel).firstOrNull,
    );
  }

  Future<Map<String, dynamic>> _enviar(String caminho, Map<String, dynamic> corpo) async {
    try {
      final resposta = await _dio.post<Map<String, dynamic>>(
        caminho,
        data: corpo,
        options: Options(receiveTimeout: const Duration(seconds: 100)),
      );
      return resposta.data!;
    } on DioException catch (erro) {
      final dados = erro.response?.data;
      final titulo = dados is Map ? dados['title'] as String? : null;
      throw ErroIa(switch (erro.response?.statusCode) {
        null => 'Sem conexão com a internet.',
        429 => 'Muitas consultas seguidas. Espere um minuto e tente de novo.',
        _ => titulo ?? 'Não foi possível consultar a IA agora.',
      });
    }
  }

  static double? _numero(Object? valor) => (valor as num?)?.toDouble();
}

final clienteIaProvider = Provider<ClienteIa>((ref) => ClienteIa(ref.watch(dioApiProvider)));
