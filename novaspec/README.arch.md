# nova-spec Architecture

## Propósito

Framework de Spec-Driven Development (SDD) que estructura el ciclo ticket→PR paraClaude Code.

## Por qué existe

- Tickets llegan vagos
- Contexto arquitectónico vive en cabeza de seniors
- Decisiones se pierden entre sesiones
- Juniors tardan semanas en ser productivos

## Flujo SDD

```
Ticket → /nova-start → /nova-spec → /nova-plan 
→ /nova-build → /nova-review → /nova-wrap → PR
```

## Capas de memoria

| Capa | Dónde | Ciclo |
|------|-------|-------|
| Sesión | Contexto de Claude Code | Horas |
| Proyecto | `context/changes/active/` | Semanas |
| Sistema | `context/adr/`, `context/services/` | Años |
| Org | Repo base (plantillas) | Permanente |

## Clasificación de tickets

| Tipo | Cuándo | Flujo |
|------|-------|-------|
| quick-fix | Bug < 2h | start→build→wrap |
| feature | Funcionalidad 2h-3d | Completo |
| architecture | Rewrite > 3d | Completo + ADR obligatorio |

## No negociables

1. No saltar pasos (orden existe por diseño)
2. No inventar contexto (preguntar si falta)
3. Checkpoints humanos tras spec y antes wrap
4. Alimentar memoria al cerrar

## Extensible

- Agregar skills en `novaspec/skills/`
- Agregar commands en `novaspec/commands/`
- Templates en `novaspec/templates/`
- Config en `novaspec/config.yml`