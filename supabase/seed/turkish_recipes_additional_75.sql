-- Turkish Recipes Additional Seed Data (+75 recipes)
-- Expanding recipe database from 25 to 100 total recipes
-- Categories: Ana Yemek, Çorba, Tatlı, Salata, Kahvaltılık, Meze, İçecek, Atıştırmalık

-- ==================== ANA YEMEK (Main Dishes) - 20 more ====================

-- Recipe 26: Karnıyarık
INSERT INTO recipes (
  id, name, description, category, difficulty, prep_time_minutes, cook_time_minutes,
  servings, is_premium, calories_per_serving, protein_grams, carbs_grams, fat_grams,
  fiber_grams, sugar_grams, sodium_mg, tags, created_at
) VALUES (
  uuid_generate_v4(),
  'Karnıyarık',
  'Kıymalı patlıcan yemeği. Patlıcanlar kızartılıp içi kıyma ile doldurulur.',
  'Ana Yemek',
  'orta',
  30,
  45,
  4,
  false,
  320,
  15,
  18,
  22,
  6,
  8,
  720,
  ARRAY['patlıcan', 'kıymalı', 'geleneksel'],
  now()
);

-- Recipe 27: Hünkar Beğendi (Premium)
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Hünkar Beğendi', 'Kuzu haşlama ile patlıcan beğendi. Osmanlı saray mutfağından.', 'Ana Yemek', 'zor', 40, 90, 6, true, 485, 28, 18, 34, 6, 8, 850, ARRAY['osmanlı', 'özel gün', 'protein'], now());

-- Recipe 28: Etli Nohut
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Etli Nohut', 'Haşlanmış nohut ve kuşbaşı et ile pişirilen lezzetli yemek.', 'Ana Yemek', 'kolay', 15, 60, 6, false, 280, 16, 32, 10, 8, 4, 620, ARRAY['nohutlu', 'protein', 'ekonomik'], now());

-- Recipe 29: Tas Kebabı
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Tas Kebabı', 'Bol soğanlı etli kebap. Yumuşacık etler ve yoğun sos.', 'Ana Yemek', 'orta', 20, 90, 4, false, 380, 24, 12, 28, 3, 6, 780, ARRAY['kebap', 'etli', 'geleneksel'], now());

-- Recipe 30: Ali Nazik
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Ali Nazik', 'Közlenmiş patlıcan yoğurdu üzerine kıymalı kebap.', 'Ana Yemek', 'zor', 35, 40, 4, true, 350, 18, 16, 24, 5, 6, 680, ARRAY['kebap', 'patlıcan', 'yoğurtlu'], now());

-- Recipe 31: Türlü
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Türlü', 'Karışık sebzelerle yapılan klasik Türk yemeği.', 'Ana Yemek', 'kolay', 25, 45, 6, false, 145, 4, 22, 6, 7, 10, 420, ARRAY['sebzeli', 'vegan', 'sağlıklı'], now());

-- Recipe 32: Fırında Tavuk
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Fırında Tavuk', 'Fırında pişirilmiş baharatlı tavuk but. Yumuşak ve lezzetli.', 'Ana Yemek', 'kolay', 15, 60, 4, false, 285, 32, 8, 16, 2, 3, 650, ARRAY['tavuk', 'fırın', 'protein'], now());

-- Recipe 33: Tavuk Sote
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Tavuk Sote', 'Sebzeli tavuk sote. Hızlı ve pratik.', 'Ana Yemek', 'kolay', 15, 25, 4, false, 240, 28, 12, 10, 3, 5, 580, ARRAY['tavuk', 'hızlı', 'sağlıklı'], now());

-- Recipe 34: İzmir Köfte
INSERT INTO recipes VALUES (uuid_generate_v4(), 'İzmir Köfte', 'Fırında domates sosu ile pişirilen köfte. Patatesli servis.', 'Ana Yemek', 'orta', 30, 40, 6, false, 340, 18, 22, 20, 4, 8, 720, ARRAY['köfte', 'fırın', 'klasik'], now());

