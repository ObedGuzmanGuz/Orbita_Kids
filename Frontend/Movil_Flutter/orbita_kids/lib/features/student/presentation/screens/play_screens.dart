import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/core/audio/speech.dart';
import 'package:orbita_kids/core/notifications/local_notifier.dart';
import 'package:orbita_kids/config/providers/core_providers.dart';
import 'package:orbita_kids/features/settings/presentation/providers/settings_controller.dart';
import 'package:orbita_kids/core/sync/presentation/providers/sync_controller.dart';
import 'package:orbita_kids/shared/presentation/art/mascot.dart';
import 'package:orbita_kids/shared/presentation/art/space_art.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';
import 'package:orbita_kids/shared/presentation/widgets/ui.dart';
import 'package:orbita_kids/features/auth/presentation/providers/auth_controller.dart';
import 'package:orbita_kids/features/student/presentation/providers/student_controller.dart';
import 'package:orbita_kids/features/student/domain/services/mission_engine.dart';

const _uuid = Uuid();

const _obj = {
  'star': (
    'estrellas',
    'estrella',
    '¿Cuántas estrellas hay en total?',
    'todas las estrellas juntas',
  ),
  'planet': (
    'planetas',
    'planeta',
    '¿Cuántos planetas hay en total?',
    'todos los planetas juntos',
  ),
  'rocket': (
    'cohetes',
    'cohete',
    '¿Cuántos cohetes hay en total?',
    'todos los cohetes juntos',
  ),
};

/// 20 · 21 · Ejercicio en curso (apoyo visual o selección).
class PlayScreen extends ConsumerStatefulWidget {
  const PlayScreen({super.key});

