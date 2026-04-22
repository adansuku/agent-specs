# Guardrails validan precondición antes de cada comando

**Fecha**: 2026-XX (AGEX-002)

## Decisión

Cada `/nova-*` (excepto `/nova-start`) valida activamente que el paso anterior se completó antes de ejecutarse. Si la precondición no se cumple, el agente emite `⛔ Guardrail: <motivo>` y se detiene.

Los guardrails viven como archivos markdown compartidos en `novaspec/guardrails/` referenciados por ruta desde cada comando.

## Alternativas descartadas

- **Skill parametrizable**: las skills se invocan no deterministamente por el modelo; no se puede garantizar que se ejecute.
- **Hook en `settings.json`**: determinista pero requiere bash imperativo y no se distribuye con `install.sh`.

## Por qué

Un archivo markdown referenciado desde el comando fuerza al modelo a leerlo antes de actuar, es determinista dentro del flujo del comando, y viaja con `install.sh` sin tocar configuración del harness.

## Detalles

Detección basada en: rama git activa con patrón de ticket + existencia de artefactos (`proposal.md`, `tasks.md`, `review.md`) + estado de checkboxes en `tasks.md`.
