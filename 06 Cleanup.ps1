clear

# Cleanup
Get-AzureRmADAppCredential -ApplicationId $applicationId | Remove-AzureRmADAppCredential -ApplicationId $applicationId -Force

$webApp = Get-AzureRmWebApp -ResourceGroupName $webAppResourceGroup `
                            -Name $webAppName

$appSettings = [ordered]@{}
$webapp.SiteConfig.AppSettings `
    | ? { $_.Name -notlike 'KeyVault.*' -and $_.Name -ne "WEBSITE_LOAD_CERTIFICATES"} `
    | % { $appSettings[$_.Name] = $_.Value }

$webApp = Set-AzureRmWebApp -ResourceGroupName $webAppResourceGroup `
                            -Name $webAppName `
                            -AppSettings $appSettings

Remove-AzureKeyVaultManagedStorageSasDefinition -VaultName $vaultName -AccountName MSAKV01 -Name BlobSAS1 -Force
Remove-AzureKeyVaultManagedStorageSasDefinition -VaultName $vaultName -AccountName MSAKV01 -Name BlobSAS2 -Force
Remove-AzureKeyVaultManagedStorageSasDefinition -VaultName $vaultName -AccountName MSAKV01 -Name BlobSAS3 -Force

Remove-AzureKeyVaultManagedStorageAccount -VaultName $vaultName -Name MSAKV01 -Force

Remove-AzureRmRoleAssignment -ObjectId $vaultPrincipalId -Scope $storageId `
                             -RoleDefinitionName "Storage Account Key Operator Service Role"

Get-AzureRmKeyVault -VaultName $vaultName `
           | Select -ExpandProperty AccessPolicies `
           | ? { $_.DisplayName -like 'Wazug43*' -or $_.DisplayName -like ' (*' } `
           | Remove-AzureRmKeyVaultAccessPolicy -VaultName $vaultName