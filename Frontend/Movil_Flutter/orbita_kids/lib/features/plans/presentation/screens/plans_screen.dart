import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:orbita_kids/shared/domain/content/catalog.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';
import 'package:orbita_kids/shared/presentation/widgets/ui.dart';
import 'package:orbita_kids/features/auth/presentation/providers/auth_controller.dart';
import 'package:orbita_kids/features/plans/providers/plans_providers.dart';
import 'package:orbita_kids/features/plans/domain/repositories/plans_repository.dart';

final _money = NumberFormat.currency(
  locale: 'es_MX',
  symbol: r'$',
  decimalDigits: 0,
);

/// 52 · Planes institucionales: consulta y solicitud de información.
/// Sin pagos ni checkout.
class PlansScreen extends ConsumerStatefulWidget {
  const PlansScreen({super.key});

  @override
  ConsumerState<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends ConsumerState<PlansScreen> {
  bool yearly = false;

  @override
  Widget build(BuildContext context) {
    final plans = ref.watch(getPlansProvider).call();
    final c = context.ok;
    return OkPage(
      title: 'Planes institucionales',
      subtitle: 'Consulta y solicita información',
      children: [
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Mensual')),
            ButtonSegment(value: true, label: Text('Anual')),
          ],
          selected: {yearly},
          onSelectionChanged: (v) => setState(() => yearly = v.first),
        ),
        Gap.h12,
        for (final p in plans)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OkCard(
              color: p.highlighted ? c.tintViolet : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      if (p.highlighted)
                        const TagChip('Recomendado', tone: Tone.warn),
                    ],
                  ),
                  Text(p.who, style: Theme.of(context).textTheme.bodySmall),
                  Gap.h8,
                  Semantics(
                    label: p.monthly == 0
                        ? 'Gratis'
                        : '${_money.format(yearly ? p.yearly : p.monthly)} pesos al ${yearly ? 'año' : 'mes'}',
                    excludeSemantics: true,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: p.monthly == 0
                                ? 'Gratis'
                                : _money.format(yearly ? p.yearly : p.monthly),
                            style: AppTextStyles.number(30, color: c.ink),
                          ),
                          if (p.monthly != 0)
                            TextSpan(
                              text: yearly ? ' MXN/año' : ' MXN/mes',
                              style: TextStyle(
                                color: c.muted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (yearly && p.monthly != 0)
                    Text(
                      'Equivale a ${_money.format(p.yearly / 12)} al mes',
                      style: TextStyle(
                        color: c.ok,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  Gap.h8,
                  for (final l in [...p.limits, ...p.features])
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_rounded, size: 18, color: c.ok),
                          Gap.w6,
                          Expanded(child: Text(l)),
                        ],
                      ),
                    ),
                  Gap.h12,
                  SizedBox(
                    width: double.infinity,
                    child: p.monthly == 0
                        ? OutlinedButton(
                            onPressed: () => toast(
                              context,
                              'Ya usas el plan Gratis: no necesitas solicitar nada.',
                              icon: Icons.check_rounded,
                            ),
                            child: const Text('Plan actual de demostración'),
                          )
                        : FilledButton(
                            onPressed: () => _request(p),
                            child: const Text('Solicitar información'),
                          ),
                  ),
                ],
              ),
            ),
          ),
        const InfoBanner(
          icon: Icons.info_outline_rounded,
          text: Catalog.planNote,
        ),
        const SectionTitle('Códigos de grupo'),
        const OkCard(
          child: Text(
            'Cada licencia incluye códigos para que los estudiantes se unan a sus grupos. La administración de códigos se hace desde la institución; en esta app solo se consultan.',
          ),
        ),
        Gap.h8,
        Text(
          'Órbita Kids no procesa pagos dentro de la app.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Future<void> _request(Plan p) async {
    final user = ref.read(currentUserProvider);
    final inst = TextEditingController(text: user?.institution);
    final contact = TextEditingController(text: user?.email);
    final students = TextEditingController(
      text: switch (p.id) {
        'aula' => '50',
        'escuela' => '150',
        _ => '500',
      },
    );
    final msg = TextEditingController();
    String? err;
    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            20 + MediaQuery.viewInsetsOf(ctx).bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Información del plan ${p.name}',
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
                Text(
                  yearly ? 'Periodo anual' : 'Periodo mensual',
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
                Gap.h12,
                TextField(
                  controller: inst,
                  decoration: const InputDecoration(labelText: 'Institución'),
                ),
                Gap.h10,
                TextField(
                  controller: contact,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo de contacto',
                    errorText: err,
                  ),
                ),
                Gap.h10,
                TextField(
                  controller: students,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Estudiantes aproximados',
                  ),
                ),
                Gap.h10,
                TextField(
                  controller: msg,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Mensaje (opcional)',
                  ),
                ),
                Gap.h12,
                const InfoBanner(
                  icon: Icons.cloud_upload_outlined,
                  text: 'La solicitud se guarda en el teléfono y se envía cuando el servidor esté disponible. No implica ningún pago.',
                ),
                Gap.h12,
                FilledButton(
                  onPressed: () async {
                    final error = await ref
                        .read(requestPlanInformationProvider)
                        .call(
                          PlanInfoRequest(
                            owner: user?.id ?? 'guest',
                            plan: p,
                            yearly: yearly,
                            institution: inst.text.trim(),
                            contact: contact.text.trim(),
                            students: int.tryParse(students.text) ?? 0,
                            message: msg.text.trim(),
                          ),
                        );
                    if (error != null) {
                      setS(() => err = error);
                      return;
                    }
                    if (ctx.mounted) Navigator.pop(ctx, true);
                  },
                  child: const Text('Guardar solicitud'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (sent == true && mounted) {
      toast(
        context,
        'Solicitud guardada. Aparece en Sincronización como pendiente hasta que se envíe.',
        icon: Icons.cloud_upload_outlined,
      );
    }
  }
}