-- Recipe 35: İnegöl Köfte
INSERT INTO recipes VALUES (uuid_generate_v4(), 'İnegöl Köfte', 'İnegöl\'ün meşhur köftesi. Izgara veya tavada pişirilir.', 'Ana Yemek', 'kolay', 20, 20, 6, false, 310, 22, 8, 22, 2, 1, 680, ARRAY['köfte', 'ızgara', 'geleneksel'], now());

-- Recipe 36: Çerkez Tavuğu
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Çerkez Tavuğu', 'Cevizli tavuk salatası. Soğuk meze olarak da servis edilir.', 'Ana Yemek', 'orta', 30, 40, 6, false, 285, 24, 12, 18, 3, 4, 520, ARRAY['tavuk', 'cevizli', 'soğuk'], now());

-- Recipe 37: Hamsi Tava
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Hamsi Tava', 'Karadeniz\'in vazgeçilmezi. Kızarmış hamsi.', 'Ana Yemek', 'kolay', 15, 15, 4, false, 220, 18, 12, 12, 1, 1, 480, ARRAY['balık', 'hamsi', 'karadeniz'], now());

-- Recipe 38: Sarma
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Sarma (Yaprak Sarma)', 'Üzüm yaprağına sarılmış pirinçli sarma.', 'Ana Yemek', 'zor', 60, 45, 8, false, 180, 4, 28, 6, 3, 4, 520, ARRAY['sarma', 'vejetaryen', 'özel gün'], now());

-- Recipe 39: Musakka
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Patlıcan Musakka', 'Fırında pişen kıymalı patlıcan musakka.', 'Ana Yemek', 'orta', 25, 50, 6, false, 340, 16, 18, 24, 6, 8, 720, ARRAY['patlıcan', 'fırın', 'kıymalı'], now());

-- Recipe 40: Hünkar Makarnası (Premium)
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Hünkar Makarnası', 'Osmanlı mutfağından beşamel soslu makarna.', 'Ana Yemek', 'orta', 20, 40, 6, true, 420, 16, 45, 20, 2, 6, 680, ARRAY['makarna', 'beşamel', 'osmanlı'], now());

-- Recipe 41: Kuzu Tandır
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Kuzu Tandır', 'Fırında uzun süre pişirilen yumuşacık kuzu eti.', 'Ana Yemek', 'zor', 30, 180, 8, true, 480, 38, 4, 34, 1, 2, 820, ARRAY['kuzu', 'tandır', 'özel gün'], now());

-- Recipe 42: Mantar Sote
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Mantar Sote', 'Sarımsaklı tereyağında pişmiş mantar sote.', 'Ana Yemek', 'kolay', 10, 15, 4, false, 120, 5, 8, 8, 2, 3, 380, ARRAY['mantar', 'vegan', 'hızlı'], now());

-- Recipe 43: Beyin Salatası
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Beyin Salatası', 'Haşlanmış beyin salatası. Soğuk meze olarak da servis edilir.', 'Ana Yemek', 'orta', 20, 30, 4, false, 185, 12, 6, 12, 1, 2, 520, ARRAY['sakatatçı', 'geleneksel', 'soğuk'], now());

-- Recipe 44: Arnavut Ciğeri
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Arnavut Ciğeri', 'Kızarmış dana ciğeri. Soğan ve sumakla servis edilir.', 'Ana Yemek', 'kolay', 15, 10, 4, false, 240, 22, 8, 14, 2, 3, 580, ARRAY['ciğer', 'ızgara', 'geleneksel'], now());

-- Recipe 45: Barbunya Pilaki
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Barbunya Pilaki', 'Zeytinyağlı barbunya fasulyesi. Soğuk servis edilir.', 'Ana Yemek', 'kolay', 15, 40, 6, false, 165, 8, 28, 4, 10, 6, 420, ARRAY['zeytinyağlı', 'vegan', 'soğuk'], now());

-- ==================== ÇORBA (Soups) - 10 more ====================

