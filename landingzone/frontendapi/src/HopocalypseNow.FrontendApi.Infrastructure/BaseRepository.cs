using System.Linq.Expressions;
using HopocalypseNow.FrontendApi.Models;
using Microsoft.EntityFrameworkCore;

namespace HopocalypseNow.FrontendApi.Infrastructure;

public class BaseRepository<TEntity> : IRepository<TEntity> where TEntity : class
{
    private readonly IDbContextFactory<DatabaseContext> _dbContextFactory;

    public BaseRepository(IDbContextFactory<DatabaseContext> dbContextFactory)
    {
        _dbContextFactory = dbContextFactory;
    }
    
    public async Task<TEntity?> Get(Expression<Func<TEntity, bool>> predicate) 
    {
        await using var dbContext = await _dbContextFactory.CreateDbContextAsync();
        return await dbContext.Set<TEntity>().FirstOrDefaultAsync(predicate);
    }
}