# Contribuir a nova-spec

nova-spec es un framework opinado de Spec-Driven Development sobre Claude Code. Pensado para equipos pequeños; las contribuciones externas son bienvenidas pero valoramos más un issue bien planteado que un PR grande.

## Antes de escribir código

1. Abre un issue en GitHub describiendo el problema o propuesta. Si ya tienes ticket en Jira (proyecto `NOVA`), pégalo en el issue.
2. Espera feedback si el cambio es > 30 minutos. Para cambios obvios (typos, fixes de docs) puedes ir directo a PR.

## Flujo

nova-spec se dogfoodea a sí mismo. Para cambios no triviales:

```bash
/nova-start <TICKET>   # baja contexto y crea rama
/nova-spec             # cierra decisiones, genera proposal.md
/nova-plan             # plan.md + tasks.md
/nova-build            # implementa tarea a tarea
/nova-review           # review contra spec y convenciones
/nova-wrap             # actualiza memoria, commit y PR
```

Para fixes pequeños salta `/nova-spec` y `/nova-plan` — el ticket los marca como `quick-fix`.

## Convención de ramas

- `feature/<TICKET>-<slug-kebab>` — nueva capacidad.
- `fix/<TICKET>-<slug-kebab>` — corrección de bug.
- `arch/<TICKET>-<slug-kebab>` — cambio de arquitectura, requiere ADR.

Base: `develop`. `main` se actualiza desde `develop` en release.

## Qué va en git y qué no

Ver `context/decisions/convencion-context-git-vs-local.md`. TL;DR:
- Coordinación del equipo (decisions, gotchas, services, changes) → git.
- Scratch personal, `.env`, `config.yml` real, symlinks → local (`.gitignore`).

## Estilo

- **Español**. El framework se escribe en español.
- Markdown atómico: un hecho por archivo bajo `context/decisions/`; nombre = índice (p. ej. `symlinks-vs-copia.md`, no `ADR-0042.md`).
- Sin frontmatter en memoria, sin numeración global.
- Commits convencionales (`feat:`, `fix:`, `refactor:`, `docs:`, `chore:`).

## Tests

No hay suite automatizada. La verificación es el smoke test manual documentado en cada `proposal.md` y la review humana.

## Preguntas

Abre un issue con la etiqueta `question` o pregunta en el ticket de Jira correspondiente.
