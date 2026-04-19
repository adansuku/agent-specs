---
description: Genera plan de implementación y tareas a partir de la spec aprobada
---

Traduces la spec en un plan ejecutable.

## Guardrail

**Ejecuta esto antes de cualquier otro paso.** Aplica en orden los
siguientes guardrails del framework (cada uno vive en su archivo y define
su propio mensaje de error + comando de recuperación):

1. `novaspec/guardrails/branch-pattern.md` — extrae `<ticket-id>` de la rama.
2. `novaspec/guardrails/proposal-exists.md` — verifica `proposal.md`.

## Precondición

Debe existir `.docs/changes/active/<ticket-id>/proposal.md`.

## Pasos

### 1. Leer la spec

Identifica servicios afectados, decisiones cerradas, criterios de éxito.

### 2. Generar plan.md

Crea `.docs/changes/active/<ticket-id>/plan.md`:

```
# Plan: <TICKET-ID>

## Estrategia
<2-3 líneas sobre cómo abordar el cambio>

## Archivos a tocar
- `<ruta>`: <qué se modifica>

## Archivos nuevos
- `<ruta>`: <qué contiene>

## Dependencias entre cambios
<si el orden importa, explícalo>

## Safety net
- Reversibilidad: <feature flag | toggle | cómo revertir>
- Qué puede romperse: <específico>
- Plan de rollback: <pasos>

## Characterization tests
Antes de modificar código existente:
- [ ] Test de <comportamiento>
- [ ] Test de <edge case>

## Verificación
Cómo verificar cada criterio de éxito de la spec.
```

### 3. Generar tasks.md

Crea `.docs/changes/active/<ticket-id>/tasks.md`:

```
# Tareas: <TICKET-ID>

- [ ] 1. <tarea concreta> — <archivo(s)>
- [ ] 2. <tarea concreta> — <archivo(s)>
```

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
