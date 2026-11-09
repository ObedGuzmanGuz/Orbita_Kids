import { HttpError } from '../lib/errors.js';

export function notFoundHandler(req, res) {
  res.status(404).json({ error: { code: 'not_found', message: `No existe ${req.method} ${req.path}` } });
}

// Express reconoce el manejador de errores por sus 4 parámetros.
export function errorHandler(err, req, res, _next) {
  if (err instanceof HttpError) {
    return res.status(err.status).json({
      error: { code: err.code, message: err.message, ...(err.details && { details: err.details }) },
    });
  }
  // JSON mal formado (express.json).
  if (err?.type === 'entity.parse.failed') {
    return res.status(400).json({ error: { code: 'bad_json', message: 'El cuerpo no es JSON válido' } });
  }
  req.log.error({ err }, 'Error no controlado');
  // 5xx: la app lo reintenta con espera exponencial.
  res.status(500).json({ error: { code: 'internal', message: 'Error interno del servidor' } });
}
