# Review: NOVA-011

## Cumplimiento de spec

- [✓] Tabla de comandos eliminada de `CLAUDE.md` (líneas 15-23 del original)
- [✓] `CLAUDE.md` < 20 LOC: 18 LOC actuales
- [✓] Frontmatter `description:` de `novaspec/commands/nova-*.md` intacto — `/` sigue mostrando todos los comandos
- [✓] Orden del flujo conservado en 1 línea (`nova-start` → ... → `nova-wrap`)

## Convenciones

- Sin incidencias. Markdown consistente con el estilo previo del archivo.

## ADRs

- ADR-0001: no aplica (no toca install.sh)
- ADR-0002: no aplica (no toca naming)
- Sin conflictos

## Riesgos

- La sección "Memoria arquitectónica" se eliminó. El LLM ya no ve explícitamente
  las rutas `.docs/services/`, `.docs/adr/`, `.docs/glossary.md` en CLAUDE.md.
  Mitigación: `load-context` carga esas rutas al inicio de cada ticket — no es
  información que el LLM necesite en frío, sino en el momento de trabajar.

## Bloqueantes

- Ninguno

## Sugerencias

- Ninguna

## Veredicto

✓ Listo para /nova-wrap
