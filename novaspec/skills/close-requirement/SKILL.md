---
name: close-requirement
description: Convierte ticket vago en requisito cerrado con preguntas estructuradas.
---

# Cerrar requisito

Transforma ticket vago en requisito con decisiones cerradas.

## Contexto previo

Lee antes de preguntar:
- `.docs/services/<servicio>/CONTEXT.md`
- `.docs/adr/`
- `.docs/glossary.md`

## Pasos

### 1. Entender la petición

Qué quiere, qué problema resuelve, qué no está claro.

### 2. Preguntas clarificadoras

Objetivo: forzar decisiones, no explorar.

- tono conversacional, max 3 preguntas por turno
- prefiere trade-offs (A vs B) a abiertas
- incluye default sugerido anclado en código

### Dimensiones obligatorias

1. Forma de la solución
2. Output esperado
3. Comportamiento (normal, edge, fallo)
4. Actor y contexto
5. Alcance
6. Criterios de éxito

### 3. Iterar hasta cerrar

No avances si hay decisiones abiertas.

### 4. Confirmar antes de redactar

> "Todo claro. ¿Redacto el requisito final?"

## Output

Plantilla: `novaspec/templates/proposal.md` (úsala tras confirmación)

## Reglas

- No escribas código
- No asumas decisiones que faltan
- No redactes si hay decisiones abiertas