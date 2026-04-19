---
name: update-service-context
description: Actualiza el CONTEXT.md de un servicio cuando su comportamiento,
  responsabilidades o integraciones han cambiado. Úsala al cerrar un ticket
  que modifica un servicio.
---

# Actualizar CONTEXT.md de servicio

## Cuándo actualizar

Si el cambio:
- Añade/quita responsabilidades
- Modifica contratos públicos (endpoints, formatos)
- Cambia integraciones con otros servicios
- Introduce/elimina dependencias relevantes
- Cambia comportamiento observable desde fuera

**No actualices** para cambios internos sin impacto externo.

## Pasos

### 1. Verificar si existe

**Si no existe**:
> "No hay CONTEXT.md para <servicio>. ¿Lo creamos?
>  - Sí, crear con plantilla
>  - No, saltar"

**Si existe**: léelo entero antes de proponer cambios.

### 2. Identificar qué cambia

Compara estado anterior vs nuevo. Identifica:
- Secciones obsoletas
- Secciones que necesitan añadir info
- Información nueva sin encaje

### 3. Plantilla

```
# Servicio: <nombre>

## Qué hace
<2-3 líneas. Responsabilidad principal.>

## Por qué existe
<1-2 líneas.>

## Contratos públicos
### Inputs
- <endpoint / mensaje / trigger>: <descripción>

### Outputs
- <endpoint / evento / respuesta>: <descripción>

## Dependencias
### De los que depende
- <servicio>: <para qué>

### Que dependen de este
- <servicio>: <para qué>

## Datos que maneja

## Decisiones clave
- Ver ADRs: <lista>
- Decisiones locales: `.docs/services/<servicio>/decisions.md`

## Peculiaridades conocidas

## Incidentes
- Ver `.docs/services/<servicio>/incidents.md`

## Última actualización
YYYY-MM-DD — <ticket>
```

### 4. Proponer diff al usuario

```
## Cambios propuestos

### Sección: <nombre>
- [antes] <contenido>
- [después] <contenido>

### Sección nueva: <nombre>
<contenido>
```

> "¿Aplico, ajustamos, o cancelamos?"

Solo escribe tras confirmación.

### 5. Actualizar fecha

```
## Última actualización
<YYYY-MM-DD> — <TICKET-ID>
```

## Reglas

- No inventes responsabilidades ni dependencias.
- Si es interno sin impacto externo, no actualices.
- CONTEXT.md corto. Si crece, parte en archivos separados.
- No repitas lo que está en ADRs. Usa `Ver ADR-NNNN`.
- Presente, no pasado.
