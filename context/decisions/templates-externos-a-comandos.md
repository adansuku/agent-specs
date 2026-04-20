# Templates de salida viven en archivos, no inline en comandos

**Fecha**: 2026-XX (NOVA-001)

## Decisión

Los skeletons de formato de los artefactos generados (`proposal.md`, `plan.md`, `tasks.md`, `review.md`, `commit.md`, `pr-body.md`, etc.) viven en `novaspec/templates/*.md`. Los comandos los referencian por ruta en texto.

## Alternativa descartada

Embeber el skeleton inline dentro de cada comando.

## Por qué

- **Reduce tokens de contexto**: el comando es más corto; el template se carga solo cuando hace falta.
- **Centraliza el formato**: cambiar el formato de un artefacto es una edición en un archivo, no N ediciones en N comandos.
- Mismo patrón que los guardrails.
