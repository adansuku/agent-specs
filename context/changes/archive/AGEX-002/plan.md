# Plan: AGEX-002

## Estrategia

Añadir un bloque `## Guardrail` al inicio de cada comando `/sdd-*` que
tenga precondiciones. Los guardrails son instrucciones en lenguaje natural
que el agente ejecuta antes del resto del comando. El orden de modificación
sigue el flujo del pipeline: primero los comandos que producen artefactos
que otros necesitan (`sdd-spec`, `sdd-plan`, `sdd-do`, `sdd-review`),
luego el consumidor final (`sdd-wrap`). Se modifica también `sdd-review`
para que persista su reporte en `review.md`.

## Archivos a tocar

- `.spec/commands/sdd-spec.md`: añadir bloque `## Guardrail` antes de `## Precondición`
- `.spec/commands/sdd-plan.md`: añadir bloque `## Guardrail` antes de `## Precondición`
- `.spec/commands/sdd-do.md`: añadir bloque `## Guardrail` antes de `## Precondición`
- `.spec/commands/sdd-review.md`: añadir bloque `## Guardrail` + paso para escribir `review.md`
- `.spec/commands/sdd-wrap.md`: añadir bloque `## Guardrail` antes de `## Precondición`

## Archivos nuevos

Ninguno (el `review.md` lo genera el agente en runtime, no es un template).

## Dependencias entre cambios

- `sdd-review.md` debe modificarse antes de `sdd-wrap.md`, porque el
  guardrail de `sdd-wrap` depende del `review.md` que `sdd-review` genera.
- El resto de modificaciones son independientes entre sí.

## Safety net

- **Reversibilidad**: git revert de los 5 archivos. Cambio 100% reversible.
- **Qué puede romperse**: ningún comportamiento de producción — los
  guardrails solo añaden lógica al inicio; si las precondiciones se cumplen,
  el flujo es idéntico al actual.
- **Plan de rollback**: `git checkout main -- .spec/commands/` restaura
  todos los comandos al estado anterior.

## Characterization tests

Los comandos son Markdown interpretado por Claude — no hay test harness
ejecutable. La "characterization" es documentar el comportamiento actual
antes de modificar:

- [ ] Verificar que `sdd-spec.md` actual NO tiene bloque `## Guardrail`
- [ ] Verificar que `sdd-plan.md` actual NO tiene bloque `## Guardrail`
- [ ] Verificar que `sdd-do.md` actual NO tiene bloque `## Guardrail`
- [ ] Verificar que `sdd-review.md` actual NO tiene bloque `## Guardrail`
  ni paso de escritura de `review.md`
- [ ] Verificar que `sdd-wrap.md` actual NO tiene bloque `## Guardrail`

## Verificación

| Criterio de éxito (spec) | Cómo verificar |
|---|---|
| `/sdd-spec` sin rama → `⛔ Guardrail` | Leer el bloque guardrail del archivo y confirmar que la condición y mensaje son correctos |
| `/sdd-plan` sin `proposal.md` → `⛔ Guardrail` | Ídem para `sdd-plan.md` |
| `/sdd-do` sin `plan.md`/`tasks.md` → `⛔ Guardrail` | Ídem para `sdd-do.md`, incluyendo excepción quick-fix |
| `/sdd-review` con tareas pendientes → `⛔ Guardrail` | Ídem para `sdd-review.md` |
| `/sdd-wrap` sin `review.md` con `✓` → `⛔ Guardrail` | Ídem para `sdd-wrap.md` |
| Sin regresión cuando precondiciones OK | El resto del contenido de cada archivo es idéntico al actual |