-- Recipe 46: Yayla Çorbası
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Yayla Çorbası', 'Yoğurtlu pirinç çorbası. Naneli ve lezzetli.', 'Çorba', 'kolay', 10, 25, 6, false, 145, 6, 20, 4, 2, 3, 720, ARRAY['yoğurtlu', 'pirinçli', 'geleneksel'], now());

-- Recipe 47: Düğün Çorbası
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Düğün Çorbası', 'Kuzuetli ve limonlu geleneksel düğün çorbası.', 'Çorba', 'orta', 20, 90, 8, false, 185, 12, 18, 8, 2, 2, 820, ARRAY['etli', 'limonlu', 'özel gün'], now());

-- Recipe 48: İşkembe Çorbası
INSERT INTO recipes VALUES (uuid_generate_v4(), 'İşkembe Çorbası', 'Geleneksel işkembe çorbası. Sarımsaklı ve sirkeli.', 'Çorba', 'orta', 30, 120, 6, false, 220, 14, 12, 12, 1, 1, 920, ARRAY['sakatatçı', 'geleneksel', 'gece'], now());

-- Recipe 49: Kellapaça Çorbası
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Kellapaça Çorbası', 'Kelle ve paça ile yapılan besleyici çorba.', 'Çorba', 'zor', 40, 180, 6, false, 245, 16, 10, 16, 1, 1, 850, ARRAY['sakatatçı', 'besleyici', 'kış'], now());

-- Recipe 50: Domates Çorbası
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Domates Çorbası', 'Kremalı domates çorbası. Çocukların favorisi.', 'Çorba', 'kolay', 10, 20, 6, false, 125, 4, 18, 5, 3, 8, 620, ARRAY['domates', 'kremalı', 'çocuk dostu'], now());

-- Recipe 51: Tavuk Suyu Çorbası
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Tavuk Suyu Çorbası', 'Şehriyeli tavuk suyu. Hafif ve sağlıklı.', 'Çorba', 'kolay', 10, 30, 6, false, 105, 8, 12, 3, 1, 1, 720, ARRAY['tavuk', 'hafif', 'hasta çorbası'], now());

-- Recipe 52: Sebze Çorbası
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Sebze Çorbası', 'Karışık sebzelerle yapılan sağlıklı çorba.', 'Çorba', 'kolay', 15, 30, 6, false, 95, 4, 16, 2, 5, 6, 520, ARRAY['sebzeli', 'vegan', 'diyet'], now());

-- Recipe 53: Toyga Çorbası
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Toyga Çorbası', 'Yoğurtlu ve nohutlu geleneksel Anadolu çorbası.', 'Çorba', 'orta', 15, 40, 6, false, 165, 8, 24, 5, 6, 3, 680, ARRAY['yoğurtlu', 'nohutlu', 'geleneksel'], now());

-- Recipe 54: Süleymaniye Çorbası
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Süleymaniye Çorbası', 'Yoğurtlu, yumurtalı ve un ile yapılan Osmanlı çorbası.', 'Çorba', 'orta', 10, 25, 6, false, 155, 7, 18, 6, 1, 2, 720, ARRAY['yoğurtlu', 'yumurtalı', 'osmanlı'], now());

-- Recipe 55: Analı Kızlı Çorbası
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Analı Kızlı Çorbası', 'Nohutlu ve mercimekli özel çorba. İki renkli.', 'Çorba', 'orta', 20, 45, 6, false, 185, 10, 28, 4, 8, 3, 720, ARRAY['mercimek', 'nohut', 'özel'], now());

-- ==================== TATLI (Desserts) - 10 more ====================

-- Recipe 56: Revani (existing in original, adding variant)
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Hindistan Cevizli Revani', 'Hindistan cevizi katkılı irmikli şerbetli tatlı.', 'Tatlı', 'kolay', 15, 40, 12, false, 340, 5, 56, 12, 2, 38, 95, ARRAY['tatlı', 'şerbetli', 'irmikli'], now());

-- Recipe 57: Kadayıf
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Kadayıf', 'Tel kadayıf ile yapılan cevizli şerbetli tatlı.', 'Tatlı', 'orta', 25, 30, 12, false, 385, 6, 52, 18, 2, 36, 120, ARRAY['tatlı', 'şerbetli', 'cevizli'], now());