  @override
  ConsumerState<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends ConsumerState<PlayScreen> {
  String typed = '';

  /// null | hint | reveal | ok | bad
  String? state;
  bool shake = false;
  bool showHint = false;
  final wrong = <int>[];
  int? picked;
  int _spokenIndex = -1;

  MissionRun? get run => ref.read(runProvider);

  void _reset() {
    typed = '';
    state = null;
    shake = false;
    showHint = false;
    wrong.clear();
    picked = null;
  }

  void _feedback(bool ok) {
    if (!ref.read(settingsProvider).sounds) return;
    ok ? HapticFeedback.lightImpact() : HapticFeedback.mediumImpact();
  }

  void _checkVisual() {
    final r = run!;
    if (typed.isEmpty) return;
    final ok = r.answer(int.parse(typed), _uuid.v4());
    _feedback(ok);
    setState(() {
      if (ok) {
        state = 'ok';
        shake = false;
      } else if (r.tries == 1) {
        state = 'hint';
        shake = true;
        typed = '';
      } else {
        state = 'reveal';
        shake = true;
      }
    });
  }

  void _pick(int v) {
    final r = run!;
    final ok = r.answer(v, _uuid.v4());
    _feedback(ok);
    setState(() {
      if (ok) {
        state = 'ok';
        picked = v;
      } else {
        wrong.add(v);
        state = r.tries >= 2 ? 'reveal' : 'bad';
      }
    });
  }

  void _next() {
    final r = run!;
    r.next();
    ref.read(runProvider.notifier).touch();
    if (r.finished) {
      context.pushReplacement(AppRoutes.results);
      return;
    }
    setState(_reset);
  }

  Future<void> _quit() async {
    final leave = await confirm(
      context,
      title: '¿Salir de la misión?',
      text: 'Si sales ahora, esta misión no se guardará. Podrás empezarla de nuevo cuando quieras.',
      ok: 'Salir',
      cancel: 'Seguir jugando',
    );
    if (leave && mounted) {
      ref.read(runProvider.notifier).clear();
      context.pop();
    }
  }

  void _autoRead(MissionRun r) {
    if (_spokenIndex == r.index || !ref.read(settingsProvider).readAloud) {
      return;
    }
    _spokenIndex = r.index;
    final it = r.current;
    final q = it.kind == MissionType.visual
        ? _obj[it.object]!.$3
        : '¿Cuánto es';
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.speak(
        '$q ${it.a} más ${it.b}${it.kind == MissionType.visual ? '' : '?'}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = ref.watch(runProvider);
    if (r == null || r.finished) {
      return OkPage(
        title: 'Misión',
        children: [
          const InfoBanner(text: 'No hay una misión en curso.'),
          Gap.h12,
          FilledButton(
            onPressed: () => context.go(AppRoutes.map),
            child: const Text('Ir al mapa'),
          ),
        ],
      );
    }
    _autoRead(r);
    final it = r.current;
    final c = context.ok;
    final name = ref.watch(studentProvider.select((s) => s.name));
    final visual = it.kind == MissionType.visual;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _quit();
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: const Alignment(0, -.2),
              colors: [c.soft, c.bg],
            ),
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _RunHeader(run: r, onQuit: _quit),
                if (r.ruleJustApplied) ...[
                  Gap.h10,
                  const InfoBanner(
                    icon: Icons.auto_awesome_rounded,
                    title: 'Activamos ayuda con dibujos para las siguientes sumas.',
                    text: 'R1 · 2 errores seguidos → apoyo visual',
                  ),
                ],
                Gap.h12,
                if (visual)
                  ..._visual(context, r, it, name)
                else
                  ..._choice(context, r, it, name),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _visual(
    BuildContext context,
    MissionRun r,
    SumItem it,
    String name,
  ) {
    final c = context.ok;
    final show =
        state == 'hint' || state == 'reveal' || state == 'ok' || r.support;
    final tens = r.level >= 5 && !r.support;
    final q = tens ? 'Suma las decenas y las unidades' : _obj[it.object]!.$3;
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              q,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: c.muted,
                fontSize: 15,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Escuchar en voz alta',
            onPressed: () => ref.speak('$q ${it.a} más ${it.b}'),
            icon: Icon(Icons.volume_up_rounded, color: c.purpleDark),
          ),
        ],
      ),
      Semantics(
        liveRegion: true,
        label:
            '${it.a} más ${it.b} igual a ${state == 'reveal'
                ? it.answer
                : typed.isEmpty
                ? 'tu respuesta'
                : typed}',
        excludeSemantics: true,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${it.a} + ${it.b} =',
                style: AppTextStyles.number(42, color: c.ink),
              ),
              Gap.w12,
              _Shake(
                key: ValueKey('shake$shake${r.tries}'),
                active: shake && !reduceMotion(context, ref),
                child: Container(
                  width: 92,
                  height: 70,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: state == 'ok' ? c.okBg : c.card,
                    borderRadius: AppRadius.card,
                    border: Border.all(
                      width: 3,
                      color: state == 'ok'
                          ? c.ok
                          : shake
                          ? c.err
                          : Brand.purple,
                    ),
                  ),
                  child: Text(
                    state == 'reveal'
                        ? '${it.answer}'
                        : (typed.isEmpty ? '?' : typed),
                    style: AppTextStyles.number(38, color: c.ink),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Gap.h14,
      _ObjectsCard(item: it, show: show, level: r.support ? 1 : r.level),
      Gap.h12,
      if (state == 'ok')
        OrbiSays(
          text: '¡Excelente! ${it.a} + ${it.b} = ${it.answer}',
          pose: 'celebrate',
        )
      else if (state == 'hint')
        OrbiSays(
          pose: 'think',
          text: tens
              ? (r.level == 6
                    ? '¡Casi! Suma las unidades: si llegan a 10 o más, forman una decena nueva.'
                    : '¡Casi! Junta primero las barras (decenas) y luego los puntos (unidades).')
              : '¡Casi! Cuenta ${_obj[it.object]!.$4}. Ya les pusimos números.',
        )
      else if (state == 'reveal')
        OrbiSays(
          pose: 'point',
          text: tens
              ? 'La respuesta es ${it.answer}. ${it.a ~/ 10 + it.b ~/ 10} decenas y ${it.a % 10 + it.b % 10} unidades.'
              : 'La respuesta es ${it.answer}. Contamos ${it.a} y luego ${it.b} más: llegamos a ${it.answer}.',
        ),
      if (state == 'ok' || state == 'reveal') ...[
        Gap.h14,
        FilledButton.icon(
          onPressed: _next,
          icon: const Icon(Icons.arrow_forward_rounded),
          label: const Text('Continuar'),
        ),
      ] else ...[
        Gap.h6,
        _Keypad(
          onKey: (n) => setState(() {
            if (typed.length >= 2) return;
            typed = '${typed == '0' ? '' : typed}$n';
            shake = false;
          }),
        ),
        Gap.h10,
        Row(
          children: [
            SizedBox(
              width: 84,
              child: OutlinedButton(
                onPressed: typed.isEmpty
                    ? null
                    : () => setState(() {
                        typed = typed.substring(0, typed.length - 1);
                        shake = false;
                      }),
                child: const Icon(
                  Icons.backspace_outlined,
                  semanticLabel: 'Borrar',
                ),
              ),
            ),
            Gap.w10,
            Expanded(
              child: FilledButton(
                onPressed: typed.isEmpty ? null : _checkVisual,
                child: const Text('Comprobar'),
              ),
            ),
          ],
        ),
        if (state == null) ...[
          Gap.h14,
          OrbiSays(
            text: r.index == 0
                ? '¡Vamos, $name! Cuenta con calma.'
                : '¡Tú puedes, $name!',
            pose: 'wave',
            size: 64,
          ),
        ],
      ],
    ];
  }

  List<Widget> _choice(
    BuildContext context,
    MissionRun r,
    SumItem it,
    String name,
  ) {
    final c = context.ok;
    final done = state == 'ok' || state == 'reveal';
    return [
      OkCard(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '¿Cuánto es…?',
                  style: TextStyle(fontWeight: FontWeight.w800, color: c.muted),
                ),
                IconButton(
                  tooltip: 'Escuchar en voz alta',
                  onPressed: () => ref.speak('¿Cuánto es ${it.a} más ${it.b}?'),
                  icon: Icon(Icons.volume_up_rounded, color: c.purpleDark),
                ),
              ],
            ),
            Semantics(
              label: '${it.a} más ${it.b}',
              excludeSemantics: true,
              child: Text(
                '${it.a} + ${it.b}',
                style: AppTextStyles.number(56, color: c.ink),
              ),
            ),
            if (showHint) ...[
              Gap.h10,
              _ObjectsCard(item: it, show: true, level: r.level, flat: true),
            ],
          ],
        ),
      ),
      Gap.h14,
      Semantics(
        label: 'Opciones de respuesta',
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.1,
          children: [
            for (final o in it.options)
              _OptionButton(
                value: o,
                good:
                    (state == 'ok' && o == picked) ||
                    (state == 'reveal' && o == it.answer),
                bad: wrong.contains(o),
                enabled: !done && !wrong.contains(o),
                onTap: () => _pick(o),
              ),
          ],
        ),
      ),
      Gap.h12,
      if (state == 'ok')
        OrbiSays(
          text: '¡Muy bien! ${it.a} + ${it.b} = ${it.answer}',
          pose: 'celebrate',
        )
      else if (state == 'bad')
        const OrbiSays(
          text: 'Esa no es. Intenta otra vez. ¿Quieres una pista?',
          pose: 'think',
        )
      else if (state == 'reveal')
        OrbiSays(
          text:
              'Era ${it.answer}. Si cuentas ${it.a} y sigues ${it.b} más, llegas a ${it.answer}.',
          pose: 'point',
        )
      else
        OrbiSays(
          text: 'Elige la respuesta. ¡Tú puedes, $name!',
          pose: 'wave',
          size: 64,
        ),
      if (done) ...[
        Gap.h14,
        FilledButton.icon(
          onPressed: _next,
          icon: const Icon(Icons.arrow_forward_rounded),
          label: const Text('Continuar'),
        ),
      ] else if (state == 'bad' && !showHint) ...[
        Gap.h14,
        OutlinedButton.icon(
          onPressed: () => setState(() => showHint = true),
          icon: const Icon(Icons.auto_awesome_rounded),
          label: const Text('Ver pista con dibujos'),
        ),
      ],
    ];
  }
}

