import { createRouter, createWebHistory } from 'vue-router'
import { useAuth } from '@/composables/useAuth'
import AuthPage from '@/views/AuthPage.vue'
import HomePage from '@/views/HomePage.vue'
import LessonsPage from '@/views/LessonsPage.vue'
import PracticePage from '@/views/PracticePage.vue'
import FluensaPage from '@/views/FluensaPage.vue'
import ProfilePage from '@/views/ProfilePage.vue'
import LessonDetail from '@/views/LessonDetail.vue'
import MainLayout from '@/layouts/MainLayout.vue'

const routes = [
  {
    path: '/auth',
    name: 'Auth',
    component: AuthPage,
    meta: { requiresGuest: true }
  },
  {
    path: '/',
    component: MainLayout,
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        name: 'Home',
        component: HomePage,
      },
      {
        path: 'lessons',
        name: 'Lessons',
        component: LessonsPage,
      },
      {
        path: 'lessons/:id',
        name: 'LessonDetail',
        component: LessonDetail,
      },
      {
        path: 'practice',
        name: 'Practice',
        component: PracticePage,
      },
      {
        path: 'fluensa',
        name: 'Fluensa',
        component: FluensaPage,
      },
      {
        path: 'profile',
        name: 'Profile',
        component: ProfilePage,
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach(async (to) => {
  const { isAuthenticated, loading } = useAuth()
  
  // Wait for auth to initialize
  while (loading.value) {
    await new Promise(res => setTimeout(res, 50));
  }
  
  if (to.meta.requiresAuth && !isAuthenticated.value) {
    return '/auth'
  }
  
  if (to.meta.requiresGuest && isAuthenticated.value) {
    return '/'
  }
  
  return true
})

export default router
