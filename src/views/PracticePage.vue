<template>
  <div class="min-h-screen bg-neutral-50">
    <!-- Header -->
    <div class="p-6 pt-12">
      <h1 class="text-2xl font-bold text-neutral-800 mb-1">Practice Center</h1>
      <p class="text-neutral-500">Improve your pronunciation and speaking</p>
    </div>

    <div class="px-6 space-y-6">
      <!-- Youglish Widget -->
      <div class="card">
        <div class="flex items-center space-x-3 mb-4">
          <div class="w-10 h-10 bg-blue-100 rounded-xl flex items-center justify-center">
            <Youtube :size="20" class="text-accent-blue" />
          </div>
          <div>
            <h3 class="font-semibold text-neutral-800">Shadow Practice</h3>
            <p class="text-sm text-neutral-500">Listen and repeat with natives</p>
          </div>
        </div>
        
        <div class="relative mb-4">
          <input
            v-model="searchQuery"
            @keyup.enter="searchVideos"
            type="text"
            placeholder="Search for words or phrases..."
            class="input-field pl-10"
          >
          <Search :size="18" class="absolute left-3 top-1/2 -translate-y-1/2 text-neutral-400" />
        </div>
        
        <div class="bg-neutral-100 rounded-2xl h-64 flex items-center justify-center overflow-hidden">
          <div v-if="!youglishUrl" class="text-center text-neutral-400">
            <Search :size="32" class="mx-auto mb-2" />
            <p>Search for a word to start</p>
          </div>
          <iframe
            v-else
            :src="youglishUrl"
            class="w-full h-full"
            frameborder="0"
            allowfullscreen
          ></iframe>
        </div>
      </div>

      <!-- Voice Recording -->
      <div class="card">
        <div class="flex items-center space-x-3 mb-4">
          <div class="w-10 h-10 bg-red-100 rounded-xl flex items-center justify-center">
            <Mic :size="20" class="text-accent-red" />
          </div>
          <div>
            <h3 class="font-semibold text-neutral-800">Voice Recording</h3>
            <p class="text-sm text-neutral-500">Record yourself and compare</p>
          </div>
        </div>

        <div class="space-y-4">
          <div class="flex items-center justify-center space-x-4 p-4 bg-secondary rounded-2xl">
            <button
              v-if="!isRecording && !audioUrl"
              @click="startRecording"
              class="w-16 h-16 bg-accent-red rounded-full flex items-center justify-center text-white hover:bg-red-600 transition-colors shadow-lg"
            >
              <Mic :size="24" />
            </button>
            
            <button
              v-if="isRecording"
              @click="stopRecording"
              class="w-16 h-16 bg-accent-red rounded-full flex items-center justify-center text-white animate-pulse shadow-lg"
            >
              <Square :size="24" />
            </button>
            
            <div v-if="audioUrl" class="flex items-center space-x-4">
              <button
                @click="playRecording"
                class="w-12 h-12 bg-accent-green rounded-full flex items-center justify-center text-white hover:bg-green-600 transition-colors"
              >
                <Play :size="20" />
              </button>
              
              <button
                @click="resetRecording"
                class="w-12 h-12 bg-neutral-500 rounded-full flex items-center justify-center text-white hover:bg-neutral-600 transition-colors"
              >
                <RotateCcw :size="20" />
              </button>
              
              <button
                @click="saveRecording"
                :disabled="saving"
                class="btn-primary"
              >
                {{ saving ? 'Saving...' : 'Save' }}
              </button>
            </div>
          </div>

          <div v-if="isRecording" class="text-center">
            <p class="text-lg font-mono text-accent-red">{{ formatTime(recordingDuration) }}</p>
          </div>
          <div v-if="recordingStatus" class="text-center text-sm text-neutral-500">{{ recordingStatus }}</div>
        </div>
      </div>

      <!-- Recent Recordings -->
      <div class="card">
        <h3 class="font-semibold text-neutral-800 mb-4">Recent Recordings</h3>
        <div v-if="recordings.length === 0" class="text-center py-8 text-neutral-400">
          <Mic :size="32" class="mx-auto mb-2" />
          <p>No recordings yet</p>
        </div>
        <div v-else class="space-y-3">
          <div
            v-for="recording in recordings"
            :key="recording.id"
            class="flex items-center justify-between p-3 bg-neutral-50 rounded-xl"
          >
            <div class="flex items-center space-x-3">
              <div class="w-8 h-8 bg-secondary rounded-full flex items-center justify-center">
                <Volume2 :size="16" class="text-primary" />
              </div>
              <p class="text-sm font-medium text-neutral-800">
                {{ formatDate(recording.created_at) }}
              </p>
            </div>
            <button @click="playStoredRecording(recording)" class="w-8 h-8 bg-white rounded-full flex items-center justify-center text-primary hover:bg-secondary">
              <Play :size="16" />
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { useAuth } from '@/composables/useAuth'
import { supabase } from '@/lib/supabase'
import type { VoiceRecording } from '@/lib/supabase'
import { Mic, Play, Square, RotateCcw, Search, Volume2, Youtube } from 'lucide-vue-next'

const { profile } = useAuth()

const searchQuery = ref('')
const youglishUrl = ref('')
const isRecording = ref(false)
const audioUrl = ref('')
const recordingDuration = ref(0)
const recordingStatus = ref('')
const saving = ref(false)
const recordings = ref<VoiceRecording[]>([])

let mediaRecorder: MediaRecorder | null = null
let recordingInterval: number | null = null
let audioChunks: Blob[] = []

const searchVideos = () => {
  if (!searchQuery.value.trim()) return
  const query = encodeURIComponent(searchQuery.value.trim())
  youglishUrl.value = `https://youglish.com/embed/english/${query}?autoplay=1`
}

const startRecording = async () => {
  try {
    const stream = await navigator.mediaDevices.getUserMedia({ audio: true })
    mediaRecorder = new MediaRecorder(stream)
    audioChunks = []
    recordingDuration.value = 0
    
    mediaRecorder.ondataavailable = (event) => audioChunks.push(event.data)
    mediaRecorder.onstop = () => {
      const audioBlob = new Blob(audioChunks, { type: 'audio/wav' })
      audioUrl.value = URL.createObjectURL(audioBlob)
      stream.getTracks().forEach(track => track.stop())
    }
    
    mediaRecorder.start()
    isRecording.value = true
    recordingStatus.value = 'Recording...'
    recordingInterval = window.setInterval(() => recordingDuration.value++, 1000)
    
  } catch (error) {
    recordingStatus.value = 'Error: Microphone access denied.'
  }
}

const stopRecording = () => {
  if (mediaRecorder && isRecording.value) {
    mediaRecorder.stop()
    isRecording.value = false
    if (recordingInterval) clearInterval(recordingInterval)
    recordingInterval = null
    recordingStatus.value = 'Recording finished.'
  }
}

const playRecording = () => {
  if (audioUrl.value) new Audio(audioUrl.value).play()
}

const resetRecording = () => {
  audioUrl.value = ''
  recordingDuration.value = 0
  recordingStatus.value = ''
  audioChunks = []
}

const saveRecording = async () => {
  if (!audioUrl.value || !profile.value) return
  
  saving.value = true
  recordingStatus.value = 'Uploading...'
  
  try {
    const response = await fetch(audioUrl.value)
    const blob = await response.blob()
    const filename = `recording_${Date.now()}.wav`
    
    const { data: uploadData, error: uploadError } = await supabase.storage
      .from('voice-recordings')
      .upload(`${profile.value.id}/${filename}`, blob)
    
    if (uploadError) throw uploadError
    
    const { error: dbError } = await supabase
      .from('voice_recordings')
      .insert({
        user_id: profile.value.id,
        lesson_id: 1, // Placeholder
        file_path: uploadData.path,
        duration_seconds: recordingDuration.value
      })
    
    if (dbError) throw dbError
    
    recordingStatus.value = 'Saved successfully!'
    resetRecording()
    await fetchRecordings()
    
  } catch (error) {
    recordingStatus.value = 'Error saving recording.'
  } finally {
    saving.value = false
  }
}

const playStoredRecording = async (recording: VoiceRecording) => {
  try {
    const { data } = await supabase.storage
      .from('voice-recordings')
      .createSignedUrl(recording.file_path, 60)
    
    if (data?.signedUrl) new Audio(data.signedUrl).play()
  } catch (error) {
    console.error('Error playing stored recording:', error)
  }
}

const fetchRecordings = async () => {
  if (!profile.value) return
  const { data } = await supabase
    .from('voice_recordings')
    .select('*')
    .eq('user_id', profile.value.id)
    .order('created_at', { ascending: false })
    .limit(5)
  recordings.value = data || []
}

const formatTime = (seconds: number) => new Date(seconds * 1000).toISOString().substr(14, 5)
const formatDate = (dateString: string) => new Date(dateString).toLocaleDateString([], { month: 'short', day: 'numeric' })

onMounted(fetchRecordings)
onUnmounted(() => {
  if (recordingInterval) clearInterval(recordingInterval)
  if (audioUrl.value) URL.revokeObjectURL(audioUrl.value)
})
</script>
