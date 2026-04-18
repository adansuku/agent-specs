# Servicio: agex

## Qué hace

agex es un framework de **Spec-Driven Development (SDD)** que estructura
el ciclo de trabajo de Claude Code en proyectos de software. Convierte
tickets de Jira en Pull Requests con specs cerradas, memoria arquitectónica
viva y trazabilidad end-to-end.

## Por qué existe

Los tickets llegan vagos, el contexto arquitectónico vive en la cabeza
de las personas y las decisiones se pierden. agex fuerza un flujo donde
las decisiones se cierran antes de escribir código, el contexto se carga
automáticamente y cada cambio alimenta la memoria del sistema.

## Interfaz con el usuario

agex se usa a través de 6 slash commands en Claude Code:

| Comando | Qué hace |
|---|---|
| `/sdd-start <TICKET>` | Baja ticket, clasifica, crea rama, carga contexto |
| `/sdd-spec` | Cierra decisiones y genera la spec del cambio |
| `/sdd-plan` | Traduce la spec en plan ejecutable y lista de tareas |
| `/sdd-do` | Implementa tareas una a una con review incremental |
| `/sdd-review` | Code review final contra spec, ADRs y convenciones; persiste `review.md` |
| `/sdd-wrap` | Actualiza memoria, archiva spec, commit y PR |
| `/sdd-status [TICKET-ID]` | Muestra el estado actual de un ticket en el flujo (solo lectura) |

Cada comando (excepto `/sdd-start`) tiene un bloque **Guardrail** que valida
que el paso anterior se completó antes de ejecutarse. Si la precondición no
se cumple, el agente emite `⛔ Guardrail: <motivo>` y se detiene.

Los tickets clasificados como `quick-fix` saltan `/sdd-spec` y `/sdd-plan`.

## Componentes

### Comandos (`/.spec/commands/`)

Seis archivos Markdown con frontmatter YAML. Claude Code los descubre
a través del symlink `.claude/commands → ../.spec/commands`.

- `sdd-start.md` — orquestador de inicio; clasifica el ticket y crea rama
- `sdd-spec.md` — usa la skill `close-requirement`; genera `proposal.md`
- `sdd-plan.md` — genera `plan.md` y `tasks.md` a partir de la spec
- `sdd-do.md` — ejecuta `tasks.md` tarea a tarea con review incremental
- `sdd-review.md` — revisa en 4 ejes: spec, convenciones, ADRs, riesgos
- `sdd-wrap.md` — alimenta memoria, archiva spec, crea commit y PR
- `sdd-status.md` — comando de solo lectura; infiere y reporta el estado actual de un ticket

### Skills (`/.spec/skills/`)

Cuatro skills autocargadas por contexto. Claude Code las descubre
a través del symlink `.claude/skills → ../.spec/skills`.

- `load-context` — carga CONTEXT.md, ADRs y specs relevantes al inicio
- `close-requirement` — cierra decisiones abiertas con preguntas estructuradas
- `write-adr` — crea Architectural Decision Records en `.docs/adr/`
- `update-service-context` — actualiza CONTEXT.md de un servicio al cerrar ticket

### Configuración (`.spec/config.yml`)

```yaml
branch:
  pattern: "{type}/{ticket}-{slug}"
  types:
    quick-fix: fix
    feature: feature
    architecture: arch
  ticket_case: upper
```

### Agentes (`.spec/agents/`)

Directorio vacío reservado para sub-agentes futuros.

## Dependencias

### De las que depende

- **Claude Code**: runtime que ejecuta los comandos y skills
- **Git**: creación de ramas y commits
- **Bash**: script de instalación (`install.sh`)
- **Jira** (opcional): skill `jira-integration` para bajar tickets automáticamente

### Que dependen de este

- Cualquier repo destino donde esté instalado agex. El framework es
  instalable en múltiples repos mediante `install.sh`.

## Instalación

El script `install.sh` (en la raíz del repo agex) crea en el repo destino:

1. La estructura `.spec/` con comandos, skills y config
2. La estructura `.docs/` con subdirectorios de memoria
3. El `CLAUDE.md` que ancla el repo para Claude Code
4. Los symlinks en `.claude/` que apuntan a `.spec/`

Los symlinks son el mecanismo por el que Claude Code descubre los comandos
y skills: `.claude/commands → ../.spec/commands`, etc.

El script es idempotente: puede ejecutarse varias veces sin romper
instalaciones existentes. No toca `.docs/`, `notes.md` ni los archivos
de trabajo en `.docs/changes/`.

## Memoria arquitectónica generada

Cada ejecución del flujo produce artefactos en `.docs/`:

| Artefacto | Dónde | Ciclo de vida |
|---|---|---|
| spec en curso | `.docs/changes/<ticket>/proposal.md` | Hasta cerrar el ticket |
| plan en curso | `.docs/changes/<ticket>/plan.md` | Hasta cerrar el ticket |
| tareas | `.docs/changes/<ticket>/tasks.md` | Hasta cerrar el ticket |
| spec archivada | `.docs/changes/archive/<ticket>/` | Permanente |
| ADRs | `.docs/adr/` | Permanente |
| CONTEXT.md de servicio | `.docs/services/<servicio>/` | Actualizable |

## Decisiones clave

- **Symlinks en lugar de copias**: `.claude/` contiene symlinks hacia
  `.spec/` para que Claude Code descubra comandos y skills. Elegido sobre
  copiar archivos para evitar divergencia entre la fuente y lo que ve el
  agente.

- **`.docs/` como contenedor único de memoria**: toda la memoria
  arquitectónica (ADRs, CONTEXT.md, specs, cambios en curso) vive bajo
  `.docs/`. La alternativa anterior (`openspec/`) se eliminó por ser
  redundante.

- **Separación canónico/symlink**: el contenido vive en `.spec/` (canónico
  y versionado), mientras que `.claude/` solo tiene symlinks. Esto permite
  actualizar el framework sin tocar `.claude/`.

- **Checkpoints humanos obligatorios**: después de `/sdd-spec` y antes de
  `/sdd-wrap`. El flujo no avanza automáticamente en esos puntos.

- **Guardrails por paso**: desde AGEX-002, cada comando `/sdd-*` (excepto
  `/sdd-start`) valida activamente que el paso anterior se completó antes
  de ejecutarse. La detección se basa en: rama git activa con patrón de
  ticket, existencia de artefactos (`proposal.md`, `plan.md`, `tasks.md`,
  `review.md`) y estado de los checkboxes en `tasks.md`. El error tiene
  prefijo `⛔ Guardrail:` e indica qué comando ejecutar.

- **`quick-fix` como tipo ligero**: los cambios menores saltan spec y plan
  para reducir fricción, manteniendo el commit y la actualización de
  memoria en `/sdd-wrap`.

- **Idioma**: todo en español. Coherente con el equipo y el contexto
  de uso actual.

## Peculiaridades conocidas

- El nombre del framework cambió de `libnova.spec` a `agex` (Agent
  Experience) durante el piloto. El `install.sh` todavía contiene
  referencias a `libnova.spec` en comentarios y en el header del script
  (bug conocido, pendiente de limpiar en ticket posterior).

- El prefijo de tickets era `LNS-` (libnova) y pasó a `AGEX-`. Los
  archivos del ticket piloto LNS-001 fueron borrados en AGEX-001.

- `notes.md` en la raíz es el cuaderno de feedback del piloto: cualquier
  observación sobre el framework durante su uso se anota ahí.

## Última actualización

2026-04-18 — AGEX-003
