# 🏗️ TürkKalori - Architecture & Design Patterns

## 📐 Overall Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │ Screens  │  │ Widgets  │  │ Providers│             │
│  └──────────┘  └──────────┘  └──────────┘             │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────┴────────────────────────────────────┐
│                   Business Logic Layer                   │
│  ┌──────────────────────────────────────────────────┐  │
│  │              Services                             │  │
│  │  • MealPlanningService                           │  │
│  │  • WeightTrackingService                         │  │
│  │  • SmartSuggestionsService                       │  │
│  │  • RecentSearchesService                         │  │
│  │  • NutritionService                              │  │
│  └──────────────────────────────────────────────────┘  │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────┴────────────────────────────────────┐
│                      Data Layer                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │ Supabase │  │   Hive   │  │ Firebase │             │
│  │PostgreSQL│  │  NoSQL   │  │   FCM    │             │
│  └──────────┘  └──────────┘  └──────────┘             │
└─────────────────────────────────────────────────────────┘
```

## 🎯 Design Patterns

### 1. **Provider Pattern (Riverpod)**

**Usage:** State management across the app

```dart
// Auto-dispose future provider
final activeMealPlanProvider = FutureProvider.autoDispose<MealPlan?>((ref) async {
  final userId = SupabaseConfig.currentUser?.id;
  if (userId == null) return null;
  return await MealPlanningService.getActiveMealPlan(userId);
});

// Family provider for dynamic parameters
final mealPlanDetailProvider =
    FutureProvider.autoDispose.family<MealPlan?, String>((ref, planId) async {
  return await MealPlanningService.getMealPlan(planId);
});
```

**Benefits:**
- Auto-disposal prevents memory leaks
- Ref invalidation for refresh
- Type-safe
- No boilerplate

**Files Using:**
- All screen files
- Provider declarations at top

### 2. **Service Layer Pattern**

**Purpose:** Separate business logic from UI

**Structure:**
```
services/
├── meal_planning_service.dart    # Static class with methods
├── weight_tracking_service.dart
├── nutrition_service.dart
└── smart_suggestions_service.dart
```

**Example:**
```dart
class MealPlanningService {
  static Future<MealPlan> createMealPlan({...}) async {
    // Business logic here
    await SupabaseConfig.client.from('meal_plans').insert(...);
    return mealPlan;
  }
}
```

**Benefits:**
- Testable
- Reusable
- Centralized logic
- Easy to mock

### 3. **Repository Pattern (Implicit)**

**Implementation:** Services act as repositories

```dart
class WeightTrackingService {
  // CRUD operations
  static Future<WeightEntry> addWeightEntry(...) {}
  static Future<List<WeightEntry>> getWeightEntries(...) {}
  static Future<void> updateWeightEntry(...) {}
  static Future<void> deleteWeightEntry(...) {}
}
```

**Data Sources:**
- Supabase (remote)
- Hive (local cache)
- Firebase (notifications)

### 4. **Factory Pattern**

**Usage:** Model creation from JSON

```dart
class WeightEntry {
  factory WeightEntry.fromJson(Map<String, dynamic> json) {
    return WeightEntry(
      id: json['id'] as String,
      weight: (json['weight'] as num).toDouble(),
      // ...
    );
  }

  factory WeightEntry.empty() => WeightEntry(...);
}
```

**Benefits:**
- Consistent parsing
- Named constructors for variants
- Type safety

### 5. **Builder Pattern**

**Usage:** Complex widget construction

```dart
class EmptyState extends StatelessWidget {
  final EmptyStateType type;
  final String? title;
  final String? message;
  final String? actionText;
  final VoidCallback? onAction;

  // Pre-configured builders
  factory EmptyState.noFoods() => EmptyState(type: EmptyStateType.noFoods);
  factory EmptyState.noSearchResults() => ...
}
```

### 6. **Strategy Pattern**

**Usage:** Different algorithms for same task

```dart
// Smart suggestion strategies
class SmartSuggestionsService {
  // Strategy 1: Time-based meal detection
  static String getCurrentMealTime() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 11) return 'kahvalti';
    // ...
  }

  // Strategy 2: Calorie-based similarity
  static Future<List<FoodItem>> getSimilarFoods(FoodItem food) {
    final minCal = food.calories * 0.8;
    final maxCal = food.calories * 1.2;
    // ...
  }

  // Strategy 3: Nutritional complementation
  static Future<List<FoodItem>> getComplementaryFoods(FoodItem food) {
    if (food.protein > 15) {
      // Suggest high-carb foods
    }
    // ...
  }
}
```

### 7. **Observer Pattern**

**Usage:** Riverpod providers automatically notify listeners

```dart
// Provider change triggers rebuild
ref.watch(activeMealPlanProvider);

