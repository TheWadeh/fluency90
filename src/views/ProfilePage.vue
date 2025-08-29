<template>
  <div class="min-h-screen bg-neutral-50">
    <!-- Header -->
    <div class="p-6 pt-12">
      <h1 class="text-2xl font-bold text-neutral-800 mb-1">Profile</h1>
      <p class="text-neutral-500">Manage your account and progress</p>
    </div>

    <div class="px-6 space-y-6">
      <!-- Profile Info -->
      <div class="card">
        <div class="flex items-center space-x-4">
          <div class="w-16 h-16 bg-secondary rounded-full flex items-center justify-center">
            <User :size="32" class="text-primary" />
          </div>
          <div class="flex-1">
            <h3 class="text-lg font-bold text-neutral-800">{{ profile?.full_name || 'User' }}</h3>
            <p class="text-neutral-500">{{ profile?.email }}</p>
          </div>
          <button @click="showEditProfile = !showEditProfile" class="text-neutral-400 hover:text-primary">
            <Edit :size="20" />
          </button>
        </div>
        <div v-if="showEditProfile" class="mt-6 border-t border-neutral-100 pt-4">
          <form @submit.prevent="handleUpdateProfile" class="space-y-4">
            <input v-model="editForm.full_name" type="text" class="input-field">
            <div class="flex space-x-3">
              <button type="submit" :disabled="updating" class="btn-primary">
                {{ updating ? 'Saving...' : 'Save' }}
              </button>
              <button type="button" @click="cancelEdit" class="btn-secondary">Cancel</button>
            </div>
          </form>
        </div>
      </div>

      <!-- Stats Cards -->
      <div class="grid grid-cols-2 gap-4">
        <div class="card p-4 text-center">
          <div class="w-10 h-10 bg-green-100 rounded-xl flex items-center justify-center mx-auto mb-2">
            <TrendingUp :size="20" class="text-accent-green" />
          </div>
          <p class="text-2xl font-bold text-neutral-800">{{ stats?.current_day || 1 }}</p>
          <p class="text-sm text-neutral-500">Current Day</p>
        </div>
        <div class="card p-4 text-center">
          <div class="w-10 h-10 bg-blue-100 rounded-xl flex items-center justify-center mx-auto mb-2">
            <Zap :size="20" class="text-accent-blue" />
          </div>
          <p class="text-2xl font-bold text-neutral-800">{{ stats?.total_xp || 0 }}</p>
          <p class="text-sm text-neutral-500">Total XP</p>
        </div>
        <div class="card p-4 text-center">
          <div class="w-10 h-10 bg-orange-100 rounded-xl flex items-center justify-center mx-auto mb-2">
            <Flame :size="20" class="text-accent-orange" />
          </div>
          <p class="text-2xl font-bold text-neutral-800">{{ stats?.current_streak || 0 }}</p>
          <p class="text-sm text-neutral-500">Streak</p>
        </div>
        <div class="card p-4 text-center">
          <div class="w-10 h-10 bg-purple-100 rounded-xl flex items-center justify-center mx-auto mb-2">
            <Trophy :size="20" class="text-primary" />
          </div>
          <p class="text-2xl font-bold text-neutral-800">{{ stats?.best_streak || 0 }}</p>
          <p class="text-sm text-neutral-500">Best Streak</p>
        </div>
      </div>

      <!-- Actions -->
      <div class="card p-4 space-y-2">
        <button @click="showResetConfirm = true" class="w-full flex items-center p-3 text-left rounded-xl hover:bg-neutral-50">
          <div class="w-8 h-8 bg-orange-100 rounded-full flex items-center justify-center mr-3">
            <RotateCcw :size="16" class="text-accent-orange" />
          </div>
          <span class="font-medium text-neutral-800 flex-1">Reset Progress</span>
          <ChevronRight :size="16" class="text-neutral-400" />
        </button>
        <button @click="handleSignOut" class="w-full flex items-center p-3 text-left rounded-xl hover:bg-neutral-50">
          <div class="w-8 h-8 bg-red-100 rounded-full flex items-center justify-center mr-3">
            <LogOut :size="16" class="text-accent-red" />
          </div>
          <span class="font-medium text-neutral-800 flex-1">Sign Out</span>
          <ChevronRight :size="16" class="text-neutral-400" />
        </button>
      </div>
    </div>

    <!-- Reset Confirmation Modal -->
    <div v-if="showResetConfirm" class="fixed inset-0 bg-black bg-opacity-60 flex items-center justify-center p-4 z-50">
      <div class="card w-full max-w-sm">
        <h3 class="text-lg font-bold text-neutral-800 mb-2">Reset Progress?</h3>
        <p class="text-neutral-500 mb-6">This will reset your progress to Day 1. This action cannot be undone.</p>
        <div class="flex space-x-3">
          <button @click="showResetConfirm = false" class="flex-1 btn-secondary">Cancel</button>
          <button @click="handleResetProgress" :disabled="resetting" class="flex-1 bg-accent-red text-white py-3 rounded-xl font-semibold hover:bg-red-700 disabled:opacity-50">
            {{ resetting ? 'Resetting...' : 'Yes, Reset' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuth } from '@/composables/useAuth'
import { supabase } from '@/lib/supabase'
import type { UserStats } from '@/lib/supabase'
import { User, Edit, TrendingUp, Zap, Flame, Trophy, RotateCcw, LogOut, ChevronRight } from 'lucide-vue-next'

const router = useRouter()
const { profile, signOut, updateProfile } = useAuth()
const stats = ref<UserStats | null>(null)
const showEditProfile = ref(false)
const showResetConfirm = ref(false)
const updating = ref(false)
const resetting = ref(false)
const editForm = ref({ full_name: '' })

const fetchUserStats = async () => {
  if (!profile.value) return
  const { data } = await supabase.from('user_stats').select('*').eq('user_id', profile.value.id).single()
  stats.value = data
}

const handleUpdateProfile = async () => {
  if (!profile.value) return
  updating.value = true
  await updateProfile({ full_name: editForm.value.full_name })
  showEditProfile.value = false
  updating.value = false
}

const cancelEdit = () => {
  editForm.value.full_name = profile.value?.full_name || ''
  showEditProfile.value = false
}

const handleResetProgress = async () => {
  if (!profile.value) return
  resetting.value = true
  await supabase.from('user_stats').update({ current_day: 1, total_xp: 0, current_streak: 0, last_activity_date: new Date().toISOString() }).eq('user_id', profile.value.id)
  await supabase.from('user_progress').delete().eq('user_id', profile.value.id)
  await fetchUserStats()
  showResetConfirm.value = false
  resetting.value = false
}

const handleSignOut = async () => {
  await signOut()
  router.push('/auth')
}

onMounted(async () => {
  if (profile.value) editForm.value.full_name = profile.value.full_name || ''
  await fetchUserStats()
})
</script>
