using System.Linq.Expressions;

namespace HopocalypseNow.FrontendApi.Models;

public interface IRepository<TEntity> where TEntity : class
{
    Task<TEntity?> Get(Expression<Func<TEntity, bool>> predicate);
}