# Servicio: nova-spec

## Qué hace

nova-spec es un framework de **Spec-Driven Development (SDD)** que estructura
el ciclo de trabajo de Claude Code en proyectos de software. Convierte
tickets de Jira en Pull Requests con specs cerradas, memoria arquitectónica
viva y trazabilidad end-to-end.

## Por qué existe

Los tickets llegan vagos, el contexto arquitectónico vive en la cabeza
de las personas y las decisiones se pierden. nova-spec fuerza un flujo donde
las decisiones se cierran antes de escribir código, el contexto se carga
automáticamente y cada cambio alimenta la memoria del sistema.

## Interfaz con el usuario

nova-spec se usa a través de 7 slash commands en Claude Code:

| Comando | Qué hace |
|---|---|
| `/nova-start <TICKET>` | Baja ticket, clasifica, crea rama, carga contexto |
| `/nova-spec` | Cierra decisiones y genera la spec del cambio |
| `/nova-plan` | Traduce la spec en plan ejecutable y lista de tareas |
| `/nova-build` | Implementa tareas una a una con review incremental |
| `/nova-review` | Code review final contra spec, ADRs y convenciones; persiste `review.md` |
| `/nova-wrap` | Actualiza memoria, archiva spec, commit y PR |
| `/nova-status [TICKET-ID]` | Muestra el estado actual de un ticket en el flujo (solo lectura) |

Cada comando (excepto `/nova-start`) tiene un bloque **Guardrail** que valida
que el paso anterior se completó antes de ejecutarse. Si la precondición no
se cumple, el agente emite `⛔ Guardrail: <motivo>` y se detiene.

Los tickets clasificados como `quick-fix` saltan `/nova-spec` y `/nova-plan`.

## Componentes

### Comandos (`novaspec/commands/`)

Siete archivos Markdown con frontmatter YAML. Claude Code los descubre
a través del symlink `.claude/commands → ../novaspec/commands`.

- `nova-start.md` — orquestador de inicio; clasifica el ticket, crea rama e invoca el agente `context-loader`
- `nova-spec.md` — usa la skill `close-requirement`; genera `proposal.md`
- `nova-plan.md` — genera `plan.md` y `tasks.md` a partir de la spec
- `nova-build.md` — ejecuta `tasks.md` en secuencia; para solo ante bloqueantes o decisiones no cerradas
- `nova-review.md` — lanza el agente `nova-review-agent` con el ticket-id; muestra el veredicto
- `nova-wrap.md` — alimenta memoria, archiva spec, crea commit y PR
- `nova-status.md` — comando de solo lectura; infiere y reporta el estado actual de un ticket

### Skills (`novaspec/skills/`)

Tres skills autocargadas por contexto. Claude Code las descubre
a través del symlink `.claude/skills → ../novaspec/skills`.

- `close-requirement` — cierra decisiones abiertas con preguntas estructuradas
- `write-adr` — crea Architectural Decision Records en `.docs/adr/`
- `update-service-context` — actualiza CONTEXT.md de un servicio al cerrar ticket

### Templates (`novaspec/templates/`)

Ocho archivos Markdown con los skeletons de salida que los comandos
referencian por ruta en lugar de incluir inline. Distribuidos con `install.sh`
vía `cp -R novaspec/`.

- `proposal.md` — skeleton de la spec (usado por `nova-spec`)
- `plan.md` — skeleton del plan (usado por `nova-plan`)
- `tasks.md` — skeleton de tareas (usado por `nova-plan`)
- `review.md` — skeleton del reporte de review (usado por `nova-review`)
- `commit.md` — template del mensaje de commit (usado por `nova-wrap`)
- `pr-body.md` — template del cuerpo del PR (usado por `nova-wrap`)
- `ticket-summary.md` — skeleton del resumen inicial (usado por `nova-start`)
- `status-report.md` — formato del reporte de estado (usado por `nova-status`)

### Configuración (`novaspec/config.yml`)

