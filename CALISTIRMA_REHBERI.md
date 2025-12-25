# 🚀 TürkKalori Uygulaması Çalıştırma Rehberi

## 📱 Uygulamanın Ekranları

### Authentication (Giriş/Kayıt)
- ✅ **Login Screen** - Email/Şifre ile giriş
- ✅ **Register Screen** - Yeni kullanıcı kaydı + profil oluşturma

### Ana Ekranlar
- ✅ **Home Screen** - Günlük kalori takibi, progress ring, makro barlar
- ✅ **Food Search Screen** - 150+ Türk yemeği arama, kategori filtreleme
- ✅ **Add Food Screen** - Porsiyon ayarlama, öğün seçimi
- ✅ **Feed Screen** - Sosyal paylaşımlar

### Kamera & AI Özellikleri
- ✅ **Camera Picker Screen** - Kamera/Galeri seçimi
- ✅ **Food Recognition Result Screen** - AI sonuç gösterimi
- ✅ **Barcode Scanner Screen** - Barkod okuma

### Profil & İstatistikler
- ✅ **Profile Screen** - Kullanıcı bilgileri, istatistikler
- ✅ **Edit Profile Screen** - Hedef güncelleme (kilo, kalori)
- ✅ **Stats Screen** - Haftalık/Aylık grafikler (fl_chart)
- ✅ **Achievements Screen** - 11 başarım, puan sistemi
- ✅ **Settings Screen** - Görünüm, bildirimler, gizlilik

## 🎨 Tasarım Özellikleri

### Renk Paleti
- **Primary**: `#4CAF50` (Yeşil - Sağlık teması)
- **Accent**: `#FF5722` (Turuncu - Enerji)
- **Protein**: `#2196F3` (Mavi)
- **Carbs**: `#FFC107` (Sarı)
- **Fat**: `#E91E63` (Pembe)
- **Dark Mode**: Hive ile kalıcı tema desteği ✅

### UI Bileşenleri
- ✅ Circular progress ring (kalori takibi)
- ✅ Line chart & Pie chart (haftalık/aylık)
- ✅ Gradient buttons & cards
- ✅ Bottom navigation bar
- ✅ Custom food cards
- ✅ Achievement badges
- ✅ Shimmer loading effects
- ✅ Lottie animasyonlar

## 🖥️ Bilgisayarınızda Çalıştırma Adımları

### Adım 1: Flutter Kurulumu

**Flutter SDK'yı indirin:**
- Windows/macOS/Linux: https://docs.flutter.dev/get-started/install

**Kurulum kontrolü:**
```bash
flutter doctor
```

Eksik olanları kurun:
- ✅ Flutter SDK
- ✅ Android Studio (Android için)
- ✅ Xcode (macOS - iOS için)
- ✅ Chrome (Web için)

### Adım 2: Proje Bağımlılıklarını Yükleyin

Proje klasörüne gidin:
```bash
cd /path/to/Yemek-Kalori-App
```

Bağımlılıkları yükleyin:
```bash
flutter pub get
```

### Adım 3: Emulator/Cihaz Hazırlayın

**Android Emulator (Önerilen - Kolay):**
```bash
# Android Studio'da AVD Manager > Create Virtual Device
# Pixel 7 veya benzeri bir cihaz seçin
# API Level 34 (Android 14) önerilir

# Emulator'u başlatın
flutter emulators --launch <emulator-id>
```

**Gerçek Android Cihaz:**
1. Telefonda: Ayarlar > Geliştirici Seçenekleri > USB Debugging aktif
2. USB ile bilgisayara bağlayın
3. `flutter devices` ile cihazı görün

**iOS Simulator (Sadece macOS):**
```bash
open -a Simulator
flutter devices
```

**Web Browser (En Kolay - Tasarım İçin):**
```bash
# Chrome'da çalıştırmak için
flutter run -d chrome
```

### Adım 4: Uygulamayı Çalıştırın

**Bağlı cihazları görüntüle:**
```bash
flutter devices
```

**Uygulamayı başlat:**
```bash
# Android emulator/cihazda
flutter run

# Belirli bir cihazda
flutter run -d <device-id>

# Web'de (Hızlı önizleme için)
flutter run -d chrome

# Release mode (Daha hızlı)
flutter run --release
```

### Adım 5: Hot Reload ile Geliştirme

Uygulama çalışırken:
- **`r`** tuşuna basın = Hot reload (değişiklikleri anında görün)
- **`R`** tuşuna basın = Hot restart (uygulamayı yeniden başlat)
- **`q`** tuşuna basın = Çıkış

## 📂 Önemli Dosyalar

```
lib/
├── main.dart                 # Uygulama giriş noktası
├── app.dart                  # Ana uygulama yapılandırması
├── config/
│   ├── routes.dart          # Sayfa yönlendirmeleri
│   ├── supabase_config.dart # Backend bağlantısı
│   └── firebase_config.dart # Push notifications
└── presentation/screens/    # Tüm ekranlar burada
```

## ⚠️ İlk Çalıştırmada Dikkat!

### Supabase Bağlantısı
Eğer backend'e bağlanmak isterseniz:

1. `.env` dosyası oluşturun (`.env.example` dosyasını kopyalayın)
2. Supabase credentials'ları ekleyin:
```env
SUPABASE_URL=your_actual_supabase_url
SUPABASE_ANON_KEY=your_actual_anon_key
```

3. Veya `lib/config/supabase_config.dart` dosyasını güncelleyin

### Firebase (Push Notifications)
Firebase testi için:
- Android: `android/app/google-services.json` mevcut ✅
- iOS: `ios/Runner/GoogleService-Info.plist` mevcut ✅

### Fontlar
```bash
# Inter fontları assets/fonts/ klasörüne eklenmelidir
# Yoksa placeholder fontlar kullanılır
```

## 🎯 Hızlı Test (Önizleme)

**En kolay yöntem - Web'de çalıştırın:**
```bash
flutter run -d chrome --web-renderer html
```

Bu şekilde:
- Emulator kurmaya gerek yok
- Tarayıcıda anında görürsünüz
- Tasarımı ve akışı test edebilirsiniz
- Backend olmadan da UI görünür

**Not:**
- Kamera/Barkod özellikleri web'de çalışmayabilir
- Mobil görünüm için DevTools'da responsive mode kullanın

## 🐛 Sorun Giderme

**"Flutter not found" hatası:**
```bash
# Flutter'ı PATH'e ekleyin
export PATH="$PATH:/path/to/flutter/bin"
```

**Bağımlılık hataları:**
```bash
flutter clean
flutter pub get
```

**Build hataları:**
```bash
# Android
cd android && ./gradlew clean
cd .. && flutter clean && flutter pub get

# iOS (macOS)
cd ios && pod install
cd .. && flutter clean && flutter pub get
```

**Emulator bulunamıyor:**
```bash
flutter emulators
flutter emulators --launch <name>
```

## 📸 Ekran Görüntüleri İçin

Uygulama çalışırken:
1. VS Code kullanıyorsanız: Flutter DevTools > Widget Inspector
2. Android Studio kullanıyorsanız: Flutter Inspector tab
3. Ekran görüntüsü almak için cihazın screenshot özelliği

## 💡 Öneriler

**En kolay başlangıç (Windows/Mac/Linux):**
1. Flutter SDK kur
2. `flutter doctor` çalıştır
3. `flutter pub get`
4. `flutter run -d chrome`
5. Tarayıcıda uygulamayı gör!

**Mobil deneyim için (önerilir):**
1. Android Studio kur
2. AVD Manager'dan Pixel 7 emulator oluştur
3. Emulator'u başlat
4. `flutter run`
5. Gerçek mobil deneyimi gör!

---

**Herhangi bir sorun olursa bana yazın, yardımcı olurum! 🚀**
