# scripts/post-restart-ad.ps1
# Eesmärk: pärast DC restarti - DNS forwarderid ja OU struktuur

$DomainName = "lab.local"
$DNSForwarders = @("1.1.1.1", "8.8.8.8")

# 1. DNS forwarderid
Write-Host "Seadistan DNS forwarderid..." -ForegroundColor Yellow
Set-DnsServerForwarder -IPAddress $DNSForwarders

# 2. OU struktuur
Write-Host "Loon OU struktuuri..." -ForegroundColor Yellow
New-ADOrganizationalUnit -Name "Lab" -Path "DC=lab,DC=local"
New-ADOrganizationalUnit -Name "Servers" -Path "OU=Lab,DC=lab,DC=local"
New-ADOrganizationalUnit -Name "Users" -Path "OU=Lab,DC=lab,DC=local"

# 3. Kontrolli
Get-ADOrganizationalUnit -Filter * | Select Name, DistinguishedName
Write-Host "AD DS seadistus lõpetatud!" -ForegroundColor Green