```yaml
branch:
  pattern: "{type}/{ticket}-{slug}"
  types:
    quick-fix: fix
    feature: feature
    architecture: arch
  ticket_case: upper
  base: main            # rama base del flujo
```

`branch.base` define la rama contra la que se crea cada rama de ticket
en `/nova-start` y contra la que se abre el PR en `/nova-wrap`. Si la
clave falta (instalación vieja), el framework intenta `develop` y, si
tampoco existe, pregunta al usuario recomendando fijarla en `config.yml`.

### Agentes (`novaspec/agents/`)

Ejecutan operaciones pesadas en contexto aislado (ver ADR-0003):

- `nova-review-agent.md` — code review en 4 ejes; escribe `review.md`
- `context-loader.md` — carga CONTEXT.md y ADRs; devuelve resumen estructurado

### Guardrails (`novaspec/guardrails/`)

Archivos Markdown compartidos que los comandos referencian por ruta para
validar precondiciones antes de ejecutarse. Cada archivo es autocontenido
(título, qué comprueba, mensaje `⛔ Guardrail: ...` si falla y comando de
recuperación). Los comandos los componen en orden:

- `branch-pattern.md` — detecta rama de ticket activa; extrae `<ticket-id>`.
- `proposal-exists.md` — verifica `proposal.md` (usado por `/nova-plan`).
- `plan-and-tasks-exist.md` — verifica `plan.md` y `tasks.md`; respeta la
  excepción `quick-fix` (usado por `/nova-build`).
- `all-tasks-done.md` — verifica que `tasks.md` no tiene `- [ ]` pendientes
  (usado por `/nova-review`).
- `review-approved.md` — verifica `review.md` existe y contiene la línea
  `✓ Listo para /nova-wrap` (usado por `/nova-wrap`).

Elegido sobre (a) skill parametrizable — las skills se invocan no
deterministamente por el modelo — y (b) hook en `settings.json` —
determinista pero añade bash imperativo y no se distribuye con `install.sh`.
Introducido en AGEX-010.

## Dependencias

### De las que depende

- **Claude Code**: runtime que ejecuta los comandos y skills
- **Git**: creación de ramas y commits
- **Bash**: script de instalación (`install.sh`)
- **Jira** (opcional): skill `jira-integration` para bajar tickets automáticamente

### Que dependen de este

- Cualquier repo destino donde esté instalado nova-spec. El framework es
  instalable en múltiples repos mediante `install.sh`.

## Instalación

El script `install.sh` (en la raíz del repo nova-spec) **copia** `novaspec/` y
`CLAUDE.md` desde su propia ubicación (`SCRIPT_DIR`) al repo destino
(`$PWD`) y **crea** la estructura vacía `.docs/` y los symlinks `.claude/`.

Invocación canónica desde el repo destino:

```bash
bash /ruta/a/nova-spec/install.sh
```

El script resuelve `SCRIPT_DIR` vía `cd "$(dirname "${BASH_SOURCE[0]}")" && pwd`
y aborta (`exit 1`) si no encuentra `novaspec/` y `CLAUDE.md` en `SCRIPT_DIR`,
o si se ejecuta desde dentro del propio repo nova-spec (`PWD == SCRIPT_DIR`, caso
destructivo porque `rm -rf novaspec` borraría la fuente).

Los symlinks son el mecanismo por el que Claude Code descubre los comandos
y skills: `.claude/commands → ../novaspec/commands`, etc.

El script es idempotente: puede ejecutarse varias veces. Sobrescribe `novaspec/`
y `CLAUDE.md` con la versión de la fuente. **No toca** `.docs/`, `notes.md`
ni los archivos de trabajo en `.docs/changes/`.

## Memoria arquitectónica generada

Cada ejecución del flujo produce artefactos en `.docs/`:

