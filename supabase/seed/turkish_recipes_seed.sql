-- Turkish Recipes Seed Data
-- 25 authentic Turkish recipes with complete nutritional information
-- Categories: Ana Yemek, Çorba, Tatlı, Salata, Kahvaltılık, Meze, İçecek, Atıştırmalık

-- ==================== ANA YEMEK (Main Dishes) ====================

-- Recipe 1: Mercimek Çorbası (Çorba - Free)
INSERT INTO recipes (
  id, name, description, category, difficulty, prep_time_minutes, cook_time_minutes,
  servings, is_premium, calories_per_serving, protein_grams, carbs_grams, fat_grams,
  fiber_grams, sugar_grams, sodium_mg, tags, created_at
) VALUES (
  uuid_generate_v4(),
  'Mercimek Çorbası',
  'Geleneksel Türk mercimek çorbası. Besleyici ve lezzetli, her öğüne yakışan klasik bir tarif.',
  'Çorba',
  'kolay',
  10,
  30,
  6,
  false,
  180,
  9,
  28,
  4,
  6,
  2,
  850,
  ARRAY['vegan', 'vejetaryen', 'sağlıklı', 'ekonomik', 'geleneksel'],
  now()
);

-- Get the recipe ID for ingredients and steps
DO $$
DECLARE
  v_recipe_id UUID;
BEGIN
  SELECT id INTO v_recipe_id FROM recipes WHERE name = 'Mercimek Çorbası' LIMIT 1;

  -- Ingredients
  INSERT INTO recipe_ingredients (recipe_id, name, amount, unit, notes) VALUES
    (v_recipe_id, 'Kırmızı mercimek', 1.5, 'su bardağı', 'yıkanmış'),
    (v_recipe_id, 'Havuç', 1, 'adet', 'rendelenmiş'),
    (v_recipe_id, 'Soğan', 1, 'adet', 'doğranmış'),
    (v_recipe_id, 'Tereyağı', 2, 'yemek kaşığı', NULL),
    (v_recipe_id, 'Un', 1, 'yemek kaşığı', NULL),
    (v_recipe_id, 'Su', 6, 'su bardağı', NULL),
    (v_recipe_id, 'Tuz', 1, 'tatlı kaşığı', 'veya tad'),
    (v_recipe_id, 'Karabiber', 0.5, 'tatlı kaşığı', NULL),
    (v_recipe_id, 'Limon suyu', 1, 'yemek kaşığı', 'isteğe bağlı');

  -- Steps
  INSERT INTO recipe_steps (recipe_id, step_number, instruction, duration_minutes, tip) VALUES
    (v_recipe_id, 1, 'Mercimek, havuç ve soğanı tencereye alın. Üzerine suyu ekleyin.', 5, 'Mercimeği önceden yıkayıp süzmek önemli'),
    (v_recipe_id, 2, 'Orta ateşte yaklaşık 25 dakika, mercimekler yumuşayana kadar pişirin.', 25, 'Pişerken ara sıra karıştırın'),
    (v_recipe_id, 3, 'Blender veya çubuk blender ile çorbayı püre haline getirin.', 3, NULL),
    (v_recipe_id, 4, 'Ayrı bir tavada tereyağını eritin, unu ekleyip kavurun.', 3, 'Unu yakmamaya dikkat edin'),
    (v_recipe_id, 5, 'Un karışımını çorbaya ekleyin, tuz ve karabiber ile tatlandırın.', 5, NULL),
    (v_recipe_id, 6, '5 dakika daha kaynatıp servis edin. Üzerine limon sıkabilirsiniz.', 2, 'Sıcak servis yapın');
END $$;

-- Recipe 2: Kuru Fasulye (Ana Yemek - Free)
INSERT INTO recipes (
  id, name, description, category, difficulty, prep_time_minutes, cook_time_minutes,
  servings, is_premium, calories_per_serving, protein_grams, carbs_grams, fat_grams,
  fiber_grams, sugar_grams, sodium_mg, tags, created_at
) VALUES (
  uuid_generate_v4(),
  'Kuru Fasulye',
  'Pilav ve turşu ile servis edilen geleneksel Türk kuru fasulye yemeği.',
  'Ana Yemek',
  'orta',
  15,
  90,
  6,
  false,
  320,
  15,
  45,
  8,
  12,
  5,
  920,
  ARRAY['protein', 'geleneksel', 'ekonomik', 'lif açısından zengin'],
  now()
);

