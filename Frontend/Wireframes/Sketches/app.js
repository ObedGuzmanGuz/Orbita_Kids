const byId = id => document.getElementById(id);
const state = { role:'Estudiante', platform:'Movil', index:0, query:'', caseId:'inicio', selectedEvent:0, lightbox:false, view:'wire' };
const humanPlatform = p => p==='Movil' ? 'App móvil' : 'Web / PWA';
const list = () => CATALOGO.filter(s=>s.role===state.role && s.platform===state.platform).sort((a,b)=>a.step-b.step);
const getCurrent = () => list()[state.index] || list()[0];
const imgOf = s => state.view==='sketch' ? (s.fileSketch||s.file) : s.file;
const techOf = s => s.platform==='Movil' ? 'Flutter' : 'React + Vite';
function specHTML(s){
 const sp=s.spec; if(!sp) return '';
 const fl=s.platform==='Movil', u=sp.frame.unit, limit=fl?648:720;
 const regs=sp.regions.map(r=>`<div class="spec-row"><span>${escapeHtml(r.name)}</span><b>${escapeHtml(r.size)}</b></div>`).join('');
 const comps=sp.components.map(c=>`<div class="spec-comp"><div><strong>${escapeHtml(c.name)}</strong><code>${escapeHtml(fl?c.flutter:c.react)}</code></div><b>${escapeHtml(c.size)}</b></div>`).join('');
 return `<div class="spec-frame"><b>${sp.frame.w}×${sp.frame.h} ${u}</b><span>${sp.frame.tech}</span></div>${regs}<h4>Componentes (${sp.components.length})</h4>${comps}<p class="spec-note">Altura total del contenido: ${sp.contentHeight} ${u}${sp.contentHeight>limit?' · requiere scroll':' · cabe sin scroll'}. Medidas en ${fl?'dp (Flutter)':'px CSS (React + Vite)'}.</p>`;
}
function syncViewToggle(){
 document.querySelectorAll('[data-view]').forEach(b=>{const on=b.dataset.view===state.view;b.classList.toggle('selected',on);b.setAttribute('aria-pressed',String(on));});
 const wf=document.querySelector('.stage-head .wireframe'); if(wf) wf.textContent=state.view==='wire'?'WIREFRAME · SOLO CAJAS Y MEDIDAS':'SKETCH ORIGINAL · B/N';
 const cap=document.querySelector('.modal-image-caption span'); if(cap) cap.textContent=state.view==='wire'?'WIREFRAME · B/N · MEDIDAS dp / px':'SKETCH ORIGINAL · B/N';
}
function setView(v){state.view=v;render();if(!byId('lightbox').hidden)renderLightbox();if(!byId('diagramOverlay').hidden)renderDiagramDetail();}
const norm = s => String(s||'').normalize('NFD').replace(/[\u0300-\u036f]/g,'').toLowerCase();