| Artefacto | Dónde | Ciclo de vida |
|---|---|---|
| spec en curso | `.docs/changes/active/<ticket>/proposal.md` | Hasta cerrar el ticket |
| plan en curso | `.docs/changes/active/<ticket>/plan.md` | Hasta cerrar el ticket |
| tareas | `.docs/changes/active/<ticket>/tasks.md` | Hasta cerrar el ticket |
| review | `.docs/changes/active/<ticket>/review.md` | Hasta cerrar el ticket |
| spec archivada | `.docs/changes/archive/<ticket>/` | Permanente |
| ADRs | `.docs/adr/` | Permanente |
| CONTEXT.md de servicio | `.docs/services/<servicio>/` | Actualizable |

`.docs/changes/` tiene dos hijos: `active/` (tickets en curso) y
`archive/` (tickets cerrados). `/nova-wrap` mueve la carpeta del ticket
de `active/` a `archive/`.

## Decisiones clave

- **Symlinks en lugar de copias**: `.claude/` contiene symlinks hacia
  `novaspec/` para que Claude Code descubra comandos y skills. Elegido sobre
  copiar archivos para evitar divergencia entre la fuente y lo que ve el
  agente.

- **`install.sh` copia desde la fuente** (ADR-0001, AGEX-009): el instalador
  hace `cp -R` desde `SCRIPT_DIR` en vez de embeber heredocs. Elegido sobre
  mantener heredocs tras drift probado (AGEX-004, AGEX-005, AGEX-008) y
  sobre un generador externo. Coste: requiere tener el repo nova-spec clonado
  localmente para instalar o actualizar.

- **`.docs/` como contenedor único de memoria**: toda la memoria
  arquitectónica (ADRs, CONTEXT.md, specs, cambios en curso) vive bajo
  `.docs/`. La alternativa anterior (`openspec/`) se eliminó por ser
  redundante.

- **Separación canónico/symlink**: el contenido vive en `novaspec/` (canónico
  y versionado), mientras que `.claude/` solo tiene symlinks. Esto permite
  actualizar el framework sin tocar `.claude/`.

- **Checkpoints humanos obligatorios**: después de `/nova-spec` y antes de
  `/nova-wrap`. El flujo no avanza automáticamente en esos puntos.

- **Guardrails por paso**: desde AGEX-002, cada comando `/nova-*` (excepto
  `/nova-start`) valida activamente que el paso anterior se completó antes
  de ejecutarse. La detección se basa en: rama git activa con patrón de
  ticket, existencia de artefactos (`proposal.md`, `plan.md`, `tasks.md`,
  `review.md`) y estado de los checkboxes en `tasks.md`. El error tiene
  prefijo `⛔ Guardrail:` e indica qué comando ejecutar.

- **Templates de salida** (`novaspec/templates/`, NOVA-001): los skeletons de
  formato de los artefactos generados viven en archivos externos, no inline
  en los comandos. Los comandos los referencian por ruta en texto. Mismo
  patrón de referencia que los guardrails. Reduce tokens de contexto y
  centraliza el formato en un único lugar.

- **`quick-fix` como tipo ligero**: los cambios menores saltan spec y plan
  para reducir fricción, manteniendo el commit y la actualización de
  memoria en `/nova-wrap`.

- **Naming** (ADR-0002, AGEX-016): framework renombrado de `agex` a
  `nova-spec`. Carpeta `novaspec/` (sin punto, visible). Comandos `/nova-*`
  en kebab-case, compatible con Claude Code, Gemini CLI y OpenCode.

- **Idioma**: todo en español. Coherente con el equipo y el contexto
  de uso actual.

## Peculiaridades conocidas

- El prefijo de tickets era `LNS-` (libnova), luego `AGEX-` (Agent Experience),
  y ahora los tickets nuevos usan `NOVA-`. Los archivos históricos mantienen
  sus prefijos originales como registro.

- `notes.md` en la raíz es el cuaderno de feedback del piloto: cualquier
  observación sobre el framework durante su uso se anota ahí.

## Última actualización

2026-04-19 — NOVA-001
