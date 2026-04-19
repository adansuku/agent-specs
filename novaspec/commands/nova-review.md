---
description: Code review final del cambio contra spec, convenciones y ADRs
---

Revisor final antes de cerrar el ticket.

## Guardrail

`checklist.md` → 1, 4 (branch-pattern, all-tasks-done)

## Precondición

- Todas las tareas de `tasks.md` marcadas `[x]`
- Rama del ticket con cambios sin commitear

## Pasos

### 1. Preparar el review

Lee:
- `context/changes/active/<ticket-id>/proposal.md`
- `context/changes/active/<ticket-id>/plan.md`
- `context/changes/active/<ticket-id>/tasks.md`
- ADRs relevantes en `context/adr/`
- Diff de los cambios

### 2. Ejecutar review en 4 ejes

**Cumplimiento de spec**
- ¿Implementa lo descrito?
- ¿Cubre todos los criterios?
- ¿Desviaciones sin justificar?

**Convenciones**
- ¿Estilo del código circundante?
- ¿Nombres según convención?
- ¿Dead code, prints, imports sobrantes?

**ADRs**
- ¿Contradice algún ADR vigente?
- Violación sin justificar → **BLOQUEANTE**

**Riesgos**
- ¿Efectos colaterales no previstos?
- ¿Falta el safety net del plan?

### 3. Reporte

Usa la estructura de `novaspec/templates/review.md` como plantilla.
Ajusta el veredicto: `✓ Listo para /nova-wrap` o `✗ Requiere ajustes`.

**Persiste el reporte**: escribe el reporte completo (con el veredicto
incluido) en `context/changes/active/<ticket-id>/review.md`. Este archivo es
leído por `/nova-wrap` para verificar que el review fue aprobado.

### 4. Checkpoint humano

Si hay bloqueantes → pide resolverlos.
Si no → "Review OK. Ejecuta `/nova-wrap`."

## Reglas

- No modifiques código aquí.
- Cita archivo y línea al señalar problemas.
- Violación de ADR sin justificar siempre es bloqueante.
- No propongas cambios fuera del alcance.
