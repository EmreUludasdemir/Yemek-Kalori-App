# 🎯 TürkKalori - Technical Decisions & Trade-offs

Bu dokümanda projenin geliştirilmesi sırasında alınan önemli teknik kararlar ve nedenleri yer almaktadır.

---

## 🏗️ Architecture Decisions

### **1. Flutter over React Native / Native**

**Decision:** Flutter seçildi

**Rationale:**
- ✅ Single codebase for iOS & Android
- ✅ Fast development with hot reload
- ✅ Rich animation support (critical for UI/UX)
- ✅ Strong Dart type safety
- ✅ Growing ecosystem
- ✅ Good performance (Skia engine)

**Trade-offs:**
- ❌ Larger app size (~15-20 MB base)
- ❌ Dart less popular than JavaScript
- ❌ Platform-specific features require plugins

**Impact:** Positive - 50% faster development time

---

### **2. Supabase over Firebase / Custom Backend**

**Decision:** Supabase as primary backend

**Rationale:**
- ✅ Open-source (avoid vendor lock-in)
- ✅ PostgreSQL (proven, ACID compliant)
- ✅ Built-in auth & RLS
- ✅ JSONB support (flexible schemas)
- ✅ Real-time subscriptions
- ✅ RESTful auto-generated APIs
- ✅ Free tier generous (500 MB, 2 GB bandwidth)

**Trade-offs:**
- ❌ Smaller community than Firebase
- ❌ Fewer integrations
- ❌ Self-hosting complexity (if needed)

**Why not Firebase?**
- NoSQL less suitable for relational data (users ↔ food_logs)
- Cost concerns at scale
- Less SQL flexibility

**Why not custom backend?**
- Development time (weeks vs days)
- DevOps overhead
- Auth/security implementation complexity

**Impact:** Very positive - Rapid feature development, 90% less backend code

---

### **3. Riverpod over BLoC / Provider**

**Decision:** Riverpod for state management

**Rationale:**
- ✅ Compile-time safety (no runtime errors)
- ✅ Auto-dispose (memory leak prevention)
- ✅ Family providers (dynamic parameters)
- ✅ No BuildContext needed
- ✅ Testability
- ✅ Less boilerplate than BLoC

**Trade-offs:**
- ❌ Learning curve
- ❌ Migration from Provider 1.x can be tricky

**Why not BLoC?**
- Too verbose for simple use cases
- Unnecessary for small-medium apps

**Why not GetX?**
- Service locator pattern (anti-pattern)
- Global state risks

**Impact:** Positive - Clean, maintainable code

---

### **4. Hive over Shared Preferences / SQLite**

**Decision:** Hive for local storage

**Rationale:**
- ✅ NoSQL key-value store (perfect for cache)
- ✅ Fast (pure Dart, no FFI)
- ✅ Type-safe boxes
- ✅ No migrations needed
- ✅ Lazy loading
- ✅ Auto-compaction

**Use Cases:**
- Recent searches (FIFO queue)
- Favorite foods (toggle list)
- Frequent foods (usage counts)
- Onboarding status (bool)

**Why not Shared Preferences?**
- Only supports primitives
- Slow for lists
- No structure

**Why not SQLite (Drift)?**
- Overkill for simple cache
- More setup required
- SQL overhead

**Decision for Future:** Use Drift for offline-first architecture (Phase 5)

**Impact:** Positive - Instant local data access

---

## 📊 Database Design Decisions

### **5. JSONB for Meal Plans**

**Decision:** Store `daily_plans` as JSONB in Supabase

**Rationale:**
- ✅ Flexible schema (meals can vary)
- ✅ No need for meal_plan_items junction table
- ✅ Single query to fetch plan with all meals
- ✅ Easy updates (replace entire array)
- ✅ Supports nested structures

**Example:**
```json
{
  "daily_plans": [
    {
      "date": "2025-12-25",
      "meals": [
        {
          "id": "uuid",
          "meal_type": "kahvalti",
          "food_id": "uuid",
          "food_name": "Menemen",
          "calories": 250
        }
      ]
    }
  ]
}
```

**Trade-offs:**
- ❌ Harder to query individual meals
- ❌ JSONB query syntax less intuitive
- ❌ Size can grow large

**Alternative Considered:** Relational (meal_plan → daily_plan → planned_meal)
- ✅ Better normalization
- ❌ 3 queries instead of 1
- ❌ More complex CRUD
- ❌ Migrations for schema changes

**Impact:** Positive - Faster development, simpler queries

---

### **6. JSONB for Body Measurements**

**Decision:** Store measurements as JSONB in weight_entries

**Rationale:**
- ✅ Optional measurements (neck, waist, hips, chest, thigh, arm)
- ✅ Users can add custom measurements later
- ✅ No schema changes needed
- ✅ Small footprint

**Example:**
```json
{
  "measurements": {
    "neck": 38.5,
    "waist": 85.0,
    "hips": 95.0
  }
}
```

**Alternative:** Separate body_measurements table
- ❌ Overkill for optional data
- ❌ More joins

**Impact:** Positive - Flexibility

---

## 🎨 UI/UX Decisions

