-- ==========================================
-- TÜRK YEMEKLERİ SEED DATA
-- ==========================================
-- Bu dosya Supabase SQL Editor'de çalıştırılarak
-- veritabanına popüler Türk yemeklerini ekler.

-- ==========================================
-- KAHVALTILIK ÜRÜNLER
-- ==========================================

INSERT INTO foods (name_tr, name_en, serving_size, serving_unit, calories, protein, carbohydrates, fat, category, source, is_verified)
VALUES
    ('Menemen', 'Turkish Scrambled Eggs', 200, 'porsiyon', 250, 12, 8, 18, 'kahvalti', 'turkomp', true),
    ('Sucuklu Yumurta', 'Eggs with Turkish Sausage', 150, 'porsiyon', 380, 22, 2, 31, 'kahvalti', 'turkomp', true),
    ('Simit', 'Turkish Sesame Bagel', 100, 'adet', 280, 9, 52, 4, 'kahvalti', 'turkomp', true),
    ('Peynirli Börek', 'Cheese Pastry', 100, 'dilim', 290, 9, 28, 16, 'kahvalti', 'turkomp', true),
    ('Gözleme (Peynirli)', 'Turkish Flatbread with Cheese', 150, 'porsiyon', 320, 14, 38, 12, 'kahvalti', 'turkomp', true),
    ('Poğaça', 'Turkish Pastry', 80, 'adet', 250, 7, 32, 11, 'kahvalti', 'turkomp', true),
    ('Açma', 'Turkish Soft Roll', 100, 'adet', 310, 8, 48, 9, 'kahvalti', 'turkomp', true),
    ('Bal Kaymak', 'Honey and Clotted Cream', 50, 'porsiyon', 180, 2, 18, 12, 'kahvalti', 'turkomp', true);

-- ==========================================
-- ANA YEMEKLER - KEBAPLAR
-- ==========================================

INSERT INTO foods (name_tr, name_en, serving_size, serving_unit, calories, protein, carbohydrates, fat, category, source, is_verified)
VALUES
    ('Döner (Tavuk)', 'Chicken Doner', 200, 'porsiyon', 350, 32, 28, 12, 'ana_yemek', 'turkomp', true),
    ('Döner (Et)', 'Beef Doner', 200, 'porsiyon', 450, 28, 35, 22, 'ana_yemek', 'turkomp', true),
    ('İskender Kebap', 'Iskender Kebab', 350, 'porsiyon', 650, 45, 35, 38, 'ana_yemek', 'turkomp', true),
    ('Adana Kebap', 'Adana Kebab', 200, 'porsiyon', 380, 32, 4, 26, 'ana_yemek', 'turkomp', true),
    ('Urfa Kebap', 'Urfa Kebab', 200, 'porsiyon', 360, 30, 5, 24, 'ana_yemek', 'turkomp', true),
    ('Tavuk Şiş', 'Chicken Shish', 150, 'porsiyon', 220, 28, 2, 11, 'ana_yemek', 'turkomp', true),
    ('Et Şiş', 'Beef Shish', 150, 'porsiyon', 280, 26, 2, 18, 'ana_yemek', 'turkomp', true),
    ('Izgara Köfte', 'Grilled Meatballs', 150, 'porsiyon', 350, 28, 5, 24, 'ana_yemek', 'turkomp', true),
    ('İnegöl Köfte', 'Inegol Meatballs', 150, 'porsiyon', 320, 26, 8, 20, 'ana_yemek', 'turkomp', true),
    ('Çöp Şiş', 'Small Skewers', 150, 'porsiyon', 310, 25, 3, 22, 'ana_yemek', 'turkomp', true);

-- ==========================================
-- ANA YEMEKLER - PİDE VE LAHMACUN
-- ==========================================

