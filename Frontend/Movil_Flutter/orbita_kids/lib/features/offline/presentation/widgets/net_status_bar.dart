import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:orbita_kids/config/themes/app_themes.dart';
import 'package:orbita_kids/core/network/connectivity.dart';
import 'package:orbita_kids/config/routes/app_router.dart';
import 'package:orbita_kids/core/sync/domain/sync_models.dart';
import 'package:orbita_kids/core/sync/presentation/providers/sync_controller.dart';
import 'package:orbita_kids/features/auth/presentation/providers/auth_controller.dart';
import 'package:orbita_kids/features/auth/domain/entities/auth_entities.dart';

typedef NetStatus = (Color bg, Color fg, IconData icon, String text);

/// Estado visible de conexión y cola. Nunca dice «enviado» si el servidor no
/// lo confirmó.
NetStatus? netStatusOf(WidgetRef ref) {
  final online = ref.watch(onlineProvider);
  final sync = ref.watch(syncControllerProvider);
  final user = ref.watch(currentUserProvider);
  final mine = user == null ? const <SyncItem>[] : sync.of(user.id);
  final n = mine.length;
  final student = user?.role == UserRole.student;
  if (sync.running && n > 0) {
    return (
      Brand.turquoise,
      Brand.ink,
      Icons.sync_rounded,
      'Sincronizando $n registro${n == 1 ? '' : 's'}…',
    );
  }
  if (!online) {
    return (
      const Color(0xFF3A3F7A),
      Colors.white,
      Icons.wifi_off_rounded,
      '${student || user == null ? '¡Podemos seguir la misión sin Internet!' : 'Sin conexión · datos guardados en el teléfono'}${n > 0 ? ' · $n por enviar' : ''}',
    );
  }
  if (n == 0) return null;
  if (mine.any((i) => i.status == SyncStatus.conflict)) {
    return (
      const Color(0xFFFDECEF),
      const Color(0xFF8E2338),
      Icons.call_split_rounded,
      'Hay un conflicto por revisar. Toca para ver',
    );
  }
  if (mine.any((i) => i.status == SyncStatus.error)) {
    return (
      const Color(0xFFFDECEF),
      const Color(0xFF8E2338),
      Icons.error_outline_rounded,
      'No pudimos enviar $n. Toca para reintentar',
    );
  }
  return (
    Brand.yellow,
    Brand.ink,
    Icons.cloud_upload_outlined,
    sync.lastRunNoBackend
        ? '$n guardado${n == 1 ? '' : 's'} en el teléfono · servidor pendiente'
        : '$n resultado${n == 1 ? '' : 's'} esperando viajar a la base',
  );
}

/// Coloca la barra de estado sobre todas las pantallas (`#netbar`).
class NetStatusFrame extends ConsumerWidget {
  const NetStatusFrame({super.key, required this.child});
  final Widget child;

  static const _hidden = {
    '/',
    AppRoutes.studios,
    AppRoutes.loading,
    AppRoutes.onboarding,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final status = netStatusOf(ref);
    return ValueListenableBuilder(
      valueListenable: router.routeInformationProvider,
      builder: (context, info, _) {
        final path = info.uri.path;
        if (status == null ||
            _hidden.contains(path) ||
            path.startsWith('/login/demo')) {
          return child;
        }
        final (bg, fg, icon, text) = status;
        final signedIn = ref.read(currentUserProvider) != null;
        return Column(
          children: [
            Material(
              color: bg,
              child: SafeArea(
                bottom: false,
                child: Semantics(
                  liveRegion: true,
                  button: true,
                  label: text,
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: () => router.push(
                      signedIn ? AppRoutes.sync : AppRoutes.connection,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 40),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Icon(icon, size: 18, color: fg),
                            Gap.w8,
                            Expanded(
                              child: Text(
                                text,
                                style: TextStyle(
                                  color: fg,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: fg,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: child,
              ),
            ),
          ],
        );
      },
    );
  }
}
