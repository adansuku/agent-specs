# `context/` — memoria del proyecto (simple y grep-friendly)

`context/` es la “memoria” que acompaña al código: lo que el equipo necesita
para no re-explicar el porqué en cada ticket.

## Directorios

- `context/decisions/` — decisiones técnicas con alternativa real (un hecho por archivo).
  - `context/decisions/archived/` — decisiones superseded (no se auto-cargan).
- `context/gotchas/` — trampas no obvias que otro dev redescubriría.
- `context/services/` — mapa corto por servicio (`<svc>.md`, ≤80 líneas).
- `context/changes/active/` — specs en curso (coordinación del equipo).
- `context/changes/archive/` — specs cerradas (histórico + ejemplos).

## Reglas rápidas

- “Un hecho → un archivo”. Si cambia, crea otro y supersede (no acumules).
- Nombra por concepto (grep como índice).
- Default: no escribir (solo lo que realmente aporta).

Fuente canónica del modelo: `context/decisions/memoria-sencilla.md`.
