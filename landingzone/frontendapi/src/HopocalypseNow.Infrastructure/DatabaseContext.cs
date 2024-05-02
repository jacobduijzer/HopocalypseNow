using HopocalypseNow.FrontendApi.Models;
using Microsoft.EntityFrameworkCore;

namespace HopocalypseNow.Infrastructure;

public class DatabaseContext : DbContext
{
    public DatabaseContext(DbContextOptions<DatabaseContext> options)
        : base(options)
    {
    }

    public DbSet<Beer>? Beers { get; set; }
    public DbSet<Brewery>? Breweries { get; set; }
    public DbSet<Style>? Styles { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasAutoscaleThroughput(1000);
        modelBuilder.HasDefaultContainer("beers");
        modelBuilder.Entity<Beer>()
            .HasNoDiscriminator()
            // .HasOne<Style>(b => b.Style)
            // .WithMany(b => b.Beers);
        // .HasPartitionKey(x => x.Brewery.BreweryId)
        // .HasPartitionKey(x => x.Style.StyleId)
        // modelBuilder.Entity<Beer>()
            .HasKey(x => x.BeerId);

        modelBuilder.Entity<Brewery>()
            .HasNoDiscriminator()
            .ToContainer("breweries")
        //     .HasMany<Beer>(b => b.Beers);
        // modelBuilder.Entity<Brewery>()
            // .HasPartitionKey(x => x.Beers)
            .HasKey(x => x.BreweryId);

        modelBuilder.Entity<Style>()
            .HasNoDiscriminator()
            .ToContainer("styles")
            // .HasMany<Beer>(s => s.Beers)
            // .WithOne(s => s.Style);
        // modelBuilder.Entity<Style>()
            .HasKey(s => s.StyleId);
        // .HasPartitionKey(x => x.StyleId)
    }
}