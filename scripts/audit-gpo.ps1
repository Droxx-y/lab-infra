# scripts/audit-gpo.ps1
# Eesmärk: GPO seadete ülevaade - mis on olemas, kuhu lingitud, mis seaded sees
# Kasutamine: .\audit-gpo.ps1

$ReportPath = "C:\scripts\gpo-report.html"

Write-Host "=== GPO AUDIT ===" -ForegroundColor Cyan
Write-Host ""

# 1. Kõik GPO-d
Write-Host "Olemasolevad GPO-d:" -ForegroundColor Yellow
Get-GPO -All | Format-Table DisplayName, CreationTime, ModificationTime, GpoStatus -AutoSize

# 2. Lingid - mis GPO kuhu külge käib
Write-Host "GPO lingid:" -ForegroundColor Yellow
$GPOs = Get-GPO -All
foreach ($GPO in $GPOs) {
    $Links = (Get-GPOReport -Guid $GPO.Id -ReportType XML | 
        Select-Xml -XPath "//gpo:LinksTo/gpo:SOMPath" -Namespace @{gpo="http://www.microsoft.com/GroupPolicy/Settings"}).Node.'#text'
    
    if ($Links) {
        Write-Host "  $($GPO.DisplayName):" -ForegroundColor Green
        foreach ($Link in $Links) {
            Write-Host "    -> $Link"
        }
    } else {
        Write-Host "  $($GPO.DisplayName): lingitud pole" -ForegroundColor DarkGray
    }
}

# 3. Paroolipoliitika
Write-Host ""
Write-Host "Domeeni paroolipoliitika:" -ForegroundColor Yellow
Get-ADDefaultDomainPasswordPolicy | Format-List MinPasswordLength, MaxPasswordAge, PasswordHistoryCount, ComplexityEnabled, LockoutThreshold

# 4. HTML raport
Write-Host ""
Write-Host "Genereerin HTML raportid..." -ForegroundColor Yellow
$GPOs | ForEach-Object {
    try {
        Get-GPOReport -Guid $_.Id -ReportType HTML -Path "C:\scripts\gpo-$($_.DisplayName).html"
        Write-Host "  -> gpo-$($_.DisplayName).html" -ForegroundColor Green
    } catch {
        Write-Host "  -> gpo-$($_.DisplayName).html - VIGA, vahele jäetud" -ForegroundColor Red
    }
}