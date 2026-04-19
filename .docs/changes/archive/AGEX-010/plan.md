# Plan: AGEX-010

## Estrategia
Snapshot primero (characterization) para tener los textos de guardrail y mensajes de error actuales como oráculo. Luego crear los 5 archivos compartidos bajo `.spec/guardrails/` que **reproducen literalmente** el texto actual — no es refactor de lógica, es relocalización. Después sustituir el bloque `## Guardrail` inline en cada uno de los 5 comandos por una sección corta que referencia los archivos compartidos. Verificación final: greps del criterio, smoke install, y comparación de mensajes de error contra el snapshot.

## Archivos a tocar
- `.spec/commands/sdd-spec.md` — sustituir el bloque `## Guardrail` (~15 líneas) por sección que referencia `branch-pattern.md`.
- `.spec/commands/sdd-plan.md` — sustituir bloque (~25 líneas) por referencia a `branch-pattern.md` + `proposal-exists.md`.
- `.spec/commands/sdd-do.md` — sustituir bloque (~30 líneas) por referencia a `branch-pattern.md` + `plan-and-tasks-exist.md` (incluye excepción quick-fix).
- `.spec/commands/sdd-review.md` — sustituir bloque (~30 líneas) por referencia a `branch-pattern.md` + `all-tasks-done.md`.
- `.spec/commands/sdd-wrap.md` — sustituir bloque (~30 líneas) por referencia a `branch-pattern.md` + `review-approved.md`.

## Archivos nuevos
- `.spec/guardrails/branch-pattern.md` — detectar rama activa, validar patrón `(feature|fix|arch)/<TICKET>-<slug>`, extraer `<ticket-id>`, emitir `⛔ Guardrail: no hay rama de ticket activa. Ejecuta /sdd-start <TICKET> primero.` si falla.
- `.spec/guardrails/proposal-exists.md` — verificar `.docs/changes/active/<ticket-id>/proposal.md`, emitir `⛔ Guardrail: no existe proposal.md para <ticket-id>. Ejecuta /sdd-spec primero.` si falta.
- `.spec/guardrails/plan-and-tasks-exist.md` — verificar `plan.md` y `tasks.md`, con excepción quick-fix (rama `fix/`). Mensaje: `⛔ Guardrail: no existe plan.md o tasks.md para <ticket-id>. Ejecuta /sdd-plan primero.`
- `.spec/guardrails/all-tasks-done.md` — verificar que `tasks.md` no contiene `- [ ]`, con excepción quick-fix sin `tasks.md`. Mensaje: `⛔ Guardrail: hay N tarea(s) sin completar en tasks.md. Ejecuta /sdd-do para completarlas primero.`
- `.spec/guardrails/review-approved.md` — verificar `review.md` + línea `✓ Listo para /sdd-wrap`. Dos mensajes: `⛔ Guardrail: no existe review.md...` y `⛔ Guardrail: el review de <ticket-id> no tiene veredicto ✓...`.

## Dependencias entre cambios
- **Tarea 1 (snapshot) precede todas**: capturar textos actuales como oráculo.
- **Tarea 2 (crear archivos en `.spec/guardrails/`) precede tarea 3**: los comandos no pueden referenciar archivos inexistentes.
- **Tarea 3 (modificar comandos)**: los 5 comandos son independientes entre sí; orden interno irrelevante. Se agrupan en una sola tarea porque el cambio es mecánico y repetitivo.
- **Tarea 4 (verificación)** depende de las anteriores.

## Safety net
- **Reversibilidad**: `git revert` sobre el commit del ticket. Solo se tocan archivos del framework; nada en `.docs/` de trabajo ni en código de usuario de otros repos.
- **Qué puede romperse**:
  - Un comando con referencia mal formada (ruta incorrecta, nombre mal escrito). Mitigación: el snapshot permite comparar textos de error antes/después.
  - Un archivo de `.spec/guardrails/` con texto divergente respecto al original. Mitigación: la tarea 2 copia **literalmente** el texto del bloque `## Guardrail` actual, sin reformular.
  - `install.sh` falla al copiar si la estructura es anormal. Mitigación: `cp -R .spec/` copia todo `.spec/` incluyendo subdirectorios nuevos; ya lo hace tras AGEX-009.
- **Plan de rollback**: `git reset --hard origin/main` sobre la rama del ticket antes de mergear.

## Characterization tests
Antes de tocar los comandos:
- [ ] Capturar el texto literal de cada bloque `## Guardrail ... ## Precondición` en los 5 comandos actuales → `/tmp/agex-010-snapshot/guardrails-before.md`.
- [ ] Capturar los mensajes de error exactos (`⛔ Guardrail: ...`) y los comandos de recuperación correspondientes → `/tmp/agex-010-snapshot/error-messages-before.txt`.
- [ ] Guardar ambos como oráculo: al verificar tras el refactor, los textos de los archivos `.spec/guardrails/*.md` + las referencias en los comandos deben reproducir literalmente el mismo contenido (posición distinta, contenido idéntico).

## Verificación
Mapeo 1:1 con los criterios de éxito de `proposal.md`:

- `ls .spec/guardrails/` = 5 archivos esperados → tarea 4.
- `grep -c "⛔ Guardrail" .spec/commands/*.md` = 0 → tarea 4.
- `grep -c "⛔ Guardrail" .spec/guardrails/*.md` ≥ 5 → tarea 4.
- `grep -l "Para aquí. No sigas." .spec/commands/*.md` = 0 → tarea 4.
- Regresión textual: para cada mensaje `⛔ Guardrail` del snapshot, debe existir **idéntico** en `.spec/guardrails/`. Diff textual → tarea 4.
- Smoke install: en tmpdir, `bash install.sh` genera `.spec/guardrails/` con los 5 archivos, `diff -r` vs fuente = 0 → tarea 4.
- Regresión manual (documentada, no ejecutable en sesión): confirmar que al modificar la ruta en `proposal-exists.md` el mensaje de `/sdd-plan` cambia sin tocar el comando. Se anota como comprobación posterior en el review, no como test automatizado.
