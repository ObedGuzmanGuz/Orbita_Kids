import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:orbita_kids/features/auth/presentation/providers/auth_controller.dart';
import 'package:orbita_kids/features/student/providers/student_providers.dart';
import 'package:orbita_kids/features/student/domain/usecases/progress_usecases.dart';
import 'package:orbita_kids/features/student/presentation/providers/student_controller.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';

/// Tareas que la maestra asignó al grupo del estudiante.
final studentTasksProvider = FutureProvider<List<Activity>>((ref) async {
  final groupId = ref.watch(currentUserProvider)?.groupId;
  if (groupId == null) return const [];
  return ref.watch(getStudentTasksProvider).call(groupId);
});

/// Tareas activas aún sin hacer.
final pendingTasksProvider = Provider<List<Activity>>(
  (ref) => const PendingTasks().call(
    ref.watch(studentTasksProvider).value ?? const [],
    ref.watch(studentProvider.select((s) => s.tasksDone)),
  ),
);
