import { createApp } from 'vue'
import router from './router'
import { useAuth } from './composables/useAuth'
import App from './App.vue'
import './style.css'

const app = createApp(App)

// Initialize auth before mounting
const { initAuth } = useAuth()

initAuth().then(() => {
  app.use(router)
  app.mount('#app')
})
