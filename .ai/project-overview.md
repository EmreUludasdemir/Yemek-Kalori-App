# 🍽️ TürkKalori - Türk Mutfağına Özel Kalori Takip Uygulaması

## 📱 Proje Özeti

TürkKalori, Türk mutfağına özel yemeklerle kalori takibi yapmanızı sağlayan bir Flutter mobil uygulamasıdır. Supabase backend, Firebase notifications ve AI destekli yemek tanıma özellikleriyle donatılmıştır.

## 🎯 Hedef Kitle

- Türk mutfağı tüketen kullanıcılar
- Kalori takibi yapmak isteyenler
- Sağlıklı beslenme hedefi olanlar
- Kilo verme/alma/koruma yapanlar

## 🏗️ Teknoloji Stack

### Frontend
- **Flutter 3.x** - Cross-platform mobile framework
- **Riverpod** - State management
- **fl_chart** - Charts and graphs
- **flutter_animate** - Animations
- **flutter_slidable** - Swipe gestures
- **introduction_screen** - Onboarding
- **intl** - Internationalization (Turkish)

### Backend & Services
- **Supabase** - PostgreSQL database, Auth, Storage
- **Firebase** - FCM push notifications, Analytics
- **Hive** - Local NoSQL storage
- **Camera** - Food photography
- **Image Picker** - Photo selection with compression & cropping
- **Connectivity Plus** - Network monitoring
- **Path Provider** - File system access

### Design System
- **Custom animations** - Page transitions, micro-interactions
- **Skeleton loaders** - Professional loading states
- **Empty states** - Beautiful placeholder screens
- **Dark mode** - Full theme support

## 📊 Veritabanı Yapısı

### Ana Tablolar
1. **profiles** - Kullanıcı profilleri (bio, avatar, is_public, followers/following counts)
2. **food_items** - Türk yemekleri veritabanı
3. **food_logs** - Günlük yemek kayıtları
4. **achievements** - Başarım sistemi
5. **meal_plans** - Haftalık öğün planları (JSONB daily_plans)
6. **meal_templates** - Yeniden kullanılabilir şablonlar
7. **weight_entries** - Kilo takibi kayıtları
8. **weight_goals** - Hedef kilo ayarları
9. **posts** - Sosyal gönderi paylaşımları (Phase 4)
10. **likes** - Post beğenileri (Phase 4)
11. **comments** - Post yorumları (Phase 4)
12. **follows** - Takip sistemi (Phase 4)
13. **notifications** - Bildirim sistemi (Phase 4)

### Hive Boxes (Local Storage)
- **onboarding_box** - İlk kullanım kontrolü
- **recent_searches_box** - Son aramalar
- **favorite_foods_box** - Favori yemekler
- **frequent_foods_box** - Sık kullanılan yemekler

## 🎨 UI/UX Özellikleri

### Modern Bileşenler
- MultiActionFAB - Hızlı eylem butonu
- CustomBottomSheet - Alt sayfa modalları
- CustomDialog - Özel diyaloglar
- SwipeableItem - Kaydırma gestürleri
- EmptyState - 12 farklı boş durum
- SkeletonLoader - 6 iskelet tipi

### Animasyonlar
- Page transitions (slide, fade, scale)
- Micro-interactions (bouncy buttons, like button)
- Hero animations (shared element transitions)
- Progress bar animations
- Lottie support

### Onboarding & Tutorial
- 5 sayfalık onboarding flow
- 6 adımlı profil kurulum sihirbazı
- Mifflin-St Jeor kalori hesaplama
- Feature discovery tooltips

## 🚀 Temel Özellikler

### ✅ Tamamlanmış (Faz 1-5)

**Kimlik Doğrulama**
- Email/password login
- Supabase Auth entegrasyonu

**Yemek Takibi**
- Türk yemekleri arama
- Öğün bazlı ekleme (kahvaltı, öğle, akşam, ara öğün)
- Besin değerleri (kalori, protein, karbonhidrat, yağ)
- Kamera ile fotoğraf
- Barkod okuyucu placeholder

**İstatistikler**
- Haftalık kalori grafiği (line chart)
- Aylık kalori grafiği
- Makro besin dağılımı (pie chart)
- Empty state handling

**Başarımlar**
- 20+ başarım
- 5 kategori (Başlangıç, Düzenlilik, Kalori, Sosyal, Özel)
- Progress tracking

**Akıllı Özellikler**
- Son aramalar (son 10)
- Favori yemekler (toggle)
- Sık kullanılan yemekler (top 20, usage count)
- Akıllı öneriler (meal time, calorie budget, similar foods)
- Quick add section (tabbed: Recent/Favorites/Frequent)

**Öğün Planlama** (Faz 3)
- Haftalık plan oluşturma
- Günlük öğün yönetimi
- Meal templates (kişisel ve genel)
- Plan-to-log kopyalama
- Akıllı plan oluşturma (kalori hedefine göre)

**Kilo Takibi** (Faz 3)
- Günlük kilo girişi
- Fotoğraf ve notlar
- Vücut ölçüleri (boyun, bel, kalça, göğüs)
- Hedef ayarlama (ver/al/koru)
- İlerleme yüzdesi
- BMI hesaplama
- Trend analizi (30 gün)
- Haftalık ortalamalar
- CSV export

**UI/UX İyileştirmeleri**
- Dark mode
- Turkish localization
- Skeleton loading
- Empty states
- Page transitions
- Swipe gestures
- Bottom sheets
- Custom dialogs

**Sosyal Özellikler** (Faz 4)
- Kullanıcı profilleri (avatar, bio, stats)
- Takip sistemi (follow/unfollow)
- Post paylaşımı (text + image)
- Like ve comment sistemi
- Activity feed
- Notifications sistemi
- Leaderboard (streak, posts, followers)
- Image upload (Supabase Storage)

