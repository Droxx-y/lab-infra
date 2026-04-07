# scripts/setup-ad.ps1
# Eesmärk: ühe käsuga uus DC üles - rolli paigaldus, domeeni loomine, DNS, OU struktuur
# Kasutamine: jooksuta uuel Windows Serveril administraatorina

# Muutujad - kohanda vastavalt keskkonnale
$DomainName = "lab.local"
$DomainNetbios = "LAB"
$DNSForwarders = @("1.1.1.1", "8.8.8.8")

# Parool küsitakse jooksutamisel
$SafePassword = Read-Host -AsSecureString "Sisesta DSRM parool"

# 1. Paigalda AD DS roll
Write-Host "Paigaldan AD DS rolli..." -ForegroundColor Yellow
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

# 2. Promoteeri domain controlleriks
Write-Host "Promoteerin domain controlleriks..." -ForegroundColor Yellow
Install-ADDSForest `
    -DomainName $DomainName `
    -DomainNetbiosName $DomainNetbios `
    -SafeModeAdministratorPassword $SafePassword `
    -InstallDns `
    -Force