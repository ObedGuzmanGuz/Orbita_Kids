import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import '@fontsource-variable/red-hat-display'
import '@fontsource-variable/red-hat-text'
import '@fontsource/red-hat-mono/latin-500.css'
import './index.css'
import './styles/ui.css'
import App from './App.jsx'

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
