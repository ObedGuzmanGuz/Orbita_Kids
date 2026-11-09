import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:orbita_kids/config/providers/core_providers.dart';
import 'package:orbita_kids/config/routes/app_router.dart';
import 'package:orbita_kids/shared/presentation/widgets/ui.dart';
import 'package:orbita_kids/features/auth/presentation/providers/auth_controller.dart';
import 'package:orbita_kids/features/auth/domain/entities/auth_entities.dart';

/// Aviso visible de modo demo (sin Keycloak configurado).
class DemoModeBanner extends ConsumerWidget {
  const DemoModeBanner({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cfg = ref.watch(appConfigProvider);
    if (!cfg.isDemo) return const SizedBox.shrink();
    final text = cfg.devServer
        ? (compact
              ? 'MODO DEMO CON SERVIDOR · cuentas de prueba; los datos van al servidor de desarrollo.'
              : 'MODO DEMO CON SERVIDOR · Keycloak no está configurado. Las cuentas son de prueba, pero el progreso, las actividades y los reportes se envían al servidor de desarrollo (${cfg.apiBaseUrl}).')
        : (compact
              ? 'MODO DEMO · datos ficticios, sin servidor.'
              : 'MODO DEMO · Keycloak no está configurado. Las cuentas e identidades son de demostración: no se conecta con Google, Facebook ni con tu escuela, y nada se envía a un servidor.');
    return Semantics(
      container: true,
      label: 'Modo demo',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Brand.yellow,
          borderRadius: AppRadius.field,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.science_rounded, color: Brand.ink),
            Gap.w10,
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Brand.ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Inicia el flujo de Keycloak y dirige al estado correspondiente.
Future<void> runKeycloakSignIn(
  WidgetRef ref,
  AuthMethod method, {
  bool remember = true,
  bool register = false,
}) async {
  final router = ref.read(routerProvider);
  try {
    await ref
        .read(authControllerProvider.notifier)
        .signInWithKeycloak(method, remember: remember, register: register);
    final auth = ref.read(authControllerProvider);
    router.go(
      AppRoutes.loadingTo(
        homeFor(auth),
        message: 'Conectando con Keycloak',
        sub: method == AuthMethod.orbita
            ? 'Cuenta Órbita Kids'
            : 'Con ${method.label}',
        authFlow: true,
      ),
    );
  } on AuthFailure catch (f) {
    router.push(AppRoutes.authState(f.code.name, method: method.name));
  }
}

/// Lleva al inicio tras entrar en modo demo (sin simular pasos de Keycloak).
void goHomeAfterDemoSignIn(WidgetRef ref) {
  final auth = ref.read(authControllerProvider);
  ref
      .read(routerProvider)
      .go(
        AppRoutes.loadingTo(
          homeFor(auth),
          message: '¡Hola, ${auth.user?.name ?? ''}!',
          sub: 'Entrando en modo demo',
        ),
      );
}

/// Botón de proveedor de identidad.
class IdpButton extends StatelessWidget {
  const IdpButton({
    super.key,
    required this.logo,
    required this.label,
    required this.sub,
    required this.onTap,
    this.enabled = true,
  });

  final Widget logo;
  final String label;
  final String sub;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: enabled,
    label: '$label. ${enabled ? sub : 'Requiere Internet'}',
    excludeSemantics: true,
    child: Opacity(
      opacity: enabled ? 1 : .55,
      child: Material(
        color: Colors.white,
        borderRadius: AppRadius.card,
        child: InkWell(
          borderRadius: AppRadius.card,
          onTap: enabled ? onTap : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 60),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  SizedBox(width: 30, child: Center(child: logo)),
                  Gap.w14,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            color: Brand.ink,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          enabled ? sub : 'Requiere Internet',
                          style: const TextStyle(
                            color: Color(0xFF66638A),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF66638A),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Logotipo «G» de Google (marca del proveedor, solo como identificador).
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 24});
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(size: Size.square(size), painter: _GPainter()),
  );
}

class _GPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final r = Rect.fromLTWH(
      s.width * .1,
      s.height * .1,
      s.width * .8,
      s.height * .8,
    );
    final w = s.width * .18;
    Paint p(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = w;
    canvas.drawArc(r, -0.8, -1.6, false, p(const Color(0xFFEA4335)));
    canvas.drawArc(r, -2.4, -1.4, false, p(const Color(0xFFFBBC05)));
    canvas.drawArc(r, 2.5, -1.7, false, p(const Color(0xFF34A853)));
    canvas.drawArc(r, 0.8, -0.8, false, p(const Color(0xFF4285F4)));
    canvas.drawLine(
      Offset(s.width * .5, s.height * .5),
      Offset(s.width * .9, s.height * .5),
      p(const Color(0xFF4285F4)),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Logotipo «f» de Facebook (marca del proveedor, solo como identificador).
class FacebookLogo extends StatelessWidget {
  const FacebookLogo({super.key, this.size = 24});
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFF1877F2),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.bottomCenter,
      child: Text(
        'f',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: size * .82,
          height: 1.05,
        ),
      ),
    ),
  );
}