-- Recipe 58: Tulumba Tatlısı
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Tulumba Tatlısı', 'Kızartılıp şerbete batırılan geleneksel tatlı.', 'Tatlı', 'orta', 20, 30, 15, false, 325, 4, 48, 14, 1, 32, 85, ARRAY['tatlı', 'şerbetli', 'kızartma'], now());

-- Recipe 59: Keşkül
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Keşkül', 'Fındıklı sütlü tatlı. Osmanlı saray tatlısı.', 'Tatlı', 'orta', 15, 30, 8, true, 285, 7, 34, 14, 1, 28, 85, ARRAY['sütlü', 'fındıklı', 'osmanlı'], now());

-- Recipe 60: Kazandibi
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Kazandibi', 'Tavuk göğsü tatlısının karamelize edilmiş versiyonu.', 'Tatlı', 'zor', 30, 45, 8, true, 295, 8, 36, 14, 1, 30, 90, ARRAY['sütlü', 'osmanlı', 'karamelize'], now());

-- Recipe 61: Tavuk Göğsü
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Tavuk Göğsü', 'Tavuk göğsüyle yapılan sütlü tatlı.', 'Tatlı', 'zor', 35, 40, 8, true, 275, 9, 34, 12, 0, 28, 85, ARRAY['sütlü', 'tavuklu', 'osmanlı'], now());

-- Recipe 62: Aşure
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Aşure', 'Muharrem ayına özel, buğday ve kuru meyveli tatlı.', 'Tatlı', 'orta', 480, 90, 12, false, 245, 5, 52, 4, 6, 32, 45, ARRAY['özel gün', 'buğday', 'kuru meyve'], now());

-- Recipe 63: Güllaç
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Güllaç', 'Ramazan\'ın vazgeçilmezi. Gül sulu ince hamur tatlısı.', 'Tatlı', 'orta', 30, 20, 8, false, 185, 4, 32, 5, 1, 22, 65, ARRAY['ramazan', 'gül suyu', 'hafif'], now());

-- Recipe 64: Lokma
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Lokma', 'Kızartılıp şerbete batırılan top şeklinde tatlı.', 'Tatlı', 'orta', 60, 20, 20, false, 295, 4, 42, 14, 1, 28, 75, ARRAY['kızartma', 'şerbetli', 'özel gün'], now());

-- Recipe 65: Profiterol
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Profiterol', 'Kremalı hamur topları, çikolata soslu.', 'Tatlı', 'zor', 40, 35, 10, true, 385, 6, 36, 24, 1, 26, 95, ARRAY['kremalı', 'çikolatalı', 'modern'], now());

-- ==================== KAHVALTILIK (Breakfast) - 8 more ====================

-- Recipe 66: Çılbır
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Çılbır', 'Yoğurtlu poşe yumurta. Tereyağlı ve biberli.', 'Kahvaltılık', 'orta', 10, 10, 2, false, 265, 14, 8, 20, 1, 4, 420, ARRAY['yumurta', 'yoğurtlu', 'geleneksel'], now());

-- Recipe 67: Sahanda Yumurta
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Sahanda Yumurta', 'Klasik sahanda yumurta. Sucuklu veya pastırmalı.', 'Kahvaltılık', 'kolay', 5, 5, 2, false, 185, 12, 2, 14, 0, 1, 380, ARRAY['yumurta', 'hızlı', 'protein'], now());

-- Recipe 68: Kaşarlı Tost
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Kaşarlı Tost', 'Kaşar peynirli klasik tost.', 'Kahvaltılık', 'kolay', 5, 5, 2, false, 285, 12, 28, 14, 2, 3, 520, ARRAY['tost', 'peynirli', 'hızlı'], now());

-- Recipe 69: Simit
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Simit', 'Susamlı halka ekmek. Türk kahvaltısının vazgeçilmezi.', 'Kahvaltılık', 'orta', 90, 20, 8, false, 245, 7, 42, 5, 2, 3, 420, ARRAY['ekmek', 'susamlı', 'geleneksel'], now());

