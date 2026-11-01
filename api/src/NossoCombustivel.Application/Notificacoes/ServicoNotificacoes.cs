using NossoCombustivel.Application.Comum;

namespace NossoCombustivel.Application.Notificacoes;

public sealed record EnvioTeste(int Enviados, int Removidos);

public sealed class ServicoNotificacoes(IEnviadorPush enviador, IRepositorioInscricoes repositorio)
{
    private const int TamanhoMaximoEndpoint = 1000;
    private const int TamanhoMaximoChave = 200;
    private const int TamanhoMaximoAparelho = 100;

    public Resultado<string> ChavePublica() => string.IsNullOrWhiteSpace(enviador.ChavePublica)
        ? Resultado<string>.Falha(TipoErro.Indisponivel, "As notificações ainda não estão configuradas no servidor.")
        : Resultado<string>.Ok(enviador.ChavePublica);

    public async Task<Resultado<bool>> InscreverAsync(
        Guid usuarioId, InscricaoPush inscricao, string? aparelho, CancellationToken cancelamento)
    {
        if (!Uri.TryCreate(inscricao.Endpoint, UriKind.Absolute, out var endereco) || endereco.Scheme != Uri.UriSchemeHttps
            || inscricao.Endpoint.Length > TamanhoMaximoEndpoint)
            return Resultado<bool>.Falha(TipoErro.Validacao, "Endereço de notificação inválido.");
        if (string.IsNullOrWhiteSpace(inscricao.P256dh) || string.IsNullOrWhiteSpace(inscricao.Auth)
            || inscricao.P256dh.Length > TamanhoMaximoChave || inscricao.Auth.Length > TamanhoMaximoChave)
            return Resultado<bool>.Falha(TipoErro.Validacao, "Chaves de notificação inválidas.");

        var nome = string.IsNullOrWhiteSpace(aparelho) ? null : aparelho.Trim();
        if (nome?.Length > TamanhoMaximoAparelho) nome = nome[..TamanhoMaximoAparelho];
        await repositorio.SalvarAsync(usuarioId, inscricao, nome, cancelamento);
        return Resultado<bool>.Ok(true);
    }

    public Task CancelarAsync(Guid usuarioId, string endpoint, CancellationToken cancelamento) =>
        repositorio.RemoverAsync(usuarioId, endpoint, cancelamento);

    public async Task<Resultado<EnvioTeste>> EnviarTesteAsync(Guid usuarioId, CancellationToken cancelamento)
    {
        if (string.IsNullOrWhiteSpace(enviador.ChavePublica))
            return Resultado<EnvioTeste>.Falha(TipoErro.Indisponivel, "As notificações ainda não estão configuradas no servidor.");

        var inscricoes = await repositorio.DoUsuarioAsync(usuarioId, cancelamento);
        if (inscricoes.Count == 0)
            return Resultado<EnvioTeste>.Falha(TipoErro.NaoEncontrado, "Ative as notificações neste aparelho primeiro.");

        var mensagem = new MensagemPush(
            "Pit Garage", "Notificações ativadas. Os lembretes de lavagem, manutenção e contas vão chegar assim.", "/inicio");
        var enviados = new List<string>();
        var removidos = 0;
        foreach (var inscricao in inscricoes)
        {
            switch (await enviador.EnviarAsync(inscricao, mensagem, cancelamento))
            {
                case ResultadoEnvioPush.Enviado:
                    enviados.Add(inscricao.Endpoint);
                    break;
                case ResultadoEnvioPush.InscricaoExpirada:
                    await repositorio.RemoverAsync(usuarioId, inscricao.Endpoint, cancelamento);
                    removidos++;
                    break;
            }
        }

        if (enviados.Count == 0)
            return Resultado<EnvioTeste>.Falha(TipoErro.Indisponivel,
                removidos > 0 ? "Este aparelho não está mais inscrito. Ative as notificações de novo." : "Não deu para enviar agora. Tente de novo.");
        await repositorio.MarcarEnviadoAsync(enviados, cancelamento);
        return Resultado<EnvioTeste>.Ok(new EnvioTeste(enviados.Count, removidos));
    }
}