### **7. Phase-based Development (UI First)**

**Decision:** Develop in phases: UI/UX → Features → Social → Technical

**Rationale:**
- ✅ Early user feedback on design
- ✅ Motivating visual progress
- ✅ Reusable components built first
- ✅ Cleaner integration

**Phases:**
1. **Phase 1:** Design system (animations, loaders, empty states)
2. **Phase 2:** UX enhancements (onboarding, quick actions, suggestions)
3. **Phase 3:** Advanced features (meal planning, weight tracking)
4. **Phase 4:** Social features
5. **Phase 5:** Technical (offline, cache, performance)
6. **Phase 6:** Premium features

**Alternative:** Feature-first (MVP → iterate)
- ❌ UI inconsistencies
- ❌ Refactoring overhead later

**Impact:** Very positive - Professional app feel from day 1

---

### **8. 12 Pre-configured Empty States**

**Decision:** Create EmptyState widget with 12 types

**Rationale:**
- ✅ Consistency across app
- ✅ One-line implementation
- ✅ Easy to maintain
- ✅ Better UX than generic messages

**Types:** NoFoods, NoMeals, NoSearchResults, NoStats, etc.

**Trade-offs:**
- ❌ Larger widget file (~350 lines)

**Alternative:** Custom empty state per screen
- ❌ Inconsistent design
- ❌ Duplicate code

**Impact:** Positive - Professional polish

---

### **9. Skeleton Loaders over Spinners**

**Decision:** Use skeleton screens for all async operations

**Rationale:**
- ✅ Perceived faster loading (research shows 20-30% improvement)
- ✅ Less jarring than spinners
- ✅ Shows layout structure
- ✅ Modern UX pattern

**Implementation:** 6 skeleton types (FoodCard, FoodList, StatsCard, Profile, Post, Chart)

**Trade-offs:**
- ❌ More code than CircularProgressIndicator
- ❌ Needs matching layout

**Alternative:** Simple spinners
- ❌ Boring
- ❌ User perceives as slower

**Impact:** Very positive - Premium feel

---

## 🔧 Feature Implementation Decisions

### **10. Mifflin-St Jeor over Harris-Benedict**

**Decision:** Use Mifflin-St Jeor equation for calorie calculation

**Formula:**
```
Male:   BMR = (10 × weight) + (6.25 × height) - (5 × age) + 5
Female: BMR = (10 × weight) + (6.25 × height) - (5 × age) - 161
TDEE = BMR × Activity Multiplier
```

**Rationale:**
- ✅ More accurate (proven in studies)
- ✅ Modern equation (1990 vs 1919)
- ✅ Accounts for lean body mass better

**Alternative:** Harris-Benedict
- ❌ Older formula
- ❌ Tends to overestimate

**Impact:** Better calorie recommendations

---

### **11. ±500 kcal for Weight Goals**

**Decision:** Adjust TDEE by ±500 kcal for weight loss/gain

**Rationale:**
- ✅ Safe rate: ~0.5 kg/week
- ✅ Recommended by nutritionists
- ✅ Sustainable long-term

**Trade-offs:**
- ❌ Slower results (some users want faster)

**Alternative:** ±1000 kcal (1 kg/week)
- ❌ Too aggressive
- ❌ Harder to sustain
- ❌ Muscle loss risk

**Impact:** Healthy, sustainable goals

---

### **12. Recent Searches: FIFO Queue (Max 10)**

**Decision:** Store last 10 searches, FIFO eviction

**Rationale:**
- ✅ Relevant recency
- ✅ Small memory footprint
- ✅ Fast lookup

**Trade-offs:**
- ❌ May lose useful older searches

**Alternative:** LRU (Least Recently Used)
- ✅ Keeps frequently accessed
- ❌ More complex

**Impact:** Good balance

---

### **13. Favorite Foods: Toggle vs Star Rating**

**Decision:** Simple toggle (favorite or not)

**Rationale:**
- ✅ Easier UX (one tap)
- ✅ Clear binary state
- ✅ Common pattern (heart icon)

**Alternative:** 5-star rating
- ❌ More cognitive load
- ❌ Unused middle ratings

**Impact:** Simpler, faster interaction

---

### **14. Frequent Foods: Top 20 by Count**

**Decision:** Track usage count, show top 20

**Rationale:**
- ✅ Captures actual behavior
- ✅ 20 items enough for quick add
- ✅ Auto-ranked by frequency

**Implementation:** LRU-style cleanup (remove if not in top 50)

**Trade-offs:**
- ❌ New foods won't appear immediately

**Alternative:** Recency-based
- ❌ Doesn't reflect true frequency

**Impact:** Useful quick add

---

## 🧪 Testing Decisions

### **15. Manual Testing First, Automated Later**

**Decision:** Focus on features now, tests in Phase 5

**Rationale:**
- ✅ Faster MVP delivery
- ✅ Unclear requirements early on
- ✅ Rapid iteration

**Trade-offs:**
- ❌ Technical debt
- ❌ Harder to refactor safely

**Plan:** Add tests in Phase 5 (technical improvements)

**Impact:** Acceptable for rapid prototyping

---

