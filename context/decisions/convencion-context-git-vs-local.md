# Convención: qué de `context/` y anexos va en git vs en local

**Fecha**: 2026-04-22
**Ticket**: NOVA-38
**Estado**: Aceptada

## Decisión

Todo lo que vive bajo `context/` y los anexos del repo se clasifica por una pregunta: **¿es coordinación de equipo o configuración/scratch personal?**

| Va en git (coordinación) | Va en local (personal/config) |
|---|---|
| `context/decisions/` | `context/backlog/*` |
| `context/gotchas/` | `notes.md` |
| `context/services/` | `.env` |
| `context/changes/active/` | `novaspec/config.yml` (real) |
| `context/changes/archive/` | `.claude/*`, `.opencode/*` (symlinks y settings) |
| `novaspec/config.example.yml` | `.DS_Store`, `*.swp`, `*.swo` |
| `README.md`, `CONTRIBUTING.md`, `INSTALL.md`, `CHANGELOG.md`, `AGENTS.md`, `CLAUDE.md`, `install.sh` | |

Aplica al repo `nova-spec` **y a cualquier proyecto consumidor** que instale el framework.

## Por qué

- **`context/changes/active/` va en git** aunque esté "in-flight": las specs son coordinación del equipo, no borrador personal. El equipo necesita leer qué estás proponiendo antes de que archives.
- **`context/changes/archive/` va en git** y es, además, el mejor marketing: ejemplos reales de cómo se usó el framework.
- **`context/backlog/` es local** porque es notas crudas del maintainer antes de que se conviertan en ticket. Si algo vale la pena compartir, se convierte en ticket y spec.
- **`novaspec/config.yml` es local** porque contiene URL/email/token reales del Jira del consumidor. El distribuible es `novaspec/config.example.yml`.
- **`.env` siempre local** — axioma.

## Alternativas descartadas

- **Todo en git** → filtra tokens, dumps, notas crudas. Fácil que un secreto termine en historial público.
- **Solo `decisions/` y `gotchas/` en git, resto local** → el equipo pierde coordinación sobre specs en curso; el dogfood deja de funcionar como ejemplo externo.
- **`context/changes/active/` gitignored hasta el archive** → obliga a "preparar" la spec antes de mostrarla; rompe el ciclo `/nova-spec → revisión humana → /nova-build` que depende de ver el artefacto en disco.

## Coste aceptado

- Un consumidor nuevo que no lea esta ADR puede commitear su `notes.md` o `.env` sin querer. Mitigación: el `.gitignore` que instala `install.sh` ya cubre los casos conocidos; cualquier hueco se corrige con una línea.
- `context/changes/active/` en git expone trabajo inacabado. Aceptado: trabajo inacabado con ticket es trabajo del equipo, no del individuo.

## Consecuencias

- `install.sh` genera un bloque `# nova-spec (local) … # /nova-spec` en el `.gitignore` del destino que cubre los ítems de la columna "local". La operación es idempotente: si el bloque ya existe, no se duplica.
- Cualquier archivo nuevo bajo `context/` se clasifica respondiendo a la pregunta de arriba antes de commitear.
