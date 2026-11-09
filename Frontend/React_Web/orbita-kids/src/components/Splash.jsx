// Pantalla breve mientras se abren o descargan los datos de la cuenta.
export default function Splash({ text, action }) {
  return (
    <div className="splash" role="status" aria-live="polite">
      <span className="splash__orbit" aria-hidden />
      <p>{text}</p>
      {action && (
        <button type="button" className="btn btn--primary" onClick={action.onClick}>
          {action.label}
        </button>
      )}
    </div>
  )
}
