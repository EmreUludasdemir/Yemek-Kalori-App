# 🐳 TürkKalori Docker Quickstart Guide

TürkKalori uygulamasını Docker ile 5 dakikada test etmeye başlayın!

---

## ⚡ Hızlı Başlangıç

### 1. Docker'ı Kontrol Et

```bash
# Docker kurulu mu?
docker --version
docker-compose --version

# Eğer "command not found" hatası alırsanız Docker kurmanız gerekiyor
```

### 2. Projeyi Klonlayın (eğer henüz yapmadıysanız)

```bash
git clone https://github.com/EmreUludasdemir/Yemek-Kalori-App.git
cd Yemek-Kalori-App
```

### 3. Test Etmeye Başlayın!

#### Seçenek A: Otomatik Testler (En Kolay)

```bash
# Makefile varsa (önerilen)
make test

# Veya direkt docker-compose
docker-compose up flutter-test
```

**Sonuç**: Tüm unit ve widget testleri çalışır, coverage raporu oluşturulur.

#### Seçenek B: Web Preview (Görsel Test)

```bash
# Makefile ile
make up-web

# Veya docker-compose ile
docker-compose up -d flutter-web
```

**Sonra**: http://localhost:8080 adresine gidin

#### Seçenek C: Development Ortamı (Tam Kontrol)

```bash
# Makefile ile
make dev

# Veya manuel
docker-compose up -d flutter-dev
docker exec -it turkkalori-dev bash

# Container içinde:
flutter doctor
flutter test
flutter build apk --debug
```

---

## 🎯 Popüler Kullanım Senaryoları

### Senaryo 1: "Sadece testleri çalıştırmak istiyorum"

```bash
make test
# veya
docker-compose run --rm flutter-test
```

**Çıktı**: Test sonuçları + coverage raporu

---

### Senaryo 2: "Web versiyonunu görmek istiyorum"

```bash
make up-web
# Tarayıcıda http://localhost:8080 aç
```

**Not**: Native özellikler (kamera, healthkit) web'de çalışmaz.

---

### Senaryo 3: "APK dosyası oluşturmak istiyorum"

```bash
make build-apk
# APK dosyası: build/app/outputs/flutter-apk/app-debug.apk
```

**Release APK için**:
```bash
make build-apk-release
```

---

### Senaryo 4: "Local database ile test etmek istiyorum"

```bash
# Database'i başlat
make up-db

# Database'e bağlan
make shell-db

# SQL sorguları çalıştır
SELECT * FROM foods LIMIT 5;
```

---

### Senaryo 5: "Coverage raporu görmek istiyorum"

```bash
# Coverage oluştur
make test-coverage

# HTML rapor oluştur
make coverage-html

# Tarayıcıda aç
make coverage-serve
# http://localhost:8081 adresine git
```

---

## 📋 Tüm Makefile Komutları

```bash
# Yardım al (tüm komutları göster)
make help

# Docker
make build          # Image'ları build et
make up             # Servisleri başlat
make down           # Servisleri durdur
make logs           # Logları göster

# Test
make test           # Tüm testler
make test-unit      # Sadece unit testler
make test-widget    # Sadece widget testler
make test-coverage  # Coverage raporu

# Build
make build-apk      # Android APK (debug)
make build-apk-release    # Android APK (release)
make build-appbundle      # Android App Bundle

# Development
make dev            # Dev ortamını başlat + shell aç
make flutter-doctor # Flutter doctor çalıştır
make flutter-analyze # Kod analizi

# Database
make up-db          # Database başlat
make shell-db       # Database'e bağlan
make db-backup      # Backup oluştur

# Temizlik
make clean          # Proje temizle
make clean-all      # Tüm Docker resources temizle

# Utility
make check          # Sistem kontrolü
make health         # Servis health check
make open-web       # Web preview aç
```

---

## 🔧 Docker Olmadan (Manuel)

Eğer Docker kullanmak istemiyorsanız:

```bash
# Flutter'ı kur
# https://flutter.dev/docs/get-started/install

# Bağımlılıkları yükle
flutter pub get

# Testleri çalıştır
flutter test

# APK build et
flutter build apk --debug

# Web çalıştır
flutter run -d chrome
```

