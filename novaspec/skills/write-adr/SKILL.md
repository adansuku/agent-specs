---
name: write-adr
description: Crea un Architectural Decision Record (ADR) cuando se toma una
  decisión técnica relevante. Úsala cuando el usuario elige entre alternativas,
  cambia un patrón, introduce una dependencia nueva.
---

# Escribir un ADR

Crea un ADR en `.docs/adr/`.

## Cuándo crear ADR

Crea si:
- Elección entre alternativas técnicas
- Cambio de patrón establecido
- Nueva dependencia
- Decisión que otro dev debería conocer en 6 meses
- Deprecación de ADR anterior

**No crees** para bug fixes, cosmética, patrones ya documentados.

## Pasos

### 1. Numerar

Escanea `.docs/adr/`. Usa el siguiente número (`NNNN`, 4 dígitos).

### 2. Nombre del archivo

`NNNN-kebab-case-titulo.md`

Ejemplo: `0005-migrar-auth-a-oauth.md`

### 3. Preguntar datos clave

Si falta info, pregunta:

> "Necesito:
>  1. Título corto (<60 chars)
>  2. Alternativas consideradas y por qué se descartaron
>  3. Consecuencias negativas aceptadas
>  4. ¿Deprecia algún ADR anterior?"

No inventes.

### 4. Plantilla

```
# ADR-NNNN: <título>

## Estado
Propuesto | Aceptado | Deprecado — YYYY-MM-DD

## Contexto
<Situación que llevó a la decisión. 2-4 líneas.>

## Decisión
<Qué se decide. Directo.>

## Alternativas consideradas
- **<Opción A>**: <por qué se descartó>
- **<Opción B>**: <por qué se descartó>

## Consecuencias
### Positivas
### Negativas
### Neutras

## Relacionado
- ADRs: <o "ninguno">
- Specs: <rutas>
- Tickets: <TICKET-ID>

## Notas
```

### 5. Mostrar antes de guardar

> "Este es el ADR. ¿Lo guardo tal cual, ajustamos, o cancelamos?"

Solo escribe tras confirmación.

### 6. Deprecación

Si este ADR reemplaza otro:
- En el nuevo: `Relacionado → ADRs: ADR-NNNN (deprecado por este)`
- En el antiguo: estado `Deprecado — YYYY-MM-DD` + `Reemplazado por: ADR-NNNN`

Pregunta antes de modificar el antiguo.

## Reglas

- No inventes alternativas ni consecuencias.
- Título en sentencia, no Title Case.
- Estado inicial típicamente `Aceptado`.
- Secciones breves.
