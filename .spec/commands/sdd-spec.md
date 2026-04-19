---
description: Genera la spec del cambio a partir del ticket y el contexto cargado
---

Eres el encargado de generar la spec técnica del ticket actual.

## Guardrail

**Ejecuta esto antes de cualquier otro paso.** Aplica en orden los
siguientes guardrails del framework (cada uno vive en su archivo y define
su propio mensaje de error + comando de recuperación):

1. `.spec/guardrails/branch-pattern.md` — extrae `<ticket-id>` de la rama.

## Precondición

Debe haberse ejecutado `/sdd-start` antes. Si no detectas rama creada y
contexto cargado, pide al usuario que ejecute `/sdd-start <TICKET>` primero.

## Pasos

### 1. Invocar close-requirement

Invoca la skill `close-requirement` para:
- cerrar decisiones mediante preguntas
- anclar defaults en el código existente
- iterar hasta que no queden ambigüedades

**No sigas al paso 2 hasta que el usuario confirme** que las decisiones
están cerradas.

### 2. Redactar la spec

Crea `.docs/changes/active/<ticket-id>/proposal.md`:

```
# <TICKET-ID>: <título>

## Historia
Como <actor>, quiero <capacidad>, para <resultado>.

## Objetivo
<qué hace posible>

## Contexto
<problema y por qué importa>

## Alcance
### En alcance
- <items>
### Fuera de alcance
- <items>

## Decisiones cerradas
- <lista>

## Comportamiento esperado
- Normal: <...>
- Edge cases: <...>
- Fallo: <...>

## Output esperado
<...>

## Criterios de éxito
- <observables>

## Impacto arquitectónico
- Servicios afectados: <lista>
- ADRs referenciados: <lista o "ninguno">
- ¿Requiere ADR nuevo?: sí | no | posible

## Verificación sin tests automatizados
### Flujo manual
1. <pasos reproducibles>

### Qué mirar
- Logs: <...>
- DB: <...>
- API/UI: <...>

## Riesgos
- <riesgo>: <mitigación>
```

### 3. Checkpoint humano

Muestra la spec y di:

> "Spec generada en `.docs/changes/active/<ticket-id>/proposal.md`.
>  Revísala antes de `/sdd-plan`."

No avances automáticamente.

## Reglas

- No redactes spec sin pasar por `close-requirement`.
- Si el ticket es quick-fix, avisa: "¿seguro que necesita spec formal?"
- Si el archivo ya existe, pregunta si sobrescribir.
