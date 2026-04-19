---
name: update-service-context
description: Actualiza CONTEXT.md cuando cambia comportamiento de servicio.
---

# Actualizar CONTEXT.md

## Cuándo actualizar

- Añade/quita responsabilidades
- Modifica contratos públicos
- Cambia integraciones
- Introduce nuevas dependencias
- Cambia comportamiento observable

**No** para cambios internos sin impacto externo.

## Pasos

### 1. Verificar si existe

Si no existe, pregunta si crear.

### 2. Identificar cambios

Compara estado anterior vs nuevo.

### 3. Plantilla

Usa `novaspec/templates/context.md` o estructura básica:

```
# Servicio: <nombre>

## Qué hace
## Contratos públicos
## Dependencias
## Última actualización: YYYY-MM-DD — <ticket>
```

### 4. Proponer diff

```
## Cambios propuestos
- [antes] ...
- [después] ...
```

> "¿Aplico, ajustamos, o cancelamos?"

Solo escribe tras confirmación.

## Reglas

- No inventes responsabilidades
- Si es interno sin impacto, no actualices
- CONTEXT.md corto
- No repitas ADRs; usa "Ver ADR-NNNN"