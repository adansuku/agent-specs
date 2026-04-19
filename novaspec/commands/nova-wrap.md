---
description: Cierra el ticket — actualiza memoria, archiva spec, commit y PR
---

Este es el paso que alimenta la memoria arquitectónica.
**Sin este paso, el sistema no aprende.**

## Guardrail

**Ejecuta esto antes de cualquier otro paso.** Aplica en orden los
siguientes guardrails del framework (cada uno vive en su archivo y define
su propio mensaje de error + comando de recuperación):

1. `novaspec/guardrails/branch-pattern.md` — extrae `<ticket-id>` de la rama.
2. `novaspec/guardrails/review-approved.md` — verifica `review.md` y la línea
   `✓ Listo para /nova-wrap`.

## Precondición

- `/nova-review` con veredicto ✓
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

- Mueve `.docs/changes/active/<ticket-id>/` → `.docs/changes/archive/<ticket-id>/`

### 5. Commit

```
<tipo>(<scope>): <resumen>

<cuerpo opcional>

Refs: <TICKET-ID>
ADRs: <ADR-NNNN si aplica>
```

Si hay muchos cambios, propón agrupar en commits lógicos.

### 6. Crear PR

Resuelve la rama base igual que `/nova-start`:
- Lee `branch.base` de `novaspec/config.yml`.
- Si la clave falta, intenta `develop`; si tampoco existe, pregunta al
  usuario y recomienda fijar `branch.base` en `novaspec/config.yml`.

Crea el PR con `gh pr create --base <base-resuelta> --title "<título>"
--body "<descripción>"`.

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
