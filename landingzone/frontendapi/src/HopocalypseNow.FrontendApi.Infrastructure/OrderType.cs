using HopocalypseNow.FrontendApi.Models;
using HotChocolate.Types;

namespace HopocalypseNow.FrontendApi.Infrastructure;

public class OrderType : ObjectType<Order> 
{
    protected override void Configure(IObjectTypeDescriptor<Order> descriptor)
    {
        descriptor.BindFields(BindingBehavior.Implicit);
        descriptor
            .Field(o => o.Created)
            .Type<DateTimeType>();
    } 
}