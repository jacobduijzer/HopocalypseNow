using System;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;

namespace HopocalypseNow.PaymentsProcessor.FunctionApp;

// public class Startup : FunctionsStartup
// {
//     public override void Configure(IFunctionsHostBuilder builder)
//     {
//         var cosmosDbConnectionString = Environment.GetEnvironmentVariable("CosmosDbConnectionString") ??
//                                        throw new ArgumentNullException("Can't find variable 'CosmosDbConnectionString'.");
//         
//         var cosmosDbDatabaseName = Environment.GetEnvironmentVariable("CosmosDbDatabaseName") ??
//                                    throw new ArgumentNullException("Can't find variable 'CosmosDbDatabaseName'.");
//     }
// }