---
name: load-context
description: Carga contexto arquitectónico antes de trabajar en un ticket.
  Úsala cuando se empieza una nueva tarea, se modifica un servicio, o cuando
  el usuario menciona un servicio, un ticket, o dice "vamos a trabajar en".
---

# Cargar contexto arquitectónico

Tu trabajo: reunir contexto relevante antes de que se escriba spec o código.
Si falta documentación, **pregunta al usuario** antes de asumir nada.

## Pasos

### 1. Verifica que exista `.docs/`

Si no existe:
- Avisa al usuario
- Ofrece crear la estructura base
- Pregunta si continuar sin memoria arquitectónica

**No bloquees al usuario.** Si no hay `.docs/`, el flow sigue funcionando.

### 2. Identifica servicios afectados

Si no tienes claro qué servicios toca, pregunta con opciones concretas.

### 3. Lee lo que exista

Para cada servicio:
- `.docs/services/<servicio>/CONTEXT.md`
- `.docs/services/<servicio>/decisions.md`
- `.docs/services/<servicio>/incidents.md`

Si falta archivo, anótalo como "no documentado". Ofrece crearlo al final.

### 4. Busca ADRs y specs

Escanea `.docs/adr/`.
Si no encuentras nada claro, dilo. No fuerces conexiones.

### 5. Presenta resumen + preguntas abiertas

```
## Contexto cargado

**Servicios**:
- <servicio>: <resumen 1 línea> | no documentado

**ADRs relevantes**:
- ADR-NNNN: <título>

**Specs actuales**:
- <path>: <1 línea>

**Restricciones a preservar**:
- <lista>

**Huecos detectados**:
- <qué falta>

**Preguntas**:
- <si hay ambigüedad>
```

## Cuándo preguntar vs asumir

**Pregunta si**:
- Servicio sin CONTEXT.md
- Dos interpretaciones posibles del alcance
- Decisión arquitectónica implícita
- Falta `.docs/` entero

**Asume si**:
- La info está clara en los archivos leídos
- El usuario ya respondió antes en la conversación

## Ofertas al usuario

Cuando detectes huecos, ofrece acciones concretas:
- "¿Creo CONTEXT.md inicial para X?"
- "¿Documentamos esto como ADR?"

**No las ejecutes sin confirmación.**

## Reglas

- No inventes contexto.
- No bloquees si falta `.docs/`.
- Preguntas concretas con opciones. Agrúpalas en un solo turno.