## 🔔 Notification Decisions

### **16. Firebase FCM for Notifications**

**Decision:** Use Firebase Cloud Messaging

**Rationale:**
- ✅ Free unlimited notifications
- ✅ iOS + Android support
- ✅ Topic-based messaging
- ✅ Analytics integration
- ✅ Delivery reports

**Alternative:** OneSignal / Pusher
- ❌ Cost at scale
- ❌ Extra service dependency

**Alternative:** Supabase Edge Functions + Push API
- ❌ More complex setup
- ❌ No delivery analytics

**Impact:** Reliable, free, well-supported

---

## 🌐 Localization Decisions

### **17. Turkish-Only Initially**

**Decision:** Focus on Turkish market first

**Rationale:**
- ✅ Target audience clarity
- ✅ Turkish food database
- ✅ Simpler maintenance
- ✅ Better localization quality

**Trade-offs:**
- ❌ Limits international growth

**Plan:** Add English in Phase 5

**Impact:** Better product-market fit

---

### **18. intl Package for Date Formatting**

**Decision:** Use intl package, not custom formatters

**Rationale:**
- ✅ Locale-aware (Pazartesi, Ocak, etc.)
- ✅ Standard library
- ✅ Future i18n support

**Example:**
```dart
DateFormat('d MMMM yyyy, EEEE', 'tr').format(date)
// "25 Aralık 2025, Çarşamba"
```

**Trade-offs:**
- ❌ Adds package dependency

**Impact:** Professional Turkish formatting

---

## 💰 Monetization Decisions (Future)

### **19. Freemium Model**

**Decision:** Free base app + premium features

**Free Features:**
- Food logging
- Basic stats
- Achievements
- Meal planning

**Premium Features (Planned):**
- Advanced analytics
- Custom diet plans
- Nutritionist chat
- Ad-free
- Export all data

**Rationale:**
- ✅ Low barrier to entry
- ✅ Upsell opportunities
- ✅ Recurring revenue
- ✅ Free tier drives adoption

**Alternative:** Paid upfront
- ❌ Lower download rate

**Alternative:** Ad-supported only
- ❌ Poor UX
- ❌ Low CPM in Turkey

**Impact:** Sustainable business model

---

## 🔒 Security Decisions

### **20. Row-Level Security (RLS) in Supabase**

**Decision:** Enable RLS on all tables

**Rationale:**
- ✅ Auth.uid() automatically filters queries
- ✅ No accidental data leaks
- ✅ Defense in depth

**Policy Example:**
```sql
CREATE POLICY "Users own data" ON food_logs
  FOR ALL USING (auth.uid() = user_id);
```

**Trade-offs:**
- ❌ Slightly complex policies

**Alternative:** Backend API filters
- ❌ Easy to forget
- ❌ More code

**Impact:** Secure by default

---

## 📱 Platform-Specific Decisions

### **21. Material Design over Cupertino**

**Decision:** Use Material Design on both platforms

**Rationale:**
- ✅ Consistent experience
- ✅ Richer widget set
- ✅ Easier maintenance

**Trade-offs:**
- ❌ Not native iOS feel

**Alternative:** Platform-adaptive
- ❌ 2x UI code
- ❌ Testing overhead

**Impact:** Acceptable - Most users prefer consistency

---

## 🚀 Performance Decisions

### **22. FutureProvider.autoDispose over Regular**

**Decision:** Always use autoDispose for providers

**Rationale:**
- ✅ Prevents memory leaks
- ✅ Auto-cleanup when widget unmounted
- ✅ Fresh data on re-mount

**Trade-offs:**
- ❌ Re-fetches data on navigation back

**Alternative:** Regular FutureProvider
- ❌ Stale data
- ❌ Memory leaks

**Mitigation:** Cache in Hive for frequently accessed data

**Impact:** Better memory management

---

## 🎯 Decision Summary

**Good Decisions:**
1. ✅ Flutter (speed)
2. ✅ Supabase (flexibility)
3. ✅ Riverpod (safety)
4. ✅ Hive (speed)
5. ✅ JSONB (flexibility)
6. ✅ Phase-based dev (UX first)
7. ✅ Skeleton loaders (perception)
8. ✅ RLS (security)

**Trade-offs Accepted:**
1. ⚖️ Manual testing now → Automated later
2. ⚖️ Turkish-only → English later
3. ⚖️ Material only → Cupertino later

**Avoided Mistakes:**
1. ❌ Custom backend (time sink)
2. ❌ BLoC (overkill)
3. ❌ Shared Preferences (limited)
4. ❌ Harris-Benedict (outdated)
5. ❌ Star ratings (complex UX)

---

## 📝 Decision-Making Framework

**Criteria for Technical Decisions:**
1. **User Value** - Does it improve UX?
2. **Development Speed** - Time to market?
3. **Maintenance Cost** - Easy to change?
4. **Scalability** - Handles growth?
5. **Cost** - Affordable at scale?

**Priority Order:**
1. User Value
2. Development Speed
3. Maintenance
4. Scalability
5. Cost

---

*Last Updated: 2025-12-25*
*Phase: 3 (Advanced Features)*
