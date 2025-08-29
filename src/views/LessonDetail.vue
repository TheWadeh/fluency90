<template>
  <div class="min-h-screen bg-neutral-50">
    <!-- Header -->
    <div class="p-4 pt-12 sticky top-0 bg-neutral-50/80 backdrop-blur-lg z-10">
      <div class="flex items-center space-x-4">
        <button @click="$router.back()" class="w-10 h-10 bg-white rounded-full flex items-center justify-center shadow-sm">
          <ArrowLeft :size="20" class="text-neutral-600" />
        </button>
        <div class="flex-1">
          <h1 class="text-xl font-bold text-neutral-800 truncate">{{ lesson?.title }}</h1>
          <p class="text-neutral-500">Day {{ lesson?.day_number }}</p>
        </div>
      </div>
    </div>

    <div v-if="loading" class="flex justify-center py-12">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
    </div>

    <div v-else-if="lesson" class="p-6 space-y-6">
      <!-- Content -->
      <div class="card">
        <h3 class="font-bold text-neutral-800 mb-4">Lesson Content</h3>
        <div class="prose prose-neutral prose-sm max-w-none text-neutral-600" v-html="lesson.content"></div>
        
        <div v-if="lesson.audio_url" class="mt-6 p-4 bg-secondary rounded-2xl flex items-center space-x-3">
          <button @click="toggleAudio" class="w-10 h-10 bg-primary rounded-full flex items-center justify-center text-white">
            <component :is="isPlaying ? Pause : Play" :size="20" />
          </button>
          <div>
            <p class="font-semibold text-primary-dark">Lesson Audio</p>
            <p class="text-xs text-primary">Listen for pronunciation</p>
          </div>
          <audio ref="audioElement" :src="lesson.audio_url" @ended="isPlaying = false"></audio>
        </div>
      </div>

      <!-- Exercises -->
      <div v-if="lesson.exercises && lesson.exercises.length > 0" class="card">
        <h3 class="font-bold text-neutral-800 mb-4">Exercises</h3>
        <div class="space-y-4">
          <div v-for="(exercise, index) in lesson.exercises" :key="index" class="p-4 bg-neutral-50 rounded-xl">
            <h4 class="font-semibold text-neutral-700 mb-2 capitalize">{{ exercise.type }}</h4>
            <div v-if="exercise.type === 'vocabulary'" class="space-y-2">
              <div v-for="word in exercise.words" :key="word" class="flex items-center justify-between p-3 bg-white rounded-lg">
                <span class="font-medium text-neutral-800">{{ word }}</span>
                <button @click="speakText(word)" class="text-primary hover:text-primary-dark"><Volume2 :size="16" /></button>
              </div>
            </div>
            <div v-if="exercise.type === 'pronunciation' || exercise.type === 'practice'" class="space-y-2">
              <div v-for="phrase in (exercise.phrases || exercise.sentences)" :key="phrase" class="flex items-center justify-between p-3 bg-white rounded-lg">
                <span class="text-neutral-800">{{ phrase }}</span>
                <button @click="speakText(phrase)" class="text-primary hover:text-primary-dark"><Volume2 :size="16" /></button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Complete Lesson -->
      <div class="card">
        <div v-if="isCompleted" class="text-center">
          <div class="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <Check :size="24" class="text-accent-green" />
          </div>
          <h3 class="text-lg font-bold text-neutral-800 mb-2">Lesson Completed!</h3>
          <p class="text-neutral-500 mb-4">Great job! You earned {{ xpEarned }} XP.</p>
          <button @click="goToNextLesson" class="btn-primary">Next Lesson</button>
        </div>
        <button v-else @click="completeLesson" :disabled="completing" class="w-full btn-primary">
          {{ completing ? 'Completing...' : 'Mark as Complete & Earn 50 XP' }}
        </button>
      </div>
    </div>

    <div v-else class="text-center py-12">
      <BookOpen :size="48" class="mx-auto text-neutral-300 mb-4" />
      <h3 class="text-lg font-medium text-neutral-800 mb-2">Lesson not found</h3>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuth } from '@/composables/useAuth'
import { supabase } from '@/lib/supabase'
import type { Lesson, UserProgress } from '@/lib/supabase'
import { ArrowLeft, Play, Pause, Volume2, Check, BookOpen } from 'lucide-vue-next'

const route = useRoute()
const router = useRouter()
const { profile } = useAuth()

const lesson = ref<Lesson | null>(null)
const progress = ref<UserProgress | null>(null)
const loading = ref(true)
const completing = ref(false)
const isPlaying = ref(false)
const audioElement = ref<HTMLAudioElement>()

const isCompleted = computed(() => !!progress.value?.completed_at)
const xpEarned = computed(() => progress.value?.xp_earned || 0)

const fetchLessonData = async () => {
  loading.value = true
  const lessonId = parseInt(route.params.id as string)
  
  const { data: lessonData } = await supabase.from('lessons').select('*').eq('id', lessonId).single()
  lesson.value = lessonData
  
  if (lesson.value && profile.value) {
    const { data: progressData } = await supabase.from('user_progress').select('*').eq('user_id', profile.value.id).eq('lesson_id', lesson.value.id).single()
    progress.value = progressData
  }
  loading.value = false
}

const completeLesson = async () => {
  if (!profile.value || !lesson.value || isCompleted.value) return
  completing.value = true
  
  try {
    const xp = 50
    const { data, error } = await supabase.from('user_progress').upsert({ user_id: profile.value.id, lesson_id: lesson.value.id, completed_at: new Date().toISOString(), xp_earned: xp }).select().single()
    if (error) throw error
    progress.value = data
    await supabase.rpc('update_user_stats_on_completion', { p_user_id: profile.value.id, p_xp_earned: xp })
  } finally {
    completing.value = false
  }
}

const goToNextLesson = async () => {
  if (!lesson.value) return
  const { data: nextLesson } = await supabase.from('lessons').select('id').eq('day_number', lesson.value.day_number + 1).single()
  if (nextLesson) {
    router.push(`/lessons/${nextLesson.id}`)
  } else {
    router.push('/lessons')
  }
}

const toggleAudio = () => {
  if (!audioElement.value) return
  isPlaying.value ? audioElement.value.pause() : audioElement.value.play()
  isPlaying.value = !isPlaying.value
}

const speakText = (text: string) => {
  if ('speechSynthesis' in window) {
    const utterance = new SpeechSynthesisUtterance(text)
    utterance.lang = 'en-US'
    speechSynthesis.speak(utterance)
  }
}

onMounted(fetchLessonData)
</script>
