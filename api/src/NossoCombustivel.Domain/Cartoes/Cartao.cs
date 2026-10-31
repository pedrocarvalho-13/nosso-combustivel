namespace NossoCombustivel.Domain.Cartoes;

public sealed record DadosCartao(string Nome, int DiaFechamento, DateTimeOffset AtualizadoEm, DateTimeOffset? ExcluidoEm, string? Banco = null);

public sealed class Cartao
{
    private Cartao()
    {
    }

    public Guid Id { get; private set; }
    public Guid DonoId { get; private set; }
    public string Nome { get; private set; } = string.Empty;
    public string? Banco { get; private set; }
    public int DiaFechamento { get; private set; }
    public DateTimeOffset CriadoEm { get; private set; }
    public DateTimeOffset AtualizadoEm { get; private set; }
    public DateTimeOffset? ExcluidoEm { get; private set; }
    public DateTimeOffset SincronizadoEm { get; private set; }

    public static Cartao Criar(Guid id, Guid donoId, DadosCartao dados, DateTimeOffset criadoEm, DateTimeOffset agora)
    {
        Validar(dados);
        var cartao = new Cartao { Id = id, DonoId = donoId, CriadoEm = criadoEm };
        cartao.Copiar(dados, agora);
        return cartao;
    }

    public bool Aplicar(DadosCartao dados, DateTimeOffset agora)
    {
        if (dados.AtualizadoEm <= AtualizadoEm)
            return false;
        Validar(dados);
        Copiar(dados, agora);
        return true;
    }

    private void Copiar(DadosCartao dados, DateTimeOffset agora)
    {
        Nome = dados.Nome.Trim();
        Banco = string.IsNullOrWhiteSpace(dados.Banco) ? null : dados.Banco.Trim();
        DiaFechamento = dados.DiaFechamento;
        AtualizadoEm = dados.AtualizadoEm;
        ExcluidoEm = dados.ExcluidoEm;
        SincronizadoEm = agora;
    }

    private static void Validar(DadosCartao dados)
    {
        if (string.IsNullOrWhiteSpace(dados.Nome) || dados.Nome.Trim().Length > 60)
            throw new ExcecaoDeDominio("O nome do cartão precisa ter de 1 a 60 letras.");
        if (dados.Banco?.Trim().Length > 40)
            throw new ExcecaoDeDominio("O nome do banco tem até 40 letras.");
        if (dados.DiaFechamento is < 1 or > 31)
            throw new ExcecaoDeDominio("O dia de fechamento precisa estar entre 1 e 31.");
    }
}
