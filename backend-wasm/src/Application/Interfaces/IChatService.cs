namespace backend_wasm.Application.Interfaces;

public interface IChatService
{
    Task<Domain.Entities.Message> ProcessMessageAsync(string user, string text);
    Task<List<Domain.Entities.Message>> GetRecentMessagesAsync(int count = 50);
}
