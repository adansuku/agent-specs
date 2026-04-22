# nova-spec

## Qué hace

Framework de Spec-Driven Development sobre Claude Code. Convierte tickets de Jira en PRs con spec cerrada, memoria arquitectónica atómica y trazabilidad end-to-end.

## Interfaces públicas

8 slash commands en Claude Code:

| Comando | Qué hace |
|---|---|
| `/nova-init` | Bootstrap one-off de `context/services/` escaneando el repo (genera borradores) |
| `/nova-start <TICKET>` | Baja ticket, clasifica, crea rama, carga contexto |
| `/nova-spec` | Cierra decisiones y genera la spec |
| `/nova-plan` | Traduce spec en plan + tareas |
| `/nova-build` | Implementa tareas una a una con review incremental |
| `/nova-review` | Code review final contra spec, decisiones y convenciones |
| `/nova-wrap` | Actualiza memoria, archiva spec, commit y PR |
| `/nova-status [TICKET]` | Estado actual de un ticket (solo lectura) |

Los `quick-fix` saltan `/nova-spec` y `/nova-plan`. `/nova-init` es opcional: se usa una vez al instalar nova-spec en un repo existente para sembrar `context/services/`.

## Estructura física

- `novaspec/commands/` — slash commands (8 archivos markdown)
- `novaspec/skills/` — skills autocargadas por contexto (`close-requirement`, `write-decision`, `update-service-context`, `jira-integration`)
- `novaspec/agents/` — subagentes para operaciones pesadas (`context-loader`, `nova-review-agent`)
- `novaspec/guardrails/` — precondiciones compartidas referenciadas por los comandos
- `novaspec/templates/` — skeletons de artefactos (proposal, tasks, review, commit, pr-body, ticket-summary, status-report, init-project, init-service)
- `novaspec/config.example.yml` — plantilla versionada; `install.sh` la copia a `novaspec/config.yml` (gitignored) en instalación limpia.

## Lo que no es obvio

- `.claude/commands` y `.claude/skills` son **symlinks** a `novaspec/`, no copias. Ver → `decisions/symlinks-vs-copia.md`.
- El directorio `context/` es la memoria arquitectónica: `decisions/` (por qué), `gotchas/` (trampas), `services/<svc>.md` (mapa corto), `changes/` (specs activas/archivadas). `archived/` dentro de `decisions/` existe pero **los agentes nunca la auto-cargan**.
- Cada `/nova-*` (excepto `/nova-start`) valida precondiciones con un guardrail markdown. Ver → `decisions/guardrails-por-paso.md`.
- Subagentes se usan cuando la operación cargaría >2 artefactos voluminosos (diff, decisions, specs). Ver → `decisions/patron-subagentes.md`.
- `install.sh` **copia** `novaspec/`, `CLAUDE.md` y `AGENTS.md` al repo destino desde su ubicación fuente; excluye `novaspec/config.yml` del maintainer y bootstrap-ea el del destino desde `config.example.yml` (o preserva el existente en reinstalación); `.claude/` se recrea con symlinks. Aborta si se ejecuta dentro del propio repo nova-spec. Ver → `decisions/install-sh-copia-desde-fuente.md`.
- Todo en español.

## Decisiones relevantes

- → `decisions/context-contenedor-unico-memoria.md`
- → `decisions/symlinks-vs-copia.md`
- → `decisions/guardrails-por-paso.md`
- → `decisions/checkpoints-humanos-obligatorios.md`
- → `decisions/templates-externos-a-comandos.md`
- → `decisions/patron-subagentes.md`
- → `decisions/install-sh-copia-desde-fuente.md`
- → `decisions/naming-nova-spec.md`
- → `decisions/quick-fix-salta-spec-y-plan.md`
- → `decisions/repo-unico-vs-split.md`
- → `decisions/convencion-context-git-vs-local.md`

## Dependencias

Claude Code (runtime), Git (ramas/commits), Bash (`install.sh`), Jira vía skill `jira-integration` (opcional).
