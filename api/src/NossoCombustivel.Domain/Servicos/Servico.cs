using NossoCombustivel.Domain.ObjetosDeValor;
using NossoCombustivel.Domain.Registros;

namespace NossoCombustivel.Domain.Servicos;

public enum TipoServico
{
    Manutencao = 1,
    Estetica = 2,
    Custo = 3
}

public sealed record DadosServico(
    TipoServico Tipo,
    DateTimeOffset Data,
    int? Odometro,
    IReadOnlyList<string> Categorias,
    string? Detalhes,
    decimal ValorTotal,
    decimal? ValorPecas,
    decimal? ValorMaoDeObra,
    Guid? LugarId,
    string? LugarNome,
    FormaPagamento? FormaPagamento,
    Guid? CartaoId,
    string? Observacao,
    DateTimeOffset AtualizadoEm,
    DateTimeOffset? ExcluidoEm);

public sealed class Servico
{
    private Servico()
    {
    }

    public Guid Id { get; private set; }
    public Guid VeiculoId { get; private set; }
    public Guid UsuarioId { get; private set; }
    public TipoServico Tipo { get; private set; }
    public DateTimeOffset Data { get; private set; }
    public int? Odometro { get; private set; }
    public string Categorias { get; private set; } = string.Empty;
    public string? Detalhes { get; private set; }
    public decimal ValorTotal { get; private set; }
    public decimal? ValorPecas { get; private set; }
    public decimal? ValorMaoDeObra { get; private set; }
    public Guid? LugarId { get; private set; }
    public string? LugarNome { get; private set; }
    public FormaPagamento? FormaPagamento { get; private set; }
    public Guid? CartaoId { get; private set; }
    public string? Observacao { get; private set; }
    public DateTimeOffset CriadoEm { get; private set; }
    public DateTimeOffset AtualizadoEm { get; private set; }
    public DateTimeOffset? ExcluidoEm { get; private set; }
    public DateTimeOffset SincronizadoEm { get; private set; }

    public IReadOnlyList<string> ListaCategorias =>
        Categorias.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);

    public static Servico Criar(Guid id, Guid veiculoId, Guid usuarioId, DadosServico dados, DateTimeOffset criadoEm, DateTimeOffset agora)
    {
        Validar(dados);
        var servico = new Servico { Id = id, VeiculoId = veiculoId, UsuarioId = usuarioId, CriadoEm = criadoEm };
        servico.Copiar(dados, agora);
        return servico;
    }

    public bool Aplicar(DadosServico dados, DateTimeOffset agora)
    {
        if (dados.AtualizadoEm <= AtualizadoEm)
            return false;
        Validar(dados);
        Copiar(dados, agora);
        return true;
    }

    private void Copiar(DadosServico dados, DateTimeOffset agora)
    {
        Tipo = dados.Tipo;
        Data = dados.Data;
        Odometro = dados.Odometro is null ? null : new Odometro(dados.Odometro.Value).Km;
        Categorias = string.Join(',', dados.Categorias.Select(c => c.Trim()).Where(c => c.Length > 0).Distinct());
        Detalhes = string.IsNullOrWhiteSpace(dados.Detalhes) ? null : dados.Detalhes;
        ValorTotal = new Dinheiro(dados.ValorTotal).Valor;
        ValorPecas = dados.ValorPecas;
        ValorMaoDeObra = dados.ValorMaoDeObra;
        LugarId = dados.LugarId;
        LugarNome = string.IsNullOrWhiteSpace(dados.LugarNome) ? null : dados.LugarNome.Trim();
        FormaPagamento = dados.FormaPagamento;
        CartaoId = dados.FormaPagamento == Registros.FormaPagamento.Credito ? dados.CartaoId : null;
        Observacao = string.IsNullOrWhiteSpace(dados.Observacao) ? null : dados.Observacao.Trim();
        AtualizadoEm = dados.AtualizadoEm;
        ExcluidoEm = dados.ExcluidoEm;
        SincronizadoEm = agora;
    }

    private static void Validar(DadosServico dados)
    {
        if (dados.Categorias.Count(c => !string.IsNullOrWhiteSpace(c)) == 0)
            throw new ExcecaoDeDominio("Escolha pelo menos um serviço.");
        if (string.Join(',', dados.Categorias).Length > 400)
            throw new ExcecaoDeDominio("Serviços demais num registro só.");
        if (dados.Detalhes?.Length > 8000)
            throw new ExcecaoDeDominio("Os detalhes do serviço estão grandes demais.");
        if (dados.LugarNome?.Trim().Length > 100)
            throw new ExcecaoDeDominio("O nome do lugar tem até 100 letras.");
        if (dados.Observacao?.Trim().Length > 500)
            throw new ExcecaoDeDominio("A observação tem até 500 letras.");
        if (dados.ValorPecas < 0 || dados.ValorMaoDeObra < 0)
            throw new ExcecaoDeDominio("Peças e mão de obra não podem ser negativas.");
        _ = new Dinheiro(dados.ValorTotal);
    }
}
