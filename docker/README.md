# TürkKalori Docker Test Ortamı

Bu rehber TürkKalori uygulamasını Docker ile nasıl test edeceğinizi açıklar.

---

## 🐳 Kurulum

### Ön Gereksinimler

```bash
# Docker kurulu mu kontrol et
docker --version
docker-compose --version

# Eğer kurulu değilse:
# Ubuntu/Debian:
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

---

## 🚀 Kullanım Senaryoları

### 1. Flutter Development Environment (Tam Geliştirme Ortamı)

```bash
# Container'ı başlat
docker-compose up -d flutter-dev

# Container'a bağlan
docker exec -it turkkalori-dev bash

# Container içinde:
flutter doctor
flutter pub get
flutter test
flutter build apk --debug
```

**Kullanım Alanları**:
- Yerel Flutter kurulumu olmadan geliştirme
- CI/CD pipeline'larında tutarlı ortam
- Farklı Flutter versiyonlarını test etme

---

### 2. Automated Testing (Otomatik Testler)

```bash
# Testleri çalıştır
docker-compose up flutter-test

# Sadece build et (test çalıştırmadan)
docker-compose build flutter-test

# Test sonuçlarını görüntüle
docker-compose run flutter-test flutter test --coverage

# Coverage raporunu HTML'e çevir
docker-compose run flutter-test sh -c "
    flutter test --coverage && \
    genhtml coverage/lcov.info -o coverage/html
"

# Coverage raporunu tarayıcıda görüntüle
# http://localhost:8081 adresine git
docker-compose up coverage-reporter
```

**Test Türleri**:
- Unit tests: `flutter test test/unit/`
- Widget tests: `flutter test test/widget/`
- Integration tests: `flutter test test/integration/`

---

### 3. Flutter Web Preview (Web Versiyonu)

```bash
# Web versiyonunu build et ve çalıştır
docker-compose up -d flutter-web

# Tarayıcıda aç
# http://localhost:8080

# Logları görüntüle
docker-compose logs -f flutter-web

# Yeniden build et
docker-compose up --build flutter-web
```

**Not**: Web versiyonu tüm native özellikleri desteklemez (Camera, HealthKit, vs.)

---

### 4. Local Backend Testing (PostgreSQL + Supabase)

```bash
# Tüm servisleri başlat
docker-compose up -d postgres supabase-studio

# PostgreSQL'e bağlan
docker exec -it turkkalori-db psql -U postgres -d turkkalori

# Supabase Studio
# http://localhost:3000

# Database durumunu kontrol et
docker-compose exec postgres psql -U postgres -d turkkalori -c "SELECT * FROM foods LIMIT 5;"
```

---

## 📋 Hızlı Komutlar

### Tüm Servisleri Başlat

```bash
docker-compose up -d
```

### Belirli Bir Servisi Başlat

```bash
docker-compose up -d flutter-dev
docker-compose up -d flutter-test
docker-compose up -d flutter-web
docker-compose up -d postgres
```

### Container Loglarını Görüntüle

```bash
# Tüm servisler
docker-compose logs -f

# Belirli servis
docker-compose logs -f flutter-test
```

### Container'lara Bağlan

```bash
# Development container
docker exec -it turkkalori-dev bash

# Database
docker exec -it turkkalori-db psql -U postgres -d turkkalori
```

### Container'ları Durdur

```bash
# Tümünü durdur
docker-compose down

# Volume'ları da sil (veritabanı verilerini temizler)
docker-compose down -v

# Image'ları da sil
docker-compose down --rmi all
```

### Temiz Başlangıç

```bash
# Her şeyi sil ve yeniden başlat
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

---

## 🧪 Test Senaryoları

### Senaryo 1: Unit Testleri Çalıştır

```bash
docker-compose run --rm flutter-test flutter test test/unit/
```

### Senaryo 2: Widget Testleri Çalıştır

```bash
docker-compose run --rm flutter-test flutter test test/widget/
```

### Senaryo 3: Coverage Raporu Oluştur

```bash
docker-compose run --rm flutter-test sh -c "
    flutter test --coverage && \
    lcov --summary coverage/lcov.info
"
```

### Senaryo 4: Android APK Build

```bash
docker-compose run --rm flutter-dev sh -c "
    flutter pub get && \
    flutter build apk --debug
"

# APK dosyası: build/app/outputs/flutter-apk/app-debug.apk
```

### Senaryo 5: Web Build

```bash
docker-compose up --build flutter-web
# http://localhost:8080 adresine git
```

---

## 🔍 Debugging

### Container Durumunu Kontrol Et

