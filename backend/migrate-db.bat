@echo off
echo ========================================
echo    BEP VIET - DATABASE MIGRATION
echo ========================================
echo.
echo This will DROP and recreate the 'bepviet' database!
echo All existing data will be LOST!
echo.
set /p confirm="Are you sure? (y/n): "
if /i not "%confirm%"=="y" (
    echo Migration cancelled.
    exit /b 0
)

echo.
echo Running migration...
mysql -u root -p < src/database/migrations/bepviet_full_schema.sql

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo    Migration completed successfully!
    echo ========================================
) else (
    echo.
    echo ========================================
    echo    Migration FAILED! Check errors above.
    echo ========================================
)

pause

