namespace NossoCombustivel.Infrastructure.Ia;

public sealed class OpcoesGemini
{
    public const string Secao = "Gemini";

    public string? Chave { get; set; }
    public string Modelo { get; set; } = "gemini-flash-latest";
    public string ModeloReserva { get; set; } = "gemini-flash-lite-latest";
    public int OrcamentoRaciocinio { get; set; } = 1024;
    public int SegundosLimite { get; set; } = 90;
    public string Endereco { get; set; } = "https://generativelanguage.googleapis.com/v1beta/";
}