```bash
# Çalışan container'lar
docker-compose ps

# Resource kullanımı
docker stats

# Disk kullanımı
docker system df
```

### Hata Logları

```bash
# Tüm loglar
docker-compose logs

# Son 100 satır
docker-compose logs --tail=100

# Gerçek zamanlı takip
docker-compose logs -f flutter-test
```

### Health Check

```bash
# Web servis health check
curl http://localhost:8080/health

# Database health check
docker-compose exec postgres pg_isready -U postgres
```

---

## 📦 Volume Yönetimi

### Volume'ları Listele

```bash
docker volume ls | grep turkkalori
```

### Cache Temizleme

```bash
# Flutter pub cache temizle
docker volume rm turkkalori-pub-cache

# Gradle cache temizle
docker volume rm turkkalori-gradle-cache

# Tüm volume'ları temizle
docker-compose down -v
```

### Backup Oluştur

```bash
# Database backup
docker-compose exec postgres pg_dump -U postgres turkkalori > backup.sql

# Restore
docker-compose exec -T postgres psql -U postgres turkkalori < backup.sql
```

---

## 🔧 Özelleştirme

### .env Dosyası Oluştur

```bash
# .env dosyası oluştur
cat > .env << EOF
# Database
POSTGRES_USER=postgres
POSTGRES_PASSWORD=super_secret_password
POSTGRES_DB=turkkalori

# Flutter
FLUTTER_VERSION=stable
ENABLE_WEB=true

# Ports
WEB_PORT=8080
DB_PORT=5432
SUPABASE_PORT=3000
EOF
```

### docker-compose.override.yml (Kişisel Ayarlar)

```yaml
# docker-compose.override.yml
version: '3.8'

services:
  flutter-dev:
    environment:
      - CUSTOM_ENV_VAR=value
    ports:
      - "5555:5555"  # Debug portu
```

---

## 🎯 CI/CD Entegrasyonu

### GitHub Actions

```yaml
# .github/workflows/docker-test.yml
name: Docker Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Run tests in Docker
        run: |
          docker-compose up -d flutter-test
          docker-compose logs flutter-test

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
```

### GitLab CI

```yaml
# .gitlab-ci.yml
test:
  image: docker/compose:latest
  services:
    - docker:dind
  script:
    - docker-compose up --exit-code-from flutter-test
  artifacts:
    paths:
      - coverage/
```

---

## 🐛 Bilinen Sorunlar ve Çözümler

### Sorun 1: Android Emulator Docker'da Çalışmıyor

**Sebep**: Android emulator KVM/nested virtualization gerektirir

**Çözüm**: Headless testing kullanın:
```bash
docker-compose run flutter-test flutter test
```

### Sorun 2: Container Yavaş Çalışıyor

**Çözüm**: Volume mounting yerine COPY kullanın (production builds için):
```dockerfile
COPY . /app
```

### Sorun 3: Permission Denied

**Çözüm**: Container içinde kullanıcı ID'sini ayarlayın:
```bash
docker-compose run --user $(id -u):$(id -g) flutter-dev flutter pub get
```

### Sorun 4: Port Conflict

**Çözüm**: docker-compose.yml'de portları değiştirin:
```yaml
ports:
  - "8081:80"  # 8080 yerine 8081
```

---

## 📊 Performance Optimization

### Build Cache Kullanımı

```dockerfile
# İyi: Önce dependencies, sonra kod
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .

# Kötü: Her şeyi birden kopyala
COPY . .
RUN flutter pub get
```

### Multi-stage Build

```dockerfile
FROM flutter AS builder
COPY . .
RUN flutter build web

FROM nginx:alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
```

### Docker Layer Caching

```bash
# GitHub Actions için
- uses: docker/build-push-action@v4
  with:
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

---

## 📚 Ek Kaynaklar

**Docker Docs**: https://docs.docker.com
**Flutter Docker**: https://github.com/cirruslabs/docker-images-flutter
**Supabase Local**: https://supabase.com/docs/guides/self-hosting/docker

---

## ✅ Checklist - Docker Setup Doğrulama

- [ ] Docker ve Docker Compose kurulu
- [ ] `docker-compose up -d` başarılı
- [ ] `docker-compose ps` tüm servisleri gösteriyor
- [ ] Web preview http://localhost:8080 çalışıyor
- [ ] Database http://localhost:5432 erişilebilir
- [ ] Testler `docker-compose up flutter-test` ile çalışıyor
- [ ] Coverage raporu oluşturuluyor
- [ ] Container'lara `docker exec` ile bağlanabiliyor

---

**Son Güncelleme**: 29 Aralık 2025
**Docker Version**: 24.0+
**Docker Compose Version**: 2.0+