-- Recipe 3: Menemen (Kahvaltılık - Free)
INSERT INTO recipes (
  id, name, description, category, difficulty, prep_time_minutes, cook_time_minutes,
  servings, is_premium, calories_per_serving, protein_grams, carbs_grams, fat_grams,
  fiber_grams, sugar_grams, sodium_mg, tags, created_at
) VALUES (
  uuid_generate_v4(),
  'Menemen',
  'Domates, biber ve yumurtadan oluşan klasik Türk kahvaltı yemeği.',
  'Kahvaltılık',
  'kolay',
  10,
  15,
  4,
  false,
  245,
  12,
  8,
  18,
  3,
  5,
  450,
  ARRAY['kahvaltı', 'hızlı', 'protein', 'vejetaryen'],
  now()
);

DO $$
DECLARE
  v_recipe_id UUID;
BEGIN
  SELECT id INTO v_recipe_id FROM recipes WHERE name = 'Menemen' LIMIT 1;

  INSERT INTO recipe_ingredients (recipe_id, name, amount, unit, notes) VALUES
    (v_recipe_id, 'Yumurta', 4, 'adet', NULL),
    (v_recipe_id, 'Domates', 3, 'adet', 'doğranmış'),
    (v_recipe_id, 'Yeşil biber', 2, 'adet', 'doğranmış'),
    (v_recipe_id, 'Soğan', 1, 'adet', 'ince doğranmış'),
    (v_recipe_id, 'Zeytinyağı', 3, 'yemek kaşığı', NULL),
    (v_recipe_id, 'Tuz', 1, 'tatlı kaşığı', NULL),
    (v_recipe_id, 'Karabiber', 0.5, 'tatlı kaşığı', NULL),
    (v_recipe_id, 'Pul biber', 0.5, 'tatlı kaşığı', 'isteğe bağlı');

  INSERT INTO recipe_steps (recipe_id, step_number, instruction, duration_minutes) VALUES
    (v_recipe_id, 1, 'Tavada zeytinyağını ısıtın, soğanları pembeleşene kadar kavurun.', 3),
    (v_recipe_id, 2, 'Biberleri ekleyip 2 dakika daha kavurun.', 2),
    (v_recipe_id, 3, 'Domatesleri ekleyin, yumuşayana kadar pişirin.', 5),
    (v_recipe_id, 4, 'Yumurtaları kırıp tavaya ekleyin, karıştırın.', 3),
    (v_recipe_id, 5, 'Tuz, karabiber ekleyip yumurtalar pişene kadar karıştırın.', 3),
    (v_recipe_id, 6, 'Sıcak olarak servis edin.', 1);
END $$;

-- Recipe 4: Kısır (Salata - Free)
INSERT INTO recipes (
  id, name, description, category, difficulty, prep_time_minutes, cook_time_minutes,
  servings, is_premium, calories_per_serving, protein_grams, carbs_grams, fat_grams,
  fiber_grams, sugar_grams, sodium_mg, tags, created_at
) VALUES (
  uuid_generate_v4(),
  'Kısır',
  'Bulgur, domates, salatalık ve baharatlarla hazırlanan ferahlatıcı Türk salatası.',
  'Salata',
  'kolay',
  20,
  10,
  8,
  false,
  165,
  5,
  28,
  5,
  6,
  3,
  420,
  ARRAY['vegan', 'vejetaryen', 'sağlıklı', 'soğuk', 'lif açısından zengin'],
  now()
);

-- Recipe 5: İmam Bayıldı (Ana Yemek - Premium)
INSERT INTO recipes (
  id, name, description, category, difficulty, prep_time_minutes, cook_time_minutes,
  servings, is_premium, calories_per_serving, protein_grams, carbs_grams, fat_grams,
  fiber_grams, sugar_grams, sodium_mg, tags, created_at
) VALUES (
  uuid_generate_v4(),
  'İmam Bayıldı',
  'Zeytinyağlı patlıcan yemeği. Osmanlı mutfağının en ünlü klasiklerinden biri.',
  'Ana Yemek',
  'zor',
  30,
  60,
  6,
  true,
  285,
  4,
  22,
  20,
  8,
  12,
  650,
  ARRAY['zeytinyağlı', 'vejetaryen', 'osmanlı', 'özel gün', 'premium'],
  now()
);

