# Localization Guide - TürkKalori

This guide explains how to use the localization system in the TürkKalori app.

## Supported Languages

- 🇹🇷 **Turkish (tr)** - Default language
- 🇺🇸 **English (en)** - Secondary language

## Setup

The app uses Flutter's built-in localization system with ARB (Application Resource Bundle) files.

### Files Structure

```
lib/l10n/
├── app_tr.arb          # Turkish translations (template)
├── app_en.arb          # English translations
└── LOCALIZATION_GUIDE.md
```

### Configuration

**l10n.yaml**:
```yaml
arb-dir: lib/l10n
template-arb-file: app_tr.arb
output-localization-file: app_localizations.dart
```

**pubspec.yaml**:
```yaml
flutter:
  generate: true

dependencies:
  flutter_localizations:
    sdk: flutter
```

## Generating Localization Files

After editing ARB files, run:

```bash
flutter gen-l10n
```

This generates:
- `.dart_tool/flutter_gen/gen_l10n/app_localizations.dart`
- `.dart_tool/flutter_gen/gen_l10n/app_localizations_tr.dart`
- `.dart_tool/flutter_gen/gen_l10n/app_localizations_en.dart`

**Note**: This is done automatically when you run `flutter run` or `flutter build`.

## Usage in Code

### 1. Import Generated File

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
```

### 2. Use in Widgets

```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),  // "TürkKalori" or "TurkCalorie"
      ),
      body: Column(
        children: [
          Text(l10n.homeGreeting('Emre')),  // "Merhaba, Emre!" or "Hello, Emre!"
          Text(l10n.breakfast),  // "Kahvaltı" or "Breakfast"
          Text(l10n.calories),   // "Kalori" or "Calories"
        ],
      ),
    );
  }
}
```

### 3. Configure in MaterialApp

```dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TurkKaloriApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Localization delegates
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Supported locales
      supportedLocales: [
        Locale('tr', ''),  // Turkish
        Locale('en', ''),  // English
      ],

      // Optional: locale resolution callback
      localeResolutionCallback: (locale, supportedLocales) {
        // Check if the current device locale is supported
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        // Default to Turkish
        return supportedLocales.first;
      },

      home: HomeScreen(),
    );
  }
}
```

## String Types

### 1. Simple Strings

**ARB**:
```json
{
  "appTitle": "TürkKalori",
  "loading": "Yükleniyor..."
}
```

**Usage**:
```dart
Text(l10n.appTitle)
Text(l10n.loading)
```

### 2. Strings with Placeholders

**ARB**:
```json
{
  "homeGreeting": "Merhaba, {name}!",
  "@homeGreeting": {
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  }
}
```

**Usage**:
```dart
Text(l10n.homeGreeting('Emre'))  // "Merhaba, Emre!"
```

### 3. Plural Forms

**ARB**:
```json
{
  "glassesCount": "{count, plural, =0{Henüz su içmediniz} =1{1 bardak} other{{count} bardak}}",
  "@glassesCount": {
    "placeholders": {
      "count": {
        "type": "int"
      }
    }
  }
}
```

**Usage**:
```dart
Text(l10n.glassesCount(0))  // "Henüz su içmediniz" / "No water yet"
Text(l10n.glassesCount(1))  // "1 bardak" / "1 glass"
Text(l10n.glassesCount(5))  // "5 bardak" / "5 glasses"
```

### 4. Numbers with Formatting

**ARB**:
```json
{
  "remaining": "Kalan: {amount} kg",
  "@remaining": {
    "placeholders": {
      "amount": {
        "type": "double",
        "format": "decimalPattern"
      }
    }
  }
}
```

**Usage**:
```dart
Text(l10n.remaining(2.5))  // "Kalan: 2.5 kg" / "Remaining: 2.5 kg"
```

## Language Switching

### Option 1: Using Provider

Create a locale provider:

```dart
// lib/providers/locale_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  static const String _boxName = 'settings';
  static const String _localeKey = 'locale';

  LocaleNotifier() : super(Locale('tr')) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final box = await Hive.openBox(_boxName);
    final savedLocale = box.get(_localeKey, defaultValue: 'tr') as String;
    state = Locale(savedLocale);
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final box = await Hive.openBox(_boxName);
    await box.put(_localeKey, locale.languageCode);
  }

  Future<void> toggleLocale() async {
    final newLocale = state.languageCode == 'tr' ? Locale('en') : Locale('tr');
    await setLocale(newLocale);
  }
}
```

Use in MaterialApp:

```dart
class TurkKaloriApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomeScreen(),
    );
  }
}
```

### Option 2: Language Settings Screen

```dart
// lib/presentation/screens/settings/language_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.language),
      ),
      body: ListView(
        children: [
          RadioListTile<String>(
            title: Text('Türkçe'),
            subtitle: Text('Turkish'),
            value: 'tr',
            groupValue: currentLocale.languageCode,
            onChanged: (value) {
              ref.read(localeProvider.notifier).setLocale(Locale('tr'));
            },
          ),
          RadioListTile<String>(
            title: Text('English'),
            subtitle: Text('English'),
            value: 'en',
            groupValue: currentLocale.languageCode,
            onChanged: (value) {
              ref.read(localeProvider.notifier).setLocale(Locale('en'));
            },
          ),
        ],
      ),
    );
  }
}
```

## Date and Number Formatting

### Date Formatting

Use `intl` package for locale-aware date formatting:

```dart
import 'package:intl/intl.dart';