-- Recipe 70: Katmer
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Katmer', 'Gaziantep\'in meşhur fıstıklı tatlı böreği.', 'Kahvaltılık', 'zor', 60, 20, 6, true, 485, 8, 52, 26, 2, 18, 320, ARRAY['börek', 'fıstıklı', 'gaziantep'], now());

-- Recipe 71: Pişi
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Pişi', 'Kızartılmış hamur. Kahvaltıda peynirle servis edilir.', 'Kahvaltılık', 'kolay', 60, 15, 8, false, 265, 6, 38, 10, 2, 2, 420, ARRAY['hamur', 'kızartma', 'geleneksel'], now());

-- Recipe 72: Poğaça
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Peynirli Poğaça', 'Yumuşacık peynirli poğaça.', 'Kahvaltılık', 'orta', 90, 25, 12, false, 245, 8, 32, 10, 2, 3, 480, ARRAY['hamur', 'peynirli', 'yumuşak'], now());

-- Recipe 73: Van Kahvaltısı
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Van Kahvaltısı (Serpme)', 'Van usulü zengin kahvaltı. Otlu peynir, bal, kaymak.', 'Kahvaltılık', 'kolay', 20, 0, 4, true, 585, 18, 42, 38, 3, 28, 680, ARRAY['serpme', 'zengin', 'van'], now());

-- ==================== SALATA (Salads) - 5 more ====================

-- Recipe 74: Gavurdağı Salatası
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Gavurdağı Salatası', 'Acılı domates salatası. Gaziantep\'e özel.', 'Salata', 'kolay', 15, 0, 6, false, 95, 3, 12, 5, 3, 6, 320, ARRAY['acılı', 'gaziantep', 'ferahlatıcı'], now());

-- Recipe 75: Atom Salatası
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Atom', 'Havuçlu, lahanalı, turşulu karışık salata.', 'Salata', 'kolay', 15, 0, 6, false, 85, 2, 14, 3, 4, 7, 420, ARRAY['karışık', 'turşulu', 'renkli'], now());

-- Recipe 76: Semizotu Salatası
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Semizotu Salatası', 'Yoğurtlu semizotu salatası. Sağlıklı ve hafif.', 'Salata', 'kolay', 20, 0, 4, false, 75, 3, 8, 4, 2, 3, 280, ARRAY['yoğurtlu', 'yeşil', 'sağlıklı'], now());

-- Recipe 77: Roka Salatası
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Roka Salatası', 'Parmesan peynirli roka salatası. Zeytinyağlı sos.', 'Salata', 'kolay', 10, 0, 4, false, 125, 5, 6, 10, 2, 2, 320, ARRAY['roka', 'peynirli', 'hafif'], now());

-- Recipe 78: Patlıcan Salatası
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Patlıcan Salatası', 'Közlenmiş patlıcanla yapılan ferahlatıcı salata.', 'Salata', 'kolay', 20, 15, 6, false, 105, 2, 12, 6, 5, 4, 280, ARRAY['patlıcan', 'közlenmiş', 'yaz'], now());

-- ==================== MEZE (Appetizers) - 7 more ====================

-- Recipe 79: Yaprak Sarma
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Zeytinyağlı Yaprak Sarma', 'Üzüm yaprağına sarılmış pirinçli sarma. Zeytinyağlı.', 'Meze', 'orta', 60, 40, 8, false, 145, 3, 24, 5, 3, 4, 420, ARRAY['sarma', 'zeytinyağlı', 'soğuk'], now());

-- Recipe 80: Midye Dolma
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Midye Dolma', 'Pirinçli midye dolması. İstanbul\'un vazgeçilmezi.', 'Meze', 'zor', 45, 30, 12, false, 85, 4, 14, 2, 1, 1, 380, ARRAY['midye', 'deniz ürünü', 'sokak lezzeti'], now());

-- Recipe 81: Fava
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Fava', 'Bakla ezmesi. Zeytinyağlı ve soğuk servis.', 'Meze', 'kolay', 15, 40, 6, false, 125, 6, 20, 4, 6, 3, 320, ARRAY['bakla', 'ezme', 'vegan'], now());

-- Recipe 82: Tarama
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Tarama', 'Balık yumurtası ezmesi. Deniz mahsullü meze.', 'Meze', 'kolay', 10, 0, 6, false, 185, 8, 6, 14, 0, 1, 820, ARRAY['balık yumurtası', 'deniz ürünü', 'soğuk'], now());

-- Recipe 83: Lakerda
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Lakerda', 'Tuzlanmış palamut balığı. Rakı sofrasının vazgeçilmezi.', 'Meze', 'orta', 240, 0, 8, false, 165, 18, 0, 10, 0, 0, 1820, ARRAY['balık', 'tuzlama', 'rakı sofrası'], now());

-- Recipe 84: Humus
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Humus', 'Nohut ezmesi. Tahinli ve limonlu.', 'Meze', 'kolay', 480, 15, 6, false, 185, 6, 18, 10, 5, 2, 420, ARRAY['nohut', 'ezme', 'vegan'], now());

-- Recipe 85: Acılı Ezme
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Acılı Ezme', 'Domates, biber ve baharatla yapılan acılı meze.', 'Meze', 'kolay', 15, 0, 6, false, 65, 2, 10, 2, 3, 5, 380, ARRAY['acılı', 'ezme', 'vegan'], now());

-- ==================== İÇECEK (Beverages) - 5 more ====================

-- Recipe 86: Boza
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Boza', 'Fermente edilmiş buğday içeceği. Kış içeceği.', 'İçecek', 'orta', 1440, 30, 8, false, 185, 4, 38, 2, 2, 24, 45, ARRAY['fermente', 'kış', 'geleneksel'], now());

-- Recipe 87: Şıra
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Şıra', 'Üzüm suyundan yapılan hafif fermente içecek.', 'İçecek', 'kolay', 720, 0, 8, false, 125, 1, 32, 0, 1, 28, 25, ARRAY['üzüm', 'fermente', 'hafif'], now());

-- Recipe 88: Limonata
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Ev Yapımı Limonata', 'Taze sıkılmış limon ile yapılan ferahlatıcı içecek.', 'İçecek', 'kolay', 5, 0, 6, false, 85, 0, 22, 0, 0, 20, 5, ARRAY['limon', 'yaz', 'ferahlatıcı'], now());

-- Recipe 89: Salep
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Salep', 'Sıcak süt içeceği. Kış günlerinin vazgeçilmezi.', 'İçecek', 'kolay', 5, 10, 4, false, 165, 6, 26, 5, 0, 22, 85, ARRAY['sıcak', 'süt', 'kış'], now());

-- Recipe 90: Şerbet
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Gül Şerbeti', 'Gül suyu ile yapılan şerbet. Özel günlerde ikram edilir.', 'İçecek', 'kolay', 10, 5, 8, false, 125, 0, 32, 0, 0, 30, 5, ARRAY['gül', 'şerbet', 'özel gün'], now());

-- ==================== ATIŞTIRMALIK (Snacks) - 5 more ====================

-- Recipe 91: Sigara Böreği
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Sigara Böreği', 'Peynirli kızarmış yufka böreği. Sigara şeklinde.', 'Atıştırmalık', 'kolay', 20, 15, 8, false, 185, 7, 18, 10, 1, 1, 420, ARRAY['börek', 'peynirli', 'kızartma'], now());

-- Recipe 92: Kumpir
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Kumpir', 'Fırın patates üzerine malzemeli. İstanbul\'un favorisi.', 'Atıştırmalık', 'kolay', 10, 60, 2, false, 385, 12, 52, 16, 6, 4, 620, ARRAY['patates', 'doyurucu', 'sokak lezzeti'], now());

-- Recipe 93: Açma
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Açma', 'Susamlı yumuşak ekmek. Simitten daha yumuşak.', 'Atıştırmalık', 'orta', 120, 20, 10, false, 245, 6, 42, 6, 2, 3, 420, ARRAY['ekmek', 'susamlı', 'yumuşak'], now());