-- Recipe 6: Mantı (Ana Yemek - Premium)
INSERT INTO recipes (
  id, name, description, category, difficulty, prep_time_minutes, cook_time_minutes,
  servings, is_premium, calories_per_serving, protein_grams, carbs_grams, fat_grams,
  fiber_grams, sugar_grams, sodium_mg, tags, created_at
) VALUES (
  uuid_generate_v4(),
  'Mantı',
  'Yoğurt ve tereyağlı sos ile servis edilen geleneksel Türk mantısı.',
  'Ana Yemek',
  'zor',
  90,
  30,
  6,
  true,
  420,
  18,
  48,
  18,
  3,
  4,
  780,
  ARRAY['hamur işi', 'geleneksel', 'özel gün', 'premium'],
  now()
);

-- Recipe 7: Lahmacun (Ana Yemek - Free)
INSERT INTO recipes (
  id, name, description, category, difficulty, prep_time_minutes, cook_time_minutes,
  servings, is_premium, calories_per_serving, protein_grams, carbs_grams, fat_grams,
  fiber_grams, sugar_grams, sodium_mg, tags, created_at
) VALUES (
  uuid_generate_v4(),
  'Lahmacun',
  'İnce hamur üzerine kıymalı harç sürülerek pişirilen geleneksel Türk pidesi.',
  'Ana Yemek',
  'orta',
  30,
  40,
  8,
  false,
  285,
  14,
  35,
  10,
  2,
  3,
  620,
  ARRAY['hamur işi', 'protein', 'geleneksel'],
  now()
);

-- Recipe 8: Ezogelin Çorbası (Çorba - Free)
INSERT INTO recipes (
  id, name, description, category, difficulty, prep_time_minutes, cook_time_minutes,
  servings, is_premium, calories_per_serving, protein_grams, carbs_grams, fat_grams,
  fiber_grams, sugar_grams, sodium_mg, tags, created_at
) VALUES (
  uuid_generate_v4(),
  'Ezogelin Çorbası',
  'Kırmızı mercimek, bulgur ve baharatlarla yapılan besleyici Türk çorbası.',
  'Çorba',
  'kolay',
  10,
  35,
  6,
  false,
  195,
  8,
  32,
  4,
  7,
  3,
  890,
  ARRAY['vegan', 'vejetaryen', 'sağlıklı', 'geleneksel', 'ekonomik'],
  now()
);

-- Recipe 9: Çoban Salata (Salata - Free)
INSERT INTO recipes (
  id, name, description, category, difficulty, prep_time_minutes, cook_time_minutes,
  servings, is_premium, calories_per_serving, protein_grams, carbs_grams, fat_grams,
  fiber_grams, sugar_grams, sodium_mg, tags, created_at
) VALUES (
  uuid_generate_v4(),
  'Çoban Salata',
  'Domates, salatalık, biber ve soğandan oluşan klasik Türk salatası.',
  'Salata',
  'kolay',
  15,
  0,
  6,
  false,
  85,
  2,
  8,
  5,
  3,
  4,
  280,
  ARRAY['vegan', 'vejetaryen', 'sağlıklı', 'düşük kalorili', 'hızlı'],
  now()
);

-- Recipe 10: Baklava (Tatlı - Premium)
INSERT INTO recipes (
  id, name, description, category, difficulty, prep_time_minutes, cook_time_minutes,
  servings, is_premium, calories_per_serving, protein_grams, carbs_grams, fat_grams,
  fiber_grams, sugar_grams, sodium_mg, tags, created_at
) VALUES (
  uuid_generate_v4(),
  'Baklava',
  'Fıstık veya ceviz ile hazırlanan şerbetli geleneksel Türk tatlısı.',
  'Tatlı',
  'zor',
  60,
  45,
  20,
  true,
  385,
  6,
  48,
  20,
  2,
  32,
  180,
  ARRAY['tatlı', 'özel gün', 'geleneksel', 'şerbetli', 'premium'],
  now()
);

