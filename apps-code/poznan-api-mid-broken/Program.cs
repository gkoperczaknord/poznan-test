using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using Azure.Core;
using Azure.Core.Diagnostics;

var builder = WebApplication.CreateBuilder(args);

// Add logging
using AzureEventSourceListener listener = 
    AzureEventSourceListener.CreateConsoleLogger();

// Add env variables reading
builder.Configuration.AddEnvironmentVariables();

// Reading env variables
var keyVaultURL = builder.Configuration["KeyVaultConfiguration:KeyVaultURL"];
var midClientId = builder.Configuration["KeyVaultConfiguration:MidClientId"];

var options = new DefaultAzureCredentialOptions
{
    ManagedIdentityClientId = midClientId,

    ExcludeEnvironmentCredential = true,
    ExcludeInteractiveBrowserCredential = true,
    ExcludeAzurePowerShellCredential = true,
    ExcludeSharedTokenCacheCredential = true,
    ExcludeVisualStudioCodeCredential = true,
    ExcludeVisualStudioCredential = true,
    ExcludeAzureCliCredential = true,
    ExcludeManagedIdentityCredential = false,

    Diagnostics =
    {
        LoggedHeaderNames = { "x-ms-request-id" },
        LoggedQueryParameters = { "api-version" },
        IsLoggingContentEnabled = true,
        IsAccountIdentifierLoggingEnabled = true,
    }
};

var secretClient = new SecretClient(new Uri($"{keyVaultURL}"), new DefaultAzureCredential(options));

var secretName = builder.Configuration["SecretName"];

KeyVaultSecret secret = secretClient.GetSecret($"{secretName}");

// Add services to the container.

builder.Services.AddControllers();

var app = builder.Build();

app.MapGet("/", () => "Requested secret by using mid with name: " + secret.Name + " has value of: " + secret.Value);

app.UseAuthorization();

app.MapControllers();

app.Run();