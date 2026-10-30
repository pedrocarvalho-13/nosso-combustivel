namespace NossoCombustivel.Infrastructure.Ia;

public sealed class OpcoesGemini
{
    public const string Secao = "Gemini";

    public string? Chave { get; set; }
    public string Modelo { get; set; } = "gemini-flash-latest";
    public string Endereco { get; set; } = "https://generativelanguage.googleapis.com/v1beta/";
}
