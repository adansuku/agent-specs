---
name: load-context
description: Carga contexto arquitectónico antes de trabajar en un ticket.
---

# Cargar contexto

Reunir contexto relevante antes de spec o código.

## Pasos

### 1. Verifica `context/`

Si no existe, avisa y ofrece crear estructura.

### 2. Identifica servicios afectados

Pregunta con opciones si no tienes claro.

### 3. Lee existentes

Para cada servicio:
- `context/services/<servicio>/CONTEXT.md`
- `context/services/<servicio>/decisions.md`
- `context/services/<servicio>/incidents.md`

### 4. Busca ADRs

Escanea `context/adr/`. No fuerces conexiones.

### 5. Resumen

```
## Contexto cargado

**Servicios**: <lista> | no documentado
**ADRs**: <lista o "ninguno"
**Huecos**: <qué falta>
**Preguntas**: <si hay ambigüedad>
```

## Cuándo preguntar

- Servicio sin CONTEXT.md
- Dos interpretaciones del alcance
- Falta `context/` entero

## Reglas

- No inventes contexto
- No bloquees si falta `context/`
- Preguntas concretas, agrúpalas