INSERT INTO foods (name_tr, name_en, serving_size, serving_unit, calories, protein, carbohydrates, fat, category, source, is_verified)
VALUES
    ('Lahmacun', 'Turkish Flatbread Pizza', 120, 'adet', 270, 12, 38, 8, 'ana_yemek', 'turkomp', true),
    ('Kıymalı Pide', 'Ground Meat Pide', 200, 'dilim', 380, 18, 42, 16, 'ana_yemek', 'turkomp', true),
    ('Kaşarlı Pide', 'Cheese Pide', 200, 'dilim', 360, 16, 40, 14, 'ana_yemek', 'turkomp', true),
    ('Karışık Pide', 'Mixed Pide', 220, 'dilim', 420, 20, 44, 18, 'ana_yemek', 'turkomp', true),
    ('Sucuklu Pide', 'Sausage Pide', 200, 'dilim', 400, 17, 41, 19, 'ana_yemek', 'turkomp', true),
    ('Kuşbaşılı Pide', 'Diced Meat Pide', 220, 'dilim', 440, 22, 43, 20, 'ana_yemek', 'turkomp', true);

-- ==========================================
-- ANA YEMEKLER - GELENEKSEL
-- ==========================================

INSERT INTO foods (name_tr, name_en, serving_size, serving_unit, calories, protein, carbohydrates, fat, category, source, is_verified)
VALUES
    ('Mantı', 'Turkish Dumplings', 200, 'porsiyon', 420, 18, 48, 18, 'ana_yemek', 'turkomp', true),
    ('Kuru Fasulye', 'White Bean Stew', 250, 'porsiyon', 180, 10, 28, 3, 'ana_yemek', 'turkomp', true),
    ('Nohut Yemeği', 'Chickpea Stew', 250, 'porsiyon', 210, 11, 32, 4, 'ana_yemek', 'turkomp', true),
    ('İmam Bayıldı', 'Stuffed Eggplant', 200, 'porsiyon', 220, 4, 18, 15, 'ana_yemek', 'turkomp', true),
    ('Karnıyarık', 'Split Belly Eggplant', 220, 'porsiyon', 280, 14, 22, 16, 'ana_yemek', 'turkomp', true),
    ('Hünkar Beğendi', 'Sultan''s Delight', 300, 'porsiyon', 480, 26, 28, 30, 'ana_yemek', 'turkomp', true),
    ('Etli Bamya', 'Okra with Meat', 250, 'porsiyon', 260, 18, 15, 16, 'ana_yemek', 'turkomp', true),
    ('Etli Taze Fasulye', 'Green Beans with Meat', 250, 'porsiyon', 240, 16, 18, 14, 'ana_yemek', 'turkomp', true),
    ('Türlü', 'Mixed Vegetables', 250, 'porsiyon', 180, 8, 22, 8, 'ana_yemek', 'turkomp', true),
    ('Kabak Dolması', 'Stuffed Zucchini', 200, 'porsiyon', 220, 12, 20, 11, 'ana_yemek', 'turkomp', true),
    ('Biber Dolması', 'Stuffed Peppers', 200, 'porsiyon', 240, 13, 22, 12, 'ana_yemek', 'turkomp', true),
    ('Yaprak Sarma', 'Stuffed Grape Leaves', 150, 'porsiyon', 190, 8, 24, 8, 'ana_yemek', 'turkomp', true),
    ('Kumpir', 'Loaded Baked Potato', 400, 'porsiyon', 520, 18, 68, 20, 'ana_yemek', 'turkomp', true);

-- ==========================================
-- ÇORBALAR
-- ==========================================

INSERT INTO foods (name_tr, name_en, serving_size, serving_unit, calories, protein, carbohydrates, fat, category, source, is_verified)
VALUES
    ('Mercimek Çorbası', 'Red Lentil Soup', 250, 'kase', 150, 8, 22, 4, 'corba', 'turkomp', true),
    ('Ezogelin Çorbası', 'Ezogelin Soup', 250, 'kase', 130, 6, 20, 3, 'corba', 'turkomp', true),
    ('Tarhana Çorbası', 'Tarhana Soup', 250, 'kase', 120, 5, 18, 3, 'corba', 'turkomp', true),
    ('Yayla Çorbası', 'Yogurt Soup', 250, 'kase', 140, 7, 15, 6, 'corba', 'turkomp', true),
    ('İşkembe Çorbası', 'Tripe Soup', 300, 'kase', 180, 12, 8, 11, 'corba', 'turkomp', true),
    ('Tavuk Çorbası', 'Chicken Soup', 250, 'kase', 110, 9, 8, 5, 'corba', 'turkomp', true),
    ('Düğün Çorbası', 'Wedding Soup', 250, 'kase', 160, 10, 16, 7, 'corba', 'turkomp', true),
    ('Kellepaça Çorbası', 'Head and Trotters Soup', 300, 'kase', 220, 14, 6, 15, 'corba', 'turkomp', true),
    ('Paça Çorbası', 'Trotters Soup', 300, 'kase', 200, 13, 5, 14, 'corba', 'turkomp', true);