class _RunHeader extends StatelessWidget {
  const _RunHeader({required this.run, required this.onQuit});
  final MissionRun run;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    final c = context.ok;
    return Row(
      children: [
        IconButton(
          tooltip: 'Salir de la misión',
          onPressed: onQuit,
          icon: const Icon(Icons.close_rounded, size: 28),
        ),
        Expanded(
          child: ExcludeSemantics(
            child: Row(
              children: [
                for (var k = 0; k < run.total; k++)
                  Expanded(
                    child: Container(
                      height: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: k < run.index
                            ? c.ok
                            : k == run.index
                            ? Brand.purple
                            : c.line,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Gap.w10,
        Semantics(
          label: 'Ejercicio ${run.index + 1} de ${run.total}',
          excludeSemantics: true,
          child: Text(
            '${run.index + 1}/${run.total}',
            style: AppTextStyles.number(16, color: c.muted),
          ),
        ),
        Gap.w6,
      ],
    );
  }
}

/// Grupos de objetos para contar (o decenas y unidades en niveles 5-6).
class _ObjectsCard extends StatelessWidget {
  const _ObjectsCard({
    required this.item,
    required this.show,
    required this.level,
    this.flat = false,
  });
  final SumItem item;
  final bool show;
  final int level;
  final bool flat;

  @override
  Widget build(BuildContext context) {
    final groups = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _Group(
            n: item.a,
            offset: 0,
            object: item.object,
            show: show,
            level: level,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '+',
            style: AppTextStyles.number(30, color: Brand.yellow),
          ),
        ),
        Expanded(
          child: _Group(
            n: item.b,
            offset: item.a,
            object: item.object,
            show: show,
            level: level,
          ),
        ),
      ],
    );
    if (flat) return groups;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF191B58), Color(0xFF2E3192)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: groups,
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({
    required this.n,
    required this.offset,
    required this.object,
    required this.show,
    required this.level,
  });
  final int n;
  final int offset;
  final String object;
  final bool show;
  final int level;

  Widget _art(double s) => switch (object) {
    'planet' => PlanetArt(
      light: const Color(0xFFC9C3FF),
      dark: Brand.purple,
      size: s,
    ),
    'rocket' => RocketArt(size: s, angle: 0),
    _ => StarIcon(size: s),
  };

  @override
  Widget build(BuildContext context) {
    final labelStyle = const TextStyle(
      color: Brand.lavender,
      fontWeight: FontWeight.w800,
      fontSize: 12.5,
    );
    if (level >= 5) {
      final t = n ~/ 10, u = n % 10;
      return Semantics(
        label: '$t decenas y $u unidades',
        excludeSemantics: true,
        child: Column(
          children: [
            Wrap(
              spacing: 4,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                for (var i = 0; i < t; i++)
                  Container(
                    width: 12,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Brand.violet, Brand.purple],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                Gap.w4,
                for (var i = 0; i < u; i++)
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Brand.yellow,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE0A92E),
                        width: 1.5,
                      ),
                    ),
                  ),
              ],
            ),
            Gap.h6,
            Text(
              '$t decenas y $u unidades',
              style: labelStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    final s = n > 9
        ? 22.0
        : n > 6
        ? 26.0
        : 30.0;
    final o = _obj[object]!;
    return Semantics(
      label: '$n ${n == 1 ? o.$2 : o.$1}',
      excludeSemantics: true,
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 2,
            runSpacing: 2,
            children: [
              for (var i = 0; i < n; i++)
                SizedBox(
                  width: s + 6,
                  height: s + 6,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _art(s),
                      if (show)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${offset + i + 1}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Brand.ink,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
          Gap.h4,
          Text('$n ${n == 1 ? o.$2 : o.$1}', style: labelStyle),
        ],
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onKey});
  final ValueChanged<int> onKey;

  @override
  Widget build(BuildContext context) {
    final c = context.ok;
    return Semantics(
      label: 'Teclado numérico',
      child: GridView.count(
        crossAxisCount: 5,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.15,
        children: [
          for (final n in [1, 2, 3, 4, 5, 6, 7, 8, 9, 0])
            Material(
              color: c.card,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.field,
                side: BorderSide(
                  color: c.highContrast ? c.ink : c.line,
                  width: 2,
                ),
              ),
              child: InkWell(
                borderRadius: AppRadius.field,
                onTap: () => onKey(n),
                child: Center(
                  child: Text(
                    '$n',
                    style: AppTextStyles.number(26, color: c.ink),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.value,
    required this.good,
    required this.bad,
    required this.enabled,
    required this.onTap,
  });
  final int value;
  final bool good;
  final bool bad;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.ok;
    final bg = good
        ? c.okBg
        : bad
        ? c.errBg
        : c.card;
    final border = good
        ? c.ok
        : bad
        ? c.err
        : (c.highContrast ? c.ink : c.line);
    return Semantics(
      button: true,
      enabled: enabled,
      label:
          '$value${good
              ? ', correcta'
              : bad
              ? ', incorrecta'
              : ''}',
      excludeSemantics: true,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: border, width: 3),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: enabled ? onTap : null,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text('$value', style: AppTextStyles.number(34, color: c.ink)),
              if (good || bad)
                Positioned(
                  right: 10,
                  top: 8,
                  // Ícono + color: el estado no depende solo del color.
                  child: Icon(
                    good ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: good ? c.ok : c.err,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Shake extends StatelessWidget {
  const _Shake({super.key, required this.child, required this.active});
  final Widget child;
  final bool active;

  @override
  Widget build(BuildContext context) {
    if (!active) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 360),
      builder: (_, v, ch) => Transform.translate(
        offset: Offset(
          8 *
              (1 - v) *
              (v * 12).remainder(2) *
              ((v * 6).floor().isEven ? 1 : -1),
          0,
        ),
        child: ch,
      ),
      child: child,
    );
  }
}

/// 22 · Resultados y recompensas.
class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  MissionOutcome? out;
  MissionRun? run;

  @override
  void initState() {
    super.initState();
    run = ref.read(runProvider);
    if (run != null && run!.finished) {
      // Se guarda después del primer frame: no se modifica estado en initState.
      Future(() => ref.read(studentProvider.notifier).finish(run!)).then((o) {
        if (!mounted) return;
        setState(() => out = o);
        _restReminder();
      });
    }
  }

  /// R5: 20 minutos de aprendizaje → sugerir Pausa Estelar (se puede posponer).
  Future<void> _restReminder() async {
    final st = ref.read(settingsProvider);
    final minutes = ref.read(studentProvider).minutesToday;
    if (!st.notifRest || minutes < 20 || out!.guest) return;
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    // Aviso del sistema solo fuera del horario sin avisos (8 p. m. a 7 a. m.).
    if (!(st.quietHours && inQuietHours(ref.read(clockProvider)()))) {
      ref
          .read(localNotifierProvider)
          .show(
            5,
            '¡Hora de estirarse!',
            'Llevas $minutes minutos aprendiendo.',
          );
    }
    final go = await confirm(
      context,
      title: '¡Hora de estirarse!',
      text:
          'Llevas $minutes minutos aprendiendo. Los astronautas descansan para seguir explorando. ¿Hacemos una Pausa Estelar?',
      ok: 'Ir a Pausa Estelar',
      cancel: 'Ahora no',
    );
    if (go && mounted) context.go(AppRoutes.pause);
  }

  @override
  Widget build(BuildContext context) {
    final r = run;
    final o = out;
    if (r == null || !r.finished) {
      return OkPage(
        title: 'Resultados',
        children: [
          const InfoBanner(text: 'No hay resultados para mostrar.'),
          Gap.h12,
          FilledButton(
            onPressed: () => context.go(AppRoutes.map),
            child: const Text('Ir al mapa'),
          ),
        ],
      );
    }
    if (o == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final s = ref.watch(studentProvider);
    final sync = ref.watch(syncControllerProvider);
    final queued = o.queued == null
        ? null
        : sync.items.where((i) => i.id == o.queued).firstOrNull;
    final confirmed = o.queued != null && queued == null;
    final still = reduceMotion(context, ref);
    final guest = ref.watch(authControllerProvider).isGuest;

    final title = o.stars == 3
        ? '¡Misión perfecta, astronauta!'
        : o.stars == 2
        ? '¡Muy buen trabajo!'
        : '¡Lo lograste! Cada intento te hace más fuerte.';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(guest ? AppRoutes.guestHome : AppRoutes.map);
      },
      child: Scaffold(
        backgroundColor: Brand.space,
        body: SpaceBackground(
          seed: 41,
          colors: const [
            Color(0xFF2E3192),
            Color(0xFF191B58),
            Color(0xFF0D102B),
          ],
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Text(
                  r.reinforcement
                      ? 'Misión de refuerzo'
                      : r.assigned
                      ? 'Tarea de tu maestra'
                      : 'Misión terminada',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Brand.lavender,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Semantics(
                  header: true,
                  child: Text(
                    r.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(color: Colors.white),
                  ),
                ),
                Gap.h12,
                Semantics(
                  label: '${o.stars} de 3 estrellas',
                  excludeSemantics: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var k = 1; k <= 3; k++)
                        _PopStar(
                          delay: k * 180,
                          still: still,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: k == 2 ? 14 : 0),
                            child: StarIcon(
                              size: k == 2 ? 74 : 60,
                              color: k <= o.stars
                                  ? Brand.yellow
                                  : Colors.white24,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Mascot(
                      look: s.look,
                      pose: o.stars == 3 ? 'celebrate' : 'cheer',
                      size: 110,
                    ),
                    Mascot.orbi(
                      pose: o.stars >= 2 ? 'jump' : 'cheer',
                      size: 80,
                    ),
                  ],
                ),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(color: Colors.white),
                ),
                Gap.h14,
                Row(
                  children: [
                    Expanded(
                      child: _ResultStat(
                        value: '${o.firstTry}/${o.total}',
                        label: 'correctas al primer intento',
                      ),
                    ),
                    Gap.w10,
                    Expanded(
                      child: _ResultStat(
                        value: '${o.attempts}',
                        label: 'intentos en total',
                      ),
                    ),
                  ],
                ),
                Gap.h12,
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Brand.yellow.withValues(alpha: .14),
                    borderRadius: AppRadius.field,
                  ),
                  child: Row(
                    children: [
                      const StarIcon(size: 22),
                      Gap.w8,
                      Expanded(
                        child: Text(
                          '+${o.stars} estrellas'
                          '${o.piece != null ? ' · ¡Ganaste la pieza «${o.piece}» de la nave!' : ''}'
                          '${o.firstCompletion ? ' · Nueva misión completada' : ''}'
                          '${o.newBadges.contains('b6') ? ' · Insignia «Paciencia lunar»' : ''}',
                          style: const TextStyle(
                            color: Color(0xFFFFE7A8),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (o.rule == AdaptRule.r2Advance) ...[
                  Gap.h12,
                  const InfoBanner(
                    icon: Icons.trending_up_rounded,
                    title: '¡Listo para un reto mayor!',
                    text: 'Acertaste casi todo. La siguiente misión puede ser un poco más difícil.\nR2 · 90 % o más → avanzar',
                  ),
                ],
                if (o.rule == AdaptRule.r3Reinforce &&
                    !r.reinforcement &&
                    !r.assigned) ...[
                  Gap.h12,
                  InfoBanner(
                    icon: Icons.auto_awesome_rounded,
                    title: 'Misión de refuerzo',
                    text: 'Practica 5 sumas más pequeñas con dibujos. Te ayudará en la próxima misión.\nR3 · menos de 60 % → refuerzo',
                    action: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Brand.yellow,
                        foregroundColor: Brand.ink,
                      ),
                      onPressed: () {
                        ref
                            .read(runProvider.notifier)
                            .startMission(r.missionId, easy: true);
                        context.pushReplacement(AppRoutes.play);
                      },
                      child: const Text('Hacer refuerzo'),
                    ),
                  ),
                ],
                if (o.notifyTeacher) ...[
                  Gap.h8,
                  const Text(
                    'R4 · Tu maestra verá una sugerencia para ayudarte con estas sumas cuando el resultado llegue a la base.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Brand.lavender,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                Gap.h12,
                Semantics(
                  liveRegion: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        o.guest
                            ? Icons.visibility_rounded
                            : confirmed
                            ? Icons.check_circle_rounded
                            : sync.running
                            ? Icons.sync_rounded
                            : Icons.cloud_upload_outlined,
                        size: 18,
                        color: confirmed ? Brand.mint : const Color(0xFFFFE08A),
                      ),
                      Gap.w6,
                      Flexible(
                        child: Text(
                          o.guest
                              ? 'Modo explorar: este resultado no se guarda.'
                              : confirmed
                              ? 'Guardado en la base'
                              : sync.running
                              ? 'Enviando a la base…'
                              : sync.lastRunNoBackend
                              ? 'Guardado en el teléfono · servidor pendiente'
                              : 'Guardado en el teléfono · se enviará con Internet',
                          style: TextStyle(
                            color: confirmed
                                ? Brand.mint
                                : const Color(0xFFFFE08A),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Gap.h18,
                FilledButton(
                  onPressed: () {
                    ref.read(runProvider.notifier).clear();
                    if (guest) return context.go(AppRoutes.guestHome);
                    if (r.assigned || r.reinforcement) {
                      return context.go(AppRoutes.studentHome);
                    }
                    final next = ref.read(studentProvider).nextMission();
                    context.go(AppRoutes.map);
                    context.push(AppRoutes.mission(next.id));
                  },
                  child: const Text('Continuar'),
                ),
                Gap.h10,
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38, width: 2),
                  ),
                  onPressed: () {
                    ref.read(runProvider.notifier).clear();
                    context.go(AppRoutes.map);
                  },
                  child: const Text('Volver al mapa'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  const _ResultStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$value $label',
    excludeSemantics: true,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .08),
        borderRadius: AppRadius.card,
      ),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.number(28, color: Colors.white)),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Brand.lavender,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ),
  );
}

class _PopStar extends StatelessWidget {
  const _PopStar({
    required this.child,
    required this.delay,
    required this.still,
  });
  final Widget child;
  final int delay;
  final bool still;

  @override
  Widget build(BuildContext context) {
    if (still) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + delay),
      curve: Interval(delay / (500 + delay), 1, curve: Curves.elasticOut),
      builder: (_, v, ch) => Transform.scale(scale: v, child: ch),
      child: child,
    );
  }
}
