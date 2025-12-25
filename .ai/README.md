# 🤖 AI Context & Memory System

Bu klasör, AI asistanların (Claude, ChatGPT, vb.) projede daha hızlı context yakalaması için tasarlanmış bir bellek sistemidir.

## 📁 Dosya Yapısı

```
.ai/
├── README.md             # Bu dosya
├── project-overview.md   # Proje genel bakış
├── features.md           # Tüm özellikler listesi
├── architecture.md       # Mimari ve tasarım desenleri
└── decisions.md          # Teknik kararlar ve trade-off'lar
```

## 🎯 Amaç

### Neden Bu Sistem?

AI asistanlar her yeni oturumda context kaybeder. Bu sistem sayede:

✅ **Hızlı Onboarding** - Yeni AI, 5 dakikada projeyi kavrar
✅ **Tutarlılık** - Önceki kararlar bilinir, çelişki olmaz
✅ **Ekip Çalışması** - Farklı geliştiriciler aynı bilgiye erişir
✅ **Dokümantasyon** - Otomatik, güncel proje dokümanı

### Claude-Mem'den İlham

Bu sistem [claude-mem](https://github.com/thedotmack/claude-mem) projesinden esinlenmiştir. Orijinal sistem:
- Session log'ları kaydeder
- SQLite + Chroma vector DB kullanır
- Web UI ile arama sağlar

Bizim basitleştirilmiş versiyonumuz:
- Markdown dosyalarıyla çalışır
- Git ile versiyon kontrolü
- Grep/search ile kolayca aranabilir
- Manuel güncelleme (otomatik değil)

## 📖 Dosya Açıklamaları

### 1. **project-overview.md**

**İçerik:**
- Proje özeti ve hedef kitle
- Teknoloji stack
- Veritabanı yapısı
- Tamamlanmış özellikler
- Bilinen limitasyonlar
- Git workflow

**Ne Zaman Okuyacak AI:**
- İlk oturumda
- "Projeyi anlat" sorusunda
- Tech stack sorusunda

### 2. **features.md**

**İçerik:**
- Tüm özellikler (100+)
- Implement durumları (✅❌🟡)
- Kod dosya referansları
- Service method listesi
- UI component detayları

**Ne Zaman Okuyacak AI:**
- "X özelliği var mı?" sorusunda
- Yeni özellik eklerken (çakışma kontrolü)
- Refactoring yaparken

### 3. **architecture.md**

**İçerik:**
- Genel mimari diagram
- Tasarım desenleri (Provider, Service, Factory...)
- Proje yapısı
- Data flow (read/write)
- Database design (Supabase + Hive)
- Naming conventions

**Ne Zaman Okuyacak AI:**
- Yeni özellik implementasyonunda
- "Nasıl yapılandırılmış?" sorusunda
- Best practice önerilerinde
- Code review sırasında

### 4. **decisions.md**

**İçerik:**
- 22 teknik karar
- Her kararın rationale'i
- Trade-off analizi
- Alternatif yaklaşımlar
- Impact değerlendirmesi

**Ne Zaman Okuyacak AI:**
- "Neden X kullandınız?" sorusunda
- Yeni teknoloji önerilerinde (uyumluluk kontrolü)
- Refactoring tartışmalarında

## 🚀 Kullanım

### AI'ya İlk Oturumda Sorun:

```
"Bu projeyi anlamam için .ai/ klasöründeki dosyaları oku."
```

### Özellik Eklerken:

```
"X özelliğini eklemek istiyorum. .ai/features.md ve
.ai/architecture.md dosyalarını kontrol et, var olan
desenlerle uyumlu mu?"
```

### Teknik Karar Alırken:

```
"Y teknolojisini kullanmak istiyorum. .ai/decisions.md
dosyasına bak, mevcut kararlarla uyumlu mu?"
```

### Code Review İsterken:

```
"Bu kodu review et. .ai/architecture.md'deki naming
conventions ve pattern'lere uyuyor mu?"
```

## 🔄 Güncelleme Protokolü

### Ne Zaman Güncellenir?

- ✅ Yeni özellik eklendiğinde → `features.md`
- ✅ Mimari değişiklikte → `architecture.md`
- ✅ Önemli teknik karar alındığında → `decisions.md`
- ✅ Proje milestone'unda → `project-overview.md`

### Kimler Güncellemeli?

1. **AI Asistanlar** - Her major feature sonrası
2. **Geliştiriciler** - Manual review & düzeltme
3. **Tech Lead** - Karar dokümanları

### Nasıl Güncellenir?

```bash
# 1. Dosyayı düzenle
vim .ai/features.md

# 2. Commit et
git add .ai/
git commit -m "docs: Update AI context with new feature"

# 3. Push et
git push
```

## 📊 Dosya Büyüklükleri

| Dosya | Satır | Boyut | Güncelleme Sıklığı |
|-------|-------|-------|-------------------|
| project-overview.md | ~400 | ~15 KB | Aylık |
| features.md | ~1200 | ~50 KB | Haftalık |
| architecture.md | ~800 | ~35 KB | Aylık |
| decisions.md | ~600 | ~25 KB | Arada |
| **TOPLAM** | **~3000** | **~125 KB** | - |

**Not:** Tüm dosyalar toplamı bile minimal (125 KB). AI context window'una rahatlıkla sığar.

## 🎓 AI Komutları Örnekleri

### Context Yükleme

```
🤖: "Proje hakkında bilgi alabilir miyim?"

👨‍💻: "Evet, .ai/project-overview.md dosyasını oku."

🤖: [Dosyayı okur] "TürkKalori bir Flutter uygulaması,
    Supabase backend kullanıyor..."
```

### Özellik Kontrolü

```
👨‍💻: "Recipe database özelliği var mı?"

🤖: [.ai/features.md okur] "Recipe database planned
    (Phase 4) ama henüz implement edilmemiş."
```

### Mimari Sorgulama

```
👨‍💻: "Service pattern'i nasıl kullanılmış?"

🤖: [.ai/architecture.md okur] "Static method'lu
    service class'lar kullanılmış. Örnek:
    MealPlanningService.createMealPlan(...)"
```

### Karar Analizi

```
👨‍💻: "Neden Riverpod seçilmiş?"

🤖: [.ai/decisions.md okur] "Decision #3: Compile-time
    safety, auto-dispose ve less boilerplate için."
```

## 🔍 Arama & Keşif

### Grep Kullanımı

```bash
# Tüm JSONB kullanımlarını bul
grep -r "JSONB" .ai/

# Weight tracking servisini bul
grep -r "WeightTrackingService" .ai/

# Tüm pending özellikleri listele
grep "🟡\|❌" .ai/features.md
```

### Find Kullanımı

```bash
# Belirli bir kelimenin geçtiği dosyaları bul
find .ai/ -type f -exec grep -l "Supabase" {} \;
```

### VS Code Search

```
Ctrl + Shift + F → ".ai" klasöründe ara
```

## 📝 Şablon Formatı

### Feature Ekleme

```markdown
### ✅ Yeni Özellik Adı (Phase X)
**Files:**
- `lib/path/to/file.dart`

**Models:**
- ModelAdı - Açıklama

**Features:**
- Özellik 1
- Özellik 2

**Service Methods:**
- method1() - Açıklama
```

### Decision Ekleme

```markdown
### **X. Karar Başlığı**

**Decision:** Ne karar verildi

**Rationale:**
- ✅ Neden 1
- ✅ Neden 2

**Trade-offs:**
- ❌ Eksik 1

**Alternative:** Başka seçenek
- ❌ Neden olmadı

**Impact:** Sonuç

---
```

## 🎯 Best Practices

### ✅ Yapılacaklar

1. **Detaylı Olun** - "Added feature" değil, "Added meal planning with 15+ service methods"
2. **Örnekler Verin** - Code snippet'ler ekleyin
3. **Linkler Kullanın** - Dosya path'leri ekleyin
4. **Durumu Güncelleyin** - ✅❌🟡 sembolleri kullanın
5. **Tarih Ekleyin** - *Last Updated: YYYY-MM-DD*

### ❌ Yapılmayacaklar

1. **Kod Kopyalamayın** - Sadece referans verin
2. **Her Commit'te Güncellemeyin** - Sadece major değişiklikler
3. **Boş Bölüm Bırakmayın** - "TODO" yerine "Planned" yazın
4. **Tutarsız Olmayın** - Aynı özellik birden fazla yerde varsa sync edin

## 🤝 Ekip İşbirliği

### Senaryo 1: Yeni Geliştirici

```
Adım 1: .ai/project-overview.md oku (5 dk)
Adım 2: .ai/architecture.md oku (10 dk)
Adım 3: .ai/features.md tara (5 dk)
TOPLAM: 20 dakikada projeye hazır!
```

### Senaryo 2: AI Asistan Değişimi

```
Claude → ChatGPT geçişi:
1. ChatGPT'ye ".ai/ klasörünü oku" komutu
2. Context yüklendi ✅
3. Aynı code quality devam eder
```

### Senaryo 3: Code Review

```
Reviewer: ".ai/architecture.md'deki pattern'leri
           kontrol et"
AI: "Service pattern uyumlu ✅, naming convention
     uyumlu ✅"
```

## 📈 Gelecek İyileştirmeler

### Planlanan (Phase 5)

1. **Otomatis Session Log'lar**
   - Her commit'te özet oluştur
   - `sessions/` klasöründe sakla

2. **Semantic Search**
   - Vector embedding ekle
   - Natural language query

3. **Web Dashboard**
   - Markdown → HTML render
   - İnteraktif arama

4. **Git Hooks**
   - Pre-commit: Dosya güncel mi?
   - Post-commit: Session log oluştur

## 📚 Referanslar

- [claude-mem GitHub](https://github.com/thedotmack/claude-mem)
- [Claude Agent SDK Docs](https://docs.anthropic.com/en/docs/agents)
- [Markdown Best Practices](https://www.markdownguide.org/basic-syntax/)

---

**Oluşturulma:** 2025-12-25
**Versiyon:** 1.0
**Bakım:** AI Asistan + Geliştirici
**Lisans:** Projeyle aynı

💡 **Tip:** Bu dosyayı her AI oturumu başında okutun!
