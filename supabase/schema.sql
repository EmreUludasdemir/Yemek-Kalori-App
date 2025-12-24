-- ==========================================
-- TÜRKKALORİ SUPABASE DATABASE SCHEMA
-- ==========================================

-- ==========================================
-- KULLANICI TABLOLARI
-- ==========================================

-- Kullanıcı profilleri
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username VARCHAR(30) UNIQUE NOT NULL,
    full_name VARCHAR(100),
    avatar_url TEXT,
    bio VARCHAR(300),
    daily_calorie_goal INTEGER DEFAULT 2000,
    daily_protein_goal INTEGER DEFAULT 50,
    daily_carbs_goal INTEGER DEFAULT 250,
    daily_fat_goal INTEGER DEFAULT 65,
    daily_water_goal INTEGER DEFAULT 8, -- bardak sayısı
    height_cm INTEGER,
    weight_kg DECIMAL(5,2),
    birth_date DATE,
    gender VARCHAR(10), -- 'male', 'female', 'other'
    activity_level VARCHAR(20), -- 'sedentary', 'light', 'moderate', 'active', 'very_active'
    is_public BOOLEAN DEFAULT true,
    followers_count INTEGER DEFAULT 0,
    following_count INTEGER DEFAULT 0,
    posts_count INTEGER DEFAULT 0,
    streak_days INTEGER DEFAULT 0,
    last_log_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Takip sistemi
CREATE TABLE follows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    follower_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    following_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(follower_id, following_id),
    CHECK (follower_id != following_id)
);

-- ==========================================
-- YEMEK VE BESİN TAKİBİ
-- ==========================================

-- Yemek veritabanı (özel Türk yemekleri dahil)
CREATE TABLE foods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_tr VARCHAR(200) NOT NULL,
    name_en VARCHAR(200),
    brand VARCHAR(100),
    barcode VARCHAR(50),
    serving_size DECIMAL(10,2) NOT NULL,
    serving_unit VARCHAR(20) NOT NULL, -- 'gram', 'ml', 'adet', 'porsiyon', 'dilim'
    calories DECIMAL(10,2) NOT NULL,
    protein DECIMAL(10,2) DEFAULT 0,
    carbohydrates DECIMAL(10,2) DEFAULT 0,
    fat DECIMAL(10,2) DEFAULT 0,
    fiber DECIMAL(10,2) DEFAULT 0,
    sugar DECIMAL(10,2) DEFAULT 0,
    sodium DECIMAL(10,2) DEFAULT 0,
    saturated_fat DECIMAL(10,2) DEFAULT 0,
    cholesterol DECIMAL(10,2) DEFAULT 0,
    category VARCHAR(50), -- 'ana_yemek', 'corba', 'salata', 'tatli', 'icecek', 'meze', 'kahvalti'
    source VARCHAR(20), -- 'turkomp', 'fatsecret', 'openfoodfacts', 'user'
    is_verified BOOLEAN DEFAULT false,
    created_by UUID REFERENCES profiles(id),
    image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Kullanıcı yemek logları
CREATE TABLE food_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    food_id UUID REFERENCES foods(id),
    custom_food_name VARCHAR(200), -- food_id null ise kullanılır
    meal_type VARCHAR(20) NOT NULL, -- 'kahvalti', 'ogle', 'aksam', 'ara_ogun'
    serving_count DECIMAL(5,2) DEFAULT 1,
    calories DECIMAL(10,2) NOT NULL,
    protein DECIMAL(10,2) DEFAULT 0,
    carbohydrates DECIMAL(10,2) DEFAULT 0,
    fat DECIMAL(10,2) DEFAULT 0,
    image_url TEXT,
    ai_recognized BOOLEAN DEFAULT false,
    ai_confidence DECIMAL(5,2),
    notes TEXT,
    logged_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tarif malzemeleri
CREATE TABLE recipe_ingredients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    food_id UUID REFERENCES foods(id) ON DELETE CASCADE,
    ingredient_food_id UUID REFERENCES foods(id),
    ingredient_name VARCHAR(200),
    quantity DECIMAL(10,2) NOT NULL,
    unit VARCHAR(20) NOT NULL
);

-- Su takibi
CREATE TABLE water_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    glasses INTEGER DEFAULT 1,
    logged_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- SOSYAL ÖZELLİKLER
-- ==========================================

-- Paylaşımlar
CREATE TABLE posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    food_log_id UUID REFERENCES food_logs(id) ON DELETE SET NULL,
    content TEXT,
    image_url TEXT,
    likes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    is_public BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Beğeniler
CREATE TABLE likes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, post_id)
);

-- Yorumlar
CREATE TABLE comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
    parent_comment_id UUID REFERENCES comments(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    likes_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Yorum beğenileri
CREATE TABLE comment_likes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    comment_id UUID REFERENCES comments(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, comment_id)
);

-- ==========================================
-- BİLDİRİMLER
-- ==========================================

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    actor_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    type VARCHAR(30) NOT NULL, -- 'like', 'comment', 'follow', 'mention', 'achievement'
    target_type VARCHAR(20), -- 'post', 'comment', 'profile'
    target_id UUID,
    message TEXT,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- BAŞARIMLAR VE GAMİFİCATION
-- ==========================================

CREATE TABLE achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_tr VARCHAR(100) NOT NULL,
    name_en VARCHAR(100),
    description_tr TEXT,
    description_en TEXT,
    icon_url TEXT,
    condition_type VARCHAR(30), -- 'streak', 'total_logs', 'followers', 'weight_goal'
    condition_value INTEGER,
    xp_reward INTEGER DEFAULT 0
);

CREATE TABLE user_achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    achievement_id UUID REFERENCES achievements(id) ON DELETE CASCADE,
    earned_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, achievement_id)
);

-- ==========================================
-- İNDEXLER - Performance Optimization
-- ==========================================

CREATE INDEX idx_food_logs_user_date ON food_logs(user_id, logged_at DESC);
CREATE INDEX idx_food_logs_meal_type ON food_logs(user_id, meal_type, logged_at);
CREATE INDEX idx_posts_user ON posts(user_id, created_at DESC);
CREATE INDEX idx_posts_created ON posts(created_at DESC) WHERE is_public = true;
CREATE INDEX idx_follows_follower ON follows(follower_id);
CREATE INDEX idx_follows_following ON follows(following_id);
CREATE INDEX idx_likes_post ON likes(post_id);
CREATE INDEX idx_comments_post ON comments(post_id, created_at);
CREATE INDEX idx_notifications_user ON notifications(user_id, is_read, created_at DESC);
CREATE INDEX idx_foods_name ON foods USING gin(to_tsvector('turkish', name_tr));
CREATE INDEX idx_foods_barcode ON foods(barcode) WHERE barcode IS NOT NULL;

-- ==========================================
-- ROW LEVEL SECURITY (RLS)
-- ==========================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE food_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE water_logs ENABLE ROW LEVEL SECURITY;

-- Profil politikaları
CREATE POLICY "Public profiles are viewable by everyone" ON profiles
    FOR SELECT USING (is_public = true);

CREATE POLICY "Users can view own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Food log politikaları
CREATE POLICY "Users can view own food logs" ON food_logs
    FOR ALL USING (auth.uid() = user_id);

-- Post politikaları
CREATE POLICY "Public posts are viewable" ON posts
    FOR SELECT USING (is_public = true);

CREATE POLICY "Users can manage own posts" ON posts
    FOR ALL USING (auth.uid() = user_id);

-- Like politikaları
CREATE POLICY "Anyone can view likes" ON likes
    FOR SELECT USING (true);

CREATE POLICY "Users can manage own likes" ON likes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own likes" ON likes
    FOR DELETE USING (auth.uid() = user_id);

-- Comment politikaları
CREATE POLICY "Anyone can view comments" ON comments
    FOR SELECT USING (true);

CREATE POLICY "Users can create comments" ON comments
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own comments" ON comments
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own comments" ON comments
    FOR DELETE USING (auth.uid() = user_id);

-- Follow politikaları
CREATE POLICY "Anyone can view follows" ON follows
    FOR SELECT USING (true);

CREATE POLICY "Users can manage own follows" ON follows
    FOR INSERT WITH CHECK (auth.uid() = follower_id);

CREATE POLICY "Users can delete own follows" ON follows
    FOR DELETE USING (auth.uid() = follower_id);

-- Notification politikaları
CREATE POLICY "Users can view own notifications" ON notifications
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications" ON notifications
    FOR UPDATE USING (auth.uid() = user_id);

-- Water log politikaları
CREATE POLICY "Users can manage own water logs" ON water_logs
    FOR ALL USING (auth.uid() = user_id);

-- ==========================================
-- TRİGGERLAR VE FONKSİYONLAR
-- ==========================================

-- updated_at otomatik güncelleme
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_posts_updated_at
    BEFORE UPDATE ON posts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_foods_updated_at
    BEFORE UPDATE ON foods
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- Takipçi sayısını güncelle
CREATE OR REPLACE FUNCTION update_follow_counts()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE profiles SET followers_count = followers_count + 1 WHERE id = NEW.following_id;
        UPDATE profiles SET following_count = following_count + 1 WHERE id = NEW.follower_id;

        -- Bildirim oluştur
        INSERT INTO notifications (user_id, actor_id, type, target_type, target_id)
        VALUES (NEW.following_id, NEW.follower_id, 'follow', 'profile', NEW.follower_id);
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE profiles SET followers_count = GREATEST(0, followers_count - 1) WHERE id = OLD.following_id;
        UPDATE profiles SET following_count = GREATEST(0, following_count - 1) WHERE id = OLD.follower_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_follow_change
AFTER INSERT OR DELETE ON follows
FOR EACH ROW EXECUTE FUNCTION update_follow_counts();

-- Beğeni sayısını güncelle
CREATE OR REPLACE FUNCTION update_like_counts()
RETURNS TRIGGER AS $$
DECLARE
    post_owner_id UUID;
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE posts SET likes_count = likes_count + 1 WHERE id = NEW.post_id;

        -- Post sahibini bul ve bildirim oluştur
        SELECT user_id INTO post_owner_id FROM posts WHERE id = NEW.post_id;
        IF post_owner_id != NEW.user_id THEN
            INSERT INTO notifications (user_id, actor_id, type, target_type, target_id)
            VALUES (post_owner_id, NEW.user_id, 'like', 'post', NEW.post_id);
        END IF;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE posts SET likes_count = GREATEST(0, likes_count - 1) WHERE id = OLD.post_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_like_change
AFTER INSERT OR DELETE ON likes
FOR EACH ROW EXECUTE FUNCTION update_like_counts();

-- Yorum sayısını güncelle
CREATE OR REPLACE FUNCTION update_comment_counts()
RETURNS TRIGGER AS $$
DECLARE
    post_owner_id UUID;
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE posts SET comments_count = comments_count + 1 WHERE id = NEW.post_id;

        -- Post sahibini bul ve bildirim oluştur
        SELECT user_id INTO post_owner_id FROM posts WHERE id = NEW.post_id;
        IF post_owner_id != NEW.user_id THEN
            INSERT INTO notifications (user_id, actor_id, type, target_type, target_id)
            VALUES (post_owner_id, NEW.user_id, 'comment', 'post', NEW.post_id);
        END IF;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE posts SET comments_count = GREATEST(0, comments_count - 1) WHERE id = OLD.post_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_comment_change
AFTER INSERT OR DELETE ON comments
FOR EACH ROW EXECUTE FUNCTION update_comment_counts();

-- Post sayısını güncelle
CREATE OR REPLACE FUNCTION update_post_counts()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE profiles SET posts_count = posts_count + 1 WHERE id = NEW.user_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE profiles SET posts_count = GREATEST(0, posts_count - 1) WHERE id = OLD.user_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_post_change
AFTER INSERT OR DELETE ON posts
FOR EACH ROW EXECUTE FUNCTION update_post_counts();

-- Streak güncellemesi
CREATE OR REPLACE FUNCTION update_streak()
RETURNS TRIGGER AS $$
DECLARE
    last_date DATE;
    current_streak INTEGER;
BEGIN
    SELECT last_log_date, streak_days INTO last_date, current_streak
    FROM profiles WHERE id = NEW.user_id;

    IF last_date IS NULL OR last_date < CURRENT_DATE - INTERVAL '1 day' THEN
        -- İlk log veya streak kırıldı
        IF last_date = CURRENT_DATE - INTERVAL '1 day' THEN
            -- Dün log var, streak devam
            UPDATE profiles SET
                streak_days = current_streak + 1,
                last_log_date = CURRENT_DATE
            WHERE id = NEW.user_id;
        ELSE
            -- Streak kırıldı, sıfırla
            UPDATE profiles SET
                streak_days = 1,
                last_log_date = CURRENT_DATE
            WHERE id = NEW.user_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_food_log_streak
AFTER INSERT ON food_logs
FOR EACH ROW EXECUTE FUNCTION update_streak();

-- ==========================================
-- VİEWS - Yardımcı Görünümler
-- ==========================================

-- Günlük kalori toplamını hesapla
CREATE OR REPLACE VIEW daily_nutrition_summary AS
SELECT
    user_id,
    DATE(logged_at) as log_date,
    SUM(calories) as total_calories,
    SUM(protein) as total_protein,
    SUM(carbohydrates) as total_carbs,
    SUM(fat) as total_fat,
    COUNT(*) as meal_count
FROM food_logs
GROUP BY user_id, DATE(logged_at);

-- Haftalık istatistikler
CREATE OR REPLACE VIEW weekly_nutrition_summary AS
SELECT
    user_id,
    DATE_TRUNC('week', logged_at) as week_start,
    AVG(calories) as avg_calories,
    AVG(protein) as avg_protein,
    AVG(carbohydrates) as avg_carbs,
    AVG(fat) as avg_fat,
    COUNT(DISTINCT DATE(logged_at)) as days_logged
FROM food_logs
GROUP BY user_id, DATE_TRUNC('week', logged_at);

-- Popüler Türk yemekleri
CREATE OR REPLACE VIEW popular_turkish_foods AS
SELECT
    f.id,
    f.name_tr,
    f.calories,
    f.protein,
    f.carbohydrates,
    f.fat,
    COUNT(fl.id) as times_logged
FROM foods f
LEFT JOIN food_logs fl ON f.id = fl.food_id
WHERE f.source = 'turkomp' OR f.category IN ('ana_yemek', 'corba', 'tatli', 'kahvalti')
GROUP BY f.id, f.name_tr, f.calories, f.protein, f.carbohydrates, f.fat
ORDER BY times_logged DESC
LIMIT 100;

-- ==========================================
-- STORAGE BUCKETS
-- ==========================================

-- Bu komutlar Supabase Dashboard'da çalıştırılmalı:
-- Storage > Create new bucket

-- Avatars bucket
-- Name: avatars
-- Public: true
-- File size limit: 2MB
-- Allowed MIME types: image/jpeg, image/png, image/webp

-- Food images bucket
-- Name: food_images
-- Public: true
-- File size limit: 5MB
-- Allowed MIME types: image/jpeg, image/png, image/webp

-- Post images bucket
-- Name: post_images
-- Public: true
-- File size limit: 5MB
-- Allowed MIME types: image/jpeg, image/png, image/webp
