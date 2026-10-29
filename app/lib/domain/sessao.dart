class UsuarioSessao {
  const UsuarioSessao({required this.id, required this.nome, required this.email});

  final String id;
  final String nome;
  final String email;

  factory UsuarioSessao.deJson(Map<String, dynamic> json) => UsuarioSessao(
        id: json['id'] as String,
        nome: json['nome'] as String,
        email: json['email'] as String,
      );

  Map<String, dynamic> paraJson() => {'id': id, 'nome': nome, 'email': email};
}

class Sessao {
  const Sessao({
    required this.usuario,
    required this.tokenAcesso,
    required this.acessoExpiraEm,
    required this.refreshToken,
  });

  final UsuarioSessao usuario;
  final String tokenAcesso;
  final DateTime acessoExpiraEm;
  final String refreshToken;

  factory Sessao.deJson(Map<String, dynamic> json) => Sessao(
        usuario: UsuarioSessao.deJson(json['usuario'] as Map<String, dynamic>),
        tokenAcesso: json['tokenAcesso'] as String,
        acessoExpiraEm: DateTime.parse(json['acessoExpiraEm'] as String),
        refreshToken: json['refreshToken'] as String,
      );

  Map<String, dynamic> paraJson() => {
        'usuario': usuario.paraJson(),
        'tokenAcesso': tokenAcesso,
        'acessoExpiraEm': acessoExpiraEm.toIso8601String(),
        'refreshToken': refreshToken,
      };
}
