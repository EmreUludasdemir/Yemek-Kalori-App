# 🎯 TürkKalori - Feature List

Tüm özelliklerin detaylı listesi ve implement durumları.

## 🔐 Authentication & Onboarding

### ✅ Auth System
- **Email/Password Login** - Supabase Auth
- **Session Management** - Auto-refresh tokens
- **User Profile** - Basic info storage

### ✅ Onboarding Flow
**File:** `lib/presentation/screens/onboarding/onboarding_screen.dart`
- **5 Pages:**
  1. Welcome screen
  2. Calorie tracking introduction
  3. AI food recognition demo
  4. Statistics showcase
  5. Achievements preview
- **Hive persistence** - Shows only once
- **Skip button** - Quick access
- **Lottie animations** (placeholder)

### ✅ Profile Setup Wizard
**File:** `lib/presentation/screens/onboarding/profile_setup_wizard.dart`
- **6 Steps:**
  1. Gender selection
  2. Age input (18-100)
  3. Height input (120-250 cm)
  4. Weight input (30-300 kg)
  5. Activity level (5 options: 1.2x - 1.725x)
  6. Goal (lose/maintain/gain weight)
- **Mifflin-St Jeor Equation** - BMR + TDEE calculation
- **Goal adjustment** - ±500 kcal for weight change
- **Form validation** - All fields required
- **Smooth page indicator** - Visual progress

---

## 🍽️ Food & Meal Tracking

### ✅ Food Search
**File:** `lib/presentation/screens/food_log/food_search_screen.dart`

**Search Capabilities:**
- Local database search
- Category filters (7 types)
- Turkish food database
- Popular foods section
- Recent foods section

**UI Enhancements (Phase 2):**
- **Recent searches** (ActionChip list, last 10)
- **Quick add section** (3 tabs)
  - Recent: Last used foods
  - Favorites: Toggled favorites
  - Frequent: Top 20 by usage count
- **Empty state** - No results found
- **Skeleton loading** - Food list shimmer
- **Swipe to favorite** - Quick toggle

**Services:**
- `RecentSearchesService` - Hive-based FIFO queue (max 10)
- `FavoriteFoodsService` - Toggle favorites
- `FrequentFoodsService` - Usage counting (top 20)

### ✅ Food Logging
**File:** `lib/presentation/screens/food_log/add_food_screen.dart`
- **Meal type selection** - 4 types (kahvalti, ogle, aksam, ara_ogun)
- **Serving size adjustment** - Increment/decrement
- **Nutrition preview** - Real-time calculation
- **Photo support** - Optional image
- **Notes field** - Custom text
- **Timestamp** - Auto or manual

### ✅ Meal Sections
**File:** `lib/presentation/widgets/food/meal_section.dart`
- **4 Meal Types:**
  - Kahvaltı (Breakfast) - Yellow/orange theme
  - Öğle Yemeği (Lunch) - Blue theme
  - Akşam Yemeği (Dinner) - Purple theme
  - Ara Öğün (Snacks) - Green theme
- **Swipe to delete** (Phase 2) - SwipeableItem wrapper
- **Confirmation dialog** - Delete safety
- **Real-time Supabase** - Instant deletion
- **Total calories** - Per meal type

### ✅ Smart Suggestions
**File:** `lib/services/smart_suggestions_service.dart`

**Time-based meal detection:**
- 06:00-11:00 → breakfast
- 11:00-16:00 → lunch
- 16:00-21:00 → dinner
- Other → snack

**Suggestion types:**
- **Similar foods** - ±20% calorie range
- **Complementary foods** - Nutritional pairing (high protein → suggest carbs)
- **Calorie budget suggestions** - Contextual messages based on remaining calories
- **Hydration reminders** - Time and intake based

### 🟡 AI Food Recognition
**File:** `lib/presentation/screens/camera/camera_picker_screen.dart`
- ✅ Camera integration
- ✅ Photo capture
- ❌ AI backend connection (placeholder)
- ❌ Food detection model
- ❌ Nutrition estimation

### ❌ Barcode Scanner
**File:** `lib/presentation/screens/food_log/barcode_scanner_screen.dart`
- ✅ UI placeholder
- ❌ Scanner implementation
- ❌ Product database lookup

