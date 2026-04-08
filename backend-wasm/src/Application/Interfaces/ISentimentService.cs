namespace backend_wasm.Application.Interfaces;

public interface ISentimentService
{
    Task<(string sentiment, float positive, float negative)> AnalyzeAsync(string text);
}
