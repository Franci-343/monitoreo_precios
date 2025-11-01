@echo off
echo ==========================================
echo   Build Flutter Web para Vercel
echo ==========================================
echo.

echo [1/4] Limpiando build anterior...
call flutter clean
echo.

echo [2/4] Construyendo para web...
call flutter build web --release
if errorlevel 1 (
    echo.
    echo ❌ ERROR: Build falló
    echo.
    echo Posibles causas:
    echo - Developer Mode no activado (ejecuta: start ms-settings:developers)
    echo - Problemas con dependencias (ejecuta: flutter pub get)
    echo.
    pause
    exit /b 1
)
echo.

echo [3/4] Copiando .env a build/web...
if exist "build\web" (
    copy /Y ".env" "build\web\.env" >nul 2>&1
    if exist "build\web\.env" (
        echo ✅ .env copiado exitosamente
    ) else (
        echo ⚠️  Advertencia: No se pudo copiar .env
    )
) else (
    echo ❌ ERROR: build/web no existe
    pause
    exit /b 1
)
echo.

echo [4/4] Verificando archivos...
echo.
echo Archivos en build/web:
dir /B build\web | findstr /V /C:"intermediates" /C:"tmp"
echo.

echo ==========================================
echo   ✅ Build completado exitosamente!
echo ==========================================
echo.
echo Próximos pasos:
echo 1. Verifica que .env esté en build/web
echo 2. Configura variables en Vercel Dashboard
echo 3. Ejecuta: git add . ^&^& git commit -m "Update web build" ^&^& git push
echo.
pause
