<template>
  <div class="min-h-screen bg-neutral-50 flex flex-col">
    <!-- Header -->
    <div class="bg-white px-4 pt-12 pb-4 border-b border-neutral-100 sticky top-0 z-10">
      <div class="flex items-center justify-between">
        <div>
          <h1 class="text-2xl font-bold text-neutral-800 mb-1">Fluensa AI</h1>
          <p class="text-neutral-500">Your conversation partner</p>
        </div>
        
        <select
          v-model="difficultyLevel"
          class="input-field !w-auto !py-2 !bg-white border-2 border-neutral-200"
        >
          <option value="beginner">Beginner</option>
          <option value="intermediate">Intermediate</option>
          <option value="advanced">Advanced</option>
        </select>
      </div>
    </div>

    <!-- Chat Messages -->
    <div class="flex-1 px-4 py-4 space-y-4 overflow-y-auto" ref="messagesContainer">
      <div v-if="conversations.length === 0" class="text-center py-8">
        <div class="w-16 h-16 bg-secondary rounded-full flex items-center justify-center mx-auto mb-4">
          <MessageCircle :size="24" class="text-primary" />
        </div>
        <h3 class="text-lg font-semibold text-neutral-800 mb-2">Start a conversation!</h3>
        <p class="text-neutral-500 mb-4">I'm ready to practice English with you.</p>
        <div class="flex flex-wrap justify-center gap-2">
          <button
            v-for="starter in conversationStarters"
            :key="starter"
            @click="sendMessage(starter)"
            class="px-4 py-2 bg-secondary text-primary rounded-xl text-sm font-medium hover:bg-primary/20 transition-colors"
          >
            {{ starter }}
          </button>
        </div>
      </div>

      <template v-for="conv in conversations" :key="conv.id">
        <div class="flex justify-end">
          <div class="bg-primary text-white px-4 py-3 rounded-3xl rounded-br-lg max-w-xs lg:max-w-md">
            <p>{{ conv.message }}</p>
          </div>
        </div>
        <div class="flex justify-start">
          <div class="bg-white text-neutral-800 px-4 py-3 rounded-3xl rounded-bl-lg max-w-xs lg:max-w-md shadow-sm border border-neutral-100">
            <p class="mb-2">{{ conv.response }}</p>
            <button @click="speakText(conv.response)" class="flex items-center space-x-1 text-xs text-primary hover:text-primary-dark">
              <Volume2 :size="12" />
              <span>Listen</span>
            </button>
          </div>
        </div>
      </template>

      <div v-if="isLoading" class="flex justify-start">
        <div class="bg-white px-4 py-3 rounded-3xl rounded-bl-lg shadow-sm">
          <div class="flex space-x-1.5">
            <div class="w-2 h-2 bg-neutral-300 rounded-full animate-bounce"></div>
            <div class="w-2 h-2 bg-neutral-300 rounded-full animate-bounce" style="animation-delay: 0.1s"></div>
            <div class="w-2 h-2 bg-neutral-300 rounded-full animate-bounce" style="animation-delay: 0.2s"></div>
          </div>
        </div>
      </div>
    </div>

    <!-- Input Area -->
    <div class="bg-white/80 backdrop-blur-lg border-t border-neutral-200/50 p-4 sticky bottom-0">
      <div class="flex items-center space-x-3">
        <input
          v-model="currentMessage"
          @keyup.enter="handleSendMessage"
          type="text"
          placeholder="Type or speak..."
          class="input-field flex-1"
        >
        <button
          @click="isListening ? stopListening() : startListening()"
          :class="['w-12 h-12 rounded-full flex items-center justify-center transition-colors', isListening ? 'bg-red-500 text-white animate-pulse' : 'bg-secondary text-primary']"
        >
          <Mic :size="20" />
        </button>
        <button
          @click="handleSendMessage"
          :disabled="!currentMessage.trim() || isLoading"
          class="w-12 h-12 bg-primary text-white rounded-full flex items-center justify-center disabled:opacity-50"
        >
          <Send :size="20" />
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, nextTick } from 'vue'
import { useAuth } from '@/composables/useAuth'
import { supabase } from '@/lib/supabase'
import type { AIConversation } from '@/lib/supabase'
import { MessageCircle, Mic, Send, Volume2 } from 'lucide-vue-next'

const { profile } = useAuth()
const conversations = ref<AIConversation[]>([])
const currentMessage = ref('')
const difficultyLevel = ref<'beginner' | 'intermediate' | 'advanced'>('beginner')
const isLoading = ref(false)
const isListening = ref(false)
const messagesContainer = ref<HTMLElement>()

const conversationStarters = ["Hello!", "How are you?", "Tell me a joke", "What's the weather?"]

const getAIResponse = (_message: string, difficulty: string): string => {
  const responses = {
    beginner: ["That's great!", "I see. Tell me more.", "Very good!", "Thank you for sharing."],
    intermediate: ["That's fascinating! Could you elaborate?", "I appreciate your perspective.", "Let's explore this further.", "That's an excellent point."],
    advanced: ["Your articulation is commendable.", "A sophisticated viewpoint. How do you reconcile this?", "Let's delve into the nuances.", "This presents an intellectually stimulating discourse."]
  }
  const responseList = responses[difficulty as keyof typeof responses]
  return responseList[Math.floor(Math.random() * responseList.length)]
}

const sendMessage = async (message?: string) => {
  const messageText = message || currentMessage.value.trim()
  if (!messageText || !profile.value) return
  
  isLoading.value = true
  currentMessage.value = ''
  
  try {
    await new Promise(resolve => setTimeout(resolve, 1000 + Math.random() * 1000))
    const aiResponse = getAIResponse(messageText, difficultyLevel.value)
    
    const { data, error } = await supabase
      .from('ai_conversations')
      .insert({
        user_id: profile.value.id,
        message: messageText,
        response: aiResponse,
        difficulty_level: difficultyLevel.value,
        is_voice: false
      }).select().single()
    
    if (error) throw error
    conversations.value.push(data)
    
    await nextTick()
    messagesContainer.value?.scrollTo({ top: messagesContainer.value.scrollHeight, behavior: 'smooth' })
    
  } catch (error) {
    console.error('Error sending message:', error)
  } finally {
    isLoading.value = false
  }
}

const handleSendMessage = () => sendMessage()

const startListening = () => {
  const SpeechRecognition = (window as any).webkitSpeechRecognition || (window as any).SpeechRecognition
  if (!SpeechRecognition) {
    alert('Speech recognition not supported.')
    return
  }
  const recognition = new SpeechRecognition()
  recognition.lang = 'en-US'
  recognition.onstart = () => isListening.value = true
  recognition.onresult = (event: any) => currentMessage.value = event.results[0][0].transcript
  recognition.onend = () => isListening.value = false
  recognition.start()
}

const stopListening = () => {}

const speakText = (text: string) => {
  if ('speechSynthesis' in window) {
    const utterance = new SpeechSynthesisUtterance(text)
    utterance.lang = 'en-US'
    utterance.rate = 0.9
    speechSynthesis.speak(utterance)
  }
}

const fetchConversations = async () => {
  if (!profile.value) return
  const { data } = await supabase.from('ai_conversations').select('*').eq('user_id', profile.value.id).order('created_at').limit(50)
  conversations.value = data || []
  await nextTick()
  if (messagesContainer.value) messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
}

onMounted(fetchConversations)
</script>
