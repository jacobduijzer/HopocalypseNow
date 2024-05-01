using HopocalypseNow.Models;
using Microsoft.EntityFrameworkCore;

namespace HopocalypseNow.DataFeeder;

public class DatabaseContext : DbContext
{
    public DatabaseContext(DbContextOptions<DatabaseContext> options)
        : base(options) { }

    public DbSet<Beer>? Beers { get; set; }
    public DbSet<Brewery>? Breweries { get; set; }
    public DbSet<Style>? Styles { get; set; }
    
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasAutoscaleThroughput(1000);
        modelBuilder.HasDefaultContainer("beers");
        modelBuilder.Entity<Beer>()
            .HasNoDiscriminator()
            // .HasPartitionKey(x => x.Brewery)
            .HasKey(x => x.BeerId);

        modelBuilder.Entity<Brewery>()
            .HasNoDiscriminator()
            .ToContainer("breweries")
            // .HasPartitionKey(x => x.BreweryId)
            .HasKey(x => x.BreweryId);
        
        modelBuilder.Entity<Style>()
            .HasNoDiscriminator()
            .ToContainer("styles")
            // .HasPartitionKey(x => x.StyleId)
            .HasKey(x => x.StyleId);
    }
}