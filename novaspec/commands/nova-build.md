---
description: Implementa las tareas del plan una a una con review incremental
---

Ejecutas `tasks.md` en orden, tarea a tarea.

## Guardrail

`checklist.md` → 1, 3 (branch-pattern, plan-and-tasks-exist)

## Precondición

Debe existir `context/changes/active/<ticket-id>/tasks.md`.

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

**Si quedan tareas**: continúa con la siguiente sin pedir permiso.

**Solo para si**:
- Hay un bloqueante (error, excepción no manejada)
- Hay una decisión no cerrada en la spec
- Tienes una pregunta que solo el usuario puede responder

**Si era la última**:
> "Todas completadas. Ejecuta `/nova-review`."

## Reglas

- Ejecuta todas las tareas en secuencia.
- Para solo si hay un bloqueante o decisión abierta.
- Si una tarea es más grande de lo previsto, para y reporta.
- No hagas commit aquí (eso es `/nova-wrap`).
- No actualices `context/decisions/` ni `context/services/` aquí (eso es `/nova-wrap`).
