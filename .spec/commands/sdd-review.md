---
description: Code review final del cambio contra spec, convenciones y ADRs
---

Revisor final antes de cerrar el ticket.

## Guardrail

**Ejecuta esto antes de cualquier otro paso.**

1. Lee la rama git actual y extrae el `<ticket-id>`.
   Si la rama no sigue el patrón `(feature|fix|arch)/<TICKET>-<slug>`:

   ```
   ⛔ Guardrail: no hay rama de ticket activa.
   Ejecuta /sdd-start <TICKET> primero.
   ```
   **Para aquí. No sigas.**

2. Comprueba si es quick-fix (rama `fix/`) y si existe
   `.docs/changes/<ticket-id>/tasks.md`.
   - Si **existe `tasks.md`**: comprueba que no quede ningún `- [ ]`
     sin marcar. Si quedan tareas pendientes:

     ```
     ⛔ Guardrail: hay N tarea(s) sin completar en tasks.md.
     Ejecuta /sdd-do para completarlas primero.
     ```
     **Para aquí. No sigas.**

   - Si **no existe `tasks.md`** y es quick-fix: continúa.
   - Si **no existe `tasks.md`** y no es quick-fix:

     ```
     ⛔ Guardrail: no existe tasks.md para <ticket-id>.
     Ejecuta /sdd-plan primero.
     ```
     **Para aquí. No sigas.**

## Precondición

- Todas las tareas de `tasks.md` marcadas `[x]`
- Rama del ticket con cambios sin commitear

## Pasos

### 1. Preparar el review

Lee:
- `.docs/changes/<ticket-id>/proposal.md`
- `.docs/changes/<ticket-id>/plan.md`
- `.docs/changes/<ticket-id>/tasks.md`
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
- <deben resolverse antes de /sdd-wrap>

### Sugerencias
- <mejoras opcionales>

### Veredicto
✓ Listo para /sdd-wrap
— o —
✗ Requiere ajustes
```

**Persiste el reporte**: escribe el reporte completo (con el veredicto
incluido) en `.docs/changes/<ticket-id>/review.md`. Este archivo es
leído por `/sdd-wrap` para verificar que el review fue aprobado.

### 4. Checkpoint humano

Si hay bloqueantes → pide resolverlos.
Si no → "Review OK. Ejecuta `/sdd-wrap`."

## Reglas

- No modifiques código aquí.
- Cita archivo y línea al señalar problemas.
- Violación de ADR sin justificar siempre es bloqueante.
- No propongas cambios fuera del alcance.
