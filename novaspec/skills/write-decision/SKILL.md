---
name: write-decision
description: Crea un archivo en context/decisions/ cuando se toma una decisión técnica con alternativa real.
---

# Escribir decisión

Crea un archivo markdown atómico en `context/decisions/`. Sin numeración, sin frontmatter, nombre-concepto.

## Cuándo crear

- **Sí**: elección entre alternativas técnicas reales con trade-off, cambio de patrón establecido, nueva dependencia, decisión que otro dev (o tú en 6 meses) debería conocer.
- **No**: bug fixes, refactor cosmético, patrones ya documentados, afirmaciones sin alternativa explorada.

Default: **no escribir**. La mayoría de tickets no generan decisión.

## Pasos

### 1. Nombre del archivo

`<concepto-kebab-case>.md`. Ejemplos: `symlinks-vs-copia.md`, `guardrails-por-paso.md`. **No** uses numeración `NNNN-`. El nombre es el índice; grep por concepto es más rápido que grep por número.

### 2. ¿Supersede una decisión anterior?

Si sí:
- El archivo nuevo empieza con una línea `> Supersedes: <archivo-viejo>.md`.
- Ejecuta `git mv context/decisions/<archivo-viejo>.md context/decisions/archived/<archivo-viejo>.md`.
- El guardrail `old-decision-archived` valida que esta invariante se cumpla.

### 3. Preguntar datos

> Necesito:
> 1. Nombre-concepto del archivo
> 2. Decisión (una línea)
> 3. Alternativas descartadas y por qué (breve)
> 4. Consecuencias / coste aceptado
> 5. ¿Supersede alguna decisión existente? (nombre del archivo)

### 4. Estructura

Breve o nada. Cabe en una pantalla. Sin secciones ceremoniales obligatorias; lo mínimo:

```
# <Título concepto>

[> Supersedes: <archivo-viejo>.md   ← solo si aplica]

**Fecha**: YYYY-MM-DD

## Decisión
<una línea>

## Alternativa descartada
<qué y por qué>

## Por qué
<el argumento real>

## Coste aceptado
<qué perdemos>
```

### 5. Confirmar antes de guardar

Solo escribe tras confirmación.

## Reglas

- No inventes alternativas.
- Cabe en una pantalla o falla atomicidad (pártelo en dos archivos).
- Un hecho, un archivo. Nunca actualizar con info nueva — crear otro archivo con supersede.
- Nunca escribas directamente en `context/decisions/archived/`; archived es destino de `git mv`, no de creación.
