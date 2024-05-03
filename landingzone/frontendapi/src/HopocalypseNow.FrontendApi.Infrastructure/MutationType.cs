using HotChocolate.Types;

namespace HopocalypseNow.FrontendApi.Infrastructure;

public class MutationType : ObjectType<Mutation>
{
    protected override void Configure(IObjectTypeDescriptor<Mutation> descriptor)
    {
        descriptor.Field(f => f.AddOrder(default!));
    }
}