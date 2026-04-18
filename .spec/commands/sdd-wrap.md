---
description: Cierra el ticket — actualiza memoria, archiva spec, commit y PR
---

Este es el paso que alimenta la memoria arquitectónica.
**Sin este paso, el sistema no aprende.**

## Guardrail

**Ejecuta esto antes de cualquier otro paso.**

1. Lee la rama git actual y extrae el `<ticket-id>`.
   Si la rama no sigue el patrón `(feature|fix|arch)/<TICKET>-<slug>`:

   ```
   ⛔ Guardrail: no hay rama de ticket activa.
   Ejecuta /sdd-start <TICKET> primero.
   ```
   **Para aquí. No sigas.**

2. Comprueba que existe `.docs/changes/<ticket-id>/review.md`.
   Si no existe:

   ```
   ⛔ Guardrail: no existe review.md para <ticket-id>.
   Ejecuta /sdd-review primero.
   ```
   **Para aquí. No sigas.**

3. Lee `.docs/changes/<ticket-id>/review.md` y busca la línea
   `✓ Listo para /sdd-wrap`.
   Si no aparece esa línea:

   ```
   ⛔ Guardrail: el review de <ticket-id> no tiene veredicto ✓.
   Resuelve los bloqueantes y vuelve a ejecutar /sdd-review.
   ```
   **Para aquí. No sigas.**

## Precondición

- `/sdd-review` con veredicto ✓
- Sin bloqueantes pendientes

## Pasos

### 1. Detectar decisión arquitectónica

Si se tomó una decisión relevante, invoca skill `write-adr`.

> "¿Documentamos esta decisión como ADR?
>  - Sí, crear ADR-NNNN
>  - No, es menor
>  - Ya existe: ADR-NNNN"

### 2. Actualizar CONTEXT.md

Para cada servicio modificado, invoca skill `update-service-context`.

> "¿Ha cambiado el comportamiento del servicio X?
>  - Sí, actualizar CONTEXT.md
>  - No, cambio interno sin impacto externo"

### 3. Otros rastros

> "¿Añadimos algo a...?
>  - decisions.md del servicio
>  - incidents.md del servicio
>  - glossary.md"

### 4. Archivar spec

- Consolida contenido relevante en `.docs/specs/<capability>/`
- Mueve `.docs/changes/<ticket-id>/` → `.docs/changes/archive/<ticket-id>/`

### 5. Commit

```
<tipo>(<scope>): <resumen>

<cuerpo opcional>

Refs: <TICKET-ID>
ADRs: <ADR-NNNN si aplica>
```

Si hay muchos cambios, propón agrupar en commits lógicos.

### 6. Crear PR

**Título**: `<TICKET-ID>: <título>`

**Descripción**:
```
## Ticket
<link a Jira>

## Resumen
<qué cambia y por qué>

## Spec
.docs/changes/archive/<ticket-id>/proposal.md

## ADRs
- ADR-NNNN: <título> (si aplica)

## Verificación manual
<pasos del plan>

## Checklist
- [x] Spec archivada
- [x] CONTEXT.md actualizado
- [x] ADR creado (si aplicaba)
- [x] Review sin bloqueantes
```

### 7. Resumen final

```
## Ticket <TICKET-ID> cerrado

- Spec archivada: <ruta>
- Specs consolidadas: <rutas>
- ADRs creados: <lista o "ninguno">
- CONTEXT.md actualizados: <lista o "ninguno">
- Commits: <número>
- PR: <link>
```

## Reglas

- No saltes el paso de memoria.
- Si el usuario dice "no" a todo, avisa: "cerramos sin memoria, ¿seguro?"
- No ejecutes commits ni PR sin confirmación.
- Si algo falla, para y reporta.
