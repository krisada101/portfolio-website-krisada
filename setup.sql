-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Create Tables
-- Users/Profiles should be created by the application/auth flow, but we define the table here.
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    position TEXT,
    bio TEXT,
    about_short_description TEXT,
    about_section_body TEXT,
    teaching_philosophy TEXT,
    image_url TEXT,
    stats_years TEXT,
    stats_students TEXT,
    stats_awards TEXT,
    email TEXT,
    phone TEXT,
    address TEXT,
    facebook TEXT,
    facebook_url TEXT,
    line_id TEXT,
    line_url TEXT,
    welcome_message_1 TEXT DEFAULT 'ยินดีต้อนรับสู่ Portfolio ของครู',
    welcome_message_2 TEXT DEFAULT 'สวัสดีครับ ผม',
    hero_badge_text TEXT DEFAULT 'ครูดีเด่น',
    works_description TEXT,
    certificates_description TEXT,
    activities_description TEXT,
    pa_description TEXT,
    pa_header_title TEXT,
    pa_header_subtitle TEXT,
    pa_badge_text TEXT,
    footer_text TEXT,
    google_map_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.stats (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    label TEXT NOT NULL,
    icon_name TEXT NOT NULL,
    color_class TEXT NOT NULL,
    display_order INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.highlights (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    icon_name TEXT NOT NULL,
    color_class TEXT NOT NULL,
    bg_class TEXT NOT NULL,
    display_order INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.works (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    category TEXT NOT NULL,
    description TEXT NOT NULL,
    icon_name TEXT NOT NULL,
    color_class TEXT NOT NULL,
    views INTEGER DEFAULT 0,
    is_featured BOOLEAN DEFAULT false,
    display_order INTEGER,
    file_url TEXT,
    file_type TEXT,
    external_links JSONB DEFAULT '[]'::jsonb,
    images TEXT[] DEFAULT '{}'::text[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.activities (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    date_display TEXT NOT NULL,
    location TEXT NOT NULL,
    participants INTEGER,
    description TEXT NOT NULL,
    image_emoji TEXT,
    color_gradient_class TEXT,
    display_order INTEGER,
    file_url TEXT,
    file_type TEXT,
    external_links JSONB DEFAULT '[]'::jsonb,
    images TEXT[] DEFAULT '{}'::text[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.certificates (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    issuer TEXT NOT NULL,
    year TEXT NOT NULL,
    type TEXT NOT NULL,
    icon_name TEXT NOT NULL,
    color_class TEXT NOT NULL,
    bg_class TEXT NOT NULL,
    display_order INTEGER,
    file_url TEXT,
    file_type TEXT,
    external_links JSONB DEFAULT '[]'::jsonb,
    images TEXT[] DEFAULT '{}'::text[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.pa_categories (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    category_number INTEGER NOT NULL,
    title TEXT NOT NULL,
    icon TEXT NOT NULL,
    color TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.pa_indicators (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    category_id UUID REFERENCES public.pa_categories(id) ON DELETE CASCADE,
    indicator_number TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.pa_works (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    indicator_id UUID REFERENCES public.pa_indicators(id) ON DELETE CASCADE,
    work_type TEXT NOT NULL,
    title TEXT NOT NULL,
    url TEXT,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.pa_indicator_images (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    indicator_id UUID REFERENCES public.pa_indicators(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    caption TEXT,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Add Unique Constraints safely (for idempotent seed data)
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'pa_categories_number_key') THEN 
        ALTER TABLE pa_categories ADD CONSTRAINT pa_categories_number_key UNIQUE (category_number); 
    END IF; 
    -- We don't force unique on indicators because numbers might repeat across categories if schema changes, 
    -- but for seed data we will assume unique combination or just handle by number check in INSERT.
END $$;

-- 3. Row Level Security (RLS)

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE highlights ENABLE ROW LEVEL SECURITY;
ALTER TABLE works ENABLE ROW LEVEL SECURITY;
ALTER TABLE activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;
ALTER TABLE pa_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE pa_indicators ENABLE ROW LEVEL SECURITY;
ALTER TABLE pa_works ENABLE ROW LEVEL SECURITY;
ALTER TABLE pa_indicator_images ENABLE ROW LEVEL SECURITY;

-- Public Access Policies (Everyone can read)
CREATE POLICY "Public profiles are viewable by everyone" ON profiles FOR SELECT USING (true);
CREATE POLICY "Public stats are viewable by everyone" ON stats FOR SELECT USING (true);
CREATE POLICY "Public highlights are viewable by everyone" ON highlights FOR SELECT USING (true);
CREATE POLICY "Public works are viewable by everyone" ON works FOR SELECT USING (true);
CREATE POLICY "Public activities are viewable by everyone" ON activities FOR SELECT USING (true);
CREATE POLICY "Public certificates are viewable by everyone" ON certificates FOR SELECT USING (true);
CREATE POLICY "Public pa_categories are viewable by everyone" ON pa_categories FOR SELECT USING (true);
CREATE POLICY "Public pa_indicators are viewable by everyone" ON pa_indicators FOR SELECT USING (true);
CREATE POLICY "Public pa_works are viewable by everyone" ON pa_works FOR SELECT USING (true);
CREATE POLICY "Public pa_indicator_images are viewable by everyone" ON pa_indicator_images FOR SELECT USING (true);

-- Authenticated Access Policies (Only logged in users can modify)
CREATE POLICY "Users can insert profiles" ON profiles FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Users can update profiles" ON profiles FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Users can delete profiles" ON profiles FOR DELETE USING (auth.role() = 'authenticated');

CREATE POLICY "Users can modify stats" ON stats FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Users can modify highlights" ON highlights FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Users can modify works" ON works FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Users can modify activities" ON activities FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Users can modify certificates" ON certificates FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Users can modify pa_categories" ON pa_categories FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Users can modify pa_indicators" ON pa_indicators FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Users can modify pa_works" ON pa_works FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Users can modify pa_indicator_images" ON pa_indicator_images FOR ALL USING (auth.role() = 'authenticated');

-- 4. Storage Buckets

-- Helper function to creating buckets safely
INSERT INTO storage.buckets (id, name, public) 
VALUES 
  ('profile', 'profile', true),
  ('works', 'works', true),
  ('activities', 'activities', true),
  ('certificates', 'certificates', true),
  ('pa-images', 'pa-images', true)
ON CONFLICT (id) DO NOTHING;

-- Storage Policies (Public Read, Authenticated Write)
CREATE POLICY "Public Access Profile" ON storage.objects FOR SELECT USING (bucket_id = 'profile');
CREATE POLICY "Auth Upload Profile" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'profile' AND auth.role() = 'authenticated');
CREATE POLICY "Auth Delete Profile" ON storage.objects FOR DELETE USING (bucket_id = 'profile' AND auth.role() = 'authenticated');

CREATE POLICY "Public Access Works" ON storage.objects FOR SELECT USING (bucket_id = 'works');
CREATE POLICY "Auth Upload Works" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'works' AND auth.role() = 'authenticated');
CREATE POLICY "Auth Delete Works" ON storage.objects FOR DELETE USING (bucket_id = 'works' AND auth.role() = 'authenticated');

CREATE POLICY "Public Access Activities" ON storage.objects FOR SELECT USING (bucket_id = 'activities');
CREATE POLICY "Auth Upload Activities" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'activities' AND auth.role() = 'authenticated');
CREATE POLICY "Auth Delete Activities" ON storage.objects FOR DELETE USING (bucket_id = 'activities' AND auth.role() = 'authenticated');

CREATE POLICY "Public Access Certificates" ON storage.objects FOR SELECT USING (bucket_id = 'certificates');
CREATE POLICY "Auth Upload Certificates" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'certificates' AND auth.role() = 'authenticated');
CREATE POLICY "Auth Delete Certificates" ON storage.objects FOR DELETE USING (bucket_id = 'certificates' AND auth.role() = 'authenticated');

CREATE POLICY "Public Access PA" ON storage.objects FOR SELECT USING (bucket_id = 'pa-images');
CREATE POLICY "Auth Upload PA" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'pa-images' AND auth.role() = 'authenticated');
CREATE POLICY "Auth Delete PA" ON storage.objects FOR DELETE USING (bucket_id = 'pa-images' AND auth.role() = 'authenticated');

-- 5. SEED DATA (Standard Data Population)

-- 5.1 PA Categories (Standard 3 Domains)
INSERT INTO public.pa_categories (category_number, title, icon, color)
VALUES
  (1, 'ด้านการจัดการเรียนรู้', 'BookOpen', 'from-blue-600 to-cyan-500'),
  (2, 'ด้านการส่งเสริมและสนับสนุนการจัดการเรียนรู้', 'Users', 'from-emerald-500 to-teal-400'),
  (3, 'ด้านการพัฒนาตนเองและวิชาชีพ', 'TrendingUp', 'from-purple-600 to-pink-500')
ON CONFLICT (category_number) DO NOTHING;

-- 5.2 PA Indicators (Standard 15 Indicators for ว9/2564)
-- We use a CTE or variables, but for plain SQL we can use subqueries.

-- Category 1: Learning Management
INSERT INTO public.pa_indicators (category_id, indicator_number, name, description)
SELECT id, '1.1', 'สร้างและหรือพัฒนาหลักสูตร', 'การจัดทำรายวิชาและหน่วยการเรียนรู้ให้สอดคล้องกับมาตรฐานการเรียนรู้ และตัวชี้วัดหรือผลการเรียนรู้ ตามหลักสูตร'
FROM public.pa_categories WHERE category_number = 1
AND NOT EXISTS (SELECT 1 FROM public.pa_indicators WHERE indicator_number = '1.1');

INSERT INTO public.pa_indicators (category_id, indicator_number, name, description)
SELECT id, '1.2', 'ออกแบบการจัดการเรียนรู้', 'เน้นผู้เรียนเป็นสำคัญ เพื่อให้ผู้เรียนมีความรู้ ทักษะ คุณลักษณะประจำวิชา คุณลักษณะอันพึงประสงค์ และสมรรถนะที่สำคัญ'
FROM public.pa_categories WHERE category_number = 1
AND NOT EXISTS (SELECT 1 FROM public.pa_indicators WHERE indicator_number = '1.2');

INSERT INTO public.pa_indicators (category_id, indicator_number, name, description)
SELECT id, '1.3', 'จัดกิจกรรมการเรียนรู้', 'อำนวยความสะดวกในการเรียนรู้ และส่งเสริมผู้เรียนได้พัฒนาเต็มตามศักยภาพ เรียนรู้และทำงานร่วมกัน'
FROM public.pa_categories WHERE category_number = 1
AND NOT EXISTS (SELECT 1 FROM public.pa_indicators WHERE indicator_number = '1.3');

INSERT INTO public.pa_indicators (category_id, indicator_number, name, description)
SELECT id, '1.4', 'สร้างและหรือพัฒนาสื่อ นวัตกรรม เทคโนโลยี และแหล่งเรียนรู้', 'สอดคล้องกับกิจกรรมการเรียนรู้'
FROM public.pa_categories WHERE category_number = 1
AND NOT EXISTS (SELECT 1 FROM public.pa_indicators WHERE indicator_number = '1.4');

INSERT INTO public.pa_indicators (category_id, indicator_number, name, description)
SELECT id, '1.5', 'วัดและประเมินผลการเรียนรู้', 'ประเมินผลการเรียนรู้ด้วยวิธีการที่หลากหลาย เหมาะสม และสอดคล้องกับมาตรฐานการเรียนรู้'
FROM public.pa_categories WHERE category_number = 1
AND NOT EXISTS (SELECT 1 FROM public.pa_indicators WHERE indicator_number = '1.5');

INSERT INTO public.pa_indicators (category_id, indicator_number, name, description)
SELECT id, '1.6', 'ศึกษา วิเคราะห์ และสังเคราะห์ เพื่อแก้ปัญหาหรือพัฒนาการเรียนรู้', 'ทำการศึกษา วิเคราะห์ และสังเคราะห์ เพื่อแก้ปัญหาหรือพัฒนาการเรียนรู้ที่ส่งผลต่อคุณภาพผู้เรียน'
FROM public.pa_categories WHERE category_number = 1
AND NOT EXISTS (SELECT 1 FROM public.pa_indicators WHERE indicator_number = '1.6');

INSERT INTO public.pa_indicators (category_id, indicator_number, name, description)
SELECT id, '1.7', 'จัดบรรยากาศที่ส่งเสริมและพัฒนาผู้เรียน', 'จัดบรรยากาศที่เหมาะสม สอดคล้องกับความแตกต่างผู้เรียนเป็นรายบุคคล'
FROM public.pa_categories WHERE category_number = 1
AND NOT EXISTS (SELECT 1 FROM public.pa_indicators WHERE indicator_number = '1.7');

INSERT INTO public.pa_indicators (category_id, indicator_number, name, description)
SELECT id, '1.8', 'อบรมและพัฒนาคุณลักษณะที่ดีของผู้เรียน', 'อบรมบ่มนิสัยให้ผู้เรียนมีคุณธรรม จริยธรรม คุณลักษณะอันพึงประสงค์ และค่านิยมความเป็นไทยที่ดีงาม'
FROM public.pa_categories WHERE category_number = 1
AND NOT EXISTS (SELECT 1 FROM public.pa_indicators WHERE indicator_number = '1.8');

-- Category 2: Learning Support & Support
INSERT INTO public.pa_indicators (category_id, indicator_number, name, description)
SELECT id, '2.1', 'จัดทำข้อมูลสารสนเทศของผู้เรียนและรายวิชา', 'จัดทำข้อมูลสารสนเทศของผู้เรียนและรายวิชาเพื่อใช้ในการส่งเสริมสนับสนุนการเรียนรู้'
FROM public.pa_categories WHERE category_number = 2
AND NOT EXISTS (SELECT 1 FROM public.pa_indicators WHERE indicator_number = '2.1');

INSERT INTO public.pa_indicators (category_id, indicator_number, name, description)
SELECT id, '2.2', 'ดำเนินการตามระบบดูแลช่วยเหลือผู้เรียน', 'ใช้ข้อมูลสารสนเทศเกี่ยวกับผู้เรียนรายบุคคล และประสานความร่วมมือกับผู้มีส่วนเกี่ยวข้องเพื่อพัฒนาและแก้ปัญหาผู้เรียน'
FROM public.pa_categories WHERE category_number = 2
AND NOT EXISTS (SELECT 1 FROM public.pa_indicators WHERE indicator_number = '2.2');

INSERT INTO public.pa_indicators (category_id, indicator_number, name, description)
SELECT id, '2.3', 'ปฏิบัติงานวิชาการ และงานอื่น ๆ ของสถานศึกษา', 'ร่วมปฏิบัติงานทางวิชาการ และงานอื่น ๆ ของสถานศึกษาเพื่อยกระดับคุณภาพการจัดการศึกษาของสถานศึกษา'
FROM public.pa_categories WHERE category_number = 2
AND NOT EXISTS (SELECT 1 FROM public.pa_indicators WHERE indicator_number = '2.3');

INSERT INTO public.pa_indicators (category_id, indicator_number, name, description)
SELECT id, '2.4', 'ประสานความร่วมมือกับผู้ปกครอง ภาคีเครือข่าย หรือสถานประกอบการ', 'ประสานความร่วมมือกับผู้ปกครอง ภาคีเครือข่าย หรือสถานประกอบการ เพื่อร่วมกันพัฒนาผู้เรียน'
FROM public.pa_categories WHERE category_number = 2
AND NOT EXISTS (SELECT 1 FROM public.pa_indicators WHERE indicator_number = '2.4');

-- Category 3: Self & Professional Development
INSERT INTO public.pa_indicators (category_id, indicator_number, name, description)
SELECT id, '3.1', 'พัฒนาตนเองอย่างเป็นระบบและต่อเนื่อง', 'พัฒนาตนเองอย่างเป็นระบบและต่อเนื่อง เพื่อให้มีความรู้ความสามารถ ทักษะ โดยเฉพาะอย่างยิ่งการใช้ภาษาไทยและภาษาอังกฤษเพื่อการสื่อสาร'
FROM public.pa_categories WHERE category_number = 3
AND NOT EXISTS (SELECT 1 FROM public.pa_indicators WHERE indicator_number = '3.1');

INSERT INTO public.pa_indicators (category_id, indicator_number, name, description)
SELECT id, '3.2', 'มีส่วนร่วมในการแลกเปลี่ยนเรียนรู้ทางวิชาชีพ', 'มีส่วนร่วมในการแลกเปลี่ยนเรียนรู้ทางวิชาชีพเพื่อพัฒนาการจัดการเรียนรู้'
FROM public.pa_categories WHERE category_number = 3
AND NOT EXISTS (SELECT 1 FROM public.pa_indicators WHERE indicator_number = '3.2');

INSERT INTO public.pa_indicators (category_id, indicator_number, name, description)
SELECT id, '3.3', 'นำความรู้ความสามารถ ทักษะที่ได้จากการพัฒนาตนเองและวิชาชีพมาใช้', 'นำความรู้ความสามารถ ทักษะที่ได้จากการพัฒนาตนเองและวิชาชีพมาใช้ในการพัฒนาการจัดการเรียนรู้'
FROM public.pa_categories WHERE category_number = 3
AND NOT EXISTS (SELECT 1 FROM public.pa_indicators WHERE indicator_number = '3.3');

-- 5.3 Highlights (Sample Data)
INSERT INTO public.highlights (title, description, icon_name, color_class, bg_class, display_order)
SELECT 'ประสบการณ์ 8 ปี', 'สอนในระดับชั้นมัธยมศึกษา', 'GraduationCap', 'text-blue-600', 'bg-blue-100', 1
WHERE NOT EXISTS (SELECT 1 FROM public.highlights LIMIT 1);

INSERT INTO public.highlights (title, description, icon_name, color_class, bg_class, display_order)
SELECT 'นักเรียน 300+', 'ดูแลนักเรียนที่ปรึกษาและรายวิชา', 'Users', 'text-green-600', 'bg-green-100', 2
WHERE NOT EXISTS (SELECT 1 FROM public.highlights LIMIT 1);

INSERT INTO public.highlights (title, description, icon_name, color_class, bg_class, display_order)
SELECT 'พัฒนาตนเอง 100+ ชม.', 'อบรมและพัฒนาวิชาชีพอย่างต่อเนื่อง', 'BookOpen', 'text-purple-600', 'bg-purple-100', 3
WHERE NOT EXISTS (SELECT 1 FROM public.highlights LIMIT 1);

INSERT INTO public.highlights (title, description, icon_name, color_class, bg_class, display_order)
SELECT 'รางวัลครูดีเด่น', 'ระดับจังหวัด ปี 2567', 'Award', 'text-orange-600', 'bg-orange-100', 4
WHERE NOT EXISTS (SELECT 1 FROM public.highlights LIMIT 1);