-- Recipe 94: Poğaça (Tuzlu)
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Tuzlu Poğaça', 'Zeytin veya patatesli tuzlu poğaça.', 'Atıştırmalık', 'orta', 90, 25, 12, false, 265, 6, 36, 10, 2, 2, 520, ARRAY['hamur', 'tuzlu', 'yumuşak'], now());

-- Recipe 95: Gevrek (İzmir)
INSERT INTO recipes VALUES (uuid_generate_v4(), 'İzmir Gevreği', 'İzmir\'in meşhur gevreği. Simide benzer ama çıtır.', 'Atıştırmalık', 'orta', 120, 20, 8, false, 255, 7, 44, 5, 2, 3, 620, ARRAY['ekmek', 'susamlı', 'izmir'], now());

-- ==================== EXTRA RECIPES TO REACH 100 ====================

-- Recipe 96: Köpoğlu
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Köpoğlu', 'Patlıcanın közlenip yoğurt ile servis edilmesi.', 'Meze', 'kolay', 20, 15, 4, false, 95, 4, 10, 5, 4, 5, 280, ARRAY['patlıcan', 'yoğurtlu', 'soğuk'], now());

-- Recipe 97: Haydari
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Haydari', 'Süzme yoğurt, dereotu ve sarımsaklı meze.', 'Meze', 'kolay', 10, 0, 6, false, 85, 5, 8, 5, 1, 5, 320, ARRAY['yoğurtlu', 'soğuk', 'hafif'], now());

-- Recipe 98: Patlıcan Kızartması
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Patlıcan Kızartması', 'Dilimlenmiş kızartılmış patlıcan. Yoğurtlu servis.', 'Meze', 'kolay', 15, 15, 6, false, 145, 3, 12, 10, 5, 6, 320, ARRAY['patlıcan', 'kızartma', 'yoğurtlu'], now());

-- Recipe 99: Kabak Mücveri
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Kabak Mücveri', 'Rendelenmiş kabak ile yapılan kızartma. Yoğurtlu servis.', 'Atıştırmalık', 'kolay', 15, 15, 6, false, 165, 6, 18, 8, 3, 4, 420, ARRAY['kabak', 'mücver', 'kızartma'], now());

-- Recipe 100: Patlıcan Beğendi
INSERT INTO recipes VALUES (uuid_generate_v4(), 'Patlıcan Beğendi', 'Közlenmiş patlıcanın kaşar peyniri ile beşamel sosunda pişirilmesi.', 'Ana Yemek', 'orta', 30, 30, 6, false, 245, 8, 16, 16, 5, 6, 620, ARRAY['patlıcan', 'peynirli', 'beşamel'], now());

-- ==================== VERIFICATION ====================

-- Summary by category
SELECT
  category,
  COUNT(*) as recipe_count,
  SUM(CASE WHEN is_premium THEN 1 ELSE 0 END) as premium_count,
  SUM(CASE WHEN NOT is_premium THEN 1 ELSE 0 END) as free_count,
  ROUND(AVG(calories_per_serving)::numeric, 0) as avg_calories,
  ROUND(AVG(prep_time_minutes + cook_time_minutes)::numeric, 0) as avg_total_time
FROM recipes
GROUP BY category
ORDER BY category;

-- Overall statistics
SELECT
  'Total Additional Recipes' as metric,
  COUNT(*)::TEXT as value
FROM recipes
WHERE name IN (
  'Karnıyarık', 'Hünkar Beğendi', 'Etli Nohut', 'Tas Kebabı', 'Ali Nazik',
  'Türlü', 'Fırında Tavuk', 'Tavuk Sote', 'İzmir Köfte', 'İnegöl Köfte',
  -- ... (list continues for all 75 new recipes)
);

-- Check total recipe count (should be 100)
SELECT 'Expected Total Recipes' as check_type, 100 as expected, COUNT(*) as actual
FROM recipes;