---

## 📊 Statistics & Analytics

### ✅ Stats Screen
**File:** `lib/presentation/screens/profile/stats_screen.dart`

**Weekly View:**
- **Line chart** - 7-day calorie tracking
- **Macro pie chart** - Protein/Carbs/Fat distribution
- **Daily averages** - Auto-calculated
- **Trend analysis** - Min/max/avg display

**Monthly View:**
- **Line chart** - 30-day calorie tracking
- **Bar chart** - Daily comparison
- **Active days** - Tracking consistency
- **Monthly totals** - Aggregated data

**UI Enhancements (Phase 2):**
- **Empty state** - No data available
- **Skeleton loader** - Chart type shimmer
- **Tab switcher** - Week/Month toggle
- **Refresh button** - Manual data reload

**Data Models:**
- `WeeklyNutritionData` - 7-day array, totals, averages
- `MonthlyNutritionData` - 31-day array, active days, trends

---

## 🏆 Achievements System

### ✅ Achievement Engine
**File:** `lib/presentation/screens/profile/achievements_screen.dart`

**20 Achievements in 5 Categories:**

**1. Başlangıç (Welcome)**
- İlk Adım - İlk yemek kaydı
- İlk Hafta - 7 gün takip
- Profil Tamamla - Profile photo + bio

**2. Düzenlilik (Consistency)**
- 3 Günlük Seri - 3 consecutive days
- Haftalık Rutin - 7 consecutive days
- Aylık Düzen - 30 consecutive days
- 100 Gün - 100 total days

**3. Kalori (Calories)**
- Hedefte - Stay within ±50 kcal for 7 days
- Mükemmel Hafta - Within target 7/7 days
- 10,000 Kalori - Log 10k total
- Denge Ustası - Perfect week 4 times

**4. Sosyal (Social)**
- İlk Paylaşım - Share first meal
- Sosyal Kelebek - 5 meals shared
- İlham Kaynağı - 100 likes received
- Topluluk Lideri - 50 followers

**5. Özel (Special)**
- Erken Kuş - Log before 7 AM for 5 days
- Gece Kuşu - Log after 10 PM for 5 days
- Fotoğraf Tutkunu - 50 photos
- Not Ustası - 30 meals with notes
- Çeşitlilik - 50 different foods

**Features:**
- **Progress tracking** - 0-100%
- **Unlock notifications** - Custom dialogs
- **Badge display** - Grid layout
- **Category filtering** - Filter by type
- **Rarity system** - Common/Rare/Epic/Legendary

---

## 🗓️ Meal Planning

### ✅ Meal Plan System (Phase 3)
**Files:**
- `lib/data/models/meal_plan_model.dart`
- `lib/services/meal_planning_service.dart`
- `lib/presentation/screens/meal_planning/meal_plan_screen.dart`

**Models:**
- **MealPlan** - Weekly plan container
  - Daily plans array (JSONB in Supabase)
  - Start/end dates
  - Active flag
  - Total/average calories
- **DailyMealPlan** - Single day meals
  - Date
  - Meals array
  - Nutrition totals (calories, protein, carbs, fat)
- **PlannedMeal** - Individual meal
  - Food info (id, name, image)
  - Serving count
  - Nutrition values
  - Meal type
  - Optional notes
- **MealTemplate** - Reusable combos
  - Template meals array
  - Category (breakfast/lunch/dinner/snack)
  - Public/private flag
  - Use count tracking

**Features:**
- **Create plan** - Name, description, date range
- **View active plan** - Current week overview
- **Daily detail** - Date selector, meal management
- **Add meals** - From food search
- **Swipe to delete** - Remove meals
- **Templates** - Save favorite combos
- **Apply template** - One-click meal addition
- **Copy to logs** - Convert plan → actual logs
- **Smart generation** - AI-assisted planning based on calorie target
- **Public templates** - Discover community plans

**UI Screens:**
1. **meal_plan_screen.dart** - Main hub
   - Active plan tab
   - All plans tab
   - Empty states
   - Create button
2. **create_meal_plan_screen.dart** - Wizard
   - Name/description form
   - Date range picker
   - Duration calculator
3. **meal_plan_detail_screen.dart** - Daily view
   - Horizontal date scroll
   - Daily stats card
   - 4 meal type sections
   - Add/delete meals

