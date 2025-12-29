-- TürkKalori Database Initialization Script
-- Bu script Docker container'ı ilk başlatıldığında çalışır

-- Test veritabanı oluştur
CREATE DATABASE IF NOT EXISTS turkkalori_test;

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Users table (basit test için)
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Foods table (test için örnek yemekler)
CREATE TABLE IF NOT EXISTS foods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    name_en VARCHAR(255),
    category VARCHAR(100),
    calories DECIMAL(10, 2),
    protein DECIMAL(10, 2),
    carbs DECIMAL(10, 2),
    fat DECIMAL(10, 2),
    serving_size VARCHAR(50),
    is_turkish BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Food logs table
CREATE TABLE IF NOT EXISTS food_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    food_id UUID REFERENCES foods(id),
    meal_type VARCHAR(50),
    servings DECIMAL(5, 2) DEFAULT 1,
    logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

-- Test verisi ekle
INSERT INTO foods (name, name_en, category, calories, protein, carbs, fat, serving_size, is_turkish)
VALUES
    ('Mantı', 'Turkish Dumplings', 'Main Dish', 320, 14, 45, 8, '1 porsiyon (200g)', true),
    ('Menemen', 'Turkish Scrambled Eggs', 'Breakfast', 180, 12, 8, 12, '1 porsiyon (150g)', true),
    ('Kısır', 'Bulgur Salad', 'Salad', 210, 6, 35, 5, '1 kase (150g)', true),
    ('Ayran', 'Turkish Yogurt Drink', 'Beverage', 50, 3, 6, 1, '1 bardak (200ml)', true),
    ('Baklava', 'Baklava', 'Dessert', 430, 7, 52, 22, '1 dilim (100g)', true)
ON CONFLICT DO NOTHING;

-- Test kullanıcısı
INSERT INTO users (email, name)
VALUES ('test@turkkalori.com', 'Test User')
ON CONFLICT DO NOTHING;

-- Indexes
CREATE INDEX IF NOT EXISTS idx_foods_name ON foods(name);
CREATE INDEX IF NOT EXISTS idx_foods_category ON foods(category);
CREATE INDEX IF NOT EXISTS idx_food_logs_user_id ON food_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_food_logs_logged_at ON food_logs(logged_at);

-- Grant permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO postgres;

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'TürkKalori database initialized successfully!';
END $$;
