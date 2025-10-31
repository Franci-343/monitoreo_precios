@echo off
echo Limpiando cache de Flutter...
cd /d "D:\UMSA\QUINTO_SEMESTRE\INGENIERIA_SOFTWARE\Proyecto\monitoreo_precios"

flutter clean
flutter pub get
flutter doctor

echo.
echo Intentando ejecutar en Windows...
flutter run -d windows

pause
