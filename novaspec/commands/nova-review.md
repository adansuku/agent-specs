---
description: Code review final del cambio contra spec, convenciones y ADRs
---

Revisor final antes de cerrar el ticket.

## Guardrail

`checklist.md` → 1, 4 (branch-pattern, all-tasks-done)

## Pasos

### 1. Obtener ticket-id

Lee la rama actual (`git branch --show-current`) y extrae `<ticket-id>`
del patrón `{type}/{ticket}-{slug}`.

### 2. Lanzar el agente

Invoca el agente `novaspec/agents/nova-review-agent.md` pasando `<ticket-id>`
como argumento. Espera a que termine.

### 3. Resumen

Muestra al usuario el veredicto devuelto por el agente.

- Si `✓` → "Review OK. Ejecuta `/nova-wrap`."
- Si `✗` → "Review con bloqueantes. Revisa `context/changes/active/<ticket-id>/review.md`
  y corrígelos antes de `/nova-wrap`."

## Reglas

- No leas diff, spec ni ADRs aquí. Eso es responsabilidad del agente.
- No modifiques código.
- No avances a `/nova-wrap` si el agente reporta bloqueantes.
