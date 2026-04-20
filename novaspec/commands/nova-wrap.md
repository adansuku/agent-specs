---
description: Cierra el ticket — actualiza memoria, archiva spec, commit y PR
---

Este es el paso que alimenta la memoria arquitectónica.
**Sin este paso, el sistema no aprende.**

## Guardrail

`checklist.md` → 1, 5, 6 (branch-pattern, review-approved, old-decision-archived)

## Precondición

- `/nova-review` con veredicto ✓
- Sin bloqueantes pendientes

## Pasos

### 1. Detectar decisión arquitectónica

Si se tomó una decisión real con alternativa y trade-off, invoca skill `write-decision`.

> "¿Documentamos esta decisión?
>  - Sí, crear `context/decisions/<concept>.md`
>  - No, no hay alternativa real / es cosmética
>  - Supersede una decisión existente → nombre del archivo viejo"

Si supersede: nuevo archivo incluye `> Supersedes: <viejo>.md` y ejecuta `git mv context/decisions/<viejo>.md context/decisions/archived/<viejo>.md`. El guardrail #6 valida esta invariante.

### 2. Actualizar servicio

Para cada servicio modificado cuya interfaz pública cambió, invoca skill `update-service-context`.

> "¿Ha cambiado la interfaz pública del servicio X?
>  - Sí, reescribir `context/services/<svc>.md` (≤80 líneas, reemplazar, no acumular)
>  - No, cambio interno sin impacto externo"

### 3. Gotcha descubierto

> "¿Has descubierto durante el build algo contraintuitivo que otra persona redescubriría?
>  - Sí → añadir `context/gotchas/<concept>.md` (atómico, breve)
>  - No"

Default: no escribir. La mayoría de tickets no genera gotcha.

### 4. Archivar spec

- Mueve `context/changes/active/<ticket-id>/` → `context/changes/archive/<ticket-id>/`

### 5. Commit

Usa la estructura de `novaspec/templates/commit.md` como plantilla.
Si hay muchos cambios, propón agrupar en commits lógicos.

### 6. Crear PR

Resuelve la rama base igual que `/nova-start`:
- Lee `branch.base` de `novaspec/config.yml`.
- Si la clave falta, intenta `develop`; si tampoco existe, pregunta al
  usuario y recomienda fijar `branch.base` en `novaspec/config.yml`.

Crea el PR con `gh pr create --base <base-resuelta> --title "<título>"
--body "<descripción>"`.

**Título**: `<TICKET-ID>: <título>`

**Descripción**: usa la estructura de `novaspec/templates/pr-body.md` como plantilla.

### 7. Cerrar ticket en Jira

Si `novaspec/config.yml` tiene `jira.skill` con valor, invocar la skill `jira-integration` para transicionar el ticket a "Listo":

```bash
AUTH=$(echo -n "<email>:<token>" | base64)
curl -s -X POST \
  -H "Authorization: Basic $AUTH" \
  -H "Content-Type: application/json" \
  "https://<jira-url>/rest/api/3/issue/<TICKET-ID>/transitions" \
  -d '{"transition": {"id": "41"}}'
```

Confirmar al usuario: "Ticket <TICKET-ID> marcado como Listo en Jira ✓"

### 8. Resumen final

```
## Ticket <TICKET-ID> cerrado

- Spec archivada: <ruta>
- Decisions creadas: <lista o "ninguna">
- Gotchas añadidas: <lista o "ninguna">
- Services actualizados: <lista o "ninguno">
- Commits: <número>
- PR: <link>
- Jira: <TICKET-ID> → Listo ✓ (o "Jira no configurado")
```

## Reglas

- No saltes el paso de memoria.
- Si el usuario dice "no" a todo, avisa: "cerramos sin memoria, ¿seguro?"
- No ejecutes commits ni PR sin confirmación.
- Si algo falla, para y reporta.
