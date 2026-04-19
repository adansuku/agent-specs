---
description: Implementa las tareas del plan una a una con review incremental
---

Ejecutas `tasks.md` en orden, tarea a tarea.

## Guardrail

`checklist.md` → 1, 3 (branch-pattern, plan-and-tasks-exist)

## Precondición

Debe existir `.docs/changes/active/<ticket-id>/tasks.md`.

**Excepción**: si el ticket es `quick-fix`, puedes operar sin tasks.md.
Implementa directamente y salta al paso 4.

## Pasos

### 1. Leer tasks.md

Identifica la primera sin marcar (`- [ ]`).
Si todas están marcadas, avisa: "ejecuta `/nova-review`".

### 2. Ejecutar una tarea

- Lee archivos relevantes antes de modificar
- Implementa el cambio
- Sigue las convenciones del repo circundante
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

### 5. Siguiente tarea

**Si quedan tareas**: continúa con la siguiente automáticamente.

**Solo para si**:
- Hay un bloqueante (error, decisión no cerrada)
- Tiene preguntas que necesitas responder
- Llega a un checkpoint humano (después de todas las tareas)

**Si era la última**:
> "Todas completadas. Ejecuta `/nova-review`."

## Reglas

- Ejecuta todas las tareas en secuencia.
- Solo para si:
  - Hay un bloqueante (error, excepción no manejada)
  - Necesita una decisión que no está cerrada en la spec
  - Tiene preguntas que solo tú puedes responder
- No hagas commit aquí (eso es `/nova-wrap`).
- No actualices `.docs/adr/` ni `.docs/services/` aquí.