**Service Methods (15+):**
- createMealPlan()
- getActiveMealPlan()
- getMealPlans()
- updateMealPlan()
- deleteMealPlan()
- addMealToPlan()
- removeMealFromPlan()
- createTemplate()
- getTemplates()
- getPublicTemplates()
- applyTemplate()
- copyPlanToLogs()
- generateSmartMealPlan()

---

## ⚖️ Weight Tracking

### ✅ Weight Tracking System (Phase 3)
**Files:**
- `lib/data/models/weight_entry_model.dart`
- `lib/services/weight_tracking_service.dart`

**Models:**
- **WeightEntry**
  - Weight (kg)
  - Timestamp
  - Optional photo
  - Optional notes
  - Body measurements (neck, waist, hips, chest)
- **WeightGoal**
  - Start weight
  - Target weight
  - Current weight (auto-updated)
  - Goal type (lose/gain/maintain)
  - Start/target dates
  - Progress percentage
  - Days remaining
- **WeightStats**
  - Current/previous weight
  - Highest/lowest/average
  - Weight change vs previous
  - Total entries count
  - First/last entry dates
  - Trend (increasing/decreasing/stable)

**Service Features (20+ methods):**

**Entry Management:**
- addWeightEntry() - Photo, notes, measurements
- getWeightEntries() - Date range filters
- getLatestWeightEntry() - Most recent
- updateWeightEntry() - Edit existing
- deleteWeightEntry() - Remove
- getWeightStats() - Calculate analytics

**Goal Management:**
- createWeightGoal() - Auto-deactivate previous
- getActiveWeightGoal() - Current goal
- updateWeightGoal() - Modify target
- deactivateWeightGoal() - Mark inactive
- Auto-sync current weight

**Analytics & Calculations:**
- calculateBMI() - Body Mass Index
- getBMICategory() - Zayıf/Normal/Fazla Kilolu/Obez
- getIdealWeightRange() - Based on height (BMI 18.5-25)
- predictGoalDate() - Timeline estimation
- isHealthyWeightChange() - 0.5-1 kg/week validation
- getWeightTrend() - 30-day trend (Artış/Azalış/Stabil)
- getAverageWeight() - Period average
- getWeeklyAverages() - Chart data (12 weeks)

**Export:**
- exportWeightDataCSV() - Date, weight, notes

### ✅ Weight UI (Phase 3)
**Files:**
- `lib/presentation/screens/weight/weight_tracking_screen.dart` (~800 lines)
- `lib/presentation/screens/weight/add_weight_entry_screen.dart` (~400 lines)
- `lib/presentation/screens/weight/weight_goal_screen.dart` (~500 lines)

**Features:**
- ✅ Weight entry screen with date picker
- ✅ Line chart (fl_chart, last 30 entries)
- ✅ Goal progress card with percentage
- ✅ Body measurements form (neck, waist, hips, chest)
- ✅ BMI calculator (in service)
- ✅ History tab with swipe-to-delete
- ✅ Stats cards (highest, lowest, average)
- ✅ Goal wizard with prediction
- ✅ Healthy weight change validation
- ❌ Photo gallery (planned)

---

## 💧 Water Tracking

### ✅ Water System (Phase 3)
**Files:**
- `lib/presentation/screens/home/home_screen.dart`
- `lib/services/water_reminder_service.dart` (~350 lines)
- `lib/presentation/screens/settings/water_reminder_settings_screen.dart` (~500 lines)

**Tracking:**
- ✅ Glass counter (8 glasses target)
- ✅ Progress bar
- ✅ Add water button
- ✅ Hive persistence
- ✅ Daily reset (midnight)

**Reminder System:**
- ✅ Water reminders (flutter_local_notifications)
- ✅ Interval scheduling (15-240 minutes)
- ✅ Active hours (start/end time)
- ✅ 4 preset schedules (Frequent, Regular, Relaxed, Work Hours)
- ✅ Random motivational messages (8 variants)
- ✅ Settings screen (sliders, toggles, presets)
- ✅ Test notification button
- ✅ Statistics (reminders per day)

