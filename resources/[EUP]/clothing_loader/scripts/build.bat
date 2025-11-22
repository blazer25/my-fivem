@echo off
echo ========================================
echo FiveM Clothing/EUP Auto-Builder
echo ========================================
echo.

REM Check if Node.js is available
where node >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Using Node.js builder...
    node build_clothing.js
    goto :end
)

REM Check if Python is available
where python >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Node.js not found, using Python builder...
    python build_clothing.py
    goto :end
)

REM Neither found
echo ERROR: Neither Node.js nor Python found!
echo Please install Node.js (https://nodejs.org/) or Python (https://python.org/)
echo.
pause
goto :end

:end
echo.
echo Build process completed!
pause
