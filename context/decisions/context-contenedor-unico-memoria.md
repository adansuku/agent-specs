# `context/` como contenedor único de memoria arquitectónica

**Fecha**: ~2026-04 (NOVA-9)

## Decisión

Toda la memoria arquitectónica (decisiones, gotchas, descripciones de servicios, specs en curso/archivadas) vive bajo `context/`. Un único directorio, visible.

## Alternativas descartadas

- `.docs/` — oculto por el punto, el equipo lo olvida.
- `openspec/` — nombre específico a una especificación; redundante cuando todo es contexto.
- Dispersar por servicio (`services/<svc>/docs/`) — rompe búsqueda global por concepto.

## Por qué

Un solo directorio visible es grep-friendly y descubrible. El nombre `context` es neutro: sirve para humanos y agentes sin sesgar hacia un formato.
