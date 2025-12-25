# 🚀 TürkKalori - Bilgisayarda Çalıştırma (Hızlı Başlangıç)

## 📋 Ön Gereksinimler

İşletim sisteminizi seçin ve adımları takip edin:

---

## 🪟 WINDOWS İÇİN

### Adım 1: Flutter SDK İndir ve Kur

1. **Flutter SDK'yı İndir:**
   - [https://docs.flutter.dev/get-started/install/windows](https://docs.flutter.dev/get-started/install/windows)
   - "flutter_windows_X.X.X-stable.zip" dosyasını indirin

2. **Kurulum:**
   ```
   C:\src klasörü oluşturun
   ZIP dosyasını C:\src içine çıkartın
   Sonuç: C:\src\flutter
   ```

3. **PATH'e Ekle:**
   - Windows Arama → "ortam değişkenleri" yaz
   - "Sistem ortam değişkenlerini düzenle" aç
   - "Ortam Değişkenleri" butonuna tıkla
   - "Path" değişkenini seç → "Düzenle"
   - "Yeni" → `C:\src\flutter\bin` ekle
   - Tamam → Tamam

4. **Terminali Yeniden Aç:**
   - PowerShell veya CMD'yi kapat ve tekrar aç

5. **Kontrol Et:**
   ```powershell
   flutter --version
   ```

### Adım 2: Git'i Kur (Gerekli)

1. Git indir: [https://git-scm.com/download/win](https://git-scm.com/download/win)
2. Kurun (default ayarlarla)

### Adım 3: Flutter Doktor Çalıştır

```powershell
flutter doctor
```

**Çıktı örneği:**
```
Doctor summary (to see all details, run flutter doctor -v):
[√] Flutter (Channel stable, 3.X.X)
[√] Windows Version (Installed version of Windows is version 10 or higher)
[√] Chrome - develop for the web
[!] Visual Studio - develop for Windows (Not installed)
[!] Android toolchain (Android SDK not installed)
```

**Web için yeterli olan:**
- ✅ Flutter
- ✅ Chrome

### Adım 4: Chrome Kurulu Değilse

- [https://www.google.com/chrome/](https://www.google.com/chrome/) adresinden Chrome'u indirin ve kurun

### Adım 5: Projeyi Çalıştır

```powershell
# Proje klasörüne git
cd C:\path\to\Yemek-Kalori-App

# Bağımlılıkları yükle
flutter pub get

# Web'de çalıştır
flutter run -d chrome
```

**İlk çalıştırma 2-3 dakika sürebilir, bekleyin!**

---

## 🍎 macOS İÇİN

### Adım 1: Flutter SDK İndir

1. **Flutter'ı İndir:**
   - [https://docs.flutter.dev/get-started/install/macos](https://docs.flutter.dev/get-started/install/macos)
   - "flutter_macos_X.X.X-stable.zip" indirin

2. **Kurulum:**
   ```bash
   # İndirilenler klasöründe terminal aç
   cd ~/Downloads
   unzip flutter_macos_*-stable.zip
   mv flutter ~/development/flutter
   ```

3. **PATH'e Ekle:**
   ```bash
   # .zshrc dosyasını düzenle
   nano ~/.zshrc

   # En alta ekle:
   export PATH="$PATH:$HOME/development/flutter/bin"

   # Ctrl+X → Y → Enter (kaydet)

   # Yeniden yükle
   source ~/.zshrc
   ```

4. **Kontrol Et:**
   ```bash
   flutter --version
   ```

### Adım 2: Xcode Yükle (Opsiyonel - iOS için)

```bash
# App Store'dan Xcode'u yükle (büyük dosya, 10+ GB)
# VEYA sadece web için atlayın
```

### Adım 3: Flutter Doktor

```bash
flutter doctor
```

### Adım 4: Projeyi Çalıştır

```bash
# Proje klasörüne git
cd /path/to/Yemek-Kalori-App

# Bağımlılıkları yükle
flutter pub get

# Chrome'da çalıştır
flutter run -d chrome
```

---

## 🐧 LINUX İÇİN

### Adım 1: Flutter SDK İndir

```bash
# Gerekli paketler
sudo apt-get update
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa

# Flutter'ı indir
cd ~
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_X.X.X-stable.tar.xz

# Çıkart
tar xf flutter_linux_*-stable.tar.xz

# PATH'e ekle
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# Kontrol
flutter --version
```

### Adım 2: Chrome Kur

```bash
# Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
```

### Adım 3: Flutter Doktor

```bash
flutter doctor
```

### Adım 4: Projeyi Çalıştır

```bash
cd /path/to/Yemek-Kalori-App
flutter pub get
flutter run -d chrome
```

---

## ⚡ HIZLI BAŞLANGIÇ (TÜM PLATFORMLAR)

Flutter kurulduktan sonra:

### 1. Terminal/PowerShell Aç

### 2. Proje Klasörüne Git

```bash
cd Yemek-Kalori-App
```

### 3. Bağımlılıkları Yükle

```bash
flutter pub get
```

**Çıktı:**
```
Running "flutter pub get" in turk_kalori...
Resolving dependencies... (takes 30-60 seconds)
Got dependencies!
```

### 4. Web'de Çalıştır

```bash
flutter run -d chrome
```

**Çıktı:**
```
Launching lib/main.dart on Chrome in debug mode...
Building application for the web...                      45.2s
✓ Built build/web
```

**Tarayıcı otomatik açılacak ve uygulamayı göreceksiniz! 🎉**

---

## 🎯 İLK ÇALIŞTIRMADA BEKLENENLER

### Terminal Çıktısı:
```
Flutter run key commands.
r Hot reload. 🔥
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).
```

### Tarayıcıda:
```
http://localhost:XXXX
```

Uygulama otomatik olarak Chrome'da açılacak.

---

## 📱 MOBİL GÖRÜNÜM İÇİN

Chrome açıldıktan sonra:

1. **F12** tuşuna bas (DevTools)
2. **Ctrl+Shift+M** (Device Toolbar)
3. Üstten cihaz seç: **iPhone 12 Pro** veya **Pixel 5**
4. Mobil görünümde uygulamayı gör!

---

## 🐛 SORUN GİDERME

### "flutter: command not found"

**Windows:**
```powershell
# PATH kontrolü
echo $env:PATH

# Flutter binary var mı?
C:\src\flutter\bin\flutter.bat --version
```

**macOS/Linux:**
```bash
# PATH kontrolü
echo $PATH

# Flutter binary var mı?
~/development/flutter/bin/flutter --version
```

**Çözüm:** PATH'e tekrar ekle ve terminali yeniden aç.

---

### "Unable to locate a development device"

```bash
# Web desteğini aktif et
flutter config --enable-web

# Tekrar çalıştır
flutter run -d chrome
```

---

### "Pub get failed"

```bash
# Cache temizle
flutter clean
flutter pub cache repair

# Tekrar dene
flutter pub get
```

---

### "Chrome not found"

**Windows:**
```powershell
# Chrome'u yükle
# https://www.google.com/chrome/

# Flutter'a göster
flutter config --chrome-path "C:\Program Files\Google\Chrome\Application\chrome.exe"
```

**macOS:**
```bash
flutter config --chrome-path "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
```

---

### "Build failed with exception"

```bash
# Projeyi temizle
flutter clean

# Bağımlılıkları yeniden yükle
flutter pub get

# Tekrar çalıştır
flutter run -d chrome
```

---

## 🎨 UYGULAMAYI KULLANMA

Uygulama açıldığında:

1. **Login Screen** göreceksiniz
2. Test için "Register" butonuna tıklayın
3. Bilgileri doldurun (sahte email/şifre olabilir)
4. Ana ekrana gelin
5. Kalori tracking, yemek arama vb. test edin

**Not:** Backend (Supabase) bağlantısı yoksa bazı özellikler çalışmayabilir ama UI/tasarımı görebilirsiniz!

---

## 📊 PERFORMANS İPUÇLARI

### İlk Build Yavaş (Normal)
```
İlk kez: 1-3 dakika
Sonraki çalıştırmalar: 10-30 saniye
Hot reload (r): 1-2 saniye
```

### Release Mode (Daha Hızlı)
```bash
flutter run -d chrome --release
```

---

## ✅ BAŞARILI KURULUM KONTROLLERİ

```bash
# Flutter kurulu mu?
flutter --version
# ✅ Çıktı: Flutter 3.X.X

# Pub çalışıyor mu?
flutter pub get
# ✅ Çıktı: Got dependencies!

# Web desteği var mı?
flutter devices
# ✅ Çıktı: Chrome (web) • chrome • ...

# Uygulama çalışıyor mu?
flutter run -d chrome
# ✅ Tarayıcı açıldı ve uygulama görünüyor
```

---

## 🎓 FLUTTER ÖĞRENMEYİ UNUTMAYIN!

Uygulama çalıştıktan sonra:

- **r** tuşu: Hot reload (değişiklikleri anında gör)
- **R** tuşu: Full restart
- **q** tuşu: Çık

Kod değiştirip **r** ile anında güncellemeleri görebilirsiniz!

---

## 📞 YARDIM GEREKİYORSA

Hangi aşamada takıldınız? Bana:
1. Hata mesajını
2. İşletim sisteminizi (Windows/Mac/Linux)
3. `flutter doctor` çıktısını

Paylaşın, yardımcı olayım! 🚀

---

**Başarılar! Uygulamanızı görmek üzeresiniz! 🎉**
