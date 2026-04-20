<!-- Mantén esta spec ≤ 60 líneas. Bullets y tablas, no prosa. Se carga en cada turno de nova-build. -->
# NOVA-37: Memoria sencilla — principios para nova-spec

## Historia
Como usuario del framework nova-spec, quiero un modelo de memoria atómico y grep-friendly, para que la memoria responda solo "por qué hicimos X" y "qué no es obvio" sin generadores, índices ni ceremonias.

## Objetivo
Reemplazar el modelo actual (`adr/`, `glossary.md`, `post-mortems/`, `CONTEXT.md` de 236 líneas con bullets "decisiones clave") por `decisions/` + `gotchas/` + `services/<svc>.md` ≤80 líneas.

## Contexto
El modelo actual viola sus propias reglas: `CONTEXT.md` concentra decisiones en bullets (anti-patrón), `glossary.md` está vacío, `post-mortems/` nunca se usó. Un framework pensado para cualquier equipo necesita reglas de memoria que escalen sin tooling.

## Alcance
### En alcance
- Crear estructura: `context/decisions/`, `context/gotchas/`, `context/decisions/archived/`.
- Migrar ADR-0001/0002/0003 a `decisions/` con concept-name (sin prefijo `ADR-NNNN`).
- Trocear `context/services/agex/CONTEXT.md` (236 líneas) → `context/services/agex.md` ≤80 + decisions extraídas.
- Borrar `context/glossary.md` y `context/post-mortems/`.
- Migrar layout `services/<svc>/CONTEXT.md` → `services/<svc>.md` plano.
- Nuevo guardrail compartido `novaspec/guardrails/old-decision-archived.md` referenciado desde `nova-wrap.md`.
- Actualizar `load-context` skill y `nova-start.md` para leer `decisions/` + `gotchas/` + `services/<svc>.md`, excluyendo `archived/`.
- Ediciones quirúrgicas: `AGENTS.md` (≤5 líneas + puntero al ADR), `novaspec/README.arch.md`, `novaspec/README.quickref.md`.
- ADR en `/nova-wrap` documentando el modelo como fuente canónica.

### Fuera de alcance
- Crear subagente `context-loader` en `novaspec/agents/` (ausente; queda para otro ticket).
- Tocar `context/changes/` (specs activas/archivadas).
- Tocar `CLAUDE.md` (sigue siendo puntero a `AGENTS.md`).
- Herramienta CLI para supersede automático.

## Decisiones cerradas
- Guardrail supersede como archivo compartido (patrón existente); referenciado desde `/nova-wrap`.
- `adr/` muere como directorio; `decisions/` es el nuevo nombre; concept-naming sin `ADR-NNNN`.
- `archived/` existe como papelera física; agentes NUNCA la auto-cargan.
- Supersede = `git mv` + nuevo archivo con `> Supersedes: old.md` (3 pasos, aceptado).
- `services/<svc>.md` plano, tope duro ≤80 líneas; overflow va a `decisions/` o `gotchas/`.
- ADR es la fuente única del modelo; docs son punteros surgical.
- Presupuesto `load-context`: ≤3000 tokens.

## Comportamiento esperado
- Normal: `/nova-start` lista `decisions/`, `gotchas/`, lee 3-5 archivos relevantes + `services/<svc>.md`.
- Edge cases: `archived/` presente pero no leído; `services/<svc>.md` inexistente → agente sigue sin bloquear.
- Fallo: guardrail supersede bloquea `/nova-wrap` si archivo referenciado como superseded aún vive en `decisions/` root.

## Output esperado
- Working tree post-build: sin `adr/`, sin `glossary.md`, sin `post-mortems/`, sin `services/agex/CONTEXT.md`.
- Con `decisions/{concept}.md` ×3+N, `services/agex.md` ≤80 líneas, `gotchas/.gitkeep`, `decisions/archived/.gitkeep`.

## Criterios de éxito
- `ls context/` no muestra `adr`, `glossary.md`, `post-mortems`.
- `wc -l context/services/agex.md` ≤ 80.
- Guardrail supersede ejecutable manualmente y pasa en el estado final.
- `load-context` total al cargar contexto para un ticket ficticio sobre "agex" ≤ 3000 tokens.
- `grep -r "ADR-000" context/` devuelve vacío (nombres viejos eliminados en los archivos migrados).

## Impacto arquitectónico
- Servicios afectados: `agex` (el propio framework).
- ADRs referenciados: ADR-0001, ADR-0002, ADR-0003 (se renombran, contenido intacto).
- ¿Requiere ADR nuevo?: **sí** — canónico del nuevo modelo de memoria, creado en `/nova-wrap`.

## Verificación sin tests automatizados
### Flujo manual
1. `ls context/` → confirmar ausencia de `adr`, `glossary.md`, `post-mortems`; presencia de `decisions/`, `gotchas/`, `services/agex.md`.
2. `ls context/decisions/` → 3+ archivos concept-name, más `archived/`.
3. `wc -l context/services/agex.md` → ≤80.
4. Simular supersede: crear decisión X con `> Supersedes: Y.md` sin mover Y → `/nova-wrap` debe bloquear.
5. `ls context/changes/` → intacto (active/, archive/).

### Qué mirar
- Logs: N/A (no runtime).
- DB: N/A.
- API/UI: N/A. Es un cambio estructural sobre archivos.
- Git: `git mv` preservando historia en ADRs renombrados.

## Riesgos
- Migración del `CONTEXT.md` de 236→80 líneas puede perder información si se comprime mal: mitigación = decisions extraídas primero, CONTEXT.md recortado después.
- Docs dispersos volviendo a crecer tras el ticket: mitigación = regla explícita en el ADR ("sabiduría de memoria vive en `decisions/`, no en `AGENTS.md`"). Riesgo residual aceptado.
- Concept-naming de ADRs migrados puede colisionar con futuros nombres: mitigación = nombres específicos (`install-sh-copy-from-source.md`, no `install.md`).
