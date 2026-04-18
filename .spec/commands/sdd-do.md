---
description: Implementa las tareas del plan una a una con review incremental
---

Ejecutas `tasks.md` en orden, tarea a tarea.

## Guardrail

**Ejecuta esto antes de cualquier otro paso.**

1. Lee la rama git actual y extrae el `<ticket-id>`.
   Si la rama no sigue el patrón `(feature|fix|arch)/<TICKET>-<slug>`:

   ```
   ⛔ Guardrail: no hay rama de ticket activa.
   Ejecuta /sdd-start <TICKET> primero.
   ```
   **Para aquí. No sigas.**

2. Comprueba si la rama empieza por `fix/` (quick-fix).
   - Si **no es quick-fix**: comprueba que existen
     `.docs/changes/<ticket-id>/plan.md` y
     `.docs/changes/<ticket-id>/tasks.md`.
     Si falta alguno:

     ```
     ⛔ Guardrail: no existe plan.md o tasks.md para <ticket-id>.
     Ejecuta /sdd-plan primero.
     ```
     **Para aquí. No sigas.**

   - Si **es quick-fix**: puedes continuar aunque no existan
     `plan.md` ni `tasks.md`. Salta directamente al paso 4.

## Precondición

Debe existir `.docs/changes/<ticket-id>/tasks.md`.

**Excepción**: si el ticket es `quick-fix`, puedes operar sin tasks.md.
Implementa directamente y salta al paso 4.

## Pasos

### 1. Leer tasks.md

Identifica la primera sin marcar (`- [ ]`).
Si todas están marcadas, avisa: "ejecuta `/sdd-review`".

### 2. Ejecutar una tarea

- Lee archivos relevantes antes de modificar
- Implementa el cambio
- Aplica convenciones (skill `openaccess-conventions` si existe)
- Characterization tests: escribir antes de tocar producción

No modifiques fuera del alcance de la tarea. Si hace falta, pregunta.

### 3. Review incremental

- ¿Cumple el criterio?
- ¿He roto algo adyacente?
- ¿Sigue convenciones?
- ¿Efectos no deseados?

Si hay problema, corrige antes de marcar.

### 4. Marcar completada

Actualiza `tasks.md`: `- [ ]` → `- [x]`.

Muestra al usuario:
- tarea completada
- archivos tocados (rutas concretas)
- anomalías detectadas

### 5. Siguiente tarea o parada

**Si quedan tareas**:
> "Tarea N completada. ¿Sigo con N+1 o paramos?"

**Si era la última**:
> "Todas completadas. Ejecuta `/sdd-review`."

## Reglas

- Una tarea a la vez. No encadenes sin permiso.
- Si una tarea es más grande de lo previsto, para.
- Si descubres decisión no cerrada, para.
- No hagas commit aquí (eso es `/sdd-wrap`).
- No actualices `.docs/adr/` ni `.docs/services/` aquí.
