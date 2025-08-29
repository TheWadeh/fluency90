import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

export interface Profile {
  id: string
  email: string
  full_name?: string
  avatar_url?: string
  created_at: string
  updated_at: string
}

export interface Lesson {
  id: number
  day_number: number
  title: string
  content: string
  audio_url?: string
  exercises: any[]
  created_at: string
}

export interface UserProgress {
  id: number
  user_id: string
  lesson_id: number
  completed_at?: string
  xp_earned: number
  created_at: string
}

export interface UserStats {
  id: number
  user_id: string
  current_day: number
  total_xp: number
  current_streak: number
  best_streak: number
  last_activity_date: string
  created_at: string
  updated_at: string
}

export interface VoiceRecording {
  id: number
  user_id: string
  lesson_id: number
  file_path: string
  duration_seconds?: number
  created_at: string
}

export interface AIConversation {
  id: number
  user_id: string
  message: string
  response: string
  difficulty_level: 'beginner' | 'intermediate' | 'advanced'
  is_voice: boolean
  created_at: string
}