**Teknik İyileştirmeler** (Faz 5)
- Image picker (compression, cropping)
- Firebase Analytics (20+ event tracking)
- Cache service (LRU, TTL)
- Exception handling (10+ custom exception types)
- Connectivity service (network monitoring)
- Unit tests (models, services)

### 🚧 Kısmi Tamamlanmış

**AI Yemek Tanıma**
- Kamera entegrasyonu var
- AI backend entegrasyonu eksik

**Su Takibi**
- Backend hazır
- Hatırlatıcı sistemi eksik

### ⏳ Planlanmış (Faz 6+)

**Tarif Veritabanı**
- 100+ Türk yemeği tarifi
- Adım adım talimatlar
- Cooking mode

**Premium Özellikler**
- Özel diyet planları
- Profesyonel danışmanlık
- Gelişmiş analitik
- Reklamsız deneyim

**İleri Teknik Özellikler**
- Offline mode (Drift/SQLite sync)
- Performance monitoring (Firebase Performance)
- Crash reporting (Crashlytics)
- Widget tests
- Integration tests (E2E)

## 📁 Proje Yapısı

```
lib/
├── config/              # Supabase, Firebase yapılandırma
├── core/
│   └── constants/       # AppColors, app sabitler
├── data/
│   └── models/          # Veri modelleri
├── presentation/
│   ├── screens/         # Ekranlar (home, profile, stats, meal_planning, etc.)
│   └── widgets/         # Yeniden kullanılabilir bileşenler
│       ├── animations/  # Page transitions, micro-interactions
│       ├── common/      # Empty state, FAB, swipeable, bottom sheets
│       ├── food/        # Meal section, quick add
│       ├── loading/     # Skeleton loaders
│       ├── modals/      # Dialogs, bottom sheets
│       └── tutorial/    # Feature discovery
└── services/            # Business logic
    ├── meal_planning_service.dart
    ├── weight_tracking_service.dart
    ├── water_reminder_service.dart
    ├── social_service.dart          # Phase 4 - 40+ methods
    ├── recent_searches_service.dart
    ├── smart_suggestions_service.dart
    ├── nutrition_service.dart
    ├── image_picker_service.dart    # Phase 5 - Image processing
    ├── analytics_service.dart       # Phase 5 - Firebase Analytics
    ├── cache_service.dart           # Phase 5 - LRU cache
    └── connectivity_service.dart    # Phase 5 - Network monitoring
```

## 🔄 Aktif Geliştirme Döngüsü

**Faz 1** ✅ Tasarım Sistemi & UI Polish
**Faz 2** ✅ Kullanıcı Deneyimi (Onboarding, Tutoriallar)
**Faz 3** ✅ Advanced Features (Meal Planning, Weight Tracking, Water Reminders)
**Faz 4** ✅ Sosyal & Topluluk (Profiles, Feed, Follow, Like/Comment, Leaderboard)
**Faz 5** ✅ Teknik İyileştirmeler (Image Processing, Analytics, Cache, Exception Handling, Tests)
**Faz 6** ⏳ Premium Özellikler

## 📈 Metrikler

- **Toplam Satır:** ~30,200+ (Phase 5 sonrası)
- **Model Sayısı:** 20+
- **Servis Sayısı:** 18+
- **Ekran Sayısı:** 37+
- **Widget Sayısı:** 52+
- **Animasyon Tipi:** 10+
- **API Methodları:** 100+
- **Features:** 160+
- **Test Files:** 3 (unit tests)

## 🎓 Öğrenilen Dersler

1. **Provider Pattern:** FutureProvider.autoDispose ile otomatik temizleme
2. **Hive Optimization:** Box'ları lazy açma, compact() ile temizleme
3. **Turkish Formatting:** intl package ile tarih/saat lokalizasyonu
4. **Skeleton States:** Kullanıcı deneyimi için kritik
5. **Empty States:** Her durum için özel tasarım gerekli
6. **Swipe Gestures:** flutter_slidable ile kolay implementasyon
7. **JSONB in Supabase:** Kompleks nested data için ideal
8. **Service Layer:** Business logic'i UI'dan ayırma
9. **Riverpod Families:** Dynamic provider creation
10. **Micro-interactions:** Küçük detaylar büyük fark yaratır

## 🐛 Bilinen Limitasyonlar

1. AI yemek tanıma backend'i bağlanmamış
2. Offline mod henüz yok (local-first sync)
3. Health app entegrasyonu yok (Apple Health, Google Fit)
4. Recipe database boş
5. Pagination eksik (feed, comments için TODO)
6. Real-time subscription eksik (canlı bildirim için)
7. Performance monitoring eksik (Firebase Performance)
8. Crash reporting eksik (Crashlytics)
9. Widget tests ve integration tests yok

## 🔐 Environment Variables

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
FIREBASE_API_KEY=your_api_key
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_APP_ID=your_app_id
```

## 📝 Git Workflow

- **Branch:** `claude/turkish-calorie-tracker-ai-dVMj6`
- **Main Branch:** Not specified (push to current branch)
- **Commit Style:** Conventional commits (feat:, fix:, chore:)
- **Auto-push:** After each major milestone

## 👥 Ekip

- **Geliştirici:** EmreUludasdemir
- **AI Assistant:** Claude (Anthropic)
- **Repo:** github.com/EmreUludasdemir/Yemek-Kalori-App

---

*Son Güncelleme: 2025-12-26*
*Versiyon: Phase 5 - COMPLETE (Technical Improvements: Image Processing, Analytics, Cache, Exception Handling, Connectivity, Unit Tests)*
