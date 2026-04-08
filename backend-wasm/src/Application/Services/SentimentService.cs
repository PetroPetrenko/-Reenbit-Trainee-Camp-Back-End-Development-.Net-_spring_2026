using backend_wasm.Application.Interfaces;
using Azure;
using Azure.AI.TextAnalytics;

namespace backend_wasm.Application.Services;

public class SentimentService : ISentimentService
{
    private readonly TextAnalyticsClient _client;
    private readonly ILogger<SentimentService> _logger;

    public SentimentService(TextAnalyticsClient client, ILogger<SentimentService> logger)
    {
        _client = client;
        _logger = logger;
    }

    public async Task<(string sentiment, float positive, float negative)> AnalyzeAsync(string text)
    {
        try
        {
            var result = await _client.AnalyzeSentimentAsync(text);
            
            return (result.Value.Sentiment.ToString().ToLowerInvariant(), 
                   result.Value.ConfidenceScores.Positive, 
                   result.Value.ConfidenceScores.Negative);
        }
        catch (RequestFailedException ex)
        {
            _logger.LogWarning(ex, "Sentiment analysis failed, returning neutral");
            return ("neutral", 0.5f, 0.5f);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unexpected error in sentiment analysis");
            return ("neutral", 0.5f, 0.5f);
        }
    }
}
