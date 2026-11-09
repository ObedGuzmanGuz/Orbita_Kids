import { effectiveStatus } from '../../domain/activities.js';
import { summarizeStudent, weekLabel, weekStarts } from '../../domain/studentSummary.js';
import { attemptsOf, completions, publishedActivitiesOf } from './groups.repository.js';

/** Etiquetas de las semanas que cubre `trend` (`UsersRepository.trendLabels`). */
export const trendLabels = (now) => weekStarts(now).map(weekLabel);

/**
 * Resúmenes de los estudiantes indicados, todos del grupo `group`.
 * @param {{id: string, status: string}} group
 * @param {{id: string, name: string}[]} students
 */
export async function summarize(group, students, now = new Date()) {
  const ids = students.map((s) => s.id);
  const [attempts, activities] = await Promise.all([attemptsOf(ids), publishedActivitiesOf(group.id)]);

  const open = activities.filter((a) => effectiveStatus(a, now) === 'active').map((a) => a.id);
  const doneByStudent = new Map();
  for (const c of await completions(open)) {
    doneByStudent.set(c.student_id, (doneByStudent.get(c.student_id) ?? 0) + 1);
  }
  const attemptsByStudent = Map.groupBy(attempts, (a) => a.studentId);

  return students.map((student) =>
    summarizeStudent({
      student,
      groupId: group.id,
      groupArchived: group.status === 'archived',
      attempts: attemptsByStudent.get(student.id) ?? [],
      pending: open.length - (doneByStudent.get(student.id) ?? 0),
      now,
    }),
  );
}
