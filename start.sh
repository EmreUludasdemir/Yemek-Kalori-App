#!/bin/bash

echo "========================================"
echo "  TürkKalori Uygulaması Başlatılıyor"
echo "========================================"
echo ""

echo "[1/3] Flutter versiyonu kontrol ediliyor..."
if ! command -v flutter &> /dev/null; then
    echo ""
    echo "HATA: Flutter bulunamadı!"
    echo "Lütfen Flutter'ı yükleyin: https://docs.flutter.dev/get-started/install"
    exit 1
fi

flutter --version
echo ""

echo "[2/3] Bağımlılıkları yükleniyor..."
flutter pub get
if [ $? -ne 0 ]; then
    echo ""
    echo "HATA: Bağımlılıkları yükleme başarısız!"
    echo "flutter clean komutu ile temizleyin ve tekrar deneyin."
    exit 1
fi

echo ""
echo "[3/3] Uygulama başlatılıyor (Chrome)..."
echo ""
echo "Tarayıcı otomatik açılacak..."
echo "İlk çalıştırma 2-3 dakika sürebilir, lütfen bekleyin!"
echo ""

flutter run -d chrome