-- Recipe 11: Sütlaç (Tatlı - Free)
INSERT INTO recipes (
  id, name, description, category, difficulty, prep_time_minutes, cook_time_minutes,
  servings, is_premium, calories_per_serving, protein_grams, carbs_grams, fat_grams,
  fiber_grams, sugar_grams, sodium_mg, tags, created_at
) VALUES (
  uuid_generate_v4(),
  'Sütlaç',
  'Pirinç, süt ve şekerle yapılan kremsi Türk tatlısı.',
  'Tatlı',
  'kolay',
  10,
  40,
  8,
  false,
  225,
  6,
  38,
  6,
  1,
  24,
  85,
  ARRAY['tatlı', 'sütlü', 'geleneksel', 'vejetaryen'],
  now()
);

-- Recipe 12: Patlıcan Musakka (Ana Yemek - Free)
INSERT INTO recipes (
  id, name, description, category, difficulty, prep_time_minutes, cook_time_minutes,
  servings, is_premium, calories_per_serving, protein_grams, carbs_grams, fat_grams,
  fiber_grams, sugar_grams, sodium_mg, tags, created_at
) VALUES (
  uuid_generate_v4(),
  'Patlıcan Musakka',
  'Kıymalı patlıcan musakka, fırında pişirilmiş lezzetli ev yemeği.',
  'Ana Yemek',
  'orta',
  25,
  50,
  6,
  false,
  340,
  16,
  18,
  24,
  6,
  8,
  720,
  ARRAY['fırın yemeği', 'protein', 'geleneksel'],
  now()
);

-- Recipe 13: Börek (Kahvaltılık - Free)
INSERT INTO recipes (
  id, name, description, category, difficulty, prep_time_minutes, cook_time_minutes,
  servings, is_premium, calories_per_serving, protein_grams, carbs_grams, fat_grams,
  fiber_grams, sugar_grams, sodium_mg, tags, created_at
) VALUES (
  uuid_generate_v4(),
  'Su Böreği',
  'Peynirli su böreği, kahvaltı sofralarının vazgeçilmezi.',
  'Kahvaltılık',
  'orta',
  30,
  40,
  8,
  false,
  295,
  12,
  28,
  16,
  2,
  2,
  580,
  ARRAY['hamur işi', 'kahvaltı', 'peynirli', 'geleneksel'],
  now()
);

-- Recipe 14: Cacık (Meze - Free)
INSERT INTO recipes (
  id, name, description, category, difficulty, prep_time_minutes, cook_time_minutes,
  servings, is_premium, calories_per_serving, protein_grams, carbs_grams, fat_grams,
  fiber_grams, sugar_grams, sodium_mg, tags, created_at
) VALUES (
  uuid_generate_v4(),
  'Cacık',
  'Yoğurt, salatalık ve sarımsaktan oluşan serinletici meze.',
  'Meze',
  'kolay',
  10,
  0,
  6,
  false,
  65,
  4,
  6,
  3,
  1,
  4,
  320,
  ARRAY['meze', 'vejetaryen', 'sağlıklı', 'düşük kalorili', 'hızlı', 'soğuk'],
  now()
);

-- Recipe 15: Ayran (İçecek - Free)
INSERT INTO recipes (
  id, name, description, category, difficulty, prep_time_minutes, cook_time_minutes,
  servings, is_premium, calories_per_serving, protein_grams, carbs_grams, fat_grams,
  fiber_grams, sugar_grams, sodium_mg, tags, created_at
) VALUES (
  uuid_generate_v4(),
  'Ayran',
  'Yoğurt, su ve tuzdan oluşan geleneksel Türk içeceği.',
  'İçecek',
  'kolay',
  5,
  0,
  4,
  false,
  55,
  3,
  5,
  2,
  0,
  4,
  180,
  ARRAY['içecek', 'vejetaryen', 'sağlıklı', 'hızlı', 'soğuk'],
  now()
);

