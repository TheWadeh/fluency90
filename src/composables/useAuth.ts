import { ref, computed } from 'vue'
import { supabase } from '@/lib/supabase'
import type { User } from '@supabase/supabase-js'
import type { Profile } from '@/lib/supabase'

const user = ref<User | null>(null)
const profile = ref<Profile | null>(null)
const loading = ref(true)

export const useAuth = () => {
  const isAuthenticated = computed(() => !!user.value)

  const signUp = async (email: string, password: string, fullName: string) => {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          full_name: fullName,
        },
      },
    })
    return { data, error }
  }

  const signIn = async (email: string, password: string) => {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })
    return { data, error }
  }

  const signOut = async () => {
    const { error } = await supabase.auth.signOut()
    if (!error) {
      user.value = null
      profile.value = null
    }
    return { error }
  }

  const fetchProfile = async () => {
    if (!user.value) return null
    
    const { data, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', user.value.id)
      .single()
    
    if (data) {
      profile.value = data
    }
    
    return { data, error }
  }

  const updateProfile = async (updates: Partial<Profile>) => {
    if (!user.value) return { error: new Error('No user') }
    
    const { data, error } = await supabase
      .from('profiles')
      .update(updates)
      .eq('id', user.value.id)
      .select()
      .single()
    
    if (data) {
      profile.value = data
    }
    
    return { data, error }
  }

  const initAuth = async () => {
    loading.value = true
    
    const { data: { session } } = await supabase.auth.getSession()
    user.value = session?.user ?? null
    
    if (user.value) {
      await fetchProfile()
    }
    
    supabase.auth.onAuthStateChange(async (_event, session) => {
      user.value = session?.user ?? null
      if (user.value) {
        await fetchProfile()
      } else {
        profile.value = null
      }
    })
    
    loading.value = false
  }

  return {
    user: computed(() => user.value),
    profile: computed(() => profile.value),
    loading: computed(() => loading.value),
    isAuthenticated,
    signUp,
    signIn,
    signOut,
    fetchProfile,
    updateProfile,
    initAuth,
  }
}
