/** @type {import('tailwindcss').Config} */
export default {

  //darkMode: 'class', 
  darkMode: 'media',
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      backgroundImage: {
        'zigzag': 'repeating-linear-gradient(135deg, transparent 0, transparent 3px, gray 1px, purple 5px)',
      },
      // animation: {
      //   'looping-border': 'looping-border 4s linear infinite',
      // },
      // keyframes: {
      //   'looping-border': {
      //     '0%': { 'background-position': '0% 0%' },
      //     '100%': { 'background-position': '400% 400%' },
      //   },
      // },

      animation: {
        'border-loop': 'border-loop 4s linear infinite',
        swing: 'swing 0.8s ease-in-out',
      },
      keyframes: {
         glow: {
          '0%, 100%': { boxShadow: '0 0 5px #22c55e, 0 0 10px #22c55e' },
          '50%': { boxShadow: '0 0 20px #22c55e, 0 0 30px #22c55e' },
        },
      
      animation: {
        glow: 'glow 2s ease-in-out infinite',
      },
        'border-loop': {
          '0%': { 'background-position': '0% 0%' },
          '100%': { 'background-position': '200% 200%' },
        },
        swing: {
          '0%': { transform: 'rotate(3deg)' },
          '25%': { transform: 'rotate(-3deg)' },
          '50%': { transform: 'rotate(3deg)' },
          '75%': { transform: 'rotate(-3deg)' },
           '100%': { transform: 'rotate(0deg)' },
        },
      },
      boxShadow: {
        'custom-blue': '0 4px 6px -1px rgba(59, 130, 246, 0.5)', // Example with custom color
        'custom-red': '0 4px 6px -1px rgba(220, 38, 38, 0.5)',
      },
      colors: {//text-color,....
        darkBackground: '#1a202c', // Example of a dark background color
        darkText: '#ffffff', // White text for dark mode
        icon:'#FF6B00',
        // primary: '#FA7118',
          secondary: '#FF6B00',
          
          dprimary:'#3730A3',
          primary: '#4F46E5',
          // dprimary:'#5f5ffc',
          // primary: '#5f5ffc',

          // dprimary:'#008bcf',
          // primary: '#008bcf',


        tertiary: '#c7d2fe',
        background: '#f0f4f8',
        default: '#fff',
        'custom-dark': '#1e1e1e',
        'custom-light': '#ffffff',
        main: '#3490dc', // Your main color for light mode
        'main-dark': '#1e3a8a', // Your main color for dark mode
      },
      fontFamily: {//font-sans
        sans: ['Inter', 'Helvetica', 'Arial', 'sans-serif'],
        serif: ['Georgia', 'Cambria', 'Times New Roman', 'serif'],
        mono: ['Menlo', 'Monaco', 'Consolas', 'monospace'],
      },
      fontSize: {//text-size
        xxs: '0.6rem',
        xs: '0.75rem',
        sm: '0.875rem',
        base: '1rem',
        lg: '1.125rem',
        xl: '1.25rem',
        '2xl': '1.5rem',
        '3xl': '1.875rem',
        '4xl': '2.25rem',
        '5xl': '3rem',
      },
      fontWeight: {//font
        hairline: 100,
        thin: 200,
        light: 300,
        normal: 400,
        medium: 500,
        semibold: 600,
        bold: 700,
        extrabold: 800,
        black: 900,
      },
      lineHeight: {//leading-tight
        none: 1,
        tight: 1.25,
        snug: 1.375,
        normal: 1.5,
        relaxed: 1.625,
        loose: 2,
      },
      letterSpacing: {//tracking-tighter
        tighter: '-0.05em',
        tight: '-0.025em',
        normal: '0',
        wide: '0.025em',
        wider: '0.05em',
        widest: '0.1em',
      },
      spacing: {//p,m
        default: '1px',
        '0': '0',
        '0.5': '0.125rem',
        '1': '0.25rem',
        '1.5': '0.375rem',
        '2': '0.5rem',
        '2.5': '0.625rem',
        '3': '0.75rem',
        '3.5': '0.875rem',
        '4': '1rem',
        '5': '1.25rem',
        '6': '1.5rem',
        '8': '2rem',
        '10': '2.5rem',
        '12': '3rem',
        '16': '4rem',
        '20': '5rem',
        '23': '5.5rem',
        '24': '6rem',
        '32': '8rem',
        '35': '9rem',
        '40': '10rem',
        '45': '11rem',
        '48': '12rem',
        '56': '14rem',
        '64': '16rem',
        '80': '20rem',
        '90': '25rem',
      },
      screens: {//sm,md,lg,xl,2xl:
        'sm': '640px',
        'md': '768px',
        'lg': '1024px',
        'xl': '1280px',
        '2xl': '1536px',
      },
      borderWidth: {//border 0,2,4,8
        default: '1px',
        '0': '0',
        '2': '2px',
        '4': '4px',
        '8': '8px',
      },
      borderRadius: {//rounded-sm,....
        none: '0',
        sm: '0.125rem',
        defualt: '0.25rem',
        md: '0.375rem',
        lg: '0.5rem',
        xl: '1rem',
        '2xl': '2rem',
        '3xl': '3rem',
        full: '9999px',
      },
      opacity: {//opacity-0,25,50,75,100
        '0': '0',
        '25': '0.25',
        '50': '0.5',
        '75': '0.75',
        '100': '1',
      },
      zIndex: {//z-10,20,30,40,50
        auto: 'auto',
        '0': '0',
        '10': '10',
        '20': '20',
        '30': '30',
        '40': '40',
        '50': '50',
      },
      boxShadow: {//shadow-sm,none,outline,deualt,lg,.....
        sm: '0 1px 2px 0 rgba(0, 0, 0, 0.05)',
        default: '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)',
        lg: '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)',
        outline: '0 0 0 3px rgba(66, 153, 225, 0.5)',
        none: 'none',
      },
      scale: {
        '101': '1.01',
        '102': '1.02',
        '103': '1.03',
        '104': '1.04'
      }
    },
  },
  plugins: [],
}