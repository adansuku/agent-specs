# Plan: NOVA-37

## Estrategia
Migración en 3 olas: (1) estructura nueva + extracción de decisions desde `CONTEXT.md`; (2) eliminación del modelo viejo (`adr/`, `glossary`, `post-mortems`) y rewrite de `services/agex.md`; (3) propagación a agentes/skills/docs que referencian el modelo viejo + guardrail. Cada ola deja el repo en estado coherente.

## Archivos a tocar
- `context/services/agex/CONTEXT.md` → extraer decisiones, luego trasladar a `context/services/agex.md` ≤80 líneas (git mv + rewrite)
- `context/adr/ADR-0001-install-sh-copy-from-source.md` → `git mv` a `context/decisions/install-sh-copia-desde-fuente.md`
- `context/adr/ADR-0002-naming-nova-spec.md` → `git mv` a `context/decisions/naming-nova-spec.md`
- `context/adr/ADR-0003-patron-subagentes.md` → `git mv` a `context/decisions/patron-subagentes.md`
- `context/glossary.md` → borrar (vacío)
- `context/post-mortems/` → borrar (solo `.gitkeep`)
- `context/adr/` → borrar tras mover contenido
- `novaspec/commands/nova-wrap.md` → quitar mención `glossary.md`, referenciar nuevo guardrail
- `novaspec/commands/nova-build.md` → actualizar `context/adr/` → `context/decisions/`
- `novaspec/commands/nova-start.md` → actualizar paths
- `novaspec/agents/context-loader.md` → leer `decisions/` + `gotchas/`, excluir `archived/`
- `novaspec/agents/nova-review-agent.md` → `context/adr/` → `context/decisions/`
- `novaspec/skills/load-context/SKILL.md` → paths nuevos + exclusión de `archived/`
- `novaspec/skills/close-requirement/SKILL.md` → quitar `glossary.md`, `context/adr/` → `context/decisions/`
- `novaspec/skills/write-adr/SKILL.md` → rewrite: concept-naming, sin `ADR-NNNN`, crea en `decisions/`
- `novaspec/guardrails/checklist.md` → añadir guardrail #6 supersede
- `novaspec/README.arch.md` → actualizar diagrama/capa memoria
- `novaspec/README.quickref.md` → quitar menciones ADR/glossary
- `AGENTS.md` → ≤5 líneas describiendo modelo + puntero al ADR; quitar `glossary.md` del diagrama

## Archivos nuevos
- `context/decisions/.gitkeep`
- `context/decisions/archived/.gitkeep`
- `context/gotchas/.gitkeep`
- `context/services/agex.md` — rewrite ≤80 líneas (reemplaza `context/services/agex/CONTEXT.md`)
- `context/decisions/<N concept>.md` — una por cada decisión extraída de `CONTEXT.md` (estimado 5-7)
- `novaspec/guardrails/old-decision-archived.md` — guardrail compartido
- ADR del cambio se crea en `/nova-wrap`, no aquí.

## Dependencias entre cambios
1. Extraer decisiones a `decisions/*.md` **antes** de recortar `services/agex/CONTEXT.md` (evita perder contenido).
2. Renombrar ADRs **antes** de borrar `context/adr/`.
3. Actualizar paths en agentes/skills/comandos **después** de mover archivos (si no, grep rompe).
4. Guardrail supersede se crea antes de referenciarlo desde `nova-wrap.md`.
5. Validación (`grep -r "ADR-000"`, `wc -l`) al final.

## Safety net
- Reversibilidad: todo el cambio vive en `arch/NOVA-37-memoria-sencilla`. Rollback = `git checkout develop`.
- Qué puede romperse: agentes/skills que referencien paths viejos tras merge. Mitigación = grep final del punto 5.
- Plan de rollback: si el equipo rechaza el modelo post-merge, supersede este ADR con uno que restaure `adr/`. `git log --follow` reconstruye los archivos.

## Characterization tests
Antes de modificar código existente:
- [ ] Snapshot de línea/archivo: `find context -type f | sort > /tmp/nova37-before.txt`; `wc -l context/services/agex/CONTEXT.md context/adr/*.md`
- [ ] Grep baseline: `grep -rn "context/adr\|glossary\|post-mortem\|ADR-000" novaspec/ AGENTS.md > /tmp/nova37-refs-before.txt`
- [ ] Verificar que `/nova-status` (o equivalente) sigue funcionando sobre la rama antes de tocar

## Verificación
Cómo verificar cada criterio de éxito de la spec:
- **`ls context/` sin `adr`/`glossary`/`post-mortems`** → `ls context/` y diff vs snapshot.
- **`wc -l context/services/agex.md ≤80`** → comando directo.
- **Guardrail supersede ejecutable** → crear caso artificial (decision con `> Supersedes: X.md` y X.md aún en root), ejecutar guardrail, esperar error.
- **`load-context` ≤3000 tokens** → ejecutar simulación con ticket ficticio sobre `agex`, contar tokens con heurística `wc -w * 1.3`.
- **`grep -r "ADR-000" context/` vacío** → comando directo.
- **`grep -rn "glossary\|post-mortem" novaspec/ AGENTS.md` vacío** → comando directo.
