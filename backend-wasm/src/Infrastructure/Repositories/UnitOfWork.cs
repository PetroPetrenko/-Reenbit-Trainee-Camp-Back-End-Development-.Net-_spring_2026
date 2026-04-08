using backend_wasm.Application.Interfaces;
using backend_wasm.Infrastructure.Db;

namespace backend_wasm.Infrastructure.Repositories;

public class UnitOfWork : IUnitOfWork
{
    private readonly AppDbContext _db;

    public UnitOfWork(AppDbContext db) => _db = db;

    public Task SaveChangesAsync() => _db.SaveChangesAsync();
}
