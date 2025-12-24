# 🍽️ TürkKalori - AI Destekli Sosyal Kalori Takip Uygulaması

Türkiye pazarı için geliştirilmiş, yapay zeka ile yemek fotoğraflarından kalori hesaplayan, sosyal medya özellikleri içeren cross-platform mobil uygulama.

## 🎯 Proje Özeti

TürkKalori, MyFitnessPal ve YAZIO gibi uluslararası uygulamaların Türk yemekleri konusundaki eksikliğini gidermek için geliştirilmiş bir kalori takip uygulamasıdır.

### Temel Özellikler

- ✅ **AI ile Yemek Tanıma**: Fotoğraftan otomatik kalori hesaplama (TFLite + Calorie Mama API)
- ✅ **Türk Yemekleri Veritabanı**: 150+ Türk yemeği (TürKomp verisi)
- ✅ **Sosyal Feed**: Paylaşım, beğeni, yorum sistemi
- 🔄 **Günlük Takip**: Kalori, protein, karbonhidrat, yağ takibi
- 🔄 **Barkod Tarama**: Paketli ürünler için barkod okuyucu
- 🔄 **İstatistikler**: Haftalık/aylık grafikler ve raporlar
- 🔄 **Gamification**: Seri (streak) sistemi, başarımlar

## 🛠️ Teknoloji Stack

```yaml
Frontend:
  - Flutter 3.x (Cross-platform: iOS, Android, Web)
  - Riverpod (State Management)
  - go_router (Navigation)

Backend:
  - Supabase (PostgreSQL, Auth, Storage, Realtime)
  - Firebase Cloud Messaging (Push Notifications)

AI/ML:
  - TensorFlow Lite (On-device Turkish food recognition)
  - Calorie Mama API (Fallback recognition)

Nutrition APIs:
  - FatSecret Platform API (Primary)
  - Open Food Facts (Barcode fallback)
  - TürKomp Integration (Turkish foods)

UI/Charts:
  - fl_chart (Kalori grafikleri)
  - percent_indicator (Progress ring)
  - cached_network_image (Image caching)
```

## 📁 Proje Yapısı

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/         # Renkler, stringler, API endpoints
│   ├── utils/            # Yardımcı fonksiyonlar
│   └── extensions/       # Dart extensions
├── config/
│   ├── routes.dart       # go_router yapılandırması
│   ├── supabase_config.dart
│   └── firebase_config.dart
├── data/
│   ├── models/          # Data modelleri
│   ├── repositories/    # Repository pattern
│   └── datasources/     # API data sources
├── presentation/
│   ├── screens/         # Uygulama ekranları
│   └── widgets/         # Reusable widget'lar
└── services/           # Business logic servisleri
    ├── ai_recognition_service.dart   ✅
    ├── nutrition_service.dart        🔄
    ├── auth_service.dart            🔄
    └── social_service.dart          🔄

supabase/
├── schema.sql                        ✅
└── seed_turkish_foods.sql            ✅

docs/
└── turkish-calorie-app-prompt.md     ✅
```

## 🗄️ Veritabanı

### Supabase PostgreSQL Tabloları

- ✅ **profiles** - Kullanıcı profilleri
- ✅ **foods** - Yemek veritabanı (150+ Türk yemeği seed data)
- ✅ **food_logs** - Kullanıcı yemek kayıtları
- ✅ **posts** - Sosyal paylaşımlar
- ✅ **likes** - Beğeniler
- ✅ **comments** - Yorumlar
- ✅ **follows** - Takip sistemi
- ✅ **notifications** - Bildirimler
- ✅ **achievements** - Başarımlar

### Row Level Security (RLS)

Tüm tablolar için RLS politikaları tanımlanmış, kullanıcılar sadece kendi verilerine ve public verilere erişebilir.

## 🚀 Kurulum

### Gereksinimler

- Flutter SDK 3.0+
- Dart SDK 3.0+
- Supabase hesabı
- Firebase projesi (FCM için)

### Adım 1: Bağımlılıkları Yükle

```bash
flutter pub get
```

### Adım 2: Supabase Kurulumu

1. [Supabase](https://app.supabase.com) hesabı oluşturun
2. Yeni proje oluşturun
3. `supabase/schema.sql` dosyasını SQL Editor'de çalıştırın
4. `supabase/seed_turkish_foods.sql` dosyasını çalıştırın
5. Storage'da 3 bucket oluşturun: `avatars`, `food_images`, `post_images`
6. `lib/config/supabase_config.dart` dosyasındaki URL ve API key'i güncelleyin

### Adım 3: Firebase Kurulumu

1. [Firebase Console](https://console.firebase.google.com)'da proje oluşturun
2. iOS ve Android uygulamalarını ekleyin
3. `google-services.json` (Android) ve `GoogleService-Info.plist` (iOS) dosyalarını indirin
4. `lib/config/firebase_config.dart` dosyasını güncelleyin

### Adım 4: API Key'leri Ayarlayın

`.env` dosyası oluşturun:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
CALORIE_MAMA_API_KEY=your_calorie_mama_api_key
FATSECRET_API_KEY=your_fatsecret_api_key
```

