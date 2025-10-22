# BEP VIET - DATABASE MIGRATION SCRIPT
Write-Host "========================================"
Write-Host "   BEP VIET - DATABASE MIGRATION"
Write-Host "========================================"
Write-Host ""

$password = ""
$sqlFile = "src/database/migrations/bepviet_full_schema.sql"

# Common MySQL paths
$mysqlPaths = @(
    "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe",
    "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe",
    "C:\Program Files\MySQL\MySQL Server 9.0\bin\mysql.exe",
    "C:\xampp\mysql\bin\mysql.exe",
    "C:\wamp64\bin\mysql\mysql8.0.27\bin\mysql.exe",
    "mysql" # If in PATH
)

$mysqlExe = $null
foreach ($path in $mysqlPaths) {
    if (Test-Path $path -ErrorAction SilentlyContinue) {
        $mysqlExe = $path
        break
    }
    if ($path -eq "mysql") {
        try {
            Get-Command mysql -ErrorAction Stop | Out-Null
            $mysqlExe = "mysql"
            break
        } catch {
            continue
        }
    }
}

if (-not $mysqlExe) {
    Write-Host "ERROR: MySQL not found!" -ForegroundColor Red
    Write-Host "Please install MySQL or add it to PATH" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "Found MySQL at: $mysqlExe" -ForegroundColor Green
Write-Host "Running migration..." -ForegroundColor Cyan
Write-Host ""

# Run migration
$env:MYSQL_PWD = $password
Get-Content $sqlFile | & $mysqlExe -u root --default-character-set=utf8mb4

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================"
    Write-Host "   Migration completed successfully!"
    Write-Host "========================================"
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "========================================"
    Write-Host "   Migration FAILED!"
    Write-Host "========================================"
    Write-Host ""
}

pause

