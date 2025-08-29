<template>
  <div class="min-h-screen bg-neutral-50 font-sans">
    <main class="pb-28">
      <router-view />
    </main>
    <div class="fixed bottom-0 left-0 right-0 z-50">
      <NavBar />
    </div>
  </div>
</template>

<script setup lang="ts">
import NavBar from '@/components/NavBar.vue'
</script>
