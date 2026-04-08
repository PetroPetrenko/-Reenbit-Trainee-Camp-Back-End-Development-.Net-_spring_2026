using backend_wasm.Application.Interfaces;
using backend_wasm.Domain.Entities;

namespace backend_wasm.Application.Services;

public class ChatService : IChatService
{
    private readonly IMessageRepository _repo;
    private readonly IUnitOfWork _uow;
    private readonly ISentimentService _sentiment;
    private readonly ILogger<ChatService> _logger;

    public ChatService(
        IMessageRepository repo,
        IUnitOfWork uow,
        ISentimentService sentiment,
        ILogger<ChatService> logger)
    {
        _repo = repo;
        _uow = uow;
        _sentiment = sentiment;
        _logger = logger;
    }

    public async Task<Message> ProcessMessageAsync(string user, string text)
    {
        if (string.IsNullOrWhiteSpace(user) || string.IsNullOrWhiteSpace(text))
            throw new ArgumentException("User and text cannot be empty");

        try
        {
            var (sentiment, pos, neg) = await _sentiment.AnalyzeAsync(text);

            var msg = new Message
            {
                User = user,
                Text = text,
                Sentiment = sentiment,
                PositiveScore = pos,
                NegativeScore = neg,
                Timestamp = DateTime.UtcNow
            };

            await _repo.AddAsync(msg);
            await _uow.SaveChangesAsync();

            _logger.LogInformation("Processed message from {User} with sentiment {Sentiment}", user, sentiment);
            return msg;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error processing message from {User}", user);
            throw;
        }
    }

    public async Task<List<Message>> GetRecentMessagesAsync(int count = 50)
    {
        return await _repo.GetLastMessages(count);
    }
}
