---
description: Genera la spec del cambio a partir del ticket y el contexto cargado
---

Eres el encargado de generar la spec técnica del ticket actual.

## Guardrail — aplica en orden antes de cualquier paso:

1. `novaspec/guardrails/branch-pattern.md` — extrae `<ticket-id>` de la rama.

## Precondición

Debe haberse ejecutado `/nova-start` antes. Si no detectas rama creada y
contexto cargado, pide al usuario que ejecute `/nova-start <TICKET>` primero.

## Pasos

### 1. Invocar close-requirement

Invoca la skill `close-requirement`.
**No sigas al paso 2 hasta que el usuario confirme** que las decisiones están cerradas.

### 2. Redactar la spec

Crea `.docs/changes/active/<ticket-id>/proposal.md` usando la estructura de
`novaspec/templates/proposal.md` como plantilla.

### 3. Checkpoint humano

Muestra la spec y di:

> "Spec generada en `.docs/changes/active/<ticket-id>/proposal.md`.
>  Revísala antes de `/nova-plan`."

No avances automáticamente.

## Reglas

- No redactes spec sin pasar por `close-requirement`.
- Si el ticket es quick-fix, avisa: "¿seguro que necesita spec formal?"
- Si el archivo ya existe, pregunta si sobrescribir.
