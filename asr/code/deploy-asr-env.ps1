#PowerShell Commands to create an Azure Key Vault and deployment for Backup and Resiliency Hackathon
#Make sure to install the VS Code extension for PowerShell
#Tip: Show the Integrated Terminal from View\Integrated Terminal
#Tip: click on a line and press "F8" to run the line of code

#Make sure you are running the latest version of the Azure PowerShell modules, uncomment the line below and run it (F8)
# Install-Module -Name AzureRM -Force -Scope CurrentUser -AllowClobber

#Step 1: Use a name no longer then five charactors all lowercase.  Your initials would work well if working in the same sub as others.
$HackName = 'sbk' 
$subscription = '9c29eddd-8897-46b5-b8ca-503e7ba5b463' 
$location = 'West US'

#Step 2: Create ResourceGroup after updating the location to one of your choice. Use get-AzureRmLocation to see a list
Connect-AzureRmAccount
Get-AzureRmSubscription
Select-AzureRmSubscription -SubscriptionId $subscription
New-AzureRMResourceGroup -Name $HackName -Location $location
$rg = Get-AzureRmresourcegroup -Name $HackName

#Step 3: Use Key Vault from Backup lab. If you did not complete that task, uncomment out the last line in this step and run it. Ensure you set the flag to enable for template deployment.
$HackKVName = $HackName + 'bkupresil'
#New-AzureRmKeyVault -VaultName $HackKVName -ResourceGroupName $rg.ResourceGroupName -Location $rg.Location -EnabledForTemplateDeployment

#Step 4: Add password as a secret.  Note:this will prompt you for a user and password.  User should be vmadmin and a password that meet the azure pwd police like P@ssw0rd123!!
Set-AzureKeyVaultSecret -VaultName $HackKVName -Name "VMPassword" -SecretValue (Get-Credential).Password

#Step 5: Update azuredeploy.parameters.json file with your envPrefixName and Key Vault info example- /subscriptions/{guid}/resourceGroups/{group-name}/providers/Microsoft.KeyVault/vaults/{vault-name}
(Get-AzureRmKeyVault -VaultName $HackKVName).ResourceId

#Step 6: Run deployment below after updating and SAVING the parameter file with your key vault info.  Make sure to update the paths to the json files or run the command from the same directory
#Note: You may want to adjust the VM series deployed in the ARM template. Feel free to modify the ARM template to use a different VM Series.
New-AzureRmResourceGroupDeployment -Name $HackName -ResourceGroupName $HackName -TemplateFile '.\bkup-resil-azuredeploy.json' -TemplateParameterFile '.\bckup-resil.parameters.json' -Force -Verbose -ErrorVariable ErrorMessages