import 'package:flutter/material.dart';

import '../../domain/combustivel.dart';
import '../../domain/tipo_gasolina.dart';
import '../postos/lista_postos_perto.dart';

class PostoEscolhido {
  const PostoEscolhido({required this.id, required this.nome});

  final String id;
  final String nome;
}

Future<PostoEscolhido?> escolherPosto(BuildContext context, {Combustivel? combustivel, TipoGasolina? tipoGasolina}) =>
    showModalBottomSheet<PostoEscolhido>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (contexto) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(contexto).height * 0.75),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(
                  'Postos perto de você',
                  style: Theme.of(contexto).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Flexible(
                child: ListaPostosPerto(
                  combustivel: combustivel,
                  tipoGasolina: tipoGasolina,
                  aoEscolher: (posto) => Navigator.of(contexto).pop(PostoEscolhido(id: posto.id, nome: posto.nome)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
