<template>
  <div id="app">
    <router-view v-if="!authLoading" />
    <div v-else class="min-h-screen bg-violet-600 flex items-center justify-center">
      <div class="text-center">
        <div class="w-20 h-20 bg-white rounded-2xl flex items-center justify-center mx-auto mb-4 shadow-lg">
          <div class="text-3xl font-bold text-violet-600">F90</div>
        </div>
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-white mx-auto"></div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useAuth } from './composables/useAuth'

const { loading: authLoading } = useAuth()
</script>
