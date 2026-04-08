namespace backend_wasm.Application.Interfaces;

public interface IUnitOfWork
{
    Task SaveChangesAsync();
}
