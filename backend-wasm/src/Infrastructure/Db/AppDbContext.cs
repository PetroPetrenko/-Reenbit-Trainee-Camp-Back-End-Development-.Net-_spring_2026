using backend_wasm.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace backend_wasm.Infrastructure.Db;

public class AppDbContext : DbContext
{
    public DbSet<Message> Messages => Set<Message>();

    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
    {
    }

    protected override void OnModelCreating(ModelBuilder builder)
    {
        builder.Entity<Message>().ToTable("Messages");
        builder.Entity<Message>().Property(m => m.Sentiment).HasDefaultValue("neutral");
        builder.Entity<Message>().Property(m => m.PositiveScore).HasDefaultValue(0f);
        builder.Entity<Message>().Property(m => m.NegativeScore).HasDefaultValue(0f);
    }
}
