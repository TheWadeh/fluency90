<template>
  <div class="min-h-screen bg-neutral-50">
    <!-- Header -->
    <div class="p-6 pt-12">
      <div class="flex items-center justify-between mb-6">
        <div>
          <p class="text-lg text-neutral-500">{{ greeting }}</p>
          <p class="text-2xl font-bold text-neutral-800">{{ profile?.full_name || 'Student' }} 👋</p>
        </div>
        <router-link to="/profile" class="w-12 h-12 bg-secondary rounded-full flex items-center justify-center">
          <User :size="24" class="text-primary" />
        </router-link>
      </div>
    </div>

    <!-- Continue Lesson Card -->
    <div class="px-6 mb-8">
      <div class="p-6 bg-gradient-to-br from-primary to-purple-500 rounded-4xl text-white shadow-main">
        <div class="flex items-start justify-between">
          <div>
            <h2 class="text-xl font-bold mb-1">Continue Lesson</h2>
            <p class="text-primary-light mb-4">Day {{ stats?.current_day || 1 }} is waiting for you</p>
          </div>
          <div class="w-10 h-10 bg-white/20 rounded-full flex items-center justify-center">
            <BookOpen :size="20" />
          </div>
        </div>
        <div class="w-full bg-white/20 rounded-full h-2.5 mb-2">
          <div 
            class="bg-white h-2.5 rounded-full transition-all duration-500"
            :style="{ width: `${((stats?.current_day || 1) / 90) * 100}%` }"
          ></div>
        </div>
        <div class="flex justify-between text-xs">
          <span>Progress</span>
          <span>{{ stats?.current_day || 1 }}/90</span>
        </div>
        <button
          @click="$router.push(`/lessons`)"
          class="mt-6 w-full bg-white text-primary font-semibold py-3 rounded-2xl hover:bg-secondary transition-colors"
        >
          Let's Go
        </button>
      </div>
    </div>

    <!-- Stats -->
    <div class="px-6 mb-8 grid grid-cols-2 gap-4">
      <div class="card p-4 flex items-center space-x-3">
        <div class="w-10 h-10 bg-orange-100 rounded-xl flex items-center justify-center">
          <Flame :size="20" class="text-accent-orange" />
        </div>
        <div>
          <p class="font-bold text-neutral-800">{{ stats?.current_streak || 0 }}</p>
          <p class="text-xs text-neutral-500">Day Streak</p>
        </div>
      </div>
      <div class="card p-4 flex items-center space-x-3">
        <div class="w-10 h-10 bg-blue-100 rounded-xl flex items-center justify-center">
          <Zap :size="20" class="text-accent-blue" />
        </div>
        <div>
          <p class="font-bold text-neutral-800">{{ stats?.total_xp || 0 }}</p>
          <p class="text-xs text-neutral-500">XP Points</p>
        </div>
      </div>
    </div>

    <!-- Motivational Quote -->
    <div class="px-6 mb-8">
      <div class="card p-6 bg-secondary">
        <div class="flex items-start space-x-4">
          <div class="w-10 h-10 bg-white rounded-full flex items-center justify-center flex-shrink-0">
            <Quote :size="20" class="text-primary" />
          </div>
          <div>
            <p class="text-sm font-semibold text-primary-dark mb-1">Daily Motivation</p>
            <p class="text-sm text-neutral-600 italic">"{{ motivationalQuote }}"</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useAuth } from '@/composables/useAuth'
import { supabase } from '@/lib/supabase'
import type { UserStats } from '@/lib/supabase'
import { 
  User, 
  BookOpen, 
  Flame,
  Zap,
  Quote 
} from 'lucide-vue-next'

const { profile } = useAuth()
const stats = ref<UserStats | null>(null)

const greeting = computed(() => {
  const hour = new Date().getHours()
  if (hour < 12) return 'Good morning'
  if (hour < 18) return 'Good afternoon'
  return 'Good evening'
})

const motivationalQuotes = [
  "Every expert was once a beginner. Keep going!",
  "Progress, not perfection, is the goal.",
  "Your English improves with every word you speak.",
  "Consistency is the key to mastery.",
  "Every mistake is a step towards fluency."
]

const motivationalQuote = computed(() => {
  const today = new Date().getDay()
  return motivationalQuotes[today % motivationalQuotes.length]
})

const fetchUserStats = async () => {
  if (!profile.value) return
  
  const { data } = await supabase
    .from('user_stats')
    .select('*')
    .eq('user_id', profile.value.id)
    .single()
  
  stats.value = data
}

onMounted(async () => {
  await fetchUserStats()
})
</script>