// In Turkish: "25 Aralık 2025"
// In English: "December 25, 2025"
String formatDate(DateTime date, Locale locale) {
  final format = DateFormat.yMMMMd(locale.languageCode);
  return format.format(date);
}

// In Turkish: "25.12.2025"
// In English: "12/25/2025"
String formatShortDate(DateTime date, Locale locale) {
  final format = DateFormat.yMd(locale.languageCode);
  return format.format(date);
}
```

### Number Formatting

```dart
import 'package:intl/intl.dart';

// In Turkish: "1.234,56"
// In English: "1,234.56"
String formatNumber(double number, Locale locale) {
  final format = NumberFormat.decimalPattern(locale.languageCode);
  return format.format(number);
}

// In Turkish: "₺49,99"
// In English: "$49.99"
String formatCurrency(double amount, Locale locale) {
  final format = NumberFormat.currency(
    locale: locale.languageCode,
    symbol: locale.languageCode == 'tr' ? '₺' : '\$',
    decimalDigits: 2,
  );
  return format.format(amount);
}
```

## Adding New Translations

### Step 1: Add to ARB Files

**app_tr.arb**:
```json
{
  "newFeature": "Yeni Özellik",
  "@newFeature": {
    "description": "Title for new feature"
  }
}
```

**app_en.arb**:
```json
{
  "newFeature": "New Feature"
}
```

### Step 2: Generate

```bash
flutter gen-l10n
```

### Step 3: Use in Code

```dart
Text(l10n.newFeature)
```

## Best Practices

### 1. Always Provide Context

Use `@key` metadata to describe the string:

```json
{
  "save": "Kaydet",
  "@save": {
    "description": "Button label to save changes"
  }
}
```

### 2. Use Meaningful Keys

```dart
// Good ✅
"homeGreeting": "Merhaba, {name}!",
"profileEditButton": "Profili Düzenle",

// Bad ❌
"text1": "Merhaba, {name}!",
"button2": "Profili Düzenle",
```

### 3. Group Related Strings

Use comments to organize:

```json
{
  "_comment_auth": "AUTHENTICATION",
  "login": "Giriş Yap",
  "logout": "Çıkış Yap",
  "signup": "Kayıt Ol",

  "_comment_home": "HOME SCREEN",
  "homeGreeting": "Merhaba, {name}!",
  "homeCaloriesRemaining": "Kalan Kalori"
}
```

### 4. Handle Plurals Correctly

```json
{
  "itemsCount": "{count, plural, =0{No items} =1{1 item} other{{count} items}}"
}
```

### 5. Keep Strings Short and Simple

Split long text into multiple keys:

```dart
// Good ✅
Text('${l10n.welcomeTo} ${l10n.appTitle}')

// Bad ❌
"welcomeMessage": "Welcome to TürkKalori - Your personal calorie tracker for Turkish cuisine!"
```

## Testing Localization

### 1. Test All Locales

```dart
testWidgets('Shows correct locale', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MyScreen(),
    ),
  );

  expect(find.text('Login'), findsOneWidget);
});
```

### 2. Test Locale Switching

```dart
testWidgets('Switches locale', (tester) async {
  // Start with Turkish
  final app = MaterialApp(
    locale: Locale('tr'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: HomeScreen(),
  );

  await tester.pumpWidget(app);
  expect(find.text('Giriş Yap'), findsOneWidget);

  // Switch to English
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomeScreen(),
    ),
  );

  await tester.pumpAndSettle();
  expect(find.text('Login'), findsOneWidget);
});
```

## Troubleshooting

### Strings not showing?

1. Check ARB files for syntax errors
2. Run `flutter gen-l10n`
3. Restart the app

### Wrong translations?

1. Verify key exists in both ARB files
2. Check locale is set correctly
3. Clear build cache: `flutter clean`

### Placeholders not working?

```dart
// Wrong ❌
Text(l10n.homeGreeting)

// Correct ✅
Text(l10n.homeGreeting('Emre'))
```

## Translation Coverage

Current coverage: **200+ strings**

- ✅ App general (25 strings)
- ✅ Authentication (8 strings)
- ✅ Onboarding (11 strings)
- ✅ Profile setup (20 strings)
- ✅ Home screen (12 strings)
- ✅ Macros & nutrition (12 strings)
- ✅ Meals & food logging (15 strings)
- ✅ Statistics (12 strings)
- ✅ Weight tracking (20 strings)
- ✅ Water tracking (12 strings)
- ✅ Meal planning (12 strings)
- ✅ Recipes (25 strings)
- ✅ Social features (30 strings)
- ✅ Profile (15 strings)
- ✅ Achievements (8 strings)
- ✅ Premium (15 strings)
- ✅ Settings (18 strings)
- ✅ AI features (7 strings)
- ✅ Error messages (10 strings)
- ✅ Validation (7 strings)
- ✅ Empty states (8 strings)
- ✅ Dialogs (6 strings)
- ✅ Time & dates (19 strings)

## Future Languages

Potential future additions:
- 🇩🇪 German (de)
- 🇫🇷 French (fr)
- 🇪🇸 Spanish (es)
- 🇦🇪 Arabic (ar)

To add a new language, create `app_{locale}.arb` and translate all strings.

## Resources

- [Flutter Internationalization](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
- [ARB Format Specification](https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification)
- [Intl Package](https://pub.dev/packages/intl)
