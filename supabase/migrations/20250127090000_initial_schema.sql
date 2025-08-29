/*
# Initial Fluent90 Database Schema
Create comprehensive schema for English learning app with lessons, progress tracking, and AI conversations.

## Query Description:
This migration creates the complete database structure for Fluent90 including user profiles, lessons, progress tracking, voice recordings, and AI conversations. This is a foundational schema with no existing data impact.

## Metadata:
- Schema-Category: "Safe"
- Impact-Level: "Low"  
- Requires-Backup: false
- Reversible: true

## Structure Details:
- profiles: User profile information linked to auth.users
- lessons: 90-day curriculum content
- user_progress: Lesson completion tracking
- voice_recordings: Audio practice files
- ai_conversations: Chat history with AI partner
- user_stats: Daily stats and streaks

## Security Implications:
- RLS Status: Enabled on all tables
- Policy Changes: Yes - user-based access policies
- Auth Requirements: All tables require authenticated users

## Performance Impact:
- Indexes: Added on foreign keys and commonly queried fields
- Triggers: Added for profile creation on user signup
- Estimated Impact: Minimal - new schema creation
*/

-- Enable Row Level Security
ALTER DEFAULT PRIVILEGES REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;

-- Create profiles table
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create lessons table  
CREATE TABLE lessons (
  id BIGSERIAL PRIMARY KEY,
  day_number INTEGER UNIQUE NOT NULL CHECK (day_number >= 1 AND day_number <= 90),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  audio_url TEXT,
  exercises JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create user_progress table
CREATE TABLE user_progress (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  lesson_id BIGINT REFERENCES lessons(id) ON DELETE CASCADE,
  completed_at TIMESTAMPTZ,
  xp_earned INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, lesson_id)
);

-- Create user_stats table for daily progress
CREATE TABLE user_stats (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE UNIQUE,
  current_day INTEGER DEFAULT 1,
  total_xp INTEGER DEFAULT 0,
  current_streak INTEGER DEFAULT 0,
  best_streak INTEGER DEFAULT 0,
  last_activity_date DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create voice_recordings table
CREATE TABLE voice_recordings (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  lesson_id BIGINT REFERENCES lessons(id) ON DELETE CASCADE,
  file_path TEXT NOT NULL,
  duration_seconds INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create ai_conversations table
CREATE TABLE ai_conversations (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  response TEXT NOT NULL,
  difficulty_level TEXT DEFAULT 'beginner' CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')),
  is_voice BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_user_progress_user_id ON user_progress(user_id);
CREATE INDEX idx_user_progress_lesson_id ON user_progress(lesson_id);
CREATE INDEX idx_voice_recordings_user_id ON voice_recordings(user_id);
CREATE INDEX idx_ai_conversations_user_id ON ai_conversations(user_id);
CREATE INDEX idx_lessons_day_number ON lessons(day_number);

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE voice_recordings ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_conversations ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
-- Profiles policies
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- Lessons policies (public read)
CREATE POLICY "Anyone can view lessons" ON lessons
  FOR SELECT USING (true);

-- User progress policies
CREATE POLICY "Users can view own progress" ON user_progress
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own progress" ON user_progress
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own progress" ON user_progress
  FOR UPDATE USING (auth.uid() = user_id);

-- User stats policies
CREATE POLICY "Users can view own stats" ON user_stats
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own stats" ON user_stats
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own stats" ON user_stats
  FOR UPDATE USING (auth.uid() = user_id);

-- Voice recordings policies
CREATE POLICY "Users can view own recordings" ON voice_recordings
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own recordings" ON voice_recordings
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own recordings" ON voice_recordings
  FOR DELETE USING (auth.uid() = user_id);

-- AI conversations policies
CREATE POLICY "Users can view own conversations" ON ai_conversations
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own conversations" ON ai_conversations
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Create function to handle new user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'full_name');
  
  INSERT INTO public.user_stats (user_id)
  VALUES (NEW.id);
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for new user creation
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Insert sample lessons
INSERT INTO lessons (day_number, title, content, exercises) VALUES 
(1, 'Getting Started: Basic Greetings', 'Welcome to your English learning journey! Today we''ll learn essential greetings used in American English.', '[{"type": "vocabulary", "words": ["Hello", "Hi", "Good morning", "Good afternoon", "Good evening"]}, {"type": "pronunciation", "phrases": ["How are you?", "Nice to meet you", "Have a great day!"]}]'),
(2, 'Introducing Yourself', 'Learn how to confidently introduce yourself in various situations.', '[{"type": "dialogue", "conversation": "A: Hi, I''m Sarah. B: Nice to meet you, Sarah. I''m John."}, {"type": "practice", "sentences": ["My name is...", "I''m from...", "I work as..."]}]'),
(3, 'Numbers and Time', 'Master numbers, dates, and telling time in English.', '[{"type": "numbers", "range": "1-100"}, {"type": "time", "formats": ["digital", "analog", "am/pm"]}]');