-- Recipe 16: Hünkar Beğendi (Ana Yemek - Premium)
INSERT INTO recipes (
  id, name, description, category, difficulty, prep_time_minutes, cook_time_minutes,
  servings, is_premium, calories_per_serving, protein_grams, carbs_grams, fat_grams,
  fiber_grams, sugar_grams, sodium_mg, tags, created_at
) VALUES (
  uuid_generate_v4(),
  'Hünkar Beğendi',
  'Kuzu haşlama ile patlıcan beğendi yemeği. Osmanlı saray mutfağından.',
  'Ana Yemek',
  'zor',
  40,
  90,
  6,
  true,
  485,
  28,
  18,
  34,
  6,
  8,
  850,
  ARRAY['osmanlı', 'özel gün', 'protein', 'premium'],
  now()
);

-- Recipe 17: Türk Kahvesi (İçecek - Free)
INSERT INTO recipes (
  id, name, description, category, difficulty, prep_time_minutes, cook_time_minutes,
  servings, is_premium, calories_per_serving, protein_grams, carbs_grams, fat_grams,
  fiber_grams, sugar_grams, sodium_mg, tags, created_at
) VALUES (
  uuid_generate_v4(),
  'Türk Kahvesi',
  'Geleneksel Türk kahvesi, cezve ile pişirilir.',
  'İçecek',
  'orta',
  5,
  10,
  2,
  false,
  35,
  0,
  4,
  0,
  0,
  3,
  5,
  ARRAY['içecek', 'geleneksel', 'kahve', 'düşük kalorili'],
  now()
);

-- Recipe 18: Pide (Ana Yemek - Free)
INSERT INTO recipes (
  id, name, description, category, difficulty, prep_time_minutes, cook_time_minutes,
  servings, is_premium, calories_per_serving, protein_grams, carbs_grams, fat_grams,
  fiber_grams, sugar_grams, sodium_mg, tags, created_at
) VALUES (
  uuid_generate_v4(),
  'Kıymalı Pide',
  'Kıymalı kapalı pide, hamur işi severler için ideal.',
  'Ana Yemek',
  'orta',
  30,
  35,
  6,
  false,
  380,
  18,
  42,
  16,
  3,
  3,
  680,
  ARRAY['hamur işi', 'protein', 'geleneksel'],
  now()
);

-- Recipe 19: Revani (Tatlı - Free)
INSERT INTO recipes (
  id, name, description, category, difficulty, prep_time_minutes, cook_time_minutes,
  servings, is_premium, calories_per_serving, protein_grams, carbs_grams, fat_grams,
  fiber_grams, sugar_grams, sodium_mg, tags, created_at
) VALUES (
  uuid_generate_v4(),
  'Revani',
  'İrmikli şerbetli tatlı, kolay ve lezzetli.',
  'Tatlı',
  'kolay',
  15,
  40,
  12,
  false,
  320,
  5,
  52,
  12,
  1,
  36,
  95,
  ARRAY['tatlı', 'şerbetli', 'geleneksel', 'vejetaryen'],
  now()
);

-- Recipe 20: Şakşuka (Meze - Free)
INSERT INTO recipes (
  id, name, description, category, difficulty, prep_time_minutes, cook_time_minutes,
  servings, is_premium, calories_per_serving, protein_grams, carbs_grams, fat_grams,
  fiber_grams, sugar_grams, sodium_mg, tags, created_at
) VALUES (
  uuid_generate_v4(),
  'Şakşuka',
  'Kızartılmış patlıcan ve biberle yapılan yoğurtlu meze.',
  'Meze',
  'kolay',
  15,
  20,
  6,
  false,
  145,
  4,
  12,
  10,
  4,
  6,
  420,
  ARRAY['meze', 'vejetaryen', 'zeytinyağlı'],
  now()
);

-- Recipe 21: İçli Köfte (Ana Yemek - Premium)
INSERT INTO recipes (
  id, name, description, category, difficulty, prep_time_minutes, cook_time_minutes,
  servings, is_premium, calories_per_serving, protein_grams, carbs_grams, fat_grams,
  fiber_grams, sugar_grams, sodium_mg, tags, created_at
) VALUES (
  uuid_generate_v4(),
  'İçli Köfte',
  'Bulgur ve içinde kıymalı harç olan geleneksel Türk köftesi.',
  'Ana Yemek',
  'zor',
  60,
  30,
  8,
  true,
  310,
  16,
  32,
  14,
  5,
  2,
  620,
  ARRAY['protein', 'özel gün', 'geleneksel', 'premium'],
  now()
);

