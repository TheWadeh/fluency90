<template>
  <div class="min-h-screen bg-neutral-50 flex flex-col items-center justify-center p-4">
    <div class="w-full max-w-md">
      <!-- Illustration -->
      <div class="px-8 mb-8">
        <img src="https://img-wrapper.vercel.app/image?url=https://ouch-cdn2.icons8.com/vAk8i_s_5V1e45o_a9y5f2jHuo08i55Sj232Gjb2buM/rs:fit:368:368/czM6Ly9pY29uczgu/b3VjaC1wcm9kLmFz/c2V0cy9wbmcvMjQv/YjI4YmY0YjYtYmYx/Yy00ODU4LTg5NzAt/NGRiY2EzZDRjZWYx/LnBuZw.png" alt="Language learning illustration" class="w-full h-auto">
      </div>
      
      <!-- Welcome Text -->
      <div class="text-center mb-8">
        <h1 class="text-3xl font-bold text-neutral-800 mb-2">Fluent90</h1>
        <p class="text-neutral-500">Master American English in 90 days</p>
      </div>

      <!-- Auth Form -->
      <div class="card mb-6">
        <div class="mb-6">
          <div class="flex rounded-xl bg-neutral-100 p-1">
            <button
              @click="isSignUp = false"
              :class="[
                'flex-1 py-2.5 text-sm font-semibold rounded-lg transition-all',
                !isSignUp ? 'bg-white text-neutral-900 shadow' : 'text-neutral-500'
              ]"
            >
              Sign In
            </button>
            <button
              @click="isSignUp = true"
              :class="[
                'flex-1 py-2.5 text-sm font-semibold rounded-lg transition-all',
                isSignUp ? 'bg-white text-neutral-900 shadow' : 'text-neutral-500'
              ]"
            >
              Sign Up
            </button>
          </div>
        </div>

        <form @submit.prevent="handleSubmit" class="space-y-4">
          <div v-if="isSignUp">
            <input
              v-model="fullName"
              type="text"
              required
              class="input-field"
              placeholder="Full Name"
            >
          </div>
          
          <div>
            <input
              v-model="email"
              type="email"
              required
              class="input-field"
              placeholder="Email Address"
            >
          </div>

          <div>
            <input
              v-model="password"
              type="password"
              required
              class="input-field"
              placeholder="Password"
            >
          </div>

          <button
            type="submit"
            :disabled="loading"
            class="w-full btn-primary mt-2"
          >
            <span v-if="loading">Processing...</span>
            <span v-else>{{ isSignUp ? 'Create Account' : 'Sign In' }}</span>
          </button>
        </form>

        <div v-if="error" class="mt-4 p-3 bg-red-100/50 border border-red-200/50 rounded-xl">
          <p class="text-sm text-red-600">{{ error }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuth } from '@/composables/useAuth'

const router = useRouter()
const { signUp, signIn } = useAuth()

const isSignUp = ref(false)
const email = ref('')
const password = ref('')
const fullName = ref('')
const loading = ref(false)
const error = ref('')

const handleSubmit = async () => {
  loading.value = true
  error.value = ''

  try {
    if (isSignUp.value) {
      const { error: signUpError } = await signUp(email.value, password.value, fullName.value)
      if (signUpError) {
        error.value = signUpError.message
      } else {
        router.push('/')
      }
    } else {
      const { error: signInError } = await signIn(email.value, password.value)
      if (signInError) {
        error.value = signInError.message
      } else {
        router.push('/')
      }
    }
  } catch (err) {
    error.value = 'An unexpected error occurred'
  } finally {
    loading.value = false
  }
}
</script>
