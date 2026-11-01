import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/combustivel.dart';
import '../sync/cliente_sync.dart';

class PrecoInformado {
  const PrecoInformado({required this.combustivel, required this.precoLitro, required this.data});

  final Combustivel combustivel;
  final double precoLitro;
  final DateTime data;
}

class PostoProximo {
  const PostoProximo({
    required this.id,
    required this.nome,
    required this.latitude,
    required this.longitude,
    required this.distanciaMetros,
    this.bandeira,
    this.endereco,
    this.precos = const [],
  });

  factory PostoProximo.deJson(Map<String, dynamic> json) => PostoProximo(
        id: json['id'] as String,
        nome: json['nome'] as String,
        bandeira: json['bandeira'] as String?,
        endereco: json['endereco'] as String?,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        distanciaMetros: (json['distanciaMetros'] as num).toInt(),
        precos: [
          for (final preco in (json['precos'] as List?) ?? const [])
            if (Combustivel.values.where((c) => c.name == preco['combustivel']).firstOrNull case final combustivel?)
              PrecoInformado(
                combustivel: combustivel,
                precoLitro: (preco['precoLitro'] as num).toDouble(),
                data: DateTime.parse(preco['data'] as String).toLocal(),
              ),
        ],
      );

  final String id;
  final String nome;
  final String? bandeira;
  final String? endereco;
  final double latitude;
  final double longitude;
  final int distanciaMetros;
  final List<PrecoInformado> precos;

  PrecoInformado? precoDe(Combustivel? combustivel) =>
      combustivel == null ? null : precos.where((p) => p.combustivel == combustivel).firstOrNull;
}

class PostosProximos {
  const PostosProximos({required this.postos, required this.buscaCompleta});

  final List<PostoProximo> postos;
  final bool buscaCompleta;
}

class ErroPostos implements Exception {
  const ErroPostos(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

class ClientePostos {
  ClientePostos(this._dio);

  final Dio _dio;

  Future<PostosProximos> proximos({required double latitude, required double longitude, int raioMetros = 1500}) async {
    try {
      final resposta = await _dio.get<Map<String, dynamic>>(
        '/postos/proximos',
        queryParameters: {'lat': latitude, 'lng': longitude, 'raio': raioMetros},
      );
      final corpo = resposta.data!;
      return PostosProximos(
        postos: [for (final p in corpo['postos'] as List) PostoProximo.deJson(p as Map<String, dynamic>)],
        buscaCompleta: corpo['buscaCompleta'] as bool? ?? true,
      );
    } on DioException catch (erro) {
      throw ErroPostos(_mensagem(erro));
    }
  }

  Future<PostoProximo> cadastrar({
    required String nome,
    String? bandeira,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final resposta = await _dio.post<Map<String, dynamic>>('/postos', data: {
        'nome': nome,
        'bandeira': bandeira,
        'latitude': latitude,
        'longitude': longitude,
      });
      return PostoProximo.deJson(resposta.data!);
    } on DioException catch (erro) {
      throw ErroPostos(_mensagem(erro));
    }
  }

  String _mensagem(DioException erro) {
    final titulo = erro.response?.data is Map ? (erro.response!.data as Map)['title'] as String? : null;
    return switch (erro.response?.statusCode) {
      null => 'Sem conexão. Confira a internet e tente de novo.',
      429 => 'Muitas buscas seguidas. Espere um minuto.',
      400 => titulo ?? 'Dados do posto inválidos.',
      _ => 'Não deu para buscar os postos agora.',
    };
  }
}

final clientePostosProvider = Provider<ClientePostos>((ref) => ClientePostos(ref.watch(dioApiProvider)));
