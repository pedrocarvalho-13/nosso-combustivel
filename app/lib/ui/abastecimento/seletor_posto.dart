import 'package:flutter/material.dart';

import '../../data/postos/cliente_postos.dart';
import '../../domain/combustivel.dart';
import '../../domain/tipo_gasolina.dart';
import '../postos/lugares_view.dart';
import '../postos/postos_view.dart';

class PostoEscolhido {
  const PostoEscolhido({required this.id, required this.nome});

  final String id;
  final String nome;
}

Future<PostoEscolhido?> escolherPosto(
  BuildContext context, {
  Combustivel? combustivel,
  List<Combustivel> combustiveis = const [],
  TipoGasolina? tipoGasolina,
}) =>
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<PostoEscolhido>(
        builder: (contexto) => LugaresView(
          tipoInicial: TipoPosto.combustivel,
          tiposPermitidos: const [TipoPosto.combustivel],
          combustiveis: combustiveis.isEmpty && combustivel != null ? [combustivel] : combustiveis,
          combustivelInicial: combustivel,
          tipoGasolinaInicial: tipoGasolina ?? TipoGasolina.comum,
          aoEscolher: (posto) => Navigator.of(contexto).pop(PostoEscolhido(id: posto.id, nome: posto.nome)),
          aoIrAte: (posto) => abrirRota(contexto, posto),
        ),
      ),
    );
