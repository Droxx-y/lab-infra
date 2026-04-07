# scripts/create-users.ps1
# Eesmärk: CSV-st kasutajate bulk import AD-sse
# Kasutamine: .\create-users.ps1

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$CSVPath = "$PSScriptRoot\users.csv"
$TargetOU = "OU=Users,OU=Lab,DC=lab,DC=local"

# Kontrolli et CSV eksisteerib
if (-not (Test-Path $CSVPath)) {
    Write-Host "CSV faili ei leitud: $CSVPath" -ForegroundColor Red
    exit 1
}

# Küsi vaikeparool uutele kasutajatele
$DefaultPassword = Read-Host -AsSecureString "Sisesta vaikeparool uutele kasutajatele"

# Loe CSV ja loo kasutajad
$Users = Import-Csv $CSVPath

foreach ($User in $Users) {
    # Kontrolli kas kasutaja juba eksisteerib
    $Exists = Get-ADUser -Filter "SamAccountName -eq '$($User.SamAccountName)'" -ErrorAction SilentlyContinue

    if ($Exists) {
        Write-Host "Juba olemas: $($User.Name)" -ForegroundColor Yellow
    } else {
        # Loo kasutaja
        New-ADUser `
            -SamAccountName $User.SamAccountName `
            -Name $User.Name `
            -GivenName $User.GivenName `
            -Surname $User.Surname `
            -Path $TargetOU `
            -AccountPassword $DefaultPassword `
            -Enabled $true `
            -PasswordNeverExpires $true

        Write-Host "Loodud: $($User.Name)" -ForegroundColor Green
    }

    # Lisa gruppi
    if ($User.Group) {
        Add-ADGroupMember -Identity $User.Group -Members $User.SamAccountName -ErrorAction SilentlyContinue
        Write-Host "  -> Lisatud gruppi: $($User.Group)" -ForegroundColor Cyan
    }
}

Write-Host "`nKokkuvõte:" -ForegroundColor Green
Write-Host "Kasutajaid CSV-s: $($Users.Count)"
Write-Host "Kasutajaid OU-s:  $((Get-ADUser -SearchBase $TargetOU -Filter *).Count)"