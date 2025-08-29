<template>
  <div class="min-h-screen bg-neutral-50">
    <!-- Header -->
    <div class="p-6 pt-12">
      <h1 class="text-2xl font-bold text-neutral-800 mb-1">Lessons</h1>
      <p class="text-neutral-500">Your 90-day journey to fluency</p>
    </div>

    <!-- Lessons List -->
    <div class="px-6">
      <div class="space-y-3">
        <div
          v-for="lesson in lessons"
          :key="lesson.id"
          @click="openLesson(lesson)"
          :class="[
            'p-4 rounded-2xl transition-all duration-300 flex items-center space-x-4',
            getLessonStatus(lesson) === 'locked' 
              ? 'bg-neutral-100 cursor-not-allowed' 
              : 'bg-white shadow-sm hover:shadow-md cursor-pointer'
          ]"
        >
          <!-- Icon -->
          <div 
            :class="[
              'w-12 h-12 rounded-xl flex items-center justify-center font-bold text-white text-lg flex-shrink-0',
              getLessonStatus(lesson) === 'completed' ? 'bg-accent-green' :
              getLessonStatus(lesson) === 'current' ? 'bg-primary' :
              'bg-neutral-300'
            ]"
          >
            <Check v-if="getLessonStatus(lesson) === 'completed'" :size="24" />
            <Lock v-else-if="getLessonStatus(lesson) === 'locked'" :size="24" />
            <span v-else>{{ lesson.day_number }}</span>
          </div>

          <!-- Lesson Info -->
          <div class="flex-1">
            <p 
              :class="[
                'text-xs',
                getLessonStatus(lesson) === 'locked' ? 'text-neutral-400' : 'text-primary'
              ]"
            >
              Day {{ lesson.day_number }}
            </p>
            <h3 
              :class="[
                'font-semibold mb-1',
                getLessonStatus(lesson) === 'locked' ? 'text-neutral-400' : 'text-neutral-800'
              ]"
            >
              {{ lesson.title }}
            </h3>
          </div>

          <!-- Arrow -->
          <ChevronRight 
            v-if="getLessonStatus(lesson) !== 'locked'" 
            :size="20" 
            class="text-neutral-400" 
          />
        </div>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="flex justify-center py-8">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
      </div>

      <!-- Empty State -->
      <div v-if="!loading && lessons.length === 0" class="text-center py-12">
        <BookOpen :size="48" class="mx-auto text-neutral-300 mb-4" />
        <h3 class="text-lg font-medium text-neutral-800 mb-2">No lessons found</h3>
        <p class="text-neutral-500">Check back later for new content.</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuth } from '@/composables/useAuth'
import { supabase } from '@/lib/supabase'
import type { Lesson, UserProgress, UserStats } from '@/lib/supabase'
import { 
  BookOpen, 
  ChevronRight, 
  Check, 
  Lock
} from 'lucide-vue-next'

const router = useRouter()
const { profile } = useAuth()

const lessons = ref<Lesson[]>([])
const progress = ref<UserProgress[]>([])
const stats = ref<UserStats | null>(null)
const loading = ref(true)

const currentDay = computed(() => stats.value?.current_day || 1)

const getLessonStatus = (lesson: Lesson) => {
  const progressItem = progress.value.find(p => p.lesson_id === lesson.id)
  if (progressItem?.completed_at) return 'completed'
  if (lesson.day_number === currentDay.value) return 'current'
  if (lesson.day_number < currentDay.value) return 'available' // Not completed but past
  return 'locked'
}

const openLesson = (lesson: Lesson) => {
  if (getLessonStatus(lesson) === 'locked') return
  router.push(`/lessons/${lesson.id}`)
}

const fetchLessons = async () => {
  const { data } = await supabase
    .from('lessons')
    .select('*')
    .order('day_number')
  
  lessons.value = data || []
}

const fetchUserProgress = async () => {
  if (!profile.value) return
  
  const { data } = await supabase
    .from('user_progress')
    .select('*')
    .eq('user_id', profile.value.id)
  
  progress.value = data || []
}

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
  loading.value = true
  await Promise.all([
    fetchLessons(),
    fetchUserProgress(),
    fetchUserStats()
  ])
  loading.value = false
})
</script>
