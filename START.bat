@echo off
echo ========================================
echo   TurkKalori Uygulamasi Baslatiliyor
echo ========================================
echo.

echo [1/3] Flutter versiyonu kontrol ediliyor...
flutter --version
if errorlevel 1 (
    echo.
    echo HATA: Flutter bulunamadi!
    echo Lutfen Flutter'i yukleyin: https://docs.flutter.dev/get-started/install
    pause
    exit /b 1
)

echo.
echo [2/3] Bagimliliklari yukleniyor...
flutter pub get
if errorlevel 1 (
    echo.
    echo HATA: Bagimliliklari yukleme basarisiz!
    echo flutter clean komutu ile temizleyin ve tekrar deneyin.
    pause
    exit /b 1
)

echo.
echo [3/3] Uygulama baslatiliyor (Chrome)...
echo.
echo Tarayici otomatik acilacak...
echo Ilk calistirma 2-3 dakika surebilir, lutfen bekleyin!
echo.

flutter run -d chrome

pause
