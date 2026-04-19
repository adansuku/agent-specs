---
name: write-adr
description: Crea ADR cuando se toma decisión técnica relevante.
---

# Escribir ADR

Crea en `.docs/adr/`.

## Cuándo crear

- Elección entre alternativas técnicas
- Cambio de patrón establecido
- Nueva dependencia
- Decisión que otro dev debería conocer en 6 meses

**No** para bug fixes, cosmética, patrones ya documentados.

## Pasos

### 1. Numerar

Escanea `.docs/adr/`, usa siguiente número (`NNNN`).

### 2. Nombre

`NNNN-kebab-case-titulo.md`

### 3. Preguntar datos

> Necesito:
> 1. Título corto (<60 chars)
> 2. Alternativas consideradas y por qué se descartaron
> 3. Consecuencias negativas aceptadas
> 4. ¿Deprecia ADR anterior?

### 4. Plantilla

Usa `novaspec/templates/adr.md` o estructura básica:

```
# ADR-NNNN: <título>

## Estado
Aceptado — YYYY-MM-DD

## Contexto
## Decisión
## Alternativas
## Consecuencias
## Relacionado
```

### 5. Confirmar antes de guardar

Solo escribe tras confirmación.

## Reglas

- No inventes alternativas
- Título en sentencia
- Secciones breves