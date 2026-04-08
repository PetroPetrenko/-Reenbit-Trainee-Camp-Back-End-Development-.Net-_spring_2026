using backend_wasm.Application.Interfaces;
using backend_wasm.Domain.Entities;
using backend_wasm.Infrastructure.Db;
using Microsoft.EntityFrameworkCore;

namespace backend_wasm.Infrastructure.Repositories;

public class MessageRepository : IMessageRepository
{
    private readonly AppDbContext _db;

    public MessageRepository(AppDbContext db) => _db = db;

    public async Task AddAsync(Message message)
    {
        await _db.Messages.AddAsync(message);
    }

    public Task<List<Message>> GetAllMessagesAsync()
    {
        return _db.Messages
            .OrderByDescending(m => m.Timestamp)
            .ToListAsync();
    }

    public Task<List<Message>> GetLastMessages(int count = 50)
    {
        return _db.Messages
            .OrderByDescending(m => m.Timestamp)
            .Take(count)
            .ToListAsync();
    }
}