// Searching is scoped to the role and platform selected above. Every word can
// match a different field: name, description, category, actions or keywords.
const SEARCH_SYNONYMS = {
 'ejercicio':['reto','movimiento','fisico','actividad'],
 'ejercicios':['reto','movimiento','fisico','actividad'],
 'deporte':['movimiento','fisico','reto'],
 'deportes':['movimiento','fisico','reto'],
 'mover':['movimiento','pausa','fisico'],
 'activo':['pausa','movimiento','fisico'],
 'actividad':['actividad','reto','ejercicio'],
 'actividades':['actividad','reto','ejercicio'],
 'fisica':['fisico','movimiento','reto'],
 'fisicas':['fisico','movimiento','reto'],
 'fisico':['fisico','movimiento','reto'],
 'fisicos':['fisico','movimiento','reto'],
 'offline':['sin pantalla','imprimible','entorno'],
 'sinconexion':['offline','imprimible'],
 'maestro':['profesor','docente'],
 'maestra':['profesor','docente'],
 'docente':['profesor','maestro'],
 'alumno':['estudiante','infantil'],
 'alumnos':['estudiante','infantil'],
 'ninos':['infantil','estudiante'],
 'video':['video','leccion'],
 'videos':['video','leccion'],
 'pdf':['descargar','imprimible'],
 'guardar':['guardar','registrar'],
 'descanso':['pausa','equilibrio'],
 'salud':['bienestar','fisico','equilibrio']
};
function searchTerms(query){return norm(query).replace(/[^\p{L}\p{N}]+/gu,' ').trim().split(/\s+/).filter(Boolean)}
function searchFields(screen){
 const title=norm(screen.title+' '+screen.slug.replaceAll('_',' ')+' '+screen.step+' '+String(screen.step).padStart(2,'0'));
 const actions=norm((screen.actions||[]).join(' '));
 const rest=norm([screen.description,screen.category,screen.role,humanPlatform(screen.platform),purposeFor(screen)].join(' '));
 return {title,actions,rest,full:[title,actions,rest].join(' ')};
}
function nearWord(token,text){
 if(text.includes(token))return true;
 if(token.length<5)return false;
 const words=text.split(/\s+/);
 return words.some(word=>{
  if(Math.abs(word.length-token.length)>1)return false;
  if(word[0]!==token[0])return false;
  let a=0,b=0,d=0;
  while(a<word.length&&b<token.length&&d<=1){
   if(word[a]===token[b]){a++;b++;continue;}
   d++;
   if(word.length>token.length)a++;
   else if(token.length>word.length)b++;
   else {a++;b++;}
  }
  return d+(word.length-a)+(token.length-b)<=1;
 });
}
function scoreSearch(screen,query,directTerms=new Set()){
 const terms=searchTerms(query);
 if(!terms.length)return 0;
 const fields=searchFields(screen);
 let score=0;
 for(const term of terms){
   const alternatives=directTerms.has(term)?[term]:[term,...(SEARCH_SYNONYMS[term]||[])];
   let best=0;
   for(const alt of alternatives){
     if(fields.title.includes(alt))best=Math.max(best,alt===term?12:7);
     if(fields.actions.includes(alt))best=Math.max(best,alt===term?8:5);
     if(fields.rest.includes(alt))best=Math.max(best,alt===term?5:3);
     if(!best && nearWord(alt,fields.full))best=1;
   }
   if(!best)return -1; // AND: every search word must have a match.
   score+=best;
 }
 if(fields.title.includes(norm(query).trim()))score+=18;
 return score;
}
function activeMatches(){
 const group=list();
 const terms=searchTerms(state.query);
 if(!terms.length)return group.map((screen,index)=>({screen,index,score:0}));
 const directTerms=new Set(terms.filter(term=>group.some(screen=>searchFields(screen).full.includes(term))));
 return group.map((screen,index)=>({screen,index,score:scoreSearch(screen,state.query,directTerms)}))
   .filter(entry=>entry.score>=0)
   .sort((a,b)=>b.score-a.score||a.screen.step-b.screen.step);
}
function relativeScreenIndex(delta){
 const matches=activeMatches();
 if(!matches.length)return state.index;
 const pos=matches.findIndex(entry=>entry.index===state.index);
 return matches[(pos+delta+matches.length)%matches.length].index;
}
function highlightSearch(value){
 const words=searchTerms(state.query).filter(term=>term.length>1);
 if(!words.length)return escapeHtml(value);
 const parts=String(value).split(/(\s+)/);
 return parts.map(part=>{
  const normalized=norm(part);
  return words.some(word=>normalized.includes(word))?'<mark class="search-hit">'+escapeHtml(part)+'</mark>':escapeHtml(part);
 }).join('');
}

function setScreen(i,opts={}) {
 const all=list(); if(!all.length) return;
 state.index = (i+all.length)%all.length;
 if(searchTerms(state.query).length && !activeMatches().some(entry=>entry.index===state.index)){
   state.query='';byId('search').value='';
 }
 byId('feedback').classList.remove('show');
 render();
 if(opts.scroll) byId('activeEntry')?.scrollIntoView({block:'nearest',behavior:'smooth'});
}
function showFeedback(msg){const el=byId('feedback'); el.textContent=msg; el.classList.add('show');}
function actionBehavior(action,screen){
 const a=norm(action);
 const all=list();
 const candidates = [
  [/reto|movimiento|fisic|pausa/, ['retos_fisicos','retos_offline','reto_fisico','creador_retos','pausa_activa','pausas_activas','reto_movimiento']],
  [/curso|modulo/,['cursos','dashboard_cursos','detalle_curso']],
  [/leccion|continuar contenido/,['leccion','leccion_breve']],
  [/grupo/,['mis_grupos','grupos']],
  [/perfil|avatar/,['perfil','perfil_infantil']],
  [/evalu|validar|evidencia/,['registro_sin_foto','entrega_actividad','validar_reto','validar_actividad']],
  [/actividad|tarea/,['crear_actividad','asignar_contenido','registro_actividades','quiz']],
  [/diario|reflexion/,['diario']],
  [/progreso|avance|seguimiento/,['avance_alumnos','seguimiento','reporte_semanal']],
  [/reporte|informe/,['reporte_semana','reporte_semanal','informes']],
  [/agenda|calendario|semana/,['calendario','plan_semanal']],
  [/logro|insignia|constancia/,['logros','constancias']],
  [/mensaje|familia/,['mensajes_familia','familias']],
  [/seguridad|reglas/,['seguridad','protocolo']],
 ];
 let candidate=null;
 for(const [pattern,slugs] of candidates){
  if(pattern.test(a)){ candidate=all.find(s=>slugs.includes(s.slug) && s.slug!==screen.slug); if(candidate) break; }
 }
 const nonNav=/guardar|publicar|enviar|marcar|confirmar|activar|desactivar|descargar|imprimir|compartir|registrar|comprobar|seleccionar|editar|escuchar|anotar|pausar|responder|programar|aprobar|calificar|escribir|filtrar|personalizar|configurar|solicitar|realizar|iniciar|salir a|explorar entorno|ver materiales|ver instrucciones/.test(a);
 if(candidate && !nonNav){setScreen(all.indexOf(candidate),{scroll:true}); showFeedback(`Recorrido conceptual: «${action}» abrió «${candidate.title}».`);return;}
 if(/siguiente|continuar|entrar|ir a|abrir|comenzar|revisar/.test(a) && screen.next && !nonNav){
  const target=all.findIndex(s=>s.slug===screen.next);
  if(target>=0){setScreen(target,{scroll:true});showFeedback(`Recorrido conceptual: «${action}» llevó a «${all[target].title}».`);return;}
 }
 showFeedback(`Acción simulada: «${action}». En la app real se ${effectFor(screen,action).toLowerCase()}`);
}
function effectFor(screen,action){
 const a=norm(action); let result;
 if(/descargar|imprimir/.test(a)) result='Prepara el recurso de apoyo para trabajar fuera de pantalla.';
 else if(/guardar|registrar|anotar|marcar/.test(a)) result='Registra el avance o evidencia del usuario (en este prototipo solo se muestra la simulación).';
 else if(/enviar|publicar|compartir|asignar/.test(a)) result='Presenta la confirmación del envío o asignación (simulación).';
 else if(/pausa|fisic|circuito|movimiento|salir/.test(a) || screen.category==='Fuera de pantalla') result='Muestra las instrucciones del reto y propone cerrar el dispositivo para realizar la actividad en el entorno.';
 else if(/calificar|evaluar|aprobar|validar/.test(a)) result='Actualiza el estado de revisión en la propuesta de interfaz.';
 else if(/editar|configurar|personalizar/.test(a)) result='Presenta opciones para modificar la configuración o el contenido.';
 else result='Muestra el contenido o la confirmación que corresponde a la acción elegida.';
 return result;
}
function render(){
 const arr=list();
 document.querySelectorAll('[data-role]').forEach(btn=>btn.setAttribute('aria-selected',String(btn.dataset.role===state.role)));
 document.querySelectorAll('[data-platform]').forEach(btn=>btn.setAttribute('aria-selected',String(btn.dataset.platform===state.platform)));
 document.querySelectorAll('.role-parent').forEach(btn=>{const active=btn.dataset.role===state.role;btn.classList.toggle('selected',active);btn.setAttribute('aria-pressed',String(active));btn.setAttribute('aria-expanded',String(active))});
 document.querySelectorAll('.platform-child').forEach(btn=>{const active=btn.dataset.platform===state.platform;btn.classList.toggle('selected',active);btn.setAttribute('aria-pressed',String(active))});
 byId('selectedRoleName').textContent=state.role.toUpperCase();
 byId('selectedPath').textContent=`${state.role} / ${humanPlatform(state.platform)}`;
 const matched=activeMatches();
 const searching=searchTerms(state.query).length>0;
 if(searching && matched.length && !matched.some(entry=>entry.index===state.index))state.index=matched[0].index;
 const current=arr[state.index]||arr[0];
 byId('listTotal').textContent=searching?`${matched.length} de ${arr.length} resultados`:`${arr.length} pantallas`;
 byId('clearSearch').hidden=!searching;
 byId('searchStatus').textContent=searching
   ?(matched.length?`${matched.length} coincidencia${matched.length===1?'':'s'} en ${state.role} / ${humanPlatform(state.platform)}`:`Sin resultados en ${state.role} / ${humanPlatform(state.platform)}`)
   :`Buscando en ${state.role} / ${humanPlatform(state.platform)}`;
 byId('searchStatus').classList.toggle('no-match',searching&&!matched.length);
 byId('screenList').innerHTML = matched.length
   ? matched.map(({screen:s,index})=>`<button type="button" class="screen-entry" ${index===state.index?'id="activeEntry"':''} aria-current="${index===state.index}" data-index="${index}"><img src="${imgOf(s)}" alt=""><span class="names"><b>${String(s.step).padStart(2,'0')} · ${highlightSearch(s.title)}</b><small>${highlightSearch(s.category)}</small></span><span class="chev">›</span></button>`).join('')
   : `<div class="screen-empty"><span class="empty-star">✧</span><strong>No encontramos ese sketch</strong><p>Prueba con otro término, una acción o una palabra más corta. También puedes cambiar de rol o plataforma.</p><button class="ghost" type="button" id="resetEmptySearch">Limpiar búsqueda</button></div>`;
 byId('screenList').querySelectorAll('.screen-entry').forEach(btn=>btn.onclick=()=>setScreen(Number(btn.dataset.index)));
 byId('resetEmptySearch')?.addEventListener('click',clearSearch);
 const noMatches=searching&&!matched.length;
 byId('imagePreviewTrigger').hidden=noMatches;
 byId('zoomBtn').disabled=noMatches;
 byId('backBtn').disabled=noMatches;
 byId('nextBtn').disabled=noMatches;
 let emptyPreview=byId('emptyPreview');
 if(noMatches){
   if(!emptyPreview){
     emptyPreview=document.createElement('div');emptyPreview.id='emptyPreview';emptyPreview.className='empty-preview';
     emptyPreview.innerHTML='<span>✦</span><strong>Sin coincidencias</strong><p>Intenta buscar por título, reto, movimiento, descripción o una acción del estudiante o profesor.</p>';
     byId('imagePreviewTrigger').parentElement.appendChild(emptyPreview);
   }
   emptyPreview.hidden=false;
   byId('stageName').textContent='Sin resultados';
   byId('counter').textContent='0 resultados';
   byId('detailTitle').textContent='Sin coincidencias';
   byId('detailDesc').textContent=`No hay pantallas relacionadas con «${state.query.trim()}» en esta vista.`;
   byId('purpose').textContent='Prueba con un término más general o cambia de rol y plataforma.';
   byId('actionList').innerHTML='';
   byId('tags').innerHTML='';
   byId('roleLabel').textContent='BUSCADOR · ÓRBITA KIDS';
   byId('detailNote').textContent='La búsqueda revisa títulos, descripciones, categorías y acciones.';
   return;
 }
 if(emptyPreview)emptyPreview.hidden=true;
 const screen=current;
 if(!screen)return;
 byId('modeLabel').textContent=humanPlatform(screen.platform).toUpperCase();
 byId('stageName').textContent=screen.title;
 byId('mainImg').src=imgOf(screen);
 byId('mainImg').alt=`${state.view==='wire'?'Wireframe con medidas':'Sketch original'}: ${screen.title}`;
 byId('counter').textContent=searching?`${matched.findIndex(entry=>entry.index===state.index)+1} / ${matched.length} coincidencias`:`${screen.step} / ${arr.length}`;
 byId('roleLabel').textContent=`PANTALLA ${String(screen.step).padStart(2,'0')} · ${screen.role.toUpperCase()}`;
 byId('detailTitle').textContent=screen.title;
 byId('detailDesc').textContent=screen.description;
 byId('purpose').textContent=purposeFor(screen);
 byId('tags').innerHTML=`<span class="tag">${humanPlatform(screen.platform)}</span><span class="tag">${screen.category}</span><span class="tag">${screen.role}</span>`;
 const actions=byId('actionList');actions.innerHTML='';
 screen.actions.forEach((a,i)=>{const b=document.createElement('button');b.className='action';b.type='button';b.innerHTML=`<span>${escapeHtml(a)}</span><small>${i===0?'Acción principal':'Probar acción'} ↗</small>`;b.onclick=()=>actionBehavior(a,screen);actions.appendChild(b);});
 byId('detailNote').textContent='Los wireframes son diseños conceptuales con medidas (dp en Flutter, px en React + Vite). Los botones demuestran acciones previstas y navegación ilustrativa, sin guardar datos reales.';
 byId('specTech').textContent=techOf(screen);byId('specBox').innerHTML=specHTML(screen);syncViewToggle();
}
function purposeFor(s){
 if(s.category==='Fuera de pantalla')return 'Conectar el contenido educativo con movimiento, observación o experiencias reales. Tras consultar la guía, se invita al estudiante a apartar el dispositivo.';
 if(s.category==='Seguimiento')return s.role==='Profesor'?'Facilitar la revisión de evidencias, avances y participación con información organizada.':'Permitir al estudiante revisar su avance sin fomentar sesiones prolongadas frente a la pantalla.';
 return s.role==='Profesor'?'Organizar el trabajo docente, simplificar decisiones y gestionar actividades digitales y fuera de pantalla.':'Ofrecer tareas cortas, comprensibles y adecuadas para una experiencia educativa infantil.';
}
function escapeHtml(str){return String(str).replace(/[&<>"']/g,m=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m]));}

// Sequence diagram flows use actual screens; view is opened only by pressing 'Ver diagrama'.
const CASES = {
 Estudiante:{
  inicio:{title:'Ingreso y aprendizaje',slugs:['bienvenida','acceso','inicio','cursos','leccion','video_limitado','quiz'],summary:'El estudiante entra, elige un tema y realiza una sesión breve.'},
  mundo:{title:'Reto físico y entorno',slugs:['retos_fisicos','reto_circuito','pausa_activa','explorar_entorno','experimento','lectura_sin_pantalla','actividad_familiar','retos_offline','reto_movimiento','naturaleza','experimento_casa','guia_imprimible'],summary:'La pantalla da instrucciones y el estudiante realiza el reto fuera del dispositivo.'},
  cierre:{title:'Evidencia y progreso',slugs:['registro_sin_foto','diario','equilibrio_digital','logros','perfil','entrega_actividad','equilibrio','reporte_semanal','constancias'],summary:'El estudiante registra lo realizado y consulta su progreso.'}
 },
 Profesor:{
  inicio:{title:'Clases y planeación',slugs:['acceso','inicio','mis_grupos','avance_alumnos','crear_actividad','grupos','seguimiento','cursos','asignar_contenido'],summary:'El docente consulta grupos y prepara actividades.'},
  mundo:{title:'Actividades sin pantalla',slugs:['biblioteca_offline','reto_fisico','asignar_reto','rutas_entorno','pausas_programadas','rutinas_aula','seguridad','creador_retos','plan_semanal','pausas_activas','imprimibles'],summary:'El profesor diseña retos motrices, los asigna y establece medidas de seguridad.'},
  cierre:{title:'Revisión y retroalimentación',slugs:['validar_reto','retroalimentar','rúbrica','mensajes_familia','uso_pantalla','reporte_semana','validar_actividad','rubrica','retroalimentacion','uso_digital','bienestar','informes'],summary:'El docente comprueba evidencias, devuelve comentarios y revisa el equilibrio digital.'}
 }
};
const ACTOR_LABELS={Estudiante:['Estudiante','App / PWA','Aprendizaje / datos','Entorno real'],Profesor:['Profesor','Panel docente','Contenido / datos','Estudiante / familia']};
// Diagrama actualizado: el 2.º actor refleja la tecnología real de cada plataforma.
function actorNames(){
 const base=ACTOR_LABELS[state.role].slice();
 base[1]=state.platform==='Movil' ? (state.role==='Profesor'?'App Flutter · docente':'App Flutter') : (state.role==='Profesor'?'PWA React + Vite · panel':'PWA React + Vite');
 return base;
}
function caseScreens(){const cfg=CASES[state.role][state.caseId],all=list(); const selected=all.filter(s=>cfg.slugs.includes(s.slug));
 // Preserve the user's screen order while keeping concise sequence diagrams
 return selected.slice(0,7);
}
function caseEvents(){
 const s=caseScreens();
 const events=[];
 s.forEach(screen=>{
  const external = screen.category==='Fuera de pantalla' || (state.role==='Profesor' && ['asignar_reto','mensajes_familia','familias','asignar_contenido','pausas_programadas'].includes(screen.slug));
  events.push({screen,type:'request',from:0,to:1,label:screen.actions[0],detail:`${screen.title}: ${screen.description}`,accent:'var(--amber)'});
  events.push({screen,type:'response',from:external?3:2,to:0,label:external?(state.role==='Profesor'?'Reto asignado / realizado':'Actividad fuera de pantalla'):'Confirmación / contenido',detail:modalExpectedResponse(screen,screen.actions[0]),accent:'var(--blue)'});
 });
 return events;
}
let diagramPlayTimer=null;
function pauseDiagram(){
 if(diagramPlayTimer){clearInterval(diagramPlayTimer);diagramPlayTimer=null;}
 const play=byId('diagramPlay'); if(play){play.textContent='▶ Recorrer flujo';play.setAttribute('aria-pressed','false');}
}
function navigateDiagram(delta,scroll=true){
 const events=caseEvents();if(!events.length)return;
 state.selectedEvent=(state.selectedEvent+delta+events.length)%events.length;
 renderDiagramDetail();
 byId('eventRows').querySelectorAll('.event-msg').forEach((b,j)=>b.classList.toggle('active',j===state.selectedEvent));
 if(scroll)byId('eventRows').querySelectorAll('.event-msg')[state.selectedEvent]?.scrollIntoView({behavior:'smooth',block:'center',inline:'nearest'});
}
function toggleDiagramPlayback(){
 if(diagramPlayTimer){pauseDiagram();return;}
 const events=caseEvents();if(!events.length)return;
 const btn=byId('diagramPlay');btn.textContent='Ⅱ Pausar';btn.setAttribute('aria-pressed','true');
 diagramPlayTimer=setInterval(()=>{if(state.selectedEvent>=caseEvents().length-1){pauseDiagram();return;}navigateDiagram(1);},1700);
}
function openDiagram(){
 pauseDiagram();
 state.selectedEvent=0;
 byId('diagramOverlay').hidden=false;
 document.body.style.overflow='hidden';
 renderDiagram();
 byId('closeDiagram').focus();
}
function closeDiagram(){pauseDiagram();byId('diagramOverlay').hidden=true;document.body.style.overflow='';byId('openDiagram').focus();}
function renderDiagram(){
 const cfg=CASES[state.role][state.caseId],events=caseEvents();
 byId('diagTitle').textContent=`${state.role} · ${humanPlatform(state.platform)}`;
 byId('diagSubtitle').textContent=cfg.summary;
 byId('caseTabs').innerHTML=Object.entries(CASES[state.role]).map(([id,c])=>`<button class="case-btn" data-case="${id}" aria-selected="${id===state.caseId}">${c.title}</button>`).join('');
 byId('caseTabs').querySelectorAll('button').forEach(b=>b.onclick=()=>{pauseDiagram();state.caseId=b.dataset.case;state.selectedEvent=0;renderDiagram()});
 const names=actorNames();
 byId('actors').innerHTML=names.map((n,i)=>`<div class="actor"><div class="actor-circle">${['◉','▣','▤','♧'][i]}</div><div class="actor-label">${n}</div></div>`).join('');
 byId('lifeLines').innerHTML=names.map(()=>'<div class="life"><span class="activation"></span></div>').join('');
 byId('diagramBody').style.height=`${Math.max(380,events.length*106)}px`;
 byId('eventRows').innerHTML='';
 if(!events.length){byId('eventRows').innerHTML='<p>No hay pantallas de este caso para esta plataforma.</p>';return;}
 events.forEach((event,i)=>{
   const row=document.createElement('div');row.className='event';
   const svg=document.createElementNS('http://www.w3.org/2000/svg','svg');svg.setAttribute('viewBox','0 0 1000 106');svg.setAttribute('preserveAspectRatio','none');
   const x1=125+250*event.from, x2=125+250*event.to;
   const backwards=x2<x1, positive=x2>x1;
   const stroke=event.type==='request'?'#ffc387':'#75c9ff';
   const line=document.createElementNS('http://www.w3.org/2000/svg','path');
   line.setAttribute('d',`M ${x1} 79 L ${x2} 79`);line.setAttribute('stroke',stroke);line.setAttribute('stroke-width','2.4');line.setAttribute('fill','none');
   if(event.type==='response') line.setAttribute('stroke-dasharray','9 6');
   svg.appendChild(line);
   const arrow=document.createElementNS('http://www.w3.org/2000/svg','path');
   const ax=positive?x2-1:backwards?x2+1:x1;
   arrow.setAttribute('d', positive?`M${ax-11} 72 L${ax} 79 L${ax-11} 86`: backwards?`M${ax+11} 72 L${ax} 79 L${ax+11} 86`:`M${ax-9} 72 L${ax+9} 79 L${ax-9} 86`);
   arrow.setAttribute('stroke',stroke);arrow.setAttribute('stroke-width','2.2');arrow.setAttribute('fill','none');svg.appendChild(arrow);row.appendChild(svg);
   const bubble=document.createElement('button');bubble.type='button';bubble.className='event-msg'+(i===state.selectedEvent?' active':'');bubble.style.left=`${(x1+x2)/20}%`;
   bubble.innerHTML=`<small>${String(event.screen.step).padStart(2,'0')}.${event.type==='request'?'1 · Acción':'2 · Respuesta'}</small><strong>${escapeHtml(event.label)}</strong><em>${escapeHtml(event.screen.title)}</em>`;
   bubble.onclick=()=>{pauseDiagram();state.selectedEvent=i;renderDiagramDetail(); byId('eventRows').querySelectorAll('.event-msg').forEach((b,j)=>b.classList.toggle('active',j===i))};
   row.appendChild(bubble);byId('eventRows').appendChild(row);
 });
 renderDiagramDetail();
}
function renderDiagramDetail(){
 const events=caseEvents(),e=events[state.selectedEvent]; if(!e)return;
 byId('diagramCounter').textContent=`Paso ${String(state.selectedEvent+1).padStart(2,'0')} / ${String(events.length).padStart(2,'0')}`;
 byId('selectedEventLabel').textContent=e.type==='request'?'ACCIÓN DEL USUARIO':'RESPUESTA DE LA PLATAFORMA / ENTORNO';
 byId('selectedStepName').textContent=e.screen.title;
 byId('selectedEventDesc').textContent=e.screen.description;
 byId('diagramImage').src=imgOf(e.screen);byId('diagramImage').alt=`Wireframe ${e.screen.title}`;
 const sp=e.screen.spec; byId('diagramSpec').textContent=sp?`${sp.frame.w}×${sp.frame.h} ${sp.frame.unit} · ${sp.frame.tech} · ${sp.components.length} componentes · contenido ${sp.contentHeight} ${sp.frame.unit}`:'';
 byId('sequenceAction').textContent=e.type==='request'?e.label:`La plataforma devuelve: ${e.label.toLowerCase()}`;
 const showResponse=(action,index)=>{
  byId('sequenceResponse').textContent=modalExpectedResponse(e.screen,action);
  byId('diagramAvailableActions').querySelectorAll('button').forEach((b,i)=>{b.classList.toggle('selected',i===index);b.setAttribute('aria-pressed',String(i===index));});
 };
 const wrap=byId('diagramAvailableActions');wrap.innerHTML='';
 e.screen.actions.forEach((action,i)=>{const btn=document.createElement('button');btn.className='diagram-action';btn.type='button';btn.textContent=action;btn.onclick=()=>showResponse(action,i);wrap.appendChild(btn);});
 if(e.type==='response')byId('sequenceResponse').textContent=e.detail;
 else byId('sequenceResponse').textContent=modalExpectedResponse(e.screen,e.screen.actions[0]);
 wrap.querySelector('button')?.classList.add('selected');wrap.querySelector('button')?.setAttribute('aria-pressed','true');
 byId('jumpScreen').onclick=()=>{
  const idx=list().findIndex(s=>s.slug===e.screen.slug);if(idx>=0)setScreen(idx,{scroll:true});closeDiagram();
 };
}
// Detailed modal viewer with per-role actions and next/previous controls.
let previousFocus = null;
let modalSelectedAction = 0;
function renderLightbox(){
 const s=getCurrent(); if(!s)return;
 const all=activeMatches(); const total=all.length;
 const resultIndex=all.findIndex(entry=>entry.index===state.index);
 const position=resultIndex>=0?resultIndex+1:state.index+1;
 const img=byId('lightImage');
 img.classList.add('changing');
 img.src=imgOf(s);
 img.alt=`Sketch completo: ${s.title} · ${s.role}`;
 requestAnimationFrame(()=>{img.classList.remove('changing');});
 byId('lightMeta').textContent=`PANTALLA ${String(s.step).padStart(2,'0')} · ${s.role.toUpperCase()} · ${humanPlatform(s.platform).toUpperCase()}`;
 byId('modalTitle').textContent=s.title;
 byId('lightSummary').textContent=s.description;
 byId('lightPurpose').textContent=purposeFor(s);
 byId('lightImageStep').textContent=`${String(position).padStart(2,'0')} / ${total}`;
 byId('lightCount').textContent=`${String(position).padStart(2,'0')} de ${total}`;
 byId('lightProgress').style.width=`${position*100/Math.max(1,total)}%`;
 byId('lightSpec').innerHTML=specHTML(s);byId('lightTags').innerHTML=`<span class="light-chip">${humanPlatform(s.platform)}</span><span class="light-chip">${escapeHtml(s.category)}</span><span class="light-chip">${escapeHtml(s.role)}</span>`;
 modalSelectedAction=0;
 const actionList=byId('lightActions'); actionList.innerHTML='';
 s.actions.forEach((action,i)=>{
   const btn=document.createElement('button');btn.type='button';btn.className='modal-action';
   btn.innerHTML=`<strong><span class="action-no">${i+1}</span>${escapeHtml(action)}</strong><span>Ver respuesta prevista ↗</span>`;
   btn.onclick=()=>selectModalAction(i);
   actionList.appendChild(btn);
 });
 selectModalAction(0);
 byId('lightbox-side-top')?.scrollIntoView({block:'nearest'});
 const side=document.querySelector('.lightbox-side');if(side)side.scrollTop=0;
}
function modalExpectedResponse(screen,action){
 const a=norm(action);
 if(/explorar app/.test(a))return 'La aplicación presenta el recorrido de bienvenida y ofrece acceso a las primeras actividades educativas. El estudiante elige cómo empezar.';
 if(/reglas de uso/.test(a))return 'Se explican las reglas de convivencia, privacidad y pausas digitales antes de continuar con el recorrido.';
 if(/continuar|siguiente/.test(a))return `Se muestra el siguiente paso del recorrido de ${screen.role.toLowerCase()} con una transición clara entre pantallas.`;
 if(/recuperar acceso/.test(a))return 'Se presenta el formulario para recuperar el acceso a la cuenta. No se envían datos reales en este prototipo.';
 if(/ingresar|iniciar sesion|entrar a/.test(a))return `Se valida el acceso de manera conceptual y se abre el espacio de ${screen.role.toLowerCase()}.`;
 if(/elegir reto|iniciar reto|comenzar reto|reto fisico|reto del dia|explorar entorno/.test(a))return 'Se presentan instrucciones cortas y seguras. El estudiante aparta el dispositivo y realiza el reto en su entorno real.';
 if(/abrir curso|entrar a curso|abrir modulo/.test(a))return 'Se muestran los módulos, recursos y actividades del curso, con el progreso visible.';
 if(/ver progreso|consultar avance|revisar avance/.test(a))return 'Se actualiza la vista de avances e indicadores de aprendizaje, con tareas pendientes y logros.';
 if(/guardar|registrar|marcar|anotar/.test(a))return 'Se muestra una confirmación del registro de la actividad o evidencia. En esta demostración no se guardan datos reales.';
 if(/enviar|asignar|publicar/.test(a))return 'Se muestra la confirmación conceptual de envío o asignación y el siguiente estado del flujo del docente o estudiante.';
 if(/calificar|evaluar|aprobar|validar/.test(a))return 'Se visualiza el resultado de la revisión junto con los criterios aplicados y el estado correspondiente.';
 if(/descargar|imprimir/.test(a))return 'Se prepara el material de apoyo para trabajar fuera de pantalla; esta maqueta no descarga archivos reales.';
 if(/pausa|movimiento|ejercicio/.test(a))return 'El sistema propone interrumpir el uso de pantalla para hacer una pausa activa o un ejercicio seguro.';
 if(/ver|consultar|abrir|revisar/.test(a))return `Se abre la sección o recurso de «${screen.title}» solicitado por el usuario y se muestran las opciones disponibles.`;
 return effectFor(screen,action);
}
function selectModalAction(i){
 const s=getCurrent();if(!s || !s.actions.length)return;
 modalSelectedAction=i;
 const action=s.actions[i];
 byId('lightBehavior').textContent=modalExpectedResponse(s,action);
 byId('lightActions').querySelectorAll('button').forEach((b,j)=>{
   b.classList.toggle('selected',j===i);
   b.setAttribute('aria-pressed',String(j===i));
 });
}
function openLightbox(){
 if(!byId('diagramOverlay').hidden)return;
 previousFocus=document.activeElement;
 renderLightbox();
 byId('lightbox').hidden=false;
 document.body.style.overflow='hidden';
 byId('closeLightbox').focus();
}
function closeLightbox(){
 byId('lightbox').hidden=true;
 document.body.style.overflow='';
 if(previousFocus?.isConnected)previousFocus.focus();else byId('imagePreviewTrigger').focus();
}
function shiftModal(delta){
 const all=list();if(!all.length)return;
 // Update the underlying three-column workspace as well as the open modal.
 setScreen(relativeScreenIndex(delta),{scroll:true});
 renderLightbox();
}

document.querySelectorAll('[data-role]').forEach(btn=>btn.onclick=()=>{state.role=btn.dataset.role;state.index=0;state.caseId='inicio';state.query='';byId('search').value='';render()});
document.querySelectorAll('[data-platform]').forEach(btn=>btn.onclick=()=>{state.platform=btn.dataset.platform;state.index=0;state.query='';byId('search').value='';render()});
function clearSearch(){
 state.query='';byId('search').value='';render();byId('search').focus();
}
byId('clearSearch').onclick=clearSearch;
document.querySelectorAll('[data-view]').forEach(b=>b.onclick=()=>setView(b.dataset.view));
byId('search').oninput=e=>{state.query=e.target.value;render()};
byId('search').addEventListener('keydown',e=>{
 if(e.key==='Escape' && state.query){e.preventDefault();clearSearch();return;}
 if(e.key==='Enter'){
   const matches=activeMatches();
   if(matches.length){e.preventDefault();setScreen(matches[0].index,{scroll:true});byId('activeEntry')?.focus();}
 }
 if(e.key==='ArrowDown'||e.key==='ArrowUp'){
   e.preventDefault();const matches=activeMatches();
   if(matches.length){setScreen(relativeScreenIndex(e.key==='ArrowDown'?1:-1),{scroll:true});}
 }
});
document.addEventListener('keydown',e=>{
 if(e.key==='/' && !e.ctrlKey && !e.metaKey && !e.altKey && e.target.tagName!=='INPUT' && byId('diagramOverlay').hidden && byId('lightbox').hidden){
   e.preventDefault();byId('search').focus();
 }
});
byId('backBtn').onclick=()=>setScreen(relativeScreenIndex(-1),{scroll:true});byId('nextBtn').onclick=()=>setScreen(relativeScreenIndex(1),{scroll:true});
byId('openDiagram').onclick=openDiagram;byId('closeDiagram').onclick=closeDiagram;byId('jumpBack').onclick=closeDiagram;
byId('diagramPrev').onclick=()=>{pauseDiagram();navigateDiagram(-1)};byId('diagramNext').onclick=()=>{pauseDiagram();navigateDiagram(1)};byId('diagramPlay').onclick=toggleDiagramPlayback;
byId('zoomBtn').onclick=openLightbox;byId('imagePreviewTrigger').onclick=openLightbox;byId('closeLightbox').onclick=closeLightbox;
byId('modalPrev').onclick=()=>shiftModal(-1);byId('modalNext').onclick=()=>shiftModal(1);
byId('diagramOverlay').onclick=e=>{if(e.target===byId('diagramOverlay'))closeDiagram()};
byId('lightbox').onclick=e=>{if(e.target===byId('lightbox'))closeLightbox()};
document.addEventListener('keydown',e=>{
 if(e.key==='Escape'){
   if(!byId('lightbox').hidden)closeLightbox();
   else if(!byId('diagramOverlay').hidden)closeDiagram();
   return;
 }
 if(!byId('lightbox').hidden){
   if(e.key==='ArrowRight'){e.preventDefault();shiftModal(1);return;}
   if(e.key==='ArrowLeft'){e.preventDefault();shiftModal(-1);return;}
   if(e.key==='Tab'){
     const dialog=byId('lightbox');
     const focusable=Array.from(dialog.querySelectorAll('button:not([disabled])')).filter(x=>x.offsetParent!==null);
     const first=focusable[0], last=focusable[focusable.length-1];
     if(e.shiftKey && document.activeElement===first){e.preventDefault();last.focus();}
     else if(!e.shiftKey && document.activeElement===last){e.preventDefault();first.focus();}
   }
   return;
 }
 if(!byId('diagramOverlay').hidden){if(e.key==='ArrowRight'){pauseDiagram();navigateDiagram(1)}if(e.key==='ArrowLeft'){pauseDiagram();navigateDiagram(-1)}return;}
 if(document.activeElement?.tagName==='INPUT')return;
 if(e.key==='ArrowRight')setScreen(relativeScreenIndex(1),{scroll:true});
 if(e.key==='ArrowLeft')setScreen(relativeScreenIndex(-1),{scroll:true});
});
render();
