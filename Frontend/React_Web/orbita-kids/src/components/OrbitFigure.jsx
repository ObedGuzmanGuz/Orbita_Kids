// Ilustración «Órbita» de la portada (nodo 96:961). Se compone con los vectores
// exportados de Figma, en las mismas posiciones relativas del diseño.
import group from '../assets/hero/group.svg'
import ring1 from '../assets/hero/ring1.svg'
import ring2 from '../assets/hero/ring2.svg'
import ring3 from '../assets/hero/ring3.svg'
import core from '../assets/hero/core.svg'
import dot from '../assets/hero/dot.svg'
import dotA from '../assets/hero/dot-a.svg'
import dotB from '../assets/hero/dot-b.svg'
import dotC from '../assets/hero/dot-c.svg'
import badgeRing from '../assets/hero/badge-ring.svg'
import badgeDot from '../assets/hero/badge-dot.svg'
import './orbit-figure.css'

const at = (inset) => ({ inset })

const LAYERS = [
  { src: group, inset: '1.54% 8.71% 1.54% 9.36%' },
  { src: ring1, inset: '7.31% 14.19%', bleed: '-0.17%' },
  { src: ring2, inset: '21.15% 25.81%', bleed: '-0.25%' },
  { src: ring3, inset: '35% 37.42%', bleed: '-0.48%' },
  { src: core, inset: '43.46% 44.52%' },
  { src: dot, inset: '48.65% 36.29% 48.65% 61.45%' },
  { src: dot, inset: '61.37% 42.21% 35.94% 55.53%' },
  { src: dot, inset: '61.9% 54.77% 35.4% 42.97%' },
  { src: dot, inset: '49.96% 61.4% 47.35% 36.34%' },
  { src: dot, inset: '38.62% 58.23% 58.69% 39.52%' },
  { src: dotA, inset: '60.94% 27.03% 36.56% 70.87%', bleed: '-7.69%' },
  { src: dotA, inset: '77.48% 51.06% 20.02% 46.84%', bleed: '-7.69%' },
  { src: dotB, inset: '63.17% 69.9% 34.33% 28%', bleed: '-7.69%' },
  { src: dotC, inset: '36.56% 70.87% 60.94% 27.03%', bleed: '-7.69%' },
]

const STUDENTS = [
  { name: 'Leonardo F.', score: '58 % de aciertos', ring: '22.44% 18.08% 71.4% 76.76%', dot: '23.98% 19.37% 72.94% 78.05%', name_at: '22.25% 4.47% 74.22% 82.56%', score_at: '26% 2.62% 70.91% 82.56%' },
  { name: 'Diego L.', score: '61 % de aciertos', ring: '74.37% 19.98% 19.48% 74.85%', dot: '75.9% 21.27% 21.02% 76.14%', name_at: '74.17% 10.26% 22.29% 80.66%', score_at: '77.92% 5.08% 18.99% 80.66%' },
  { name: 'Valeria P.', score: '65 % de aciertos', ring: '80.56% 69.47% 13.29% 25.37%', dot: '82.1% 70.76% 14.83% 26.66%', name_at: '80.37% 75.44% 16.1% 14.38%', score_at: '84.12% 75.3% 12.79% 9.89%', right: true },
]

export default function OrbitFigure() {
  return (
    <figure className="orbit">
      <div className="orbit__art" role="img" aria-label="Diagrama del grupo 2.º A: estudiantes al día, sin actividad reciente y que necesitan apoyo">
        {LAYERS.map((layer, i) => (
          <div key={i} className="orbit__layer" style={at(layer.inset)}>
            {layer.bleed ? (
              <div className="orbit__layer" style={at(layer.bleed)}>
                <img src={layer.src} alt="" className="orbit__fill" />
              </div>
            ) : (
              <img src={layer.src} alt="" className="orbit__fill" />
            )}
          </div>
        ))}
        <p className="orbit__label orbit__label--core" style={at('47.88% 46.95% 47.7% 46.94%')}>2.º A</p>
        <p className="orbit__label" style={at('33.37% 47.5% 63.54% 47.5%')}>Al día</p>
        <p className="orbit__label" style={at('19.52% 40.19% 77.39% 39.81%')}>Sin actividad en 3 días</p>
        <p className="orbit__label orbit__label--warn" style={at('5.67% 43.13% 91.24% 42.8%')}>Necesita apoyo</p>
        {STUDENTS.map((s) => (
          <div key={s.name}>
            <div className="orbit__layer" style={at(s.ring)}><img src={badgeRing} alt="" className="orbit__fill" /></div>
            <div className="orbit__layer" style={at(s.dot)}><img src={badgeDot} alt="" className="orbit__fill" /></div>
            <p className={`orbit__student${s.right ? ' is-right' : ''}`} style={at(s.name_at)}>{s.name}</p>
            <p className={`orbit__label${s.right ? ' is-right' : ''}`} style={{ inset: s.score_at, textAlign: s.right ? 'right' : 'left' }}>{s.score}</p>
          </div>
        ))}
      </div>
      <figcaption className="orbit__legend">
        <ul>
          <li><span className="orbit__key orbit__key--ok" />Al día: 5</li>
          <li><span className="orbit__key orbit__key--idle" />Sin actividad reciente: 4</li>
          <li><span className="orbit__key orbit__key--warn" />Necesitan apoyo: 3</li>
        </ul>
        <p>2.º A, grupo de demostración</p>
      </figcaption>
    </figure>
  )
}
