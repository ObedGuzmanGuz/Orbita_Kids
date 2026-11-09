import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbita_kids/config/themes/app_themes.dart';
import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/shared/presentation/art/mascot.dart';
import 'package:orbita_kids/features/auth/presentation/providers/auth_controller.dart';
import 'package:orbita_kids/features/auth/domain/entities/auth_entities.dart';
import 'package:orbita_kids/features/auth/presentation/widgets/auth_ui.dart';

/// 09 · Estados de autenticación. Toda variante tiene salida.
class AuthStateScreen extends ConsumerWidget {
  const AuthStateScreen({super.key, required this.code, required this.method});

  final AuthFailureCode code;
  final AuthMethod method;

  static const _data =
      <
        AuthFailureCode,
        (String, String, String, String, String?, String?, String)
      >{
        // (pose, título, texto, acción A, ruta A, acción B, código)
        AuthFailureCode.cancelled: (
          'think',
          'Acceso cancelado',
          'Cerraste la ventana antes de terminar. No pasó nada: puedes intentarlo otra vez.',
          'Volver a intentar',
          'retry',
          'Elegir otro método',
          'access_denied',
        ),
        AuthFailureCode.providerError: (
          'surprised',
          'El proveedor tuvo un problema',
          '{P} devolvió un error. Espera un momento y vuelve a intentarlo, o elige otro método.',
          'Volver a intentar',
          'retry',
          'Elegir otro método',
          'idp_error',
        ),
        AuthFailureCode.notRegistered: (
          'explore',
          'Aún no tienes cuenta',
          'Esta identidad de {P} no está registrada en Órbita Kids. Crea tu cuenta o pide un código de grupo a tu escuela.',
          'Crear cuenta',
          AppRoutes.register,
          'Volver',
          'user_not_found',
        ),
        AuthFailureCode.blocked: (
          'rest',
          'Cuenta en pausa',
          'La escuela pausó esta cuenta por ahora. Habla con tu maestra o con la dirección para reactivarla.',
          'Entendido',
          AppRoutes.login,
          'Ayuda',
          'account_disabled',
        ),
        AuthFailureCode.noRole: (
          'think',
          'Tu cuenta aún no tiene rol',
          'Tu identidad es válida, pero el servidor todavía no te asignó como estudiante o docente. Tu institución debe autorizarlo.',
          'Entendido',
          AppRoutes.login,
          'Ayuda',
          'role_missing',
        ),
        AuthFailureCode.unavailable: (
          'rest',
          'Proveedor no disponible',
          '{P} no responde en este momento. Prueba con otro método o más tarde.',
          'Elegir otro método',
          AppRoutes.login,
          'Volver a intentar',
          'temporarily_unavailable',
        ),
        AuthFailureCode.expired: (
          'rest',
          'Tu sesión terminó',
          'Por seguridad, la sesión venció. Entra otra vez para continuar. Tus resultados guardados siguen protegidos en este teléfono.',
          'Entrar de nuevo',
          AppRoutes.login,
          null,
          'token_expired',
        ),
        AuthFailureCode.network: (
          'think',
          'Sin conexión',
          'Para entrar por primera vez, registrarte o recuperar tu cuenta se necesita Internet.',
          'Reintentar',
          'retry',
          'Volver',
          'network_error',
        ),
        AuthFailureCode.linking: (
          'point',
          'Vincular cuentas',
          'Ya existe una cuenta de Órbita Kids con este correo. Para vincular {P}, entra primero con tu cuenta actual y confirma la vinculación en la página segura de Keycloak.',
          'Entrar con mi cuenta',
          AppRoutes.login,
          'Ahora no',
          'account_link',
        ),
        AuthFailureCode.backend: (
          'surprised',
          'No pudimos confirmar tus permisos',
          'Keycloak validó tu identidad, pero el servidor de Órbita Kids no respondió. No se guardó ningún cambio. Inténtalo en un momento.',
          'Volver a intentar',
          'retry',
          'Volver',
          'backend_unavailable',
        ),
        AuthFailureCode.notConfigured: (
          'think',
          'Acceso no configurado',
          'Esta instalación no tiene Keycloak configurado. Usa las cuentas de demostración o pide al equipo técnico la configuración.',
          'Volver',
          AppRoutes.login,
          'Ayuda',
          'not_configured',
        ),
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = _data[code]!;
    final p = method == AuthMethod.institution
        ? 'tu institución'
        : method.label;
    final c = context.ok;

    void act(String route) {
      if (code == AuthFailureCode.expired) {
        ref.read(authControllerProvider.notifier).clearExpired();
      }
      if (route == 'retry') {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.login);
        }
        if (method != AuthMethod.orbita) {
          final demo = ref.read(authRepositoryProvider).isDemo;
          if (!demo) runKeycloakSignIn(ref, method);
        }
        return;
      }
      context.go(route);
    }

    final bRoute = switch (d.$6) {
      'Ayuda' => AppRoutes.help,
      'Elegir otro método' || 'Volver' || 'Ahora no' => AppRoutes.login,
      'Volver a intentar' => 'retry',
      _ => AppRoutes.login,
    };

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: c.tintViolet,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Mascot.orbi(pose: d.$1, size: 130),
                ),
                Gap.h18,
                Semantics(
                  header: true,
                  child: Text(
                    d.$2,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                Gap.h8,
                Text(
                  d.$3.replaceAll('{P}', p),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: c.muted, fontSize: 16),
                ),
                Gap.h22,
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => act(d.$5!),
                    child: Text(d.$4),
                  ),
                ),
                if (d.$6 != null) ...[
                  Gap.h10,
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => act(bRoute),
                      child: Text(d.$6!),
                    ),
                  ),
                ],
                Gap.h16,
                SelectableText(
                  'Código para soporte: ${d.$7}',
                  style: TextStyle(
                    color: c.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Gap.h8,
                if (code != AuthFailureCode.expired)
                  const DemoModeBanner(compact: true),
                if (code == AuthFailureCode.expired)
                  const Icon(Icons.shield_outlined, color: Brand.violet),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
