/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#7C3AED', // violet-600
          light: '#A78BFA',   // violet-400
          dark: '#6D28D9',    // violet-700
        },
        secondary: '#F5F3FF', // violet-50
        accent: {
          green: '#10B981', // emerald-500
          red: '#EF4444',   // red-500
          blue: '#3B82F6',  // blue-500
          orange: '#F97316',// orange-500
        },
        neutral: {
          50: '#F9FAFB',  // gray-50
          100: '#F3F4F6', // gray-100
          200: '#E5E7EB', // gray-200
          300: '#D1D5DB', // gray-300
          400: '#9CA3AF', // gray-400
          500: '#6B7280', // gray-500
          600: '#4B5563', // gray-600
          700: '#374151', // gray-700
          800: '#1F2937', // gray-800
          900: '#111827', // gray-900
        }
      },
      borderRadius: {
        '4xl': '2rem',
      },
      boxShadow: {
        'main': '0 10px 40px -15px rgba(124, 58, 237, 0.4)',
        'card': '0 4px 20px -10px rgba(0, 0, 0, 0.05)',
      }
    },
  },
  plugins: [
    require('@tailwindcss/typography'),
  ],
}
