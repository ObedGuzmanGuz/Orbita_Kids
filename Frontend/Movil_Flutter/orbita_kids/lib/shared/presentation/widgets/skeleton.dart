import 'package:flutter/material.dart';

import 'package:orbita_kids/shared/presentation/widgets/ui.dart';

/// Bloque gris con brillo suave para cargas lentas (pantalla 58).
/// Con movimiento reducido el brillo no se anima.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.radius = 12,
    this.dark = false,
  });

  final double? width;
  final double height;
  final double radius;

  /// Sobre fondos espaciales (encabezados índigo).
  final bool dark;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (still) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.dark
        ? Colors.white.withValues(alpha: .12)
        : context.ok.tintViolet;
    final shine = widget.dark
        ? Colors.white.withValues(alpha: .22)
        : context.ok.soft;
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * _c.value - .6, 0),
              end: Alignment(-1 + 2 * _c.value + .6, 0),
              colors: [base, shine, base],
            ),
          ),
        ),
      ),
    );
  }
}

/// Aviso de servidor lento que acompaña a los esqueletos.
class SlowServerNote extends StatelessWidget {
  const SlowServerNote({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.ok.tintViolet,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: context.ok.inkViolet,
            ),
          ),
          Gap.w10,
          Expanded(
            child: Text(
              'El servidor está tardando un poco. Mostramos la estructura mientras llegan tus datos.',
              style: TextStyle(
                color: context.ok.inkViolet,
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// 58 · Carga esqueleto del inicio del estudiante.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Cargando tu inicio',
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Brand.indigo2, Brand.indigo],
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBox(width: 90, height: 18, dark: true),
                  Gap.h18,
                  const Row(
                    children: [
                      SkeletonBox(
                        width: 52,
                        height: 52,
                        radius: 26,
                        dark: true,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBox(width: 120, height: 12, dark: true),
                            SizedBox(height: 8),
                            SkeletonBox(width: 180, height: 20, dark: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Gap.h20,
                  Row(
                    children: [
                      const SkeletonBox(
                        width: 104,
                        height: 104,
                        radius: 24,
                        dark: true,
                      ),
                      Gap.w14,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            SkeletonBox(width: 110, height: 14, dark: true),
                            SizedBox(height: 10),
                            SkeletonBox(height: 20, dark: true),
                            SizedBox(height: 10),
                            SkeletonBox(width: 140, height: 12, dark: true),
                            SizedBox(height: 10),
                            SkeletonBox(height: 10, dark: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Gap.h18,
                  const SkeletonBox(height: 60, radius: 20, dark: true),
                ],
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(height: 64, radius: 18),
              SizedBox(height: 22),
              SkeletonBox(width: 150, height: 18),
              SizedBox(height: 12),
              SkeletonListTile(),
              SizedBox(height: 10),
              SkeletonListTile(),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: SkeletonBox(height: 120, radius: 20)),
                  SizedBox(width: 12),
                  Expanded(child: SkeletonBox(height: 120, radius: 20)),
                ],
              ),
              SizedBox(height: 16),
              SlowServerNote(),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Fila de lista en carga (pantalla 30c).
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: context.ok.card,
      borderRadius: AppRadius.card,
      border: Border.all(color: context.ok.line),
    ),
    child: const Row(
      children: [
        SkeletonBox(width: 44, height: 44, radius: 14),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(height: 14),
              SizedBox(height: 8),
              SkeletonBox(width: 120, height: 10),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Lista en carga con aviso (pantalla 30c).
class ListSkeleton extends StatelessWidget {
  const ListSkeleton({super.key, this.rows = 4});
  final int rows;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Cargando',
    child: Column(
      children: [
        for (var i = 0; i < rows; i++) ...[const SkeletonListTile(), Gap.h10],
        const SlowServerNote(),
      ],
    ),
  );
}