### Adım 5: Uygulamayı Çalıştırın

```bash
flutter run
```

## 📊 Tamamlanma Durumu

### ✅ Tamamlanan

- [x] Proje yapısı ve klasör organizasyonu
- [x] Tema ve tasarım sistemi (renkler, tipografi)
- [x] Supabase veritabanı şeması (11 tablo + triggers + RLS)
- [x] Türk yemekleri seed data (150+ yemek)
- [x] AI yemek tanıma servisi (TFLite + Calorie Mama API)
- [x] Sosyal feed ekranı ve post card widget
- [x] Data modelleri (User, Post, Comment, Nutrition)

### 🔄 Devam Eden

- [ ] Ana sayfa (kalori progress ring)
- [ ] Authentication (login/register)
- [ ] Yemek arama ve manuel ekleme
- [ ] Kamera entegrasyonu
- [ ] Barkod tarama
- [ ] Profil ekranı
- [ ] İstatistikler ve grafikler
- [ ] Push notifications
- [ ] Offline sync

### 📋 Planlanan

- [ ] Unit ve widget testleri
- [ ] Dark mode optimizasyonları
- [ ] Türkçe/İngilizce lokalizasyon
- [ ] Performance optimizasyonu
- [ ] App Store / Play Store yayını

## 🎨 UI/UX Tasarım

### Renk Paleti

- **Primary**: `#4CAF50` (Yeşil - Sağlık)
- **Accent**: `#FF5722` (Turuncu - Enerji)
- **Protein**: `#2196F3` (Mavi)
- **Carbs**: `#FFC107` (Sarı)
- **Fat**: `#E91E63` (Pembe)

### Ekran Tasarımları

Detaylı UI mockup'lar için `docs/turkish-calorie-app-prompt.md` dosyasına bakın.

## 💰 Maliyet Tahmini (MVP)

| Servis | Aylık Maliyet |
|--------|---------------|
| Supabase Pro | $25 |
| ImageKit | $9 |
| Firebase FCM | Ücretsiz |
| FatSecret API | $0-19 (Free tier) |
| **TOPLAM** | **~$34-54** |

## 🔐 Güvenlik

- Row Level Security (RLS) aktif
- JWT token authentication
- API key'ler environment variables'da
- Input validation tüm formlarda
- KVKK uyumlu veri işleme

## 📱 Desteklenen Platformlar

- ✅ iOS 12+
- ✅ Android 5.0+ (API 21+)
- ✅ Web (responsive)
- 🔄 macOS (opsiyonel)
- 🔄 Windows (opsiyonel)

## 🌍 Lokalizasyon

- 🇹🇷 Türkçe (Varsayılan)
- 🇺🇸 İngilizce (Planlanan)

## 📝 Lisans

Bu proje özel bir proje olup, ticari kullanım için geliştirilmiştir.

## 👥 Katkıda Bulunanlar

- **Geliştirici**: Claude AI
- **Proje Sahibi**: [İsminiz]

## 📞 İletişim

Sorularınız için: [email@example.com]

---

**MVP Hedefi**: 3-4 ay | **İlk Kullanıcı Hedefi**: 10K+ | **Pazar**: Türkiye (85M+ nüfus)