/// Campo de contraseña con mostrar/ocultar.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.label = 'Contraseña',
    this.errorText,
    this.onSubmitted,
    this.dark = false,
    this.autofill = AutofillHints.password,
    this.style,
  });

  final TextEditingController controller;
  final String label;
  final String? errorText;
  final ValueChanged<String>? onSubmitted;
  final bool dark;
  final String autofill;

  /// Estilo del texto escrito (p. ej. tinta oscura sobre el campo blanco del login).
  final TextStyle? style;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool show = false;

  @override
  Widget build(BuildContext context) => TextField(
    controller: widget.controller,
    obscureText: !show,
    style: widget.style,
    autofillHints: [widget.autofill],
    textInputAction: TextInputAction.done,
    onSubmitted: widget.onSubmitted,
    decoration: InputDecoration(
      labelText: widget.label,
      errorText: widget.errorText,
      prefixIcon: const Icon(Icons.lock_outline_rounded),
      suffixIcon: IconButton(
        tooltip: show ? 'Ocultar contraseña' : 'Mostrar contraseña',
        icon: Icon(
          show ? Icons.visibility_off_rounded : Icons.visibility_rounded,
        ),
        onPressed: () => setState(() => show = !show),
      ),
    ),
  );
}

/// Reglas de contraseña visibles mientras se escribe.
class PasswordRules extends StatelessWidget {
  const PasswordRules({super.key, required this.value, this.min = 8});
  final String value;
  final int min;

  static List<(String, bool)> rulesFor(String v, int min) => [
    ('Al menos $min caracteres', v.length >= min),
    (
      'Una letra y un número',
      RegExp(r'[A-Za-z]').hasMatch(v) && RegExp(r'\d').hasMatch(v),
    ),
  ];

  static bool valid(String v, int min) => rulesFor(v, min).every((r) => r.$2);

  @override
  Widget build(BuildContext context) {
    final c = context.ok;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (t, ok) in rulesFor(value, min))
          Semantics(
            label: '$t: ${ok ? 'cumplido' : 'pendiente'}',
            excludeSemantics: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(
                    ok ? Icons.check_circle_rounded : Icons.circle_outlined,
                    size: 18,
                    color: ok ? c.ok : c.muted,
                  ),
                  Gap.w6,
                  Text(
                    t,
                    style: TextStyle(
                      color: ok ? c.ok : c.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Seis casillas con avance automático y pegado.
class CodeBoxes extends StatefulWidget {
  const CodeBoxes({super.key, required this.onChanged, this.error = false});
  final ValueChanged<String> onChanged;
  final bool error;

  @override
  State<CodeBoxes> createState() => _CodeBoxesState();
}

class _CodeBoxesState extends State<CodeBoxes> {
  final _c = List.generate(6, (_) => TextEditingController());
  final _f = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _c) {
      c.dispose();
    }
    for (final f in _f) {
      f.dispose();
    }
    super.dispose();
  }

  void _changed(int i, String v) {
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 1) {
      // Pegado de varios dígitos.
      for (var k = 0; k < 6; k++) {
        _c[k].text = k < digits.length ? digits[k] : '';
      }
      _f[(digits.length).clamp(0, 5)].requestFocus();
    } else {
      _c[i].text = digits;
      if (digits.isNotEmpty && i < 5) _f[i + 1].requestFocus();
      if (digits.isEmpty && i > 0) _f[i - 1].requestFocus();
    }
    widget.onChanged(_c.map((c) => c.text).join());
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ok;
    return Semantics(
      label: 'Código de 6 dígitos',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < 6; i++)
            Container(
              width: 46,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: TextField(
                controller: _c[i],
                focusNode: _f[i],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: AppTextStyles.number(24, color: c.ink),
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: widget.error ? c.err : c.line,
                      width: 2,
                    ),
                  ),
                  semanticCounterText: 'Dígito ${i + 1}',
                ),
                onChanged: (v) => _changed(i, v),
              ),
            ),
        ],
      ),
    );
  }
}
