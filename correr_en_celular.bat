@echo off
REM Corre la app en un celular Android conectado por USB.
REM El backend (npm start) debe estar corriendo en la PC.
REM "adb reverse" hace que 127.0.0.1:3000 en el celular apunte al backend de la PC,
REM asi no hay que cambiar IPs, firewall ni depender del Wi-Fi.

cd /d "%~dp0"

set "ADB=adb"
where adb >nul 2>nul || set "ADB=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"

REM Si flutter no esta en el PATH, usar el SDK local.
where flutter >nul 2>nul || (
    if defined FLUTTER_ROOT (
        set "PATH=%FLUTTER_ROOT%\bin;%PATH%"
    ) else (
        set "PATH=%USERPROFILE%\Downloads\SDK\flutter\bin;%PATH%"
    )
)

"%ADB%" start-server >nul 2>nul

set "ID="
for /f "skip=1 tokens=1,2" %%a in ('"%ADB%" devices') do (
    if "%%b"=="device" set "ID=%%a"
    if "%%b"=="unauthorized" (
        echo Desbloquea el celular y acepta "Permitir depuracion USB", luego vuelve a correr esto.
        pause
        exit /b 1
    )
)

if not defined ID (
    echo No se detecta ningun celular.
    echo  1. Activa "Opciones de desarrollador" y "Depuracion USB" en el celular.
    echo  2. Conectalo por USB a la PC ^(modo "Transferencia de archivos"^).
    pause
    exit /b 1
)

echo Celular detectado: %ID%
"%ADB%" -s %ID% reverse tcp:3000 tcp:3000

call flutter run -d %ID%
pause
