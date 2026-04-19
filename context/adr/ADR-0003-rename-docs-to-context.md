# ADR-0003: Renombrar directorio de memoria de `.docs/` a `context/`

## Estado
Aceptado — 2026-04-19

## Contexto
`.docs/` almacena la memoria arquitectónica del proyecto (ADRs, specs, CONTEXT.md de servicios, cambios activos y archivados). El leading dot lo hace invisible por convención de sistema operativo en exploradores de archivos y terminales con `ls` sin `-a`. El directorio es un artefacto central del flujo nova-spec y merece visibilidad y un nombre que refleje su propósito.

## Decisión
Renombrar `.docs/` a `context/` en el repo canónico y actualizar todas las referencias en comandos, skills, templates, guardrails e `install.sh`.

## Alternativas
- **Mantener `.docs/`**: ya establecido, cero coste de migración. Descartado — la invisibilidad dificulta la adopción y contradice el espíritu de ADR-0002 (nombres visibles, sin ambigüedad).
- **Usar `.context/`**: mantiene leading dot, visible en algunos exploradores pero no en `ls` estándar. Descartado — no resuelve el problema raíz.

## Consecuencias
- **Positivas**: directorio visible en todos los exploradores; nombre autodescriptivo; coherente con la filosofía de naming de ADR-0002.
- **Negativas**: breaking change para repos ya instalados con `.docs/`. Migración: `git mv .docs context/` (una línea).

## Relacionado
- ADR-0002: naming nova-spec (complementario)
- NOVA-9: ticket que implementa este cambio