// Manual refresh
ref.invalidate(activeMealPlanProvider);
```

### 8. **Singleton Pattern**

**Usage:** Configuration classes

```dart
class SupabaseConfig {
  static final SupabaseClient client = SupabaseClient(...);
  static User? get currentUser => client.auth.currentUser;
}
```

**Benefits:**
- Single instance
- Global access
- Lazy initialization

---

## 📁 Project Structure

### **Clean Architecture Layers**

```
lib/
├── config/                    # Configuration (Singleton)
│   ├── supabase_config.dart
│   └── firebase_config.dart
│
├── core/                      # Core utilities
│   └── constants/
│       └── app_colors.dart
│
├── data/                      # Data layer
│   └── models/               # Domain models (Factory)
│       ├── food_item_model.dart
│       ├── food_log_model.dart
│       ├── meal_plan_model.dart
│       └── weight_entry_model.dart
│
├── services/                  # Business logic (Service + Repository)
│   ├── meal_planning_service.dart
│   ├── weight_tracking_service.dart
│   ├── nutrition_service.dart
│   ├── recent_searches_service.dart
│   └── smart_suggestions_service.dart
│
└── presentation/              # UI layer
    ├── screens/              # Feature screens
    │   ├── home/
    │   ├── food_log/
    │   ├── profile/
    │   ├── meal_planning/    # Phase 3
    │   ├── onboarding/       # Phase 2
    │   └── camera/
    │
    └── widgets/              # Reusable components
        ├── animations/       # Phase 1
        ├── common/           # Phase 1
        ├── food/             # Domain-specific
        ├── loading/          # Phase 1
        ├── modals/           # Phase 1
        └── tutorial/         # Phase 2
```

### **Naming Conventions**

**Files:**
- Screens: `*_screen.dart`
- Widgets: `*_widget.dart` or descriptive name
- Models: `*_model.dart`
- Services: `*_service.dart`
- Providers: Defined at top of screen files

**Classes:**
- Screens: `*Screen` (e.g., `HomeScreen`)
- Widgets: Descriptive (e.g., `MealSection`)
- Models: Noun (e.g., `FoodItem`)
- Services: `*Service` (e.g., `NutritionService`)

**Methods:**
- CRUD: `get*`, `create*`, `update*`, `delete*`
- Boolean: `is*`, `has*`, `can*`
- Async: Always return `Future<T>`

---

## 🔄 Data Flow

### **Read Flow (Supabase → UI)**

```
User Action
    ↓
Provider (FutureProvider)
    ↓
Service Layer (static method)
    ↓
Supabase Client (REST API)
    ↓
PostgreSQL Database
    ↓
JSON Response
    ↓
Model.fromJson() (Factory)
    ↓
Provider State Update
    ↓
Widget Rebuild (.when())
    ↓
UI Display
```

**Example:**
```dart
// 1. User opens meal plan screen
final planAsync = ref.watch(activeMealPlanProvider);

// 2. Provider calls service
final activeMealPlanProvider = FutureProvider.autoDispose<MealPlan?>((ref) async {
  return await MealPlanningService.getActiveMealPlan(userId);
});

// 3. Service queries Supabase
static Future<MealPlan?> getActiveMealPlan(String userId) async {
  final response = await SupabaseConfig.client
      .from('meal_plans')
      .select()
      .eq('user_id', userId)
      .eq('is_active', true)
      .limit(1)
      .maybeSingle();

  if (response == null) return null;
  return MealPlan.fromJson(response);
}

// 4. UI renders with .when()
planAsync.when(
  data: (plan) => _buildContent(plan),
  loading: () => SkeletonLoader(),
  error: (error, _) => ErrorWidget(),
)
```

### **Write Flow (UI → Supabase)**

```
User Action (button press)
    ↓
Event Handler (async method)
    ↓
Service Layer Method
    ↓
Model.toJson() (serialization)
    ↓
Supabase Client (INSERT/UPDATE/DELETE)
    ↓
Database Mutation
    ↓
Success/Error Response
    ↓
UI Feedback (dialog/snackbar)
    ↓
Provider Invalidation (refresh)
    ↓
Widget Rebuild (new data)
```

**Example:**
```dart
// 1. User clicks create button
onPressed: () => _createPlan()

// 2. Handler validates and calls service
Future<void> _createPlan() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    await MealPlanningService.createMealPlan(...);

    // Success feedback
    await CustomDialog.showSuccess(...);
    Navigator.pop(context);
  } catch (e) {
    // Error feedback
    CustomDialog.showError(...);
  } finally {
    setState(() => _isLoading = false);
  }
}

// 3. Service inserts to database
static Future<MealPlan> createMealPlan(...) async {
  final mealPlan = MealPlan(...);

  await SupabaseConfig.client
      .from('meal_plans')
      .insert(mealPlan.toJson());

  return mealPlan;
}
```

---

## 🗄️ Database Design

### **Supabase Tables**

**Core Tables:**
```sql
-- Users (auth.users extended)
users (
  id UUID PRIMARY KEY,
  email TEXT,
  name TEXT,
  bio TEXT,
  photo_url TEXT,
  created_at TIMESTAMP
)

-- Food Items
food_items (
  id UUID PRIMARY KEY,
  name_tr TEXT,
  calories DECIMAL,
  protein DECIMAL,
  carbohydrates DECIMAL,
  fat DECIMAL,
  category TEXT,
  serving_size TEXT,
  image_url TEXT
)

-- Food Logs
food_logs (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users,
  food_id UUID REFERENCES food_items,
  meal_type TEXT,
  serving_count DECIMAL,
  logged_at TIMESTAMP,
  notes TEXT,
  INDEX (user_id, logged_at)
)

-- Achievements
achievements (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users,
  achievement_key TEXT,
  unlocked_at TIMESTAMP,
  progress INT,
  UNIQUE (user_id, achievement_key)
)
```

**Phase 3 Tables:**
```sql
-- Meal Plans (JSONB for flexibility)
meal_plans (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users,
  name TEXT,
  description TEXT,
  start_date DATE,
  end_date DATE,
  daily_plans JSONB,        -- Array of DailyMealPlan
  is_active BOOLEAN,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
)

-- Meal Templates
meal_templates (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users,
  name TEXT,
  description TEXT,
  category TEXT,
  meals JSONB,              -- Array of TemplateMeal
  is_public BOOLEAN,
  use_count INT DEFAULT 0,
  created_at TIMESTAMP
)

-- Weight Entries
weight_entries (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users,
  weight DECIMAL,
  logged_at TIMESTAMP,
  notes TEXT,
  photo_url TEXT,
  measurements JSONB,       -- Map of body measurements
  INDEX (user_id, logged_at DESC)
)

-- Weight Goals
weight_goals (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users,
  start_weight DECIMAL,
  target_weight DECIMAL,
  current_weight DECIMAL,
  start_date DATE,
  target_date DATE,
  goal_type TEXT,
  is_active BOOLEAN,
  created_at TIMESTAMP
)
```

### **Hive Boxes (Local Storage)**

```dart
// Boxes are opened lazily
await Hive.openBox<bool>('onboarding');
await Hive.openBox<String>('recent_searches');
await Hive.openBox<String>('favorite_foods');
await Hive.openBox<Map>('frequent_foods');  // {foodId: count}
```

**Why Hive?**
- Fast local storage
- No SQL queries
- Type-safe
- Auto-sync to disk
- Small footprint

**Why JSONB in Supabase?**
- Flexible nested structures (daily_plans, meals)
- No schema migrations for plan changes
- Query support with JSONB operators
- Compact storage

---

## 🔐 Security & Auth

### **Row Level Security (RLS)**

**Supabase policies:**
```sql
-- Users can only read own data
CREATE POLICY "Users can read own data" ON food_logs
  FOR SELECT USING (auth.uid() = user_id);

-- Users can insert own data
CREATE POLICY "Users can insert own data" ON food_logs
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Public templates readable by all
CREATE POLICY "Public templates readable" ON meal_templates
  FOR SELECT USING (is_public = true OR auth.uid() = user_id);
```

### **Auth Flow**

```
1. User signs up/in → Supabase Auth
2. JWT token stored → Secure storage
3. Auto-refresh → Background refresh
4. User ID extracted → SupabaseConfig.currentUser
5. All queries filtered by user_id
```

---

## ⚡ Performance Optimizations

### **1. Auto-Dispose Providers**
```dart
FutureProvider.autoDispose<T>  // Cleans up when not used
```

### **2. Pagination (Future)**
```dart
query.range(0, 19)  // Load 20 items at a time
```

### **3. Indexes**
```sql
CREATE INDEX idx_food_logs_user_date
  ON food_logs (user_id, logged_at DESC);
```

### **4. Hive Cache**
- Recent searches (instant load)
- Favorites (offline access)
- Frequent foods (no query needed)

### **5. Skeleton Loading**
- Show UI skeleton immediately
- Load data in background
- Smooth transition

### **6. Image Optimization (Future)**
- Compress before upload
- Thumbnail generation
- Lazy loading
- CDN delivery

---

## 🧪 Testing Strategy (Planned)

### **Unit Tests**
- Model serialization
- Service logic
- Calculation functions
- Utility methods

### **Widget Tests**
- Component rendering
- User interactions
- State changes
- Navigation

### **Integration Tests**
- End-to-end flows
- Database operations
- API calls

---

## 📊 Analytics Architecture (Planned)

```
User Action
    ↓
Event Tracking (Firebase Analytics)
    ↓
Custom Parameters
    ↓
Dashboard (Firebase Console)
```

**Events to Track:**
- screen_view
- food_logged
- meal_plan_created
- weight_entry_added
- achievement_unlocked
- search_performed

---

## 🔮 Future Architecture Improvements

### **1. Offline-First**
```
Drift (SQLite)
    ↓
Sync Queue
    ↓
Background Sync Worker
    ↓
Conflict Resolution
```

### **2. Microservices**
```
AI Service (Python) ← Food Recognition
Recipe Service (Node.js) ← Recipe CRUD
Notification Service (Go) ← Push Notifications
```

### **3. GraphQL**
```
Replace REST with GraphQL
    ↓
Efficient data fetching
    ↓
Reduced over-fetching
```

### **4. State Management Evolution**
```
Riverpod → Riverpod 3.0
    ↓
Code generation
    ↓
Better type safety
```

---

*Last Updated: 2025-12-25*
*Architecture Version: Phase 3*
