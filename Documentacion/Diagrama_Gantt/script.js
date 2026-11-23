const DATA_URL = 'data/plan.json';
const GITHUB_URL = 'data/github-snapshot.json';
const GITHUB_REPO = 'https://github.com/ObedGuzmanGuz/Orbita_Kids';
const MS_DAY = 86400000;
const state = { plan: null, github: null, view: 'overview', zoom: 'week', owner: 'all', status: 'all', collapsedTasks: new Set(), selectedTask: null, selectedMember: null };

const $ = (selector, root = document) => root.querySelector(selector);
const $$ = (selector, root = document) => [...root.querySelectorAll(selector)];
const esc = (value = '') => String(value).replace(/[&<>"']/g, ch => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[ch]);
const day = value => new Date(`${value}T12:00:00`);
const dateLabel = value => new Intl.DateTimeFormat('es-MX', { day: 'numeric', month: 'short', year: 'numeric' }).format(new Date(value));
const shortDate = value => new Intl.DateTimeFormat('es-MX', { day: 'numeric', month: 'short' }).format(day(value));
const memberById = id => state.plan.members.find(member => member.id === id);
const taskById = id => {
  for (const task of state.plan.tasks) {
    if (task.id === id) return task;
    const nested = task.subtasks?.find(child => child.id === id);
    if (nested) return nested;
  }
  return undefined;
};
const statusClass = status => ({ 'Realizado': 'done', 'Avanzado': 'advanced', 'En desarrollo': 'progress', 'Iniciado': 'started', 'Pendiente': 'pending' })[status] || 'pending';
const personName = id => memberById(id)?.name || 'Equipo';
const percent = value => `${Math.max(0, Math.min(100, value))}%`;

async function init() {
  try {
    const [planResponse, githubResponse] = await Promise.all([fetch(DATA_URL), fetch(GITHUB_URL)]);
    if (!planResponse.ok || !githubResponse.ok) throw new Error('No se pudieron cargar los datos locales.');
    [state.plan, state.github] = await Promise.all([planResponse.json(), githubResponse.json()]);
    populateControls();
    bindEvents();
    renderAll();
  } catch (error) {
    document.body.insertAdjacentHTML('beforeend', `<div class="load-error">No se pudo cargar el dashboard. Ábrelo mediante un servidor estático local o GitHub Pages.<br><small>${esc(error.message)}</small></div>`);
  }
}

function populateControls() {
  const ownerOptions = state.plan.members.map(member => `<option value="${member.id}">${esc(member.name)}</option>`).join('');
  $('#ownerFilter').insertAdjacentHTML('beforeend', ownerOptions);
  $('#memberFilter').insertAdjacentHTML('beforeend', ownerOptions);
  $('#statusFilter').insertAdjacentHTML('beforeend', [...new Set(state.plan.tasks.map(task => task.status))].map(status => `<option>${esc(status)}</option>`).join(''));
  $('#branchFilter').insertAdjacentHTML('beforeend', state.github.branches.map(branch => `<option value="${esc(branch.name)}">${esc(branch.name)}</option>`).join(''));
}

function renderAll() {
  $('#updatedLabel').textContent = `GitHub consultado ${dateLabel(state.github.fetchedAt)}`;
  $('#reportDate').textContent = dateLabel(state.github.fetchedAt);
  $('#topProfile').innerHTML = avatar(memberById('yazmin'), 'small-avatar');
  renderKpis(); renderMiniGantt(); renderRecentCommits(); renderTeamStrip(); renderGantt(); renderActivities(); renderTeam(); renderGithub(); renderReports();
  animateCounters();
}

function renderKpis() {
  const tasks = state.plan.tasks;
  const counts = {
    total: tasks.length,
    done: tasks.filter(task => task.status === 'Realizado').length,
    active: tasks.filter(task => ['En desarrollo', 'Iniciado', 'Avanzado'].includes(task.status)).length,
    pending: tasks.filter(task => task.status === 'Pendiente').length
  };
  const cards = [
    ['Actividades', counts.total, 'En el plan aprobado', 'tasks', 'violet'],
    ['Completadas', counts.done, 'Estado inicial estimado', 'check', 'mint'],
    ['En desarrollo', counts.active, 'Incluye tareas iniciadas', 'pulse', 'yellow'],
    ['Pendientes', counts.pending, 'Aún por iniciar', 'clock', 'blue'],
    ['Integrantes', state.plan.members.length, 'Equipo de proyecto', 'people', 'lavender'],
    ['Commits verificados', state.github.commits.length, 'SHA únicos · GitHub', 'git', 'coral']
  ];
  $('#kpiGrid').innerHTML = cards.map(([label, value, note, icon, color], index) => `<article class="kpi-card" style="--kpi-color:var(--${color === 'coral' ? 'coral' : color === 'violet' ? 'violet' : color === 'mint' ? 'mint' : color === 'yellow' ? 'yellow' : color === 'blue' ? 'blue' : 'lavender'});--card-index:${index}"><div class="kpi-top"><span>${esc(label)}</span><i class="kpi-icon ${color}">${kpiIcon(icon)}</i></div><b class="kpi-number" data-count="${value}">0</b><small>${esc(note)}</small></article>`).join('');
  $('#githubStats').innerHTML = `<div class="github-stat"><small>Commits únicos</small><b>${state.github.commits.length}</b><span>SHA sin duplicados</span></div><div class="github-stat"><small>Ramas consultadas</small><b>${state.github.branches.length}</b><span>En GitHub al ${esc(dateLabel(state.github.fetchedAt))}</span></div><div class="github-stat"><small>Autores de equipo</small><b>${state.plan.members.filter(member => commitsForMember(member).length).length}<i> / ${state.plan.members.length}</i></b><span>Con actividad visible en la captura</span></div><div class="github-stat"><small>Último commit</small><b class="stat-date">${esc(dateLabel(state.github.commits[0]?.date || state.github.fetchedAt))}</b><span>Verificado en ramas consultadas</span></div>`;
  $('#githubStats .stat-date').textContent = dateLabel(sortedCommits()[0]?.date || state.github.fetchedAt);
}

function kpiIcon(name) {
  const paths = {
    tasks: '<rect x="4" y="4" width="16" height="17" rx="3"/><path d="M8 8h8M8 12h8M8 16h5"/><path d="M9 3v3m6-3v3"/>',
    check: '<circle cx="12" cy="12" r="9"/><path d="m8 12 2.5 2.5L16.5 9"/>',
    pulse: '<path d="M3 12h4l2.2-6 4.1 12 2.2-6H21"/>',
    clock: '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',
    people: '<path d="M16 20v-1a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v1"/><circle cx="10" cy="8" r="3.5"/><path d="M17 11a3.5 3.5 0 1 0-1-6.8M17 15a4 4 0 0 1 3 4v1"/>',
    git: '<circle cx="7" cy="6" r="2"/><circle cx="17" cy="18" r="2"/><circle cx="7" cy="18" r="2"/><path d="M7 8v8m0-5c0-3 10-3 10 4"/>'
  };
  return `<svg viewBox="0 0 24 24" aria-hidden="true">${paths[name] || paths.tasks}</svg>`;
}

function animateCounters() {
  const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  $$('.kpi-number[data-count]').forEach((counter, index) => {
    const target = Number(counter.dataset.count) || 0;
    if (reduceMotion) { counter.textContent = target; return; }
    const duration = 780, start = performance.now() + index * 55;
    const frame = now => {
      const progress = Math.min(1, Math.max(0, (now - start) / duration));
      const eased = 1 - Math.pow(1 - progress, 3);
      counter.textContent = Math.round(target * eased);
      if (progress < 1) requestAnimationFrame(frame);
    };
    requestAnimationFrame(frame);
  });
}

function commitsForMember(member) {
  return state.github.commits.filter(commit => member.gitNames.some(name => normalize(name) === normalize(commit.authorName)));
}
function sortedCommits() { return [...state.github.commits].sort((a, b) => Date.parse(b.date) - Date.parse(a.date)); }
function normalize(value) { return String(value || '').normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase().trim(); }
function ownersLabel(task) { return task.owners.map(id => personName(id).split(' ')[0]).join(', '); }
function rangeDays() { return Math.round((day(state.plan.project.end) - day(state.plan.project.start)) / MS_DAY) + 1; }

function renderMiniGantt() {
  const start = day(state.plan.project.start), duration = rangeDays();
  $('#miniGantt').innerHTML = `<div class="mini-axis"><span>FASE</span><div class="mini-axis-labels"><span>SEP</span><span>OCT</span><span>NOV</span><span>DIC</span></div></div>${state.plan.tasks.map(task => {
    const left = ((day(task.start) - start) / MS_DAY) / duration * 100;
    const width = ((day(task.end) - day(task.start)) / MS_DAY + 1) / duration * 100;
    return `<button class="mini-row" data-task="${task.id}" title="${esc(task.name)} · ${task.progress}% estimado"><span>${esc(task.name)}</span><span class="mini-track"><i class="mini-bar ${statusClass(task.status)}" style="left:${left}%;width:${width}%"><b style="width:${task.progress}%"></b></i></span></button>`;
  }).join('')}`;
}

function initials(name) { return name.split(/\s+/).filter(Boolean).slice(0, 2).map(part => part[0]).join('').toUpperCase(); }
function avatar(member, size = '') {
  const role = member.role || 'Integrante de Órbita Kids';
  const photo = member.photo ? `<img class="avatar-image" src="${esc(member.photo)}" alt="" loading="lazy" decoding="async">` : '';
  return `<span class="avatar photo-avatar ${size}" style="--avatar-color:${esc(member.color)}" title="${esc(member.name)} · ${esc(role)}" aria-label="${esc(member.name)}, ${esc(role)}"><span class="avatar-fallback">${esc(initials(member.name))}</span>${photo}</span>`;
}

function renderRecentCommits() {
  $('#recentCommits').innerHTML = sortedCommits().slice(0, 5).map(commit => {
    const member = state.plan.members.find(item => item.gitNames.some(name => normalize(name) === normalize(commit.authorName)));
    return `<a class="recent-item" href="${esc(commit.url)}" target="_blank" rel="noreferrer"><span class="commit-mark" style="--avatar-color:${member?.color || '#8A2BE2'}">⌘</span><span class="recent-copy"><b>${esc(commit.message)}</b><small>${esc(member?.name || commit.authorName)} · ${esc(dateLabel(commit.date))}</small></span><span class="recent-arrow">↗</span></a>`;
  }).join('');
  $$('#recentCommits .recent-item').forEach((item, index) => {
    const commit = sortedCommits()[index];
    const member = state.plan.members.find(person => person.gitNames.some(name => normalize(name) === normalize(commit.authorName)));
    if (member) item.querySelector('.commit-mark').outerHTML = avatar(member, 'recent-avatar');
  });
}

function renderTeamStrip() {
  $('#teamStrip').innerHTML = state.plan.members.map(member => `<button class="team-quick-select ${state.selectedMember === member.id ? 'selected' : ''}" style="--avatar-color:${esc(member.color)}" data-member-select="${member.id}" title="${esc(member.name)} · ${esc(member.role)}">${avatar(member, 'strip-avatar')}<span>${esc(member.name.split(' ')[0])}</span></button>`).join('');
}

function filteredTasks() {
  return state.plan.tasks.filter(task => (state.owner === 'all' || task.owners.includes(state.owner)) && (state.status === 'all' || task.status === state.status));
}

function ganttTasks() {
  return filteredTasks().flatMap(task => {
    const children = task.subtasks || [];
    return [{ ...task, depth: 0, parentId: null }, ...(children.length && !state.collapsedTasks.has(task.id) ? children.map(child => ({ ...child, depth: 1, parentId: task.id })) : [])];
  });
}

function ganttConfig() {
  if (state.zoom === 'day') return { unit: 'day', cell: 28, count: rangeDays() };
  if (state.zoom === 'month') return { unit: 'month', cell: 280, count: 3 };
  return { unit: 'week', cell: 94, count: 11 };
}

function timelineMarkup(config) {
  const start = day(state.plan.project.start), total = rangeDays();
  if (config.unit === 'day') {
    let dayCells = '';
    for (let i = 0; i < total; i++) {
      const date = new Date(start.getTime() + i * MS_DAY);
      const monday = date.getDay() === 1 || i === 0;
      dayCells += `<span class="day-cell ${monday ? 'week-start' : ''} ${date.toDateString() === new Date().toDateString() ? 'is-current' : ''}">${monday ? date.getDate() : ''}</span>`;
    }
    const months = monthSegments(start, total, 28);
    return { monthHeader: months, ticks: `<div class="tick-row day-ticks">${dayCells}</div>`, width: total * config.cell };
  }
  if (config.unit === 'month') {
    const months = [{ label: 'Septiembre', days: 3 }, { label: 'Octubre', days: 31 }, { label: 'Noviembre', days: 30 }, { label: 'Diciembre', days: 12 }];
    let offset = 0;
    const currentMonth = new Date().getMonth();
    const cells = months.map((month, index) => {
      const actualDays = month.days;
      const left = offset / total * 100;
      const width = actualDays / total * 100;
      offset += actualDays;
      return `<span class="month-block ${currentMonth === index + 8 ? 'is-current' : ''}" style="left:${left}%;width:${width}%">${index === 0 ? '28 sep' : index === 3 ? '1–12 dic' : esc(month.label)}</span>`;
    }).join('');
    return { monthHeader: `<div class="month-row" style="width:${config.cell * 3}px">${cells}</div>`, ticks: `<div class="tick-row month-ticks" style="width:${config.cell * 3}px"><span>SEPTIEMBRE</span><span>OCTUBRE</span><span>NOVIEMBRE</span><span>DICIEMBRE</span></div>`, width: config.cell * 3 };
  }
  const weeks = [];
  for (let i = 0; i < config.count; i++) {
    const date = new Date(start.getTime() + i * 7 * MS_DAY);
    const currentIndex = Math.floor((new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate()) - start) / (7 * MS_DAY));
    weeks.push(`<span class="${i === currentIndex ? 'is-current' : ''}">${date.getDate()} ${new Intl.DateTimeFormat('es-MX', { month: 'short' }).format(date)}</span>`);
  }
  const monthBands = [];
  const monthList = [{ label: 'SEPTIEMBRE', start: 0, days: 3 }, { label: 'OCTUBRE', start: 3, days: 31 }, { label: 'NOVIEMBRE', start: 34, days: 30 }, { label: 'DICIEMBRE', start: 64, days: 12 }];
  for (const item of monthList) monthBands.push(`<span style="left:${item.start / total * 100}%;width:${item.days / total * 100}%">${item.label}</span>`);
  return { monthHeader: `<div class="month-row" style="width:${config.cell * config.count}px">${monthBands.join('')}</div>`, ticks: `<div class="tick-row week-ticks" style="width:${config.cell * config.count}px">${weeks.join('')}</div>`, width: config.cell * config.count };
}

function monthSegments(start, total, cell) {
  const pieces = [];
  let current = new Date(start);
  while (pieces.reduce((sum, piece) => sum + piece.days, 0) < total) {
    const index = pieces.reduce((sum, piece) => sum + piece.days, 0);
    const days = Math.min(new Date(current.getFullYear(), current.getMonth() + 1, 0).getDate() - current.getDate() + 1, total - index);
    pieces.push(`<span style="left:${index * cell}px;width:${days * cell}px">${new Intl.DateTimeFormat('es-MX', { month: 'long' }).format(current)}</span>`);
    current = new Date(current.getFullYear(), current.getMonth() + 1, 1);
  }
  return `<div class="month-row" style="width:${total * cell}px">${pieces.join('')}</div>`;
}

function renderGantt() {
  const config = ganttConfig(), timeline = timelineMarkup(config), tasks = ganttTasks(), start = day(state.plan.project.start), total = rangeDays();
  const pxPerDay = config.unit === 'week' ? config.cell / 7 : timeline.width / total;
  const now = new Date(); const todayOffset = (new Date(now.getFullYear(), now.getMonth(), now.getDate(), 12) - start) / MS_DAY;
  const nowLabel = new Intl.DateTimeFormat('es-MX', { day: 'numeric', month: 'short' }).format(now);
  const todayLine = todayOffset >= 0 && todayOffset < total ? `<div class="today-line" style="left:${todayOffset * pxPerDay + 190}px" title="Hoy, ${esc(nowLabel)}"><span>HOY <b>${esc(nowLabel)}</b></span></div>` : '';
  const header = `<div class="gantt-head-row"><div class="task-head">FASE / RESPONSABLE</div><div class="timeline-head" style="width:${timeline.width}px">${timeline.monthHeader}${timeline.ticks}</div></div>`;
  const rows = tasks.map((task, index) => {
    const offset = (day(task.start) - start) / MS_DAY;
    const duration = (day(task.end) - day(task.start)) / MS_DAY + 1;
    const left = offset * pxPerDay, width = duration * pxPerDay;
    const owners = task.owners.map(id => avatar(memberById(id), 'tiny')).join('');
    const currentWeek = todayOffset >= 0 && todayOffset < total ? `<span class="current-week" style="left:${Math.floor(todayOffset / 7) * 7 * pxPerDay}px;width:${Math.min(7 * pxPerDay, timeline.width - Math.floor(todayOffset / 7) * 7 * pxPerDay)}px"></span>` : '';
    const children = state.plan.tasks.find(item => item.id === task.id)?.subtasks || [];
    const toggle = task.depth === 0 && children.length ? `<button class="task-toggle" data-toggle-task="${task.id}" aria-expanded="${!state.collapsedTasks.has(task.id)}" title="${state.collapsedTasks.has(task.id) ? 'Expandir' : 'Contraer'} subtareas">${state.collapsedTasks.has(task.id) ? '+' : '−'}</button>` : '<span class="task-toggle-placeholder"></span>';
    return `<div class="gantt-row ${task.depth ? 'subtask-row' : ''}" style="--row-index:${index}" data-row="${task.id}"><div class="task-label"><div class="task-entry" style="padding-left:${task.depth ? 16 : 0}px">${toggle}<button class="task-open" data-task="${task.id}"><b>${esc(task.name)}</b><span>${owners}<small>${esc(ownersLabel(task))}</small></span></button></div></div><div class="task-lane" style="width:${timeline.width}px;background-size:${config.cell}px 100%">${currentWeek}<button class="task-bar ${statusClass(task.status)}" data-task="${task.id}" style="--row-index:${index};left:${left}px;width:${Math.max(width - 5, 16)}px" title="${esc(task.name)} · ${task.progress}% estimado · ${esc(task.status)}"><i style="width:${task.progress}%"></i><span>${task.progress}%</span></button><span class="lane-today" style="left:${todayOffset * pxPerDay}px"></span></div></div>`;
  }).join('');
  const taskPositions = new Map(tasks.map((task, index) => [task.id, { y: index * 51 + 25, end: (day(task.end) - start) / MS_DAY } ]));
  const connectors = tasks.flatMap((task, index) => task.dependencies.flatMap(dependencyId => {
    const from = taskPositions.get(dependencyId); if (!from) return [];
    const x1 = 190 + (from.end + 1) * pxPerDay, y1 = from.y;
    const x2 = 190 + (day(task.start) - start) / MS_DAY * pxPerDay, y2 = index * 51 + 25;
    const bend = Math.max(12, Math.min(28, (x2 - x1) / 3));
    return [`<path class="dependency-path" data-from="${esc(dependencyId)}" data-to="${esc(task.id)}" d="M ${x1} ${y1} C ${x1 + bend} ${y1}, ${x2 - bend} ${y2}, ${x2} ${y2}" marker-end="url(#dep-arrow)"/>`];
  })).join('');
  const dependencySvg = connectors ? `<svg class="dependency-lines" width="${timeline.width + 190}" height="${Math.max(tasks.length * 51, 1)}" aria-hidden="true"><defs><marker id="dep-arrow" markerWidth="7" markerHeight="7" refX="6" refY="3.5" orient="auto"><path d="M0,0 L7,3.5 L0,7" fill="none" stroke="#8775a8" stroke-width="1"/></marker></defs>${connectors}</svg>` : '';
  $('#ganttGrid').innerHTML = `${header}<div class="gantt-body" style="width:${timeline.width + 190}px">${dependencySvg}${todayLine}${rows || '<div class="no-tasks">No hay actividades para estos filtros.</div>'}</div>`;
  $('#ganttGrid').style.setProperty('--timeline-width', `${timeline.width}px`);
  $('#ganttCount').textContent = `${tasks.length} de ${state.plan.tasks.length} actividades visibles`;
  $('#ganttScroll').classList.toggle('day-view', state.zoom === 'day');
  $$('[data-zoom]').forEach(button => button.classList.toggle('selected', button.dataset.zoom === state.zoom));
  if (state.selectedTask) highlightTask(state.selectedTask);
}

function renderActivities() {
  const query = normalize($('#activitySearch')?.value || '');
  const tasks = state.plan.tasks.filter(task => normalize(task.name).includes(query) || normalize(task.description).includes(query) || task.owners.some(id => normalize(personName(id)).includes(query)));
  $('#activityCards').innerHTML = tasks.map(task => `<article class="activity-card"><div class="activity-card-top"><span class="tag ${statusClass(task.status)}">${esc(task.status)}</span><button class="circle-action" data-task="${task.id}" aria-label="Ver detalles de ${esc(task.name)}">↗</button></div><h2>${esc(task.name)}</h2><p>${esc(task.description)}</p><div class="activity-dates"><span>◷ ${esc(shortDate(task.start))} — ${esc(shortDate(task.end))}</span><span>${task.progress}% estimado</span></div><div class="progress-track"><i class="${statusClass(task.status)}" style="width:${task.progress}%"></i></div><div class="activity-owners">${task.owners.map(id => avatar(memberById(id), 'tiny')).join('')}<small>${esc(task.owners.map(personName).join(' · '))}</small></div></article>`).join('');
}

function renderTeam() {
  $('#teamGrid').innerHTML = state.plan.members.map(member => {
    const tasks = state.plan.tasks.filter(task => task.owners.includes(member.id));
    const avg = tasks.length ? Math.round(tasks.reduce((sum, task) => sum + task.progress, 0) / tasks.length) : 0;
    return `<article class="panel member-card ${state.selectedMember === member.id ? 'is-selected' : ''}" data-member-card="${member.id}" style="--member-color:${member.color};--card-index:${state.plan.members.indexOf(member)}"><div class="member-card-top"><button class="member-photo-select" data-member-select="${member.id}" title="Seleccionar a ${esc(member.name)}">${avatar(member, 'member-avatar')}<span class="member-orbit">✦</span></button><span class="member-signal"><i></i> Tripulación</span></div><h2>${esc(member.name)}</h2><span class="member-role">${esc(member.role)}</span><div class="member-divider"></div><div class="member-metric"><span>Actividades asignadas</span><b>${tasks.length}</b></div><div class="member-tasks">${tasks.map(task => `<span title="${esc(task.name)} · ${task.progress}% estimado" class="member-task-dot ${statusClass(task.status)}"></span>`).join('')}</div><div class="member-metric"><span>Avance medio estimado</span><b>${avg}%</b></div><div class="progress-track"><i style="width:${avg}%;background:${member.color}"></i></div><div class="member-metric commits-metric"><span>Commits verificados</span><b>${commitsForMember(member).length}</b></div><small class="member-footnote">${commitsForMember(member).length ? 'Actividad registrada en GitHub' : 'Sin autoría identificada en esta captura'}</small></article>`;
  }).join('');
}

function filteredCommits() {
  const branch = $('#branchFilter')?.value || 'all', memberId = $('#memberFilter')?.value || 'all';
  const query = normalize($('#commitSearch')?.value || ''), period = $('#periodFilter')?.value || 'all';
  const cutoff = period === 'all' ? null : new Date(new Date(state.github.fetchedAt).getTime() - Number(period) * MS_DAY);
  return sortedCommits().filter(commit => {
    const member = state.plan.members.find(item => item.gitNames.some(name => normalize(name) === normalize(commit.authorName)));
    return (branch === 'all' || commit.branches.includes(branch)) && (memberId === 'all' || member?.id === memberId) && (!query || normalize(`${commit.authorName} ${member?.name || ''} ${commit.message}`).includes(query)) && (!cutoff || new Date(commit.date) >= cutoff);
  });
}

function renderGithub() {
  const commits = filteredCommits();
  $('#commitResults').textContent = `(${commits.length})`;
  $('#commitEmpty').classList.toggle('hidden', commits.length > 0);
  $('#commitRows').innerHTML = commits.map(commit => {
    const member = state.plan.members.find(item => item.gitNames.some(name => normalize(name) === normalize(commit.authorName)));
    const displayName = member?.name || commit.authorName;
    const branchLinks = commit.branches.slice(0, 2).map(name => {
      const branch = state.github.branches.find(item => item.name === name);
      return `<a class="branch-chip" href="${esc(branch?.url || `${GITHUB_REPO}/tree/${encodeURIComponent(name)}`)}" target="_blank" rel="noreferrer">${esc(name)}</a>`;
    }).join(' ');
    const extraBranches = commit.branches.length > 2 ? `<a class="branch-chip more-branches" href="${GITHUB_REPO}/branches" target="_blank" rel="noreferrer">+${commit.branches.length - 2}</a>` : '';
    return `<tr><td><span class="author-cell">${avatar(member || { name: displayName, color: '#8A2BE2' }, 'tiny')}<span><b>${esc(displayName)}</b><small>${esc(commit.authorLogin || 'Autor de GitHub')}</small></span></span></td><td><span class="commit-message">${esc(commit.message)}</span><small class="sha">${esc(commit.sha.slice(0, 8))}</small></td><td><span class="branch-links" title="${esc(commit.branches.join(', '))}">${branchLinks}${extraBranches}</span></td><td>${esc(dateLabel(commit.date))}</td><td><a class="commit-link" href="${esc(commit.url)}" target="_blank" rel="noreferrer" aria-label="Abrir commit">↗</a></td></tr>`;
  }).join('');
}

function renderReports() {
  const statusCounts = [...new Set(state.plan.tasks.map(task => task.status))].map(status => ({ status, count: state.plan.tasks.filter(task => task.status === status).length }));
  const colors = { 'Realizado': '#1DE9B6', 'Avanzado': '#C0B2F5', 'En desarrollo': '#8A2BE2', 'Iniciado': '#F5D742', 'Pendiente': '#3d4054' };
  let cumulative = 0;
  const donutStops = statusCounts.map(({ status, count }) => { cumulative += count / state.plan.tasks.length * 100; return `${colors[status]} ${cumulative}%`; });
  $('#statusChart').innerHTML = `<div class="donut" style="--segments:${donutStops.join(', ')}"><div><b>${state.plan.tasks.length}</b><small>actividades</small></div></div><div class="chart-legend">${statusCounts.map(({ status, count }) => `<div><span><i style="background:${colors[status]}"></i>${esc(status)}</span><b>${count}</b></div>`).join('')}</div>`;
  const counts = state.plan.members.map(member => ({ member, count: state.plan.tasks.filter(task => task.owners.includes(member.id)).length }));
  $('#ownerChart').innerHTML = counts.map(({ member, count }) => `<div class="bar-row"><span>${avatar(member, 'tiny')}<small>${esc(member.name.split(' ')[0])}</small></span><div class="bar-base"><i style="width:${count / Math.max(...counts.map(item => item.count)) * 100}%;background:${member.color}"></i></div><b>${count}</b></div>`).join('');
  const commitCounts = state.plan.members.map(member => ({ member, count: commitsForMember(member).length }));
  $('#commitChart').innerHTML = commitCounts.map(({ member, count }) => `<div class="bar-row"><span>${avatar(member, 'tiny')}<small>${esc(member.name.split(' ')[0])}</small></span><div class="bar-base"><i style="width:${state.github.commits.length ? count / Math.max(...commitCounts.map(item => item.count), 1) * 100 : 0}%;background:${member.color}"></i></div><b>${count}</b></div>`).join('');
  const months = new Map();
  sortedCommits().forEach(commit => { const key = new Intl.DateTimeFormat('es-MX', { month: 'short', year: '2-digit' }).format(new Date(commit.date)); months.set(key, (months.get(key) || 0) + 1); });
  const monthData = [...months.entries()].reverse(); const maxMonth = Math.max(...monthData.map(([, count]) => count), 1);
  $('#monthChart').innerHTML = monthData.map(([month, count]) => `<div class="month-column"><b>${count}</b><i style="height:${Math.max(8, count / maxMonth * 110)}px"></i><small>${esc(month)}</small></div>`).join('');
  $('#phaseChart').innerHTML = state.plan.tasks.map(task => `<div class="phase-row"><div><span>${esc(task.name)}</span><b>${task.progress}%</b></div><div class="progress-track"><i class="${statusClass(task.status)}" style="width:${task.progress}%"></i></div></div>`).join('');
}

function openTask(id) {
  const task = taskById(id); if (!task) return;
  state.selectedTask = id;
  highlightTask(id);
  $('#modalTitle').textContent = task.name;
  $('#modalDescription').textContent = task.description;
  $('#modalEyebrow').textContent = `ACTIVIDAD ${String(state.plan.tasks.indexOf(task) + 1).padStart(2, '0')} · ${task.status.toUpperCase()}`;
  $('#modalMeta').innerHTML = `<div><small>Inicio</small><b>${esc(dateLabel(day(task.start)))}</b></div><div><small>Fin</small><b>${esc(dateLabel(day(task.end)))}</b></div><div class="modal-assignees"><small>Responsables</small><div>${task.owners.map(id => { const member = memberById(id); return `<span class="modal-owner">${avatar(member, 'modal-avatar')}<b>${esc(member.name)}</b></span>`; }).join('')}</div></div>`;
  $('#modalProgress').textContent = `${task.progress}%`;
  $('#modalProgressBar').style.width = `${task.progress}%`;
  const dependencies = task.dependencies.map(id => taskById(id));
  $('#modalDependencies').innerHTML = dependencies.length ? dependencies.map(item => `<button class="dependency-link" data-task="${item.id}">${esc(item.name)} ↗</button>`).join('') : '<span class="muted">Sin dependencias previas</span>';
  $('#taskModal').classList.add('open'); $('#taskModal').setAttribute('aria-hidden', 'false'); document.body.classList.add('modal-open');
}
function highlightTask(id) {
  const related = new Set([id, ...((taskById(id)?.dependencies) || [])]);
  $$('#ganttGrid .gantt-row').forEach(row => {
    const selected = row.dataset.row === id;
    row.classList.toggle('is-selected', selected);
    row.classList.toggle('is-related', related.has(row.dataset.row));
  });
  $$('#ganttGrid .dependency-path').forEach(path => {
    path.classList.toggle('is-related', path.dataset.from === id || path.dataset.to === id || related.has(path.dataset.from) || related.has(path.dataset.to));
  });
}
function closeModal() { $('#taskModal').classList.remove('open'); $('#taskModal').setAttribute('aria-hidden', 'true'); document.body.classList.remove('modal-open'); }

function setView(view) {
  if (!$(`#view-${view}`)) return;
  state.view = view;
  $$('.page-view').forEach(section => section.classList.toggle('active', section.id === `view-${view}`));
  $$('.nav-link').forEach(button => button.classList.toggle('active', button.dataset.view === view));
  $('#breadcrumbCurrent').textContent = ({ overview: 'Resumen', gantt: 'Cronograma Gantt', activities: 'Actividades', team: 'Equipo', github: 'Historial de GitHub', reports: 'Reportes' })[view];
  $('#sidebar').classList.remove('mobile-open'); window.scrollTo({ top: 0, behavior: 'smooth' });
  if (view === 'gantt') renderGantt();
}

function bindEvents() {
  document.addEventListener('error', event => {
    if (!event.target.matches?.('.avatar-image')) return;
    event.target.closest('.photo-avatar')?.classList.add('missing-photo');
    event.target.remove();
  }, true);
  document.addEventListener('click', event => {
    const nav = event.target.closest('[data-view]'); if (nav) { setView(nav.dataset.view); return; }
    const openView = event.target.closest('[data-open-view]'); if (openView) { setView(openView.dataset.openView); return; }
    const toggleTask = event.target.closest('[data-toggle-task]'); if (toggleTask) { const id = toggleTask.dataset.toggleTask; state.collapsedTasks.has(id) ? state.collapsedTasks.delete(id) : state.collapsedTasks.add(id); renderGantt(); return; }
    const selectMember = event.target.closest('[data-member-select]'); if (selectMember) { state.selectedMember = selectMember.dataset.memberSelect; setView('team'); renderTeamStrip(); renderTeam(); return; }
    const task = event.target.closest('[data-task]'); if (task) { if (task.closest('#miniGantt')) setView('gantt'); openTask(task.dataset.task); return; }
    const zoom = event.target.closest('[data-zoom]'); if (zoom) { state.zoom = zoom.dataset.zoom; renderGantt(); return; }
    if (event.target.closest('#modalClose') || event.target.id === 'taskModal') closeModal();
  });
  $('#ownerFilter').addEventListener('change', event => { state.owner = event.target.value; renderGantt(); });
  $('#statusFilter').addEventListener('change', event => { state.status = event.target.value; renderGantt(); });
  $('#resetGantt').addEventListener('click', () => { state.owner = 'all'; state.status = 'all'; $('#ownerFilter').value = 'all'; $('#statusFilter').value = 'all'; renderGantt(); });
  $('#activitySearch').addEventListener('input', renderActivities);
  ['commitSearch', 'branchFilter', 'memberFilter', 'periodFilter'].forEach(id => $(`#${id}`).addEventListener(id === 'commitSearch' ? 'input' : 'change', renderGithub));
  $('#mobileMenu').addEventListener('click', () => $('#sidebar').classList.toggle('mobile-open'));
  $('#githubLink').addEventListener('click', () => window.open(GITHUB_REPO, '_blank', 'noopener,noreferrer'));
  $('#modalClose').addEventListener('click', closeModal);
  document.addEventListener('keydown', event => { if (event.key === 'Escape') closeModal(); });
}

init();
