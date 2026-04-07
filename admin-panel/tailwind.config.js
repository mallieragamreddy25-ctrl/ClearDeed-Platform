/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f0f6fb',
          100: '#e0ecf7',
          200: '#c1d9ef',
          300: '#a2c6e7',
          400: '#83b3df',
          500: '#64a0d7',
          600: '#4589ba',
          700: '#2b6699',
          800: '#003366',
          900: '#001f3f',
        },
        accent: {
          50: '#fafafa',
          100: '#f5f5f5',
          200: '#e0e0e0',
          300: '#cccccc',
          400: '#b3b3b3',
          500: '#999999',
          600: '#555555',
          700: '#333333',
          800: '#1a1a1a',
        },
        success: '#4CAF50',
        error: '#F44336',
        warning: '#FFC107',
        info: '#2196F3',
      },
      fontFamily: {
        sans: ['-apple-system', 'BlinkMacSystemFont', 'Segoe UI', 'Roboto', 'sans-serif'],
      },
      spacing: {
        xs: '4px',
        sm: '8px',
        md: '12px',
        lg: '16px',
        xl: '20px',
        '2xl': '24px',
        '3xl': '32px',
      },
    },
  },
  plugins: [require('@tailwindcss/forms')],
}