-- Recipe 22: Şekerpare (Tatlı - Free)
INSERT INTO recipes (
  id, name, description, category, difficulty, prep_time_minutes, cook_time_minutes,
  servings, is_premium, calories_per_serving, protein_grams, carbs_grams, fat_grams,
  fiber_grams, sugar_grams, sodium_mg, tags, created_at
) VALUES (
  uuid_generate_v4(),
  'Şekerpare',
  'Fındık veya badem ile süslenmiş şerbetli irmik tatlısı.',
  'Tatlı',
  'orta',
  20,
  35,
  15,
  false,
  285,
  4,
  42,
  12,
  1,
  28,
  75,
  ARRAY['tatlı', 'şerbetli', 'geleneksel', 'vejetaryen'],
  now()
);

-- Recipe 23: Çiğ Köfte (Meze - Free)
INSERT INTO recipes (
  id, name, description, category, difficulty, prep_time_minutes, cook_time_minutes,
  servings, is_premium, calories_per_serving, protein_grams, carbs_grams, fat_grams,
  fiber_grams, sugar_grams, sodium_mg, tags, created_at
) VALUES (
  uuid_generate_v4(),
  'Çiğ Köfte (Vegan)',
  'Bulgurlu çiğ köfte, acı ve baharatlı lezzetli meze.',
  'Meze',
  'orta',
  45,
  0,
  10,
  false,
  155,
  5,
  28,
  4,
  7,
  3,
  680,
  ARRAY['vegan', 'vejetaryen', 'meze', 'acılı', 'geleneksel'],
  now()
);

-- Recipe 24: Tarhana Çorbası (Çorba - Free)
INSERT INTO recipes (
  id, name, description, category, difficulty, prep_time_minutes, cook_time_minutes,
  servings, is_premium, calories_per_serving, protein_grams, carbs_grams, fat_grams,
  fiber_grams, sugar_grams, sodium_mg, tags, created_at
) VALUES (
  uuid_generate_v4(),
  'Tarhana Çorbası',
  'Fermente tarhana ile yapılan geleneksel kış çorbası.',
  'Çorba',
  'kolay',
  5,
  20,
  6,
  false,
  135,
  6,
  22,
  3,
  4,
  4,
  820,
  ARRAY['geleneksel', 'sağlıklı', 'kış', 'ekonomik'],
  now()
);

-- Recipe 25: Gözleme (Kahvaltılık - Free)
INSERT INTO recipes (
  id, name, description, category, difficulty, prep_time_minutes, cook_time_minutes,
  servings, is_premium, calories_per_serving, protein_grams, carbs_grams, fat_grams,
  fiber_grams, sugar_grams, sodium_mg, tags, created_at
) VALUES (
  uuid_generate_v4(),
  'Peynirli Gözleme',
  'İnce hamura peynir konularak tavada pişirilen geleneksel kahvaltılık.',
  'Kahvaltılık',
  'orta',
  25,
  30,
  6,
  false,
  265,
  11,
  32,
  11,
  2,
  2,
  520,
  ARRAY['hamur işi', 'kahvaltı', 'peynirli', 'geleneksel'],
  now()
);

-- ==================== VERIFY DATA ====================
-- Check total recipes created
SELECT
  category,
  COUNT(*) as recipe_count,
  SUM(CASE WHEN is_premium THEN 1 ELSE 0 END) as premium_count,
  SUM(CASE WHEN NOT is_premium THEN 1 ELSE 0 END) as free_count
FROM recipes
GROUP BY category
ORDER BY category;

-- Show summary
SELECT
  'Total Recipes' as metric,
  COUNT(*)::TEXT as value
FROM recipes
UNION ALL
SELECT
  'Premium Recipes',
  COUNT(*)::TEXT
FROM recipes WHERE is_premium = true
UNION ALL
SELECT
  'Free Recipes',
  COUNT(*)::TEXT
FROM recipes WHERE is_premium = false;