-- ==========================================
-- TATLILAR
-- ==========================================

INSERT INTO foods (name_tr, name_en, serving_size, serving_unit, calories, protein, carbohydrates, fat, category, source, is_verified)
VALUES
    ('Baklava', 'Baklava', 100, 'dilim', 280, 4, 32, 16, 'tatli', 'turkomp', true),
    ('Künefe', 'Kunefe', 150, 'porsiyon', 450, 8, 52, 24, 'tatli', 'turkomp', true),
    ('Sütlaç', 'Rice Pudding', 150, 'kase', 180, 5, 30, 5, 'tatli', 'turkomp', true),
    ('Kazandibi', 'Caramelized Milk Pudding', 150, 'kase', 200, 6, 32, 6, 'tatli', 'turkomp', true),
    ('Keşkül', 'Almond Pudding', 150, 'kase', 220, 7, 28, 9, 'tatli', 'turkomp', true),
    ('Tulumba Tatlısı', 'Fried Dough Dessert', 100, 'porsiyon', 320, 3, 42, 15, 'tatli', 'turkomp', true),
    ('Lokma', 'Sweet Fried Dough Balls', 100, 'porsiyon', 310, 4, 38, 16, 'tatli', 'turkomp', true),
    ('Revani', 'Semolina Cake', 100, 'dilim', 290, 5, 38, 13, 'tatli', 'turkomp', true),
    ('Şekerpare', 'Semolina Cookies', 80, 'adet', 240, 3, 32, 11, 'tatli', 'turkomp', true),
    ('Kabak Tatlısı', 'Pumpkin Dessert', 150, 'porsiyon', 180, 2, 38, 2, 'tatli', 'turkomp', true),
    ('Güllaç', 'Rose Water Dessert', 150, 'porsiyon', 210, 6, 36, 5, 'tatli', 'turkomp', true),
    ('Ayva Tatlısı', 'Quince Dessert', 150, 'porsiyon', 160, 1, 38, 1, 'tatli', 'turkomp', true);

-- ==========================================
-- İÇECEKLER
-- ==========================================

INSERT INTO foods (name_tr, name_en, serving_size, serving_unit, calories, protein, carbohydrates, fat, category, source, is_verified)
VALUES
    ('Ayran', 'Turkish Yogurt Drink', 200, 'ml', 66, 3, 5, 4, 'icecek', 'turkomp', true),
    ('Türk Kahvesi', 'Turkish Coffee', 50, 'ml', 5, 0, 1, 0, 'icecek', 'turkomp', true),
    ('Çay (Şekersiz)', 'Turkish Tea', 200, 'ml', 2, 0, 0, 0, 'icecek', 'turkomp', true),
    ('Çay (1 Şeker)', 'Tea with 1 Sugar', 200, 'ml', 22, 0, 5, 0, 'icecek', 'turkomp', true),
    ('Şalgam Suyu', 'Turnip Juice', 200, 'ml', 15, 0, 3, 0, 'icecek', 'turkomp', true),
    ('Boza', 'Fermented Millet Drink', 200, 'ml', 180, 2, 38, 1, 'icecek', 'turkomp', true),
    ('Sahlep', 'Salep', 200, 'ml', 140, 4, 24, 3, 'icecek', 'turkomp', true);

-- ==========================================
-- MEZELER VE SALATALAR
-- ==========================================

