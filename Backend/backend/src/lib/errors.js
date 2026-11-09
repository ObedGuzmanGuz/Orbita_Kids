/**
 * Error con código HTTP. El manejador de errores lo convierte en
 * `{ error: { code, message, details? } }`.
 *
 * La app interpreta 409 y 412 como conflicto (no reintenta ni sobrescribe) y
 * cualquier otro código como error temporal que se reintenta.
 */
export class HttpError extends Error {
  constructor(status, code, message, details) {
    super(message);
    this.status = status;
    this.code = code;
    this.details = details;
  }
}

export const badRequest = (message, details) => new HttpError(400, 'bad_request', message, details);
export const unauthorized = (message = 'Falta un token válido') => new HttpError(401, 'unauthorized', message);
export const forbidden = (message = 'No tienes permiso para esto', code = 'forbidden') =>
  new HttpError(403, code, message);
export const notFound = (message = 'No encontrado') => new HttpError(404, 'not_found', message);
export const conflict = (message, code = 'conflict') => new HttpError(409, code, message);
export const preconditionFailed = (message = 'El servidor tiene una versión más reciente') =>
  new HttpError(412, 'version_mismatch', message);
