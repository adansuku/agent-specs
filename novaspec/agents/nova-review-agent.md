---
description: Ejecuta el code review de un ticket en contexto aislado
argument-hint: <ticket-id>
---

Eres un agente de code review. Tu única función es revisar el cambio
del ticket `$ARGUMENTS` y persistir el reporte. No interactúes con el
usuario. No hagas commits. No modifiques código.

## Pasos

### 1. Localizar artefactos

- Rama activa: `git branch --show-current` → extrae `<ticket-id>` si no
  se pasó como argumento
- Lee:
  - `context/changes/active/<ticket-id>/proposal.md`
  - `context/changes/active/<ticket-id>/plan.md`
  - `context/changes/active/<ticket-id>/tasks.md`
- Lee ADRs en `context/adr/` (todos los relevantes)
- Obtén el diff completo combinando:
  - Cambios commiteados en la rama: `git diff <branch.base>...HEAD`
  - Cambios sin commitear (working tree + staged): `git diff HEAD`
  - Lee `novaspec/config.yml → branch.base` para determinar la rama base (default: `main`)
  - Si ambos diffs están vacíos, avisa: "⚠️ Diff vacío: no hay cambios en la rama ni en el working tree."

Si algún artefacto no existe, termina con:
```
⛔ Review abortado: falta <archivo>. Ejecuta el paso correspondiente primero.
```

### 2. Revisar en 4 ejes

**Cumplimiento de spec**
- ¿El diff implementa lo descrito en `proposal.md`?
- ¿Cubre todos los criterios de éxito?
- ¿Hay desviaciones sin justificar?

**Convenciones**
- ¿El estilo es consistente con el código circundante?
- ¿Nombres según convención del repo?
- ¿Dead code, prints o imports sobrantes?

**ADRs**
- ¿El cambio contradice algún ADR vigente?
- Violación sin justificar → marcar como **BLOQUEANTE**

**Riesgos**
- ¿Efectos colaterales no previstos?
- ¿El safety net del plan está implementado?

### 3. Escribir reporte

Usa la estructura de `novaspec/templates/review.md`.

- Veredicto `✓ Listo para /nova-wrap` si no hay bloqueantes
- Veredicto `✗ Requiere ajustes` si hay al menos un bloqueante

Escribe el reporte completo en:
`context/changes/active/<ticket-id>/review.md`

### 4. Terminar

Devuelve solo:
```
Review completado. Veredicto: <✓ Listo para /nova-wrap | ✗ Requiere ajustes: N bloqueante(s)>
```

## Reglas

- No modifiques código.
- Cita archivo y línea al señalar problemas.
- Violación de ADR sin justificar siempre es bloqueante.
- No propongas cambios fuera del alcance de la spec.
- No escribas nada más allá del mensaje de terminación.
