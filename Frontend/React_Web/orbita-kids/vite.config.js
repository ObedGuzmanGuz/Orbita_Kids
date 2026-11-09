import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'
import { VitePWA } from 'vite-plugin-pwa'
import pkg from './package.json' with { type: 'json' }

// Publica la versión para que la app instalada pueda decir a qué versión se actualizará (pantalla 14).
const versionFile = () => ({
  name: 'orbita-version-file',
  generateBundle() {
    this.emitFile({ type: 'asset', fileName: 'version.json', source: JSON.stringify({ version: pkg.version }) })
  },
})

// En desarrollo, Vite (puerto 5173) reenvía /api al backend (puerto 3001): para el navegador es el mismo origen.
const api = { '/api': { target: 'http://localhost:3001', changeOrigin: false } }

// https://vite.dev/config/
export default defineConfig({
  server: { proxy: api },
  preview: { proxy: api },
  define: {
    __APP_VERSION__: JSON.stringify(pkg.version),
  },
  plugins: [
    react(),
    versionFile(),
    VitePWA({
      // «prompt»: la app avisa cuando hay una versión nueva (pantalla 14) y el usuario decide cuándo actualizar.
      registerType: 'prompt',
      includeAssets: ['favicon.png', 'apple-touch-icon.png'],
      manifest: {
        id: '/',
        name: 'Órbita Kids',
        short_name: 'Órbita Kids',
        description:
          'Panel para docentes y direcciones de primaria: avance de sumas, actividades y administración de la escuela, aun sin conexión.',
        lang: 'es-MX',
        dir: 'ltr',
        start_url: '/app?source=pwa',
        scope: '/',
        display: 'standalone',
        display_override: ['window-controls-overlay', 'standalone'],
        orientation: 'any',
        background_color: '#0b0d24',
        theme_color: '#191b58',
        categories: ['education', 'productivity'],
        icons: [
          { src: '/pwa-192.png', sizes: '192x192', type: 'image/png' },
          { src: '/pwa-512.png', sizes: '512x512', type: 'image/png' },
          { src: '/pwa-maskable-512.png', sizes: '512x512', type: 'image/png', purpose: 'maskable' },
        ],
        shortcuts: [
          { name: 'Crear actividad', url: '/docente/actividades/nueva', icons: [{ src: '/pwa-192.png', sizes: '192x192' }] },
          { name: 'Mis grupos', url: '/docente/grupos', icons: [{ src: '/pwa-192.png', sizes: '192x192' }] },
        ],
      },
      workbox: {
        globPatterns: ['**/*.{js,css,html,svg,png,woff2}'],
        navigateFallback: '/index.html',
        // La API nunca se responde desde la caché del service worker: sus datos viven cifrados en IndexedDB.
        navigateFallbackDenylist: [/^\/api\//],
        cleanupOutdatedCaches: true,
      },
      devOptions: {
        enabled: false,
      },
    }),
  ],
})
