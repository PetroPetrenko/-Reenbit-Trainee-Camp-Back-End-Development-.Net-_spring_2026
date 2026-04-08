using backend_wasm.Domain.Entities;

namespace backend_wasm.Application.Interfaces;

public interface IMessageRepository
{
    Task AddAsync(Message message);
    Task<List<Message>> GetLastMessages(int count = 50);
    Task<List<Message>> GetAllMessagesAsync();
}
