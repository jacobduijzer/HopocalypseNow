using HopocalypseNow.Orders.Processors.Domain;
using Microsoft.EntityFrameworkCore;

namespace HopocalypseNow.Orders.Processors.Infrastructure;

public class DatabaseContext : DbContext
{
    public DatabaseContext(DbContextOptions<DatabaseContext> options)
        : base(options)
    {
    }

    public DbSet<Order>? Orders { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasAutoscaleThroughput(1000);
        modelBuilder.HasDefaultContainer("orders");
        modelBuilder.Entity<Order>()
            .HasNoDiscriminator()
            .HasKey(x => x.OrderId);
    }
}