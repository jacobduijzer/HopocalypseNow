using HopocalypseNow.FrontendApi.Models;
using Microsoft.EntityFrameworkCore;

namespace HopocalypseNow.FrontendApi.Infrastructure;

public class DatabaseContext : DbContext
{
    public DatabaseContext(DbContextOptions<DatabaseContext> options)
        : base(options)
    {
    }

    public DbSet<Beer>? Beers { get; set; }
    public DbSet<Brewery>? Breweries { get; set; }
    public DbSet<Style>? Styles { get; set; }
    
    public DbSet<Order>? Orders { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasAutoscaleThroughput(1000);
        modelBuilder.HasDefaultContainer("beers");
        modelBuilder.Entity<Beer>()
            .HasNoDiscriminator()
            .HasKey(x => x.BeerId);

        modelBuilder.Entity<Brewery>()
            .HasNoDiscriminator()
            .ToContainer("breweries")
            .HasKey(x => x.BreweryId);

        modelBuilder.Entity<Style>()
            .HasNoDiscriminator()
            .ToContainer("styles")
            .HasKey(s => s.StyleId);
        
        modelBuilder.Entity<Order>()
            .HasNoDiscriminator()
            .ToContainer("order")
            .HasKey(s => s.OrderId);
    }
}