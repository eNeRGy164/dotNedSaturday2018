using System;
using System.Configuration;
using System.Security.Cryptography.X509Certificates;
using System.Threading.Tasks;
using Microsoft.Azure.KeyVault;
using Microsoft.Azure.KeyVault.Models;
using Microsoft.Azure.Services.AppAuthentication;
using Microsoft.IdentityModel.Clients.ActiveDirectory;

public static async Task<string> GetKeyVaultSecret(string secretNode)
{
    var azureServiceTokenProvider = new AzureServiceTokenProvider();
    var keyVaultClient = new KeyVaultClient(new KeyVaultClient.AuthenticationCallback(azureServiceTokenProvider.KeyVaultTokenCallback));

    string value = null;
    try 
    {
        var vaultUrl = ConfigurationManager.AppSettings["KeyVault.Url"];
    
        value = (await keyVaultClient.GetSecretAsync(vaultUrl, secretNode)).Value;
    }
    catch (KeyVaultErrorException ex) 
    {
        if (!ex.Message.StartsWith("Secret not found")) 
        {
            throw;
        }
    }

    return value;
}