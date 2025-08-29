<template>
  <div class="relative max-w-md mx-auto">
    <div class="absolute bottom-6 left-1/2 -translate-x-1/2 z-10">
      <router-link
        to="/practice"
        class="w-16 h-16 bg-primary rounded-full flex items-center justify-center text-white shadow-main transform hover:scale-110 transition-transform"
      >
        <Mic :size="28" />
      </router-link>
    </div>
    <div class="bg-white/80 backdrop-blur-lg rounded-t-4xl shadow-lg border-t border-neutral-200/50 px-6 py-3">
      <div class="flex justify-around items-center">
        <router-link 
          v-for="item in leftNavItems" 
          :key="item.name"
          :to="item.path"
          class="flex flex-col items-center p-2 rounded-xl transition-all duration-200 w-16"
          :class="$route.path === item.path ? 'text-primary' : 'text-neutral-400'"
        >
          <component :is="item.icon" :size="24" />
          <span class="text-xs mt-1 font-medium">{{ item.label }}</span>
        </router-link>

        <div class="w-16"></div> <!-- Spacer for FAB -->

        <router-link 
          v-for="item in rightNavItems" 
          :key="item.name"
          :to="item.path"
          class="flex flex-col items-center p-2 rounded-xl transition-all duration-200 w-16"
          :class="$route.path === item.path ? 'text-primary' : 'text-neutral-400'"
        >
          <component :is="item.icon" :size="24" />
          <span class="text-xs mt-1 font-medium">{{ item.label }}</span>
        </router-link>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Home, BookOpen, Mic, MessageCircle, User } from 'lucide-vue-next'

const allNavItems = [
  { name: 'home', path: '/', icon: Home, label: 'Home' },
  { name: 'lessons', path: '/lessons', icon: BookOpen, label: 'Lessons' },
  { name: 'practice', path: '/practice', icon: Mic, label: 'Practice' },
  { name: 'fluensa', path: '/fluensa', icon: MessageCircle, label: 'Fluensa' },
  { name: 'profile', path: '/profile', icon: User, label: 'Profile' }
]

const leftNavItems = allNavItems.slice(0, 2);
const rightNavItems = allNavItems.slice(3, 5);
</script>