---

## 🆘 Sorun Giderme

### "docker: command not found"

**Çözüm**: Docker'ı kurun:

```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# macOS
brew install docker docker-compose

# Windows
# Docker Desktop'ı indirin: https://www.docker.com/products/docker-desktop
```

---

### "port 8080 already in use"

**Çözüm**: Portu değiştirin:

```bash
# docker-compose.yml dosyasında:
# "8080:80" yerine "8081:80" yapın

# Veya çalışan servisi durdurun
sudo lsof -ti:8080 | xargs kill -9
```

---

### "Container hızlı başlamıyor"

**Sebep**: İlk kez çalıştırıldığında Flutter SDK indirilir (2-3 GB)

**Çözüm**: Bekleyin veya progress görmek için:
```bash
docker-compose logs -f flutter-dev
```

---

### "Test failed: No tests found"

**Sebep**: Test dosyaları henüz oluşturulmamış olabilir

**Çözüm**: Örnek test ekleyin:
```bash
mkdir -p test/unit
# Sonra test dosyası oluşturun
```

---

### "Permission denied"

**Çözüm**:
```bash
# Docker grubuna kullanıcı ekle
sudo usermod -aG docker $USER
newgrp docker

# Veya sudo ile çalıştır
sudo docker-compose up
```

---

## 📊 Ne Zaman Hangi Yöntem?

| Amaç | Yöntem | Komut |
|------|--------|-------|
| Hızlı test | Docker Test | `make test` |
| Görsel kontrol | Web Preview | `make up-web` |
| APK oluştur | Docker Build | `make build-apk` |
| Debugging | Dev Container | `make dev` |
| CI/CD | Docker Compose | `docker-compose up flutter-test` |
| Production | Manuel Flutter | `flutter build appbundle --release` |

---

## 🎓 Docker Öğrenmek İstiyorum

**Temel Konseptler**:

- **Image**: Uygulama şablonu (Dockerfile'dan build edilir)
- **Container**: Çalışan image instance'ı
- **Volume**: Kalıcı veri depolama
- **docker-compose**: Birden fazla container'ı yönetir

**Yararlı Komutlar**:

```bash
# Çalışan container'ları göster
docker ps

# Tüm container'ları göster (durdurulmuş dahil)
docker ps -a

# Container loglarını göster
docker logs <container-id>

# Container'a shell ile bağlan
docker exec -it <container-id> bash

# Image'ları listele
docker images

# Kullanılmayan her şeyi temizle
docker system prune -a
```

---

## ✅ Başarılı Kurulum Kontrolü

Aşağıdaki komutları çalıştırın ve hepsinin başarılı olduğunu doğrulayın:

```bash
# 1. Docker kurulu mu?
✓ docker --version

# 2. Compose kurulu mu?
✓ docker-compose --version

# 3. Image'lar build oluyor mu?
✓ make build-test

# 4. Testler çalışıyor mu?
✓ make test

# 5. Web preview çalışıyor mu?
✓ make up-web
✓ curl http://localhost:8080/health

# 6. Database çalışıyor mu?
✓ make up-db
✓ make shell-db

# Hepsi ✓ ise kurulum başarılı! 🎉
```

---

## 📚 Daha Fazla Bilgi

- **Detaylı Dokümantasyon**: `docker/README.md`
- **Docker Compose Dosyası**: `docker-compose.yml`
- **Dockerfile'lar**: `Dockerfile.dev`, `Dockerfile.test`, `Dockerfile.web`
- **Makefile**: Tüm komutlar için `Makefile`

---

## 🚀 Sonraki Adımlar

1. ✅ Docker kurulumunu tamamlayın
2. ✅ Testleri çalıştırın (`make test`)
3. ✅ Web preview'ı görün (`make up-web`)
4. ✅ APK build edin (`make build-apk`)
5. 📱 Gerçek cihazda test edin
6. 🏪 Store'lara yükleyin

---

**Docker ile TürkKalori'yi test etmek bu kadar kolay!** 🎉

Sorularınız için: support@turkkalori.com

**Son Güncelleme**: 29 Aralık 2025
