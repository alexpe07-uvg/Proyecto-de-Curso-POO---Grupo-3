@echo off
REM Corre la app en un celular Android conectado por USB.
REM El backend (npm start) debe estar corriendo en la PC.
REM "adb reverse" hace que 127.0.0.1:3000 en el celular apunte al backend de la PC.

cd /d "%~dp0"

set "ADB=adb"
where adb >nul 2>nul
if errorlevel 1 set "ADB=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"

where flutter >nul 2>nul
if errorlevel 1 call :buscar_flutter

echo [1/3] Iniciando servicio ADB...
"%ADB%" kill-server >nul 2>nul
taskkill /F /IM adb.exe >nul 2>nul
"%ADB%" start-server >nul 2>nul

echo [2/3] Buscando celular conectado por USB...
set "ID="
set "NOAUTH="
for /f "skip=1 tokens=1,2" %%a in ('"%ADB%" devices') do call :revisar %%a %%b

if defined NOAUTH goto :no_autorizado
if not defined ID goto :sin_celular

echo.
echo Celular detectado: %ID%
echo [3/3] Conectando celular con el backend local, puerto 3000...
"%ADB%" -s %ID% reverse tcp:3000 tcp:3000

echo.
echo Lanzando la aplicacion en el celular...
echo Recuerda tener el backend corriendo en otra terminal: cd backend y npm start
echo.

call flutter run -d %ID%
pause
exit /b 0

:revisar
if "%2"=="device" if not defined ID set "ID=%1"
if "%2"=="unauthorized" set "NOAUTH=1"
exit /b 0

:buscar_flutter
if exist "C:\Users\andre\Desktop\andres\Flutter\flutter\bin\flutter.bat" set "PATH=C:\Users\andre\Desktop\andres\Flutter\flutter\bin;%PATH%"
if exist "%USERPROFILE%\Downloads\SDK\flutter\bin\flutter.bat" set "PATH=%USERPROFILE%\Downloads\SDK\flutter\bin;%PATH%"
exit /b 0

:no_autorizado
echo.
echo Celular no autorizado.
echo Desbloquea el celular y acepta "Permitir depuracion USB", luego vuelve a correr esto.
pause
exit /b 1

:sin_celular
echo.
echo No se detecta ningun celular Android.
echo  1. Activa "Depuracion por USB" en Opciones de desarrollador.
echo  2. Conectalo por USB en modo "Transferencia de archivos".
echo  3. Desbloquea la pantalla y acepta el mensaje de depuracion USB.
pause
exit /b 1