INSERT INTO foods (name_tr, name_en, serving_size, serving_unit, calories, protein, carbohydrates, fat, category, source, is_verified)
VALUES
    ('Humus', 'Hummus', 100, 'porsiyon', 177, 8, 14, 10, 'meze', 'turkomp', true),
    ('Haydari', 'Thick Yogurt Dip', 100, 'porsiyon', 120, 6, 4, 9, 'meze', 'turkomp', true),
    ('Çoban Salata', 'Shepherd Salad', 200, 'porsiyon', 90, 2, 8, 6, 'salata', 'turkomp', true),
    ('Patlıcan Salatası', 'Eggplant Salad', 150, 'porsiyon', 130, 2, 12, 9, 'meze', 'turkomp', true),
    ('Acuka', 'Red Pepper Spread', 100, 'porsiyon', 110, 2, 10, 7, 'meze', 'turkomp', true),
    ('Cacık', 'Yogurt Cucumber Dip', 150, 'porsiyon', 85, 5, 6, 5, 'meze', 'turkomp', true),
    ('Atom', 'Spicy Ezme', 100, 'porsiyon', 80, 2, 9, 5, 'meze', 'turkomp', true),
    ('Ezme', 'Tomato Pepper Paste', 100, 'porsiyon', 75, 2, 8, 4, 'meze', 'turkomp', true),
    ('Zeytinyağlı Enginar', 'Artichoke in Olive Oil', 150, 'porsiyon', 140, 3, 12, 9, 'meze', 'turkomp', true),
    ('Zeytinyağlı Barbunya', 'Kidney Beans in Olive Oil', 150, 'porsiyon', 160, 6, 18, 8, 'meze', 'turkomp', true);

-- ==========================================
-- PİLAV VE MAKARNALAR
-- ==========================================

INSERT INTO foods (name_tr, name_en, serving_size, serving_unit, calories, protein, carbohydrates, fat, category, source, is_verified)
VALUES
    ('Pilav (Sade)', 'Plain Rice', 150, 'porsiyon', 200, 4, 40, 3, 'ana_yemek', 'turkomp', true),
    ('Bulgur Pilavı', 'Bulgur Pilaf', 150, 'porsiyon', 180, 6, 35, 2, 'ana_yemek', 'turkomp', true),
    ('İç Pilav', 'Rice with Nuts', 200, 'porsiyon', 320, 8, 42, 14, 'ana_yemek', 'turkomp', true),
    ('Nohutlu Pilav', 'Rice with Chickpeas', 180, 'porsiyon', 240, 8, 44, 4, 'ana_yemek', 'turkomp', true),
    ('Şehriyeli Pilav', 'Rice with Vermicelli', 150, 'porsiyon', 220, 5, 42, 4, 'ana_yemek', 'turkomp', true),
    ('Erişte', 'Turkish Noodles', 150, 'porsiyon', 210, 7, 38, 4, 'ana_yemek', 'turkomp', true);

-- ==========================================
-- DİĞER POPÜLER YEMEKLER
-- ==========================================

INSERT INTO foods (name_tr, name_en, serving_size, serving_unit, calories, protein, carbohydrates, fat, category, source, is_verified)
VALUES
    ('Menemen (Sucuklu)', 'Scrambled Eggs with Sausage', 200, 'porsiyon', 320, 16, 10, 24, 'kahvalti', 'turkomp', true),
    ('Sigara Böreği', 'Cigarette Pastry', 100, 'porsiyon', 280, 8, 24, 18, 'meze', 'turkomp', true),
    ('Su Böreği', 'Water Pastry', 150, 'porsiyon', 310, 12, 32, 15, 'ana_yemek', 'turkomp', true),
    ('Çiğ Köfte', 'Raw Meatballs (Vegan)', 100, 'porsiyon', 180, 4, 28, 6, 'meze', 'turkomp', true),
    ('Balık Ekmek', 'Fish Sandwich', 200, 'adet', 380, 24, 42, 12, 'ana_yemek', 'turkomp', true),
    ('Hamsi Tava', 'Fried Anchovies', 150, 'porsiyon', 280, 22, 12, 16, 'ana_yemek', 'turkomp', true),
    ('Midye Dolma', 'Stuffed Mussels', 100, 'porsiyon', 160, 8, 18, 6, 'meze', 'turkomp', true),
    ('Kokoreç', 'Grilled Intestines', 150, 'porsiyon', 380, 18, 22, 24, 'ana_yemek', 'turkomp', true);

-- ==========================================
-- İNDEX OLUŞTUR
-- ==========================================

-- Türkçe tam metin araması için index (zaten schema.sql'de var)
-- CREATE INDEX IF NOT EXISTS idx_foods_name ON foods USING gin(to_tsvector('turkish', name_tr));

COMMIT;
