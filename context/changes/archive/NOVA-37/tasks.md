# Tareas: NOVA-37

## Ola 0 — Characterization / baseline

- [x] 0.1. Snapshot de estado actual — `find context -type f | sort > /tmp/nova37-before.txt`; `wc -l context/services/agex/CONTEXT.md context/adr/*.md >> /tmp/nova37-before.txt`
- [x] 0.2. Grep baseline de referencias al modelo viejo — `grep -rn "context/adr\|glossary\|post-mortem\|ADR-000" novaspec/ AGENTS.md > /tmp/nova37-refs-before.txt`

## Ola 1 — Estructura nueva + extracción de decisiones

- [x] 1.1. Crear directorios vacíos — `mkdir -p context/decisions/archived context/gotchas`; añadir `.gitkeep` a los 3
- [x] 1.2. Leer `context/services/agex/CONTEXT.md` completo e identificar las 9 entradas de "Decisiones clave" (líneas 176-224)
- [x] 1.3. Extraer cada decisión viva a `context/decisions/<concept>.md`. Extraídas 6: `symlinks-vs-copia`, `context-contenedor-unico-memoria`, `checkpoints-humanos-obligatorios`, `guardrails-por-paso`, `templates-externos-a-comandos`, `quick-fix-salta-spec-y-plan`. Saltadas: install.sh (ADR-0001), naming (ADR-0002), patrón-subagentes (ADR-0003), separación canónico/symlink (fusionada con symlinks-vs-copia), idioma español (sin alternativa).

## Ola 2 — Migrar ADRs y eliminar modelo viejo

- [x] 2.1. `git mv context/adr/ADR-0001-install-sh-copy-from-source.md context/decisions/install-sh-copia-desde-fuente.md`. El ADR es la fuente; no fusionar con CONTEXT.md (la regla de 1.3 ya evitó duplicar).
- [x] 2.2. `git mv context/adr/ADR-0002-naming-nova-spec.md context/decisions/naming-nova-spec.md`. Mismo criterio: ADR manda.
- [x] 2.3. `git mv context/adr/ADR-0003-patron-subagentes.md context/decisions/patron-subagentes.md`
- [x] 2.4. Editar los 3 archivos movidos: quitar prefijo `ADR-NNNN` del título interno si lo tienen, dejar sólo el nombre-concepto
- [x] 2.5. Borrar `context/adr/` (ya vacío): `rm -rf context/adr`
- [x] 2.6. Borrar `context/glossary.md` y `context/post-mortems/`

## Ola 3 — Rewrite de `services/agex.md`

- [x] 3.1. Crear `context/services/agex.md` ≤80 líneas con el template del ticket (Qué hace / Interfaces públicas / Lo que no es obvio / Decisiones relevantes). Decisiones referencian `→ decisions/<concept>.md`
- [x] 3.2. Verificar `wc -l context/services/agex.md ≤ 80`. Resultado: 55 líneas.
- [x] 3.3. `git rm context/services/agex/CONTEXT.md` (el dir se elimina automáticamente al quedarse vacío)

## Ola 4 — Guardrail de supersede

- [x] 4.1. Crear `novaspec/guardrails/old-decision-archived.md`: qué comprueba (archivos `> Supersedes: X.md` en `decisions/` root implican X.md vive en `archived/`), mensaje de error `⛔ Guardrail: ...`, recovery (`git mv X.md archived/`)
- [x] 4.2. Añadir guardrail #6 al `novaspec/guardrails/checklist.md` con referencia al archivo
- [x] 4.3. Referenciar el guardrail desde `novaspec/commands/nova-wrap.md` en su bloque Guardrail

## Ola 5 — Propagación a agentes/skills/comandos

- [x] 5.1. `novaspec/skills/load-context/SKILL.md` — **omitida**: skill inexistente (convertida a subagente `context-loader` por NOVA-2).
- [x] 5.2. `novaspec/agents/context-loader.md` — rewrite: paths nuevos, presupuesto 3000 tokens, exclusión explícita de `archived/`, output con Decisions/Gotchas.
- [x] 5.3. `novaspec/agents/nova-review-agent.md` — `context/adr/` → `context/decisions/` (excluyendo `archived/`), lenguaje "ADR" → "decisión viva".
- [x] 5.4. `novaspec/commands/nova-build.md` — `context/adr/` → `context/decisions/`.
- [x] 5.5. `novaspec/commands/nova-start.md` — paths `services/<svc>.md`, "ADR" → "decisión documentada" en clasificación architecture.
- [x] 5.6. `novaspec/commands/nova-wrap.md` — completado en ola 4 (paso 1 rewrite a `write-decision` + supersede, paso 2 a `services/<svc>.md`, paso 3 a `gotchas/`, sin glossary).
- [x] 5.7. `novaspec/skills/close-requirement/SKILL.md` — paths nuevos, sin glossary.
- [x] 5.8. Rename `write-adr` → `write-decision` (dir + SKILL.md rewrite completo). Referencias en `AGENTS.md` actualizadas.

## Ola 6 — Documentación

- [x] 6.1. `AGENTS.md` — sección memoria actualizada: `decisions/`, `gotchas/`, `services/<svc>.md`, puntero a `context/decisions/memoria-sencilla.md`; sin `glossary.md`. Referencia a `write-decision` también actualizada.
- [x] 6.2. `novaspec/README.arch.md` — capa Sistema actualizada con `decisions/`/`gotchas/`; architecture requiere "decisión documentada".
- [x] 6.3. `novaspec/README.quickref.md` — diagrama `context/` con `decisions/`, `gotchas/`, `services/` planos.

## Ola 7 — Validación

- [x] 7.1. grep de residuales vacío ✓ (incluyendo `write-adr`).
- [x] 7.2. `ls context/` → `backlog changes decisions gotchas services` (sin `adr`, sin `glossary.md`, sin `post-mortems`).
- [x] 7.3. `wc -l context/services/agex.md` = 55 ≤ 80 ✓
- [x] 7.4. Test del guardrail supersede: fallaba correctamente con 2 mensajes (`vive en root` + `no aparece en archived/`), `exit=1`. Archivo test limpiado.
- [x] 7.5. Estimación presupuesto: carga típica (services/agex.md + 4 decisions) ≈ **1073 tokens** ✓. Carga teórica total (todas las 9 decisions + services/agex.md) ≈ 3324 tokens — *supera* 3000 si alguien cargara todo, lo que valida la regla "3-5 relevantes" como esencial, no opcional. Se anota como gotcha implícita al alcanzar ~7 decisions.
- [x] 7.6. Diff baseline → 5 archivos eliminados (`adr/*`, `glossary.md`, `post-mortems/.gitkeep`, `services/agex/CONTEXT.md`), 12 archivos nuevos (6 decisiones extraídas + 3 ADRs migrados + 3 `.gitkeep` + `services/agex.md`). Sin pérdidas silenciosas.
