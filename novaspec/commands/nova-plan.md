---
description: Genera plan de implementación y tareas a partir de la spec aprobada
---

Traduces la spec en un plan ejecutable.

## Guardrail

`checklist.md` → 1, 2 (branch-pattern, proposal-exists)

## Precondición

Debe existir `context/changes/active/<ticket-id>/proposal.md`.

## Pasos

### 1. Leer la spec

Identifica servicios afectados, decisiones cerradas, criterios de éxito.

### 2. Generar plan.md

Crea `context/changes/active/<ticket-id>/plan.md` usando la estructura de
`novaspec/templates/plan.md` como plantilla.

### 3. Generar tasks.md

Crea `context/changes/active/<ticket-id>/tasks.md` usando la estructura de
`novaspec/templates/tasks.md` como plantilla.

Reglas:
- cada tarea ejecutable en 15-60 min
- orden ejecutable
- incluir characterization tests antes de modificar código
- usar checkboxes `- [ ]`

### 4. Checkpoint humano

> "Plan y tareas generados. Revísalos. Ejecuta `/nova-build` cuando estés listo."

## Reglas

- Las tareas deben salir del plan, no inventarlas.
- Si detectas decisiones no cubiertas en la spec, para.
- Para quick-fix el plan puede ser muy breve.
