---
description: Code review final del cambio contra spec, convenciones y ADRs
---

Revisor final antes de cerrar el ticket.

## Guardrail

**Ejecuta esto antes de cualquier otro paso.** Aplica en orden los
siguientes guardrails del framework (cada uno vive en su archivo y define
su propio mensaje de error + comando de recuperación):

1. `novaspec/guardrails/branch-pattern.md` — extrae `<ticket-id>` de la rama.
2. `novaspec/guardrails/all-tasks-done.md` — verifica que `tasks.md` no tiene
   `- [ ]` pendientes; respeta la excepción quick-fix sin `tasks.md`.

## Precondición

- Todas las tareas de `tasks.md` marcadas `[x]`
- Rama del ticket con cambios sin commitear

## Pasos

### 1. Preparar el review

Lee:
- `.docs/changes/active/<ticket-id>/proposal.md`
- `.docs/changes/active/<ticket-id>/plan.md`
- `.docs/changes/active/<ticket-id>/tasks.md`
- ADRs relevantes en `.docs/adr/`
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

```
## Review: <TICKET-ID>

### Cumplimiento de spec
- [✓/✗] Criterio 1: <detalle>

### Convenciones
- <hallazgos o "sin incidencias">

### ADRs
- <o "sin conflictos">

### Riesgos
- <o "ninguno">

### Bloqueantes
- <deben resolverse antes de /nova-wrap>

### Sugerencias
- <mejoras opcionales>

### Veredicto
✓ Listo para /nova-wrap
— o —
✗ Requiere ajustes
```

**Persiste el reporte**: escribe el reporte completo (con el veredicto
incluido) en `.docs/changes/active/<ticket-id>/review.md`. Este archivo es
leído por `/nova-wrap` para verificar que el review fue aprobado.

### 4. Checkpoint humano

Si hay bloqueantes → pide resolverlos.
Si no → "Review OK. Ejecuta `/nova-wrap`."

## Reglas

- No modifiques código aquí.
- Cita archivo y línea al señalar problemas.
- Violación de ADR sin justificar siempre es bloqueante.
- No propongas cambios fuera del alcance.
