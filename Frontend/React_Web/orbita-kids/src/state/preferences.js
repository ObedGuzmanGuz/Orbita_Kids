import { useCallback, useEffect, useState } from 'react'

// Preferencias de este equipo. También se envían a la cuenta, así que llegan al entrar en otro equipo.
const KEY = 'orbita-kids:prefs'
const EVENT = 'orbita-kids:prefs'
export const PREF_KEYS = ['theme', 'largeText', 'reduceMotion', 'captureLinks']
const DEFAULTS = { theme: 'light', largeText: false, reduceMotion: false, captureLinks: true }

export function readPreferences() {
  try {
    return { ...DEFAULTS, ...JSON.parse(localStorage.getItem(KEY)) }
  } catch {
    return { ...DEFAULTS }
  }
}

export function applyPreferences(prefs) {
  const root = document.documentElement
  root.classList.toggle('pref-large-text', !!prefs.largeText)
  root.classList.toggle('pref-reduce-motion', !!prefs.reduceMotion)
}

export function writePreferences(prefs) {
  const next = { ...DEFAULTS, ...prefs }
  try {
    localStorage.setItem(KEY, JSON.stringify(next))
  } catch {
    /* sin almacenamiento */
  }
  applyPreferences(next)
  window.dispatchEvent(new CustomEvent(EVENT, { detail: next }))
  return next
}

export function usePreferences() {
  const [prefs, setPrefs] = useState(readPreferences)

  useEffect(() => {
    const onChange = (e) => setPrefs(e.detail)
    window.addEventListener(EVENT, onChange)
    return () => window.removeEventListener(EVENT, onChange)
  }, [])

  const set = useCallback((key, value) => setPrefs(writePreferences({ ...readPreferences(), [key]: value })), [])
  return [prefs, set]
}
