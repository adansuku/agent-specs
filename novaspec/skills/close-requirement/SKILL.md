---
name: close-requirement
description: Convierte un ticket o idea vaga en un requisito técnicamente cerrado
  y revisable por un senior, mediante preguntas estructuradas ancladas en el
  código existente. Úsala antes de redactar una spec formal.
---

# Cerrar requisito

Transforma ticket vago en requisito con decisiones cerradas.

Optimiza para **claridad, completitud y decisiones cerradas**.

## Contexto previo

Antes de preguntar, lee:
- `.docs/services/<servicio>/CONTEXT.md` de servicios afectados
- `.docs/adr/` — ADRs que puedan aplicar
- `.docs/glossary.md` — términos del dominio

## Comportamiento

### 1. Entender la petición

Identifica brevemente: qué quiere, qué problema resuelve, qué no está claro.

### 2. Hacer preguntas clarificadoras

Objetivo: **forzar decisiones**, no explorar.

Reglas:
- tono conversacional
- máximo 3 preguntas por turno, agrúpalas por tema
- cada una resuelve decisión concreta
- prefiere trade-offs (A vs B) a abiertas
- siempre que puedas, incluye default sugerido

### Dimensiones obligatorias

1. **Forma de la solución** (nuevo endpoint vs extender existente)
2. **Output esperado**
3. **Comportamiento** (normal, edge cases, fallo)
4. **Actor y contexto de uso**
5. **Límites del alcance**
6. **Criterios de éxito**

### Defaults anclados en código

Antes de proponer un default:
- inspecciona código existente
- identifica patrones actuales
- referencia archivos y rutas concretas

Evita sugerencias genéricas si hay evidencia en el código.

### 3. Iterar hasta cerrar

- Respuestas incompletas → vuelve a preguntar
- Ambigüedad → vuelve a preguntar
- No avances con decisiones abiertas

### 4. Confirmar antes de redactar

> "Todo claro. ¿Redacto el requisito final?"

No redactes todavía.

### 5. Redactar solo tras confirmación

## Output

### Si quedan decisiones abiertas

```
## Entendimiento
<lo que crees que quiere>

## Preguntas
1. <pregunta>
   Default sugerido: <anclado en código>
```

### Si todo claro pero no confirmado

```
## Estado
Todas las decisiones claras.

## Confirmación
¿Redacto el requisito final?
```

### Si confirmado

```
# Requisito: <título>

## Historia
Como <actor>, quiero <capacidad>, para <resultado>.

## Objetivo
## Contexto
## Alcance (en / fuera)
## Decisiones cerradas
## Comportamiento esperado (normal / edge / fallo)
## Output esperado
## Criterios de éxito
```

## Reglas

- No escribas código
- No asumas decisiones que faltan
- No redactes si quedan decisiones abiertas
- Responde en el idioma del usuario