**Missing:**
- ❌ Custom containers (bottle sizes)
- ❌ Hydration stats screen (dedicated)
- ❌ Streak tracking
- ❌ Activity-based reminders (step counter integration)

---

## 🎨 UI/UX Components

### ✅ Advanced Animations (Phase 1)
**File:** `lib/presentation/widgets/animations/`

**page_transitions.dart** - 8 transitions
- slideFromRight()
- slideFromLeft()
- slideFromBottom()
- slideFromTop()
- fade()
- scale()
- fadeScale()
- rotation()

**micro_interactions.dart** - 4 interactions
- BouncyButton - Scale on press
- LikeButton - Heart animation
- AnimatedCounter - Number ticker
- AnimatedProgressBar - Smooth progress

### ✅ Loading States (Phase 1)
**File:** `lib/presentation/widgets/loading/skeleton_loader.dart`

**6 Skeleton Types:**
1. FoodCard - Meal card shimmer
2. FoodList - Multiple items
3. StatsCard - Dashboard card
4. Profile - User profile
5. Post - Social post
6. Chart - Graph placeholder

**Features:**
- Shimmer effect - Gradient sweep
- Dark mode support - Adaptive colors
- Customizable count - Item repetition

### ✅ Empty States (Phase 1)
**File:** `lib/presentation/widgets/common/empty_state.dart`

**12 Pre-configured Types:**
- NoFoods - Empty food list
- NoMeals - No meals logged
- NoSearchResults - Search empty
- NoStats - No statistics data
- NoAchievements - No unlocked achievements
- NoNotifications - Notification center
- NoPosts - Social feed
- NoFollowers - Following list
- NoFavorites - Favorite foods
- NoRecipes - Recipe collection
- NoPlans - Meal plans
- Error - Generic error

**Features:**
- Lottie animation support
- Custom title/message
- CTA button with callback
- Icon customization

### ✅ Bottom Sheets (Phase 1)
**File:** `lib/presentation/widgets/modals/custom_bottom_sheet.dart`

**4 Preset Types:**
1. **QuickAdd** - Meal type selector
   - 4 meal type buttons
   - Icon + label
   - Callback with selected type
2. **FilterOptions** - Category filters
   - Checkbox list
   - Apply/Reset buttons
3. **DatePicker** - Calendar selection
   - Turkish localization
   - OK/Cancel
4. **Custom** - Generic container
   - Title bar
   - Drag handle
   - Flexible content

### ✅ Dialogs (Phase 1)
**File:** `lib/presentation/widgets/modals/custom_dialog.dart`

**5 Dialog Types:**
1. **Success** - Green checkmark
2. **Error** - Red X
3. **Info** - Blue info icon
4. **Confirmation** - Yes/No buttons
5. **Loading** - Progress indicator

**Features:**
- Auto-dismiss option
- Custom buttons
- Animated entry
- Backdrop blur

### ✅ Swipeable Items (Phase 1)
**File:** `lib/presentation/widgets/common/swipeable_item.dart`

**Gestures:**
- **Swipe right** - Delete (red)
- **Swipe left** - Edit (blue)
- **Long press** - Favorite (yellow)

**Features:**
- Confirmation dialog (optional)
- Custom labels/icons
- Haptic feedback
- Smooth animation

### ✅ Multi-Action FAB (Phase 1)
**File:** `lib/presentation/widgets/common/multi_action_fab.dart`

**4 Quick Actions:**
1. Add food - Food search
2. Add water - Increment glasses
3. Open camera - AI recognition
4. Scan barcode - Product lookup

**Features:**
- Speed dial animation
- Labeled buttons
- Color-coded icons
- Backdrop overlay

### ✅ Quick Add Section (Phase 2)
**File:** `lib/presentation/widgets/food/quick_add_section.dart`

**3 Tabs:**
1. **Recent** - Last 10 foods
2. **Favorites** - Toggled favorites
3. **Frequent** - Top 20 by usage

**Features:**
- Horizontal food cards
- Tap to add
- Empty state per tab
- Badge counts

### ✅ Feature Discovery (Phase 2)
**File:** `lib/presentation/widgets/tutorial/feature_discovery.dart`

**Spotlight Tutorial:**
- Target widget highlighting
- Backdrop dimming
- Title + description
- Next/Skip buttons
- Multi-step flow support

---

## ⚙️ Services & Business Logic

### ✅ Nutrition Service
**File:** `lib/services/nutrition_service.dart`
- searchLocalFoods() - Database query
- getPopularTurkishFoods() - Top foods
- getRecentFoods() - User history
- getFoodById() - Single item

### ✅ Recent Searches Service
**File:** `lib/services/recent_searches_service.dart`
- addSearch() - FIFO queue (max 10)
- getRecentSearches() - Retrieve list
- clearAll() - Reset

### ✅ Favorite Foods Service
**File:** `lib/services/recent_searches_service.dart`
- toggleFavorite() - Add/remove
- isFavorite() - Check status
- getAllFavorites() - Full list

### ✅ Frequent Foods Service
**File:** `lib/services/recent_searches_service.dart`
- incrementFood() - Increase count
- getFrequentFoods() - Top 20
- LRU cleanup - Auto-remove old

### ✅ Smart Suggestions Service
**File:** `lib/services/smart_suggestions_service.dart`
- getCurrentMealTime() - Time-based detection
- getSuggestedFoods() - Meal time + history
- getSimilarFoods() - ±20% calories
- getComplementaryFoods() - Nutritional pairing
- getCalorieBudgetSuggestion() - Contextual messages

### ✅ Meal Planning Service
**File:** `lib/services/meal_planning_service.dart`
- 15+ methods (see Meal Planning section)

### ✅ Weight Tracking Service
**File:** `lib/services/weight_tracking_service.dart`
- 20+ methods (see Weight Tracking section)

---

## 🔔 Notifications

### 🟡 Push Notifications
**Config:** Firebase Cloud Messaging

**Implemented:**
- ✅ Firebase setup
- ✅ Token registration
- ✅ MyFirebaseMessagingService.kt

**Missing:**
- ❌ Water reminders
- ❌ Meal time reminders
- ❌ Achievement unlocks
- ❌ Goal milestones
- ❌ Inactivity nudges

---

## 🌐 Localization

### ✅ Turkish Support
- **intl package** - Date/time formatting
- **Turkish locale** - tr_TR
- **Day names** - Pazartesi, Salı, etc.
- **Month names** - Ocak, Şubat, etc.
- **Custom labels** - All UI text in Turkish

---

## 📤 Export & Sharing

### 🟡 Data Export
**Implemented:**
- ✅ Weight data CSV

**Planned:**
- ❌ Food log CSV/PDF
- ❌ Nutrition report PDF
- ❌ Achievement summary
- ❌ Progress photos ZIP

---

## 🎨 Theming

### ✅ Dark Mode
**File:** `lib/core/constants/app_colors.dart`

**Colors:**
- Primary - Blue (#2196F3)
- Secondary - Orange (#FF9800)
- Success - Green (#4CAF50)
- Error - Red (#F44336)
- Warning - Amber (#FFC107)

**Semantic Colors:**
- Protein - Red (#F44336)
- Carbs - Orange (#FF9800)
- Fat - Purple (#9C27B0)
- Breakfast - Yellow (#FFC107)
- Lunch - Blue (#2196F3)
- Dinner - Purple (#673AB7)
- Snack - Green (#4CAF50)

**Dark Mode:**
- Background - Dark grey
- Surface - Lighter grey
- Text Primary - White
- Text Secondary - Grey
- Divider - Dark border

---

## 🔮 Future Features (Not Implemented)

### Recipe Database
- 100+ Turkish recipes
- Step-by-step instructions
- Ingredient lists
- Cooking mode
- Timer integration

### Social Features
- User profiles
- Follow system
- Activity feed
- Meal sharing
- Like/comment
- Leaderboards

### Health Integration
- Apple Health sync
- Google Fit sync
- Step counting
- Heart rate
- Sleep tracking

### Premium
- Ad-free experience
- Custom diet plans
- Nutritionist consultation
- Advanced analytics
- Priority support

### Offline Mode
- Local-first architecture
- Sync queue
- Conflict resolution
- Background sync

### Gamification
- Daily challenges
- Weekly goals
- Seasonal events
- Reward system
- Level progression

---

*Last Updated: 2025-12-25*
*Total Features: 100+*
*Completion: ~70% (Phase 3)*
