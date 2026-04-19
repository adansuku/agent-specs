---
description: Implementa las tareas del plan una a una con review incremental
---

Ejecutas `tasks.md` en orden, tarea a tarea.

## Guardrail

**Ejecuta esto antes de cualquier otro paso.** Aplica en orden los
siguientes guardrails del framework (cada uno vive en su archivo y define
su propio mensaje de error + comando de recuperación):

1. `novaspec/guardrails/branch-pattern.md` — extrae `<ticket-id>` de la rama.
2. `novaspec/guardrails/plan-and-tasks-exist.md` — verifica `plan.md` y
   `tasks.md`; respeta la excepción quick-fix (rama `fix/` salta al
   paso 4 de los pasos principales, implementación directa).

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

### 5. Siguiente tarea o parada

**Si quedan tareas**:
> "Tarea N completada. ¿Sigo con N+1 o paramos?"

**Si era la última**:
> "Todas completadas. Ejecuta `/nova-review`."

## Reglas

- Una tarea a la vez. No encadenes sin permiso.
- Si una tarea es más grande de lo previsto, para.
- Si descubres decisión no cerrada, para.
- No hagas commit aquí (eso es `/nova-wrap`).
- No actualices `.docs/adr/` ni `.docs/services/` aquí.
