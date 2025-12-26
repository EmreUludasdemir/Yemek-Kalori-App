# 🍽️ TürkKalori - AI Destekli Kalori Takip Uygulaması

> **Türk mutfağına özel, profesyonel tasarımlı, full-featured kalori takip uygulaması**

TürkKalori, Türkiye pazarı için geliştirilmiş, modern UI/UX tasarımı, akıllı öneriler ve gelişmiş analitiklerle donatılmış bir sağlıklı yaşam asistanıdır.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-3ECF8E?logo=supabase)](https://supabase.com)
[![License](https://img.shields.io/badge/license-Private-red)]()

---

## 🎯 Proje Özeti

MyFitnessPal ve YAZIO gibi uluslararası uygulamaların Türk yemekleri konusundaki eksikliğini gidermek için geliştirilmiş, **profesyonel seviyede** bir kalori takip uygulaması.

### ✨ Temel Özellikler

#### 🍽️ Yemek Takibi
- ✅ **Türk Yemekleri Veritabanı** - 150+ Türk yemeği (TürKomp verisi)
- ✅ **Akıllı Arama** - Full-text search + kategori filtreleme
- ✅ **Hızlı Ekle** - Son kullanılan, favoriler, sık kullanılan yemekler
- ✅ **Öğün Bazlı** - Kahvaltı, öğle, akşam, ara öğün
- ✅ **Porsiyon Kontrolü** - Hassas kalori hesaplama
- ✅ **Swipe Gestures** - Kaydırarak sil/düzenle
- 🔄 **AI Yemek Tanıma** - Kamera ile otomatik tanıma (backend bekleniyor)
- 🔄 **Barkod Tarama** - Paketli ürünler (UI hazır)

#### 📊 İstatistikler & Analitik
- ✅ **Haftalık/Aylık Grafikler** - fl_chart ile görselleştirme
- ✅ **Makro Besin Dağılımı** - Protein, karbonhidrat, yağ pie chart
- ✅ **Günlük Hedef Takibi** - Progress ring & indicator bar
- ✅ **Trend Analizi** - Min/max/ortalama değerler

#### 🗓️ Öğün Planlama (Phase 3 ✅)
- ✅ **Haftalık Plan Oluşturma** - Tarih aralığı ile
- ✅ **Günlük Öğün Yönetimi** - Sürükle-bırak, ekle/sil
- ✅ **Meal Templates** - Yeniden kullanılabilir şablonlar
- ✅ **Plan-to-Log** - Planı günlüğe kopyalama
- ✅ **Akıllı Planlama** - Kalori hedefine göre otomatik

#### ⚖️ Kilo Takibi (Phase 3 ✅)
- ✅ **Kilo Grafiği** - Son 30 günlük line chart
- ✅ **Hedef Belirleme** - Kilo ver/al/koru
- ✅ **İlerleme Takibi** - Progress bar + istatistikler
- ✅ **Vücut Ölçüleri** - Boyun, bel, kalça, göğüs
- ✅ **BMI Hesaplama** - Otomatik kategori (Zayıf/Normal/Fazla Kilolu/Obez)
- ✅ **Sağlıklı Değişim Kontrolü** - 0.5-1 kg/hafta validasyon
- ✅ **CSV Export** - Veri dışa aktarma

#### 💧 Su Takibi (Phase 3 ✅)
- ✅ **Günlük Bardak Sayacı** - 8 bardak hedef
- ✅ **Progress Bar** - Görsel ilerleme
- ✅ **Su Hatırlatıcıları** - Akıllı bildirimler
  - Interval (15-240 dakika)
  - Aktif saat aralığı (örn: 8:00-22:00)
  - 4 ön ayar (Sık, Normal, Rahat, İş Saatleri)
  - 8 farklı motivasyon mesajı
- ✅ **Ayarlar Ekranı** - Slider'lar, toggle'lar

#### 🎨 UI/UX Excellence (Phase 1 & 2 ✅)
- ✅ **Modern Animasyonlar** - Page transitions, micro-interactions
- ✅ **Skeleton Loading** - Profesyonel yükleme durumları
- ✅ **Empty States** - 12 farklı boş durum tasarımı
- ✅ **Bottom Sheets** - Modal'lar, quick actions
- ✅ **Custom Dialogs** - Success, error, confirmation, info
- ✅ **Multi-Action FAB** - Speed dial buton (4 eylem)
- ✅ **Swipeable Items** - Kaydırma gestürleri
- ✅ **Onboarding** - 5 sayfalık tanıtım
- ✅ **Profile Wizard** - 6 adımlı kurulum + kalori hesaplama
- ✅ **Feature Discovery** - Spotlight tooltip'ler
- ✅ **Dark Mode** - Tam tema desteği

#### 🏆 Başarımlar & Gamification
- ✅ **20+ Başarım** - 5 kategori (Başlangıç, Düzenlilik, Kalori, Sosyal, Özel)
- ✅ **Progress Tracking** - %0-100 ilerleme
- ✅ **Rarity System** - Common, Rare, Epic, Legendary
- ✅ **Unlock Animations** - Görsel ödüller

#### 🔔 Bildirimler
- ✅ **Firebase FCM** - Push notification altyapısı
- ✅ **Su Hatırlatıcıları** - Zamanlanmış bildirimler
- 🔄 **Öğün Hatırlatıcıları** (planlanan)
- 🔄 **Başarım Bildirimleri** (planlanan)

#### 👥 Sosyal Özellikler (Phase 4 ✅)
- ✅ **Kullanıcı Profilleri** - Public/private hesaplar, bio, avatar
- ✅ **Gönderi Paylaşımı** - Meal posts, fotoğraf yükleme
- ✅ **Takip Sistemi** - Follow/unfollow, takipçi/takip edilen listeleri
- ✅ **Activity Feed** - Following ve popular feed'ler
- ✅ **Like & Comment** - Post beğenme ve yorum yapma
- ✅ **Liderlik Tablosu** - 3 kategori (Seri, Gönderiler, Takipçiler)
- ✅ **Bildirim Sistemi** - Like, comment, follow bildirimleri
- ✅ **Kullanıcı Arama** - Username/full name search
- ✅ **Profil Düzenleme** - Avatar, bio, username, privacy settings

---

## 🛠️ Teknoloji Stack

### Frontend
```yaml
Framework: Flutter 3.x (Cross-platform)
State Management: Riverpod 2.x
  - FutureProvider.autoDispose (auto cleanup)
  - Family providers (dynamic params)

UI Libraries:
  - fl_chart ^0.68.0              # Grafikler
  - flutter_animate ^4.5.0         # Animasyonlar
  - flutter_slidable ^3.1.0        # Swipe gestures
  - introduction_screen ^3.1.14    # Onboarding
  - smooth_page_indicator ^1.2.0   # Page indicators
  - flutter_speed_dial ^7.0.0      # Multi-action FAB
  - intl ^0.18.0                   # Turkish formatting

Local Storage:
  - Hive ^2.2.3                    # NoSQL cache
  - hive_flutter ^1.1.0

Notifications:
  - flutter_local_notifications ^17.0.0
  - timezone ^0.9.0
```

### Backend & Services
```yaml
Primary Database: Supabase (PostgreSQL)
  - 11 tables with RLS policies
  - Real-time subscriptions
  - Auto-generated REST API

Authentication: Supabase Auth
  - Email/password
  - JWT tokens
  - Auto-refresh

Push Notifications: Firebase Cloud Messaging
  - Project ID: turkkalori
  - Android + iOS support

File Storage: Supabase Storage
  - 3 buckets: avatars, food_images, post_images
```

### AI/ML (Planned)
```yaml
On-Device: TensorFlow Lite
  - Turkish food recognition model

Fallback API: Calorie Mama API
  - Cloud-based recognition
```

---

## 📁 Proje Yapısı

```
lib/
├── main.dart
├── app.dart
├── config/
│   ├── supabase_config.dart          # Supabase client
│   └── firebase_config.dart          # Firebase setup
│
├── core/
│   └── constants/
│       └── app_colors.dart           # Color palette
│
├── data/
│   └── models/                       # 15+ models
│       ├── food_item_model.dart
│       ├── food_log_model.dart
│       ├── meal_plan_model.dart      # Phase 3
│       ├── weight_entry_model.dart   # Phase 3
│       └── achievement_model.dart
│
├── services/                         # 13+ services
│   ├── meal_planning_service.dart    # 15+ methods
│   ├── weight_tracking_service.dart  # 20+ methods
│   ├── water_reminder_service.dart   # Phase 3
│   ├── recent_searches_service.dart  # Hive
│   ├── smart_suggestions_service.dart
│   └── nutrition_service.dart
│
└── presentation/
    ├── screens/                      # 30+ screens
    │   ├── home/
    │   │   └── home_screen.dart      # Main dashboard
    │   ├── food_log/
    │   │   ├── food_search_screen.dart
    │   │   └── add_food_screen.dart
    │   ├── meal_planning/            # Phase 3 (3 screens)
    │   │   ├── meal_plan_screen.dart
    │   │   ├── create_meal_plan_screen.dart
    │   │   └── meal_plan_detail_screen.dart
    │   ├── weight/                   # Phase 3 (3 screens)
    │   │   ├── weight_tracking_screen.dart
    │   │   ├── add_weight_entry_screen.dart
    │   │   └── weight_goal_screen.dart
    │   ├── settings/
    │   │   └── water_reminder_settings_screen.dart
    │   ├── profile/
    │   │   ├── stats_screen.dart
    │   │   └── achievements_screen.dart
    │   └── onboarding/               # Phase 2
    │       ├── onboarding_screen.dart
    │       └── profile_setup_wizard.dart
    │
    └── widgets/                      # 50+ reusable widgets
        ├── animations/               # Phase 1
        │   ├── page_transitions.dart (8 types)
        │   └── micro_interactions.dart
        ├── common/
        │   ├── empty_state.dart      (12 types)
        │   ├── multi_action_fab.dart
        │   ├── swipeable_item.dart
        │   └── custom_bottom_sheet.dart
        ├── loading/
        │   └── skeleton_loader.dart  (6 types)
        ├── modals/
        │   └── custom_dialog.dart    (5 types)
        ├── food/
        │   ├── meal_section.dart
        │   └── quick_add_section.dart
        └── tutorial/
            └── feature_discovery.dart

.ai/                                  # AI Memory System
├── README.md                         # Usage guide
├── project-overview.md               # Project summary
├── features.md                       # 100+ features
├── architecture.md                   # Design patterns
└── decisions.md                      # Technical decisions

docs/
├── YOL_HARITASI.md                   # 12-week roadmap
└── BILGISAYARDA_CALISTIRMA.md        # Platform-specific setup
```

---

## 🗄️ Veritabanı

### Supabase PostgreSQL Tables

```sql
-- User & Auth
✅ users                  # User profiles, goals, preferences

-- Food & Nutrition
✅ food_items             # 150+ Turkish foods (TürKomp)
✅ food_logs              # Daily meal entries

-- Meal Planning (Phase 3)
✅ meal_plans             # Weekly plans (JSONB daily_plans)
✅ meal_templates         # Reusable meal combos

-- Weight Tracking (Phase 3)
✅ weight_entries         # Weight logs + measurements
✅ weight_goals           # Target setting

-- Gamification
✅ achievements           # 20+ achievements
✅ user_achievements      # User progress

-- Social (Partial)
🔄 posts                  # Meal sharing
🔄 likes                  # Post likes
🔄 comments               # Post comments
🔄 follows                # Follow system
```

### Hive Boxes (Local Storage)

```dart
✅ onboarding_box         # First-time user flag
✅ recent_searches_box    # Last 10 searches (FIFO)
✅ favorite_foods_box     # Favorited foods
✅ frequent_foods_box     # Usage count (top 20)
✅ water_reminders_box    # Notification settings
```

### Row Level Security (RLS)

Tüm tablolar için RLS aktif. Kullanıcılar:
- ✅ Kendi verilerine tam erişim
- ✅ Public data'ya okuma erişimi
- ❌ Başkalarının private data'sına erişim YOK

---

## 🚀 Hızlı Başlangıç

### Ön Gereksinimler

- **Flutter SDK** 3.0+
- **Dart SDK** 3.0+
- Git

### 1️⃣ Repository Clone

```bash
git clone https://github.com/EmreUludasdemir/Yemek-Kalori-App.git
cd Yemek-Kalori-App
```

### 2️⃣ Dependencies Install

```bash
flutter pub get
```

### 3️⃣ Çalıştır

**🖥️ Bilgisayarda (Hızlı Test):**

Windows:
```cmd
START.bat
```

macOS/Linux:
```bash
./start.sh
```

**📱 Mobil (Emulator/Device):**

```bash
# Android
flutter run -d android

# iOS (macOS only)
flutter run -d ios

# Chrome (Web)
flutter run -d chrome
```

**⚙️ Platform-Specific Setup:**

Detaylı kurulum için: [BILGISAYARDA_CALISTIRMA.md](BILGISAYARDA_CALISTIRMA.md)

---

## ⚙️ Yapılandırma

### Supabase Setup (Opsiyonel)

Backend özellikleri için Supabase gerekli:

1. [Supabase](https://app.supabase.com) hesabı oluştur
2. Yeni proje oluştur
3. `supabase/schema.sql` dosyasını SQL Editor'de çalıştır
4. `lib/config/supabase_config.dart` içinde URL ve ANON KEY güncelle

### Firebase Setup (Opsiyonel)

Push notifications için:

1. Firebase Console'da proje oluştur
2. Android + iOS uygulamaları ekle
3. `google-services.json` (Android) ve `GoogleService-Info.plist` (iOS) indir
4. İlgili klasörlere kopyala

**Platform Permissions:**

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

**iOS:** UserNotifications framework'ü ekle

### Environment Variables

`.env` dosyası oluştur (opsiyonel):

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
FIREBASE_API_KEY=your-api-key
```

---

## 📊 Development Status

### ✅ Phase 1: Design System & UI Polish (100%)

- ✅ 8 Page transitions (slide, fade, scale)
- ✅ Micro-interactions (bouncy button, like animation)
- ✅ 6 Skeleton loaders (card, list, stats, profile, post, chart)
- ✅ 12 Empty states (no foods, no meals, no search results...)
- ✅ Multi-action FAB (speed dial with 4 actions)
- ✅ Swipeable items (delete, edit, favorite)
- ✅ Custom bottom sheets (quick add, filters, date picker)
- ✅ Custom dialogs (success, error, confirmation, info, loading)

**Code:** 3,154 lines | 10 new widgets

---

### ✅ Phase 2: User Experience (100%)

- ✅ Onboarding flow (5 pages)
- ✅ Profile setup wizard (6 steps + Mifflin-St Jeor calculation)
- ✅ Feature discovery (spotlight tooltips)
- ✅ Recent searches (Hive, last 10, FIFO)
- ✅ Favorite foods (toggle, Hive)
- ✅ Frequent foods (usage count, top 20, LRU)
- ✅ Quick add section (3 tabs: Recent/Favorites/Frequent)
- ✅ Smart suggestions (meal time, similar foods, complementary)

**Code:** 1,962 lines | 6 new files

---

### ✅ Phase 3: Advanced Features (100%)

#### A. Meal Planning
- ✅ Weekly plan creation (date range)
- ✅ Daily meal management (add/remove)
- ✅ Meal templates (save favorites)
- ✅ Plan-to-log copying (one-click)
- ✅ Smart generation (calorie target based)
- ✅ 3 UI screens (main hub, create wizard, daily detail)

**Code:** ~1,200 lines | 2 models + 1 service + 3 screens

#### B. Weight Tracking
- ✅ Weight entry logging (with date picker)
- ✅ Line chart (fl_chart, last 30 entries)
- ✅ Goal setting (lose/maintain/gain)
- ✅ Progress tracking (percentage, remaining)
- ✅ Body measurements (neck, waist, hips, chest)
- ✅ BMI calculator + categories
- ✅ Healthy change validation (0.5-1 kg/week)
- ✅ Statistics (highest, lowest, average)
- ✅ CSV export
- ✅ 3 UI screens (main tracking, add entry, goal wizard)

**Code:** ~1,700 lines | 3 models + 1 service + 3 screens

#### C. Water Reminders
- ✅ Notification scheduling (flutter_local_notifications)
- ✅ Interval settings (15-240 minutes)
- ✅ Active hours (start/end time)
- ✅ 4 presets (Frequent, Regular, Relaxed, Work Hours)
- ✅ 8 motivational messages (randomized)
- ✅ Settings screen (sliders, toggles)
- ✅ Test notification button

**Code:** ~850 lines | 1 service + 1 screen

**Phase 3 Total:** ~8,000 lines | 8 screens + 3 services

---

### ✅ Phase 4: Social Features (100%)

#### A. User Profiles & Authentication
- ✅ Public/private profile settings
- ✅ Profile editing (username, full name, bio, avatar)
- ✅ Profile viewing (own + others)
- ✅ User stats display (posts, followers, following, streak)
- ✅ User search by username/name

**Code:** ~1,100 lines | 2 screens (profile, edit)

#### B. Social Feed & Posts
- ✅ Activity feed (Following + Popular tabs)
- ✅ Post creation (text + photos)
- ✅ Post display with PostCard widget
- ✅ Post editing/deletion
- ✅ Image upload to Supabase Storage
- ✅ Empty states & error handling

**Code:** ~1,300 lines | 2 screens (feed, create post) + 1 widget (PostCard)

#### C. Engagement Features
- ✅ Like/Unlike posts (optimistic updates)
- ✅ Comment on posts
- ✅ Nested comments support
- ✅ Comment deletion
- ✅ View who liked a post

**Code:** ~600 lines | 1 widget (CommentsBottomSheet)

#### D. Follow System
- ✅ Follow/unfollow users
- ✅ Followers list
- ✅ Following list
- ✅ Follow button in multiple contexts
- ✅ Suggested users to follow

**Code:** ~700 lines | 1 screen (followers/following)

#### E. Notifications
- ✅ Notification system (like, comment, follow)
- ✅ Real-time notification triggers
- ✅ Unread count badge
- ✅ Mark as read/mark all as read
- ✅ Notification navigation

**Code:** ~500 lines | 1 screen (notifications)

#### F. Leaderboard
- ✅ Streak leaderboard
- ✅ Posts leaderboard
- ✅ Followers leaderboard
- ✅ Medal system for top 3
- ✅ Refresh functionality

**Code:** ~450 lines | 1 screen (leaderboard)

#### G. Social Service
- ✅ 40+ API methods for all social features
- ✅ Posts CRUD operations
- ✅ Like/comment management
- ✅ Follow system operations
- ✅ Notifications management
- ✅ User profile operations
- ✅ Leaderboard queries
- ✅ Image upload to storage

**Code:** ~690 lines | 1 service (social_service.dart)

**Phase 4 Total:** ~6,000 lines | 7 screens + 2 widgets + 1 service + 2 models

---

### ✅ Phase 5: Technical Improvements (Complete)

#### A. Image Processing Service
- ✅ ImagePickerService with gallery/camera picker
- ✅ Image compression (flutter_image_compress)
- ✅ Image cropping (image_cropper)
- ✅ Specialized avatar picker (square crop, 512x512)
- ✅ Specialized post image picker (1920x1920 max)
- ✅ Source selection bottom sheet
- ✅ Integration in CreatePostScreen and EditProfileScreen

**Code:** ~300 lines | 1 service (image_picker_service.dart)

#### B. Firebase Analytics
- ✅ Firebase Analytics integration
- ✅ User event tracking (login, signup)
- ✅ Food logging events
- ✅ Social events (post, like, comment, follow)
- ✅ Achievement events
- ✅ Meal planning events
- ✅ Weight/water tracking events
- ✅ Error tracking

**Code:** ~200 lines | 1 service (analytics_service.dart)

#### C. Cache Service
- ✅ In-memory cache with LRU eviction
- ✅ TTL (Time To Live) support
- ✅ Pattern-based invalidation
- ✅ Get-or-set pattern
- ✅ Cache statistics

**Code:** ~150 lines | 1 service (cache_service.dart)

#### D. Exception Handling
- ✅ Custom exception hierarchy
- ✅ NetworkException (connection, timeout, server)
- ✅ AuthException (credentials, session)
- ✅ DataException (CRUD operations)
- ✅ ValidationException (required, format, range)
- ✅ StorageException (upload/download)
- ✅ ImageException (pick, compress)
- ✅ CacheException (read/write/clear)
- ✅ PermissionException (camera, photo, notification)
- ✅ RateLimitException & UnknownException

**Code:** ~200 lines | 1 file (app_exceptions.dart)

#### E. Connectivity Service
- ✅ Network connectivity monitoring
- ✅ Stream-based connectivity changes
- ✅ Connection type detection (WiFi, Mobile, etc.)
- ✅ Wait for connection with timeout

**Code:** ~100 lines | 1 service (connectivity_service.dart)

#### F. Unit Tests
- ✅ UserProfile model tests (fromJson, toJson, copyWith)
- ✅ Post & Comment model tests
- ✅ CacheService tests (LRU, TTL, invalidation)

**Code:** ~250 lines | 3 test files

**Phase 5 Total:** ~1,200 lines | 5 services + 1 exception file + 3 test files

---

### 🔄 Phase 6: Premium Features (Planned)

- [ ] Custom diet plans
- [ ] Nutritionist consultation
- [ ] Advanced analytics
- [ ] Ad-free experience
- [ ] Priority support
- [ ] Recipe database (100+ Turkish recipes)
- [ ] Cooking mode (step-by-step)

---

## 🎨 Design System

### Color Palette

```dart
Primary:    #2196F3 (Blue)
Secondary:  #FF9800 (Orange)
Success:    #4CAF50 (Green)
Error:      #F44336 (Red)
Warning:    #FFC107 (Amber)

Semantic:
Protein:    #F44336 (Red)
Carbs:      #FF9800 (Orange)
Fat:        #9C27B0 (Purple)

Meal Types:
Breakfast:  #FFC107 (Yellow)
Lunch:      #2196F3 (Blue)
Dinner:     #673AB7 (Purple)
Snack:      #4CAF50 (Green)
```

### Typography

- **Headings:** Bold, 18-24px
- **Body:** Regular, 14-16px
- **Caption:** Light, 12px

### Spacing

- **xs:** 4px
- **sm:** 8px
- **md:** 16px
- **lg:** 24px
- **xl:** 32px

---

## 🤖 AI Memory System

Bu proje **AI context persistence** için özel bir bellek sistemi içerir (`.ai/` klasörü).

### Amaç

Farklı AI asistanların (Claude, ChatGPT) projeyi hızlıca anlaması için:

- **project-overview.md** - Proje özeti (~400 satır)
- **features.md** - 100+ özellik listesi (~1200 satır)
- **architecture.md** - Mimari & design patterns (~800 satır)
- **decisions.md** - Teknik kararlar (~600 satır)

### Kullanım

AI asistanına şunu söyleyin:
```
"Read the .ai/ directory to understand this project."
```

Detaylar için: [.ai/README.md](.ai/README.md)

---

## 📊 Metrics

```
📝 Total Lines of Code:    ~29,000
📁 Total Files:            ~120
🖼️ Screens:                37+
🧩 Widgets:                52+
📦 Models:                 20+
⚙️ Services:               14+
🎯 Features:               150+
```

---

## 🔐 Güvenlik

- ✅ Row Level Security (RLS) on all tables
- ✅ JWT token authentication
- ✅ API keys in environment variables
- ✅ Input validation on all forms
- ✅ KVKK uyumlu veri işleme
- ✅ Secure storage (Hive encrypted boxes)

---

## 📱 Desteklenen Platformlar

| Platform | Durum | Min Version |
|----------|-------|-------------|
| Android  | ✅ Fully Supported | API 21 (5.0) |
| iOS      | ✅ Fully Supported | iOS 12+ |
| Web      | ✅ Responsive | Modern browsers |
| macOS    | 🔄 Opsiyonel | macOS 10.14+ |
| Windows  | 🔄 Opsiyonel | Windows 10+ |

---

## 🌍 Localization

- 🇹🇷 **Türkçe** - Varsayılan (100%)
- 🇺🇸 **English** - Planlanan (0%)

Tarih/saat formatları **intl** package ile Türkçe'ye uyarlanmış.

---

## 💰 Maliyet Tahmini (10K kullanıcı/ay)

| Service | Plan | Monthly Cost |
|---------|------|--------------|
| Supabase | Pro | $25 |
| Firebase | Blaze (Pay as you go) | ~$10 |
| flutter_local_notifications | Free | $0 |
| **TOTAL** | | **~$35/month** |

**Not:** 100K kullanıcıya kadar ölçeklenebilir (~$100-150/month)

---

## 🛣️ Roadmap

Detaylı yol haritası: [docs/YOL_HARITASI.md](docs/YOL_HARITASI.md)

**Özet:**
- ✅ **Phase 1-4:** Complete (Design + UX + Advanced Features + Social)
- 🔄 **Phase 5:** Technical Improvements (2-3 hafta)
- 🔄 **Phase 6:** Premium Features (8-10 hafta)

**Estimated Production Ready:** 2-3 months (Phase 5 & 6)

---

## 📝 License

Bu proje özel (private) bir projedir. Ticari kullanım için geliştirilmiştir.

---

## 👥 Contributors

- **Developer:** EmreUludasdemir
- **AI Assistant:** Claude (Anthropic)
- **Repository:** [github.com/EmreUludasdemir/Yemek-Kalori-App](https://github.com/EmreUludasdemir/Yemek-Kalori-App)

---

## 📞 Contact

Sorularınız için:
- **GitHub Issues:** [Create an issue](https://github.com/EmreUludasdemir/Yemek-Kalori-App/issues)
- **Email:** [İletişim bilgisi eklenecek]

---

## 🙏 Acknowledgments

- [Supabase](https://supabase.com) - Backend infrastructure
- [Firebase](https://firebase.google.com) - Push notifications
- [fl_chart](https://pub.dev/packages/fl_chart) - Beautiful charts
- [TürKomp](http://www.turkomp.gov.tr) - Turkish food database

---

<div align="center">

**Built with ❤️ using Flutter**

*Last Updated: 2025-12-25*
*Version: Phase 4 Complete*

[⬆ Back to top](#-türkkalori---ai-destekli-kalori-takip-uygulaması)

</div>
