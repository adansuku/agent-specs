---
description: Genera plan de implementación y tareas a partir de la spec aprobada
---

Traduces la spec en un plan ejecutable.

## Guardrail

**Ejecuta esto antes de cualquier otro paso.**

1. Lee la rama git actual y extrae el `<ticket-id>`.
   Si la rama no sigue el patrón `(feature|fix|arch)/<TICKET>-<slug>`:

   ```
   ⛔ Guardrail: no hay rama de ticket activa.
   Ejecuta /sdd-start <TICKET> primero.
   ```
   **Para aquí. No sigas.**

2. Comprueba que existe `.docs/changes/<ticket-id>/proposal.md`.
   Si no existe:

   ```
   ⛔ Guardrail: no existe proposal.md para <ticket-id>.
   Ejecuta /sdd-spec primero.
   ```
   **Para aquí. No sigas.**

## Precondición

Debe existir `.docs/changes/<ticket-id>/proposal.md`.

## Pasos

### 1. Leer la spec

Identifica servicios afectados, decisiones cerradas, criterios de éxito.

### 2. Generar plan.md

Crea `.docs/changes/<ticket-id>/plan.md`:

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

Crea `.docs/changes/<ticket-id>/tasks.md`:

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

> "Plan y tareas generados. Revísalos. Ejecuta `/sdd-do` cuando estés listo."

## Reglas

- Las tareas deben salir del plan, no inventarlas.
- Si detectas decisiones no cubiertas en la spec, para.
- Para quick-fix el plan puede ser muy breve.
