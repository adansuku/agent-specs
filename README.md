# agex

> **Agent Experience (AX)** — análogo a DX (Developer Experience), pero
> aplicado a cómo los agentes de IA operan en tu sistema: qué contexto
> encuentran, qué herramientas tienen disponibles y qué memoria acumulan
> entre sesiones.

Framework de **Spec-Driven Development (SDD)** que estructura el ciclo
de trabajo de Claude Code en proyectos de software.

Convierte tickets de Jira en Pull Requests con specs cerradas, memoria
arquitectónica viva y trazabilidad end-to-end.

---

## Por qué existe

Los tickets llegan vagos. El contexto arquitectónico vive en la cabeza
de quien lleva más tiempo. Las decisiones se pierden. Los juniors tardan
semanas en ser productivos. Cada cambio empieza desde cero.

agex fuerza un flujo donde:

- Las decisiones se cierran **antes** de escribir código
- El contexto arquitectónico se carga **automáticamente**
- Cada cambio **alimenta la memoria** del sistema
- Los tickets se clasifican y siguen el nivel de ceremonia adecuado

---

## Flujo de 7 comandos

```
/sdd-start  →  /sdd-spec  →  /sdd-plan  →  /sdd-do  →  /sdd-review  →  /sdd-wrap
```

| Comando | Qué hace | Skills que usa |
|---|---|---|
| `/sdd-start <TICKET>` | Baja ticket, clasifica, crea rama, carga contexto | `jira-integration`, `load-context` |
| `/sdd-spec` | Cierra decisiones y genera la spec | `close-requirement` |
| `/sdd-plan` | Genera plan y lista de tareas | — |
| `/sdd-do` | Implementa tareas una a una con review incremental | — |
| `/sdd-review` | Code review final contra spec, ADRs y convenciones | — |
| `/sdd-wrap` | Actualiza memoria, archiva spec, commit y PR | `write-adr`, `update-service-context` |
| `/sdd-status [TICKET-ID]` | Muestra el estado actual del ticket (solo lectura) | — |

Los quick-fix saltan `/sdd-spec` y `/sdd-plan`.

---

## Mapeo al ciclo SDD clásico

```
Ticket Jira
    ↓
/sdd-start                    (jira-reviewer + carga de contexto)
    ↓
/sdd-spec                     (prepare the .spec — cierra decisiones)
    ↓
/sdd-plan                     (prepare the tasks)
    ↓
┌── /sdd-do ────────────────┐
│   execute → review         │
│   ↓                        │
│   is task done? ──no──┐    │
│   ↓ yes               │    │
└───────────────────────┘    │
    ↓                        │
/sdd-review                   (code review)
    ↓
/sdd-wrap                     (commit + PR + memoria)
```

---

## Estructura del repo

```
.
├── CLAUDE.md                    Ancla del repo, lo primero que Claude lee
│
├── .spec/                       Contenido canónico del framework
│   ├── config.yml               Convenciones configurables (ramas, etc.)
│   ├── commands/                Slash commands /sdd-*
│   ├── skills/                  Skills autocargadas por contexto
│   └── agents/                  Sub-agents (opcional)
│
├── .claude/                     Symlinks a .spec para Claude Code
│   ├── commands -> ../.spec/commands
│   ├── skills   -> ../.spec/skills
│   └── agents   -> ../.spec/agents
│
└── .docs/                       Memoria arquitectónica y specs
    ├── adr/                     Architectural Decision Records
    ├── services/                CONTEXT.md + decisions + incidents por servicio
    ├── specs/                   Source of truth (specs consolidadas)
    ├── changes/
    │   ├── active/              Specs en curso (tickets abiertos)
    │   └── archive/             Specs archivadas al cerrar ticket
    ├── post-mortems/
    └── glossary.md              Términos del dominio
```

---

## Clasificación de tickets

`/sdd-start` clasifica cada ticket en una de tres categorías:

| Tipo | Cuándo | Flujo |
|---|---|---|
| **quick-fix** | Bug menor, typo, config. < 2h | `/sdd-start → /sdd-do → /sdd-wrap` |
| **feature** | Funcionalidad acotada, refactor. 2h-3d | Flujo completo de 6 pasos |
| **architecture** | Migración, rewrite, decisión de calado. > 3d | Flujo completo + ADR obligatorio |

---

## Capas de memoria

| Capa | Dónde vive | Ciclo de vida |
|---|---|---|
| **Sesión** | Contexto de Claude Code | Horas |
| **Proyecto** | `.docs/changes/active/<ticket>/` | Semanas |
| **Sistema** | `.docs/adr/`, `.docs/services/`, `.docs/specs/` | Años |
| **Organización** | Repo base del framework (plantillas) | Permanente |

La capa de sistema se alimenta automáticamente en `/sdd-wrap`.
Sin ese paso, el sistema no aprende.

---

## Requisitos

- Claude Code instalado
- Git
- Opcional: acceso a Jira para la skill `jira-integration`

---

## Primer uso

Ver [INSTALL.md](./INSTALL.md) para instrucciones de instalación completas.

Resumen:

1. Ejecutar `bash install.sh` en el repo destino
2. Verificar los symlinks de `.claude/`
3. Abrir Claude Code en la raíz del proyecto
4. Empezar con un ticket pequeño: `/sdd-start TICKET-ID`

---

## Reglas no negociables

- **No saltar pasos.** El orden existe por diseño.
- **No inventar contexto.** Si falta documentación, preguntar.
- **Checkpoints humanos** después de `/sdd-spec` y antes de `/sdd-wrap`.
- **Alimentar memoria al cerrar.** Sin esto, el sistema no escala.

---

## Estado

Versión inicial. En piloto. El feedback se anota en `notes.md` conforme
aparece, para iterar con datos reales y no con teoría.