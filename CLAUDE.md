# Proyecto con agex

Este repo usa el flujo **agex** (SDD) para cualquier cambio no trivial.

## Memoria arquitectónica

Antes de empezar cualquier ticket, carga el contexto relevante:

1. `.docs/services/<servicio>/CONTEXT.md` — qué hace cada servicio
2. `.docs/adr/` — decisiones arquitectónicas vigentes
3. `.docs/glossary.md` — términos del dominio

## Flujo de trabajo

```
/sdd-start <TICKET>       Arranca el flujo, clasifica, carga contexto
/sdd-spec                 Genera la spec (qué cambia y por qué)
/sdd-plan                 Genera plan y tareas
/sdd-do                   Implementa tareas
/sdd-review               Valida spec, convenciones y ADRs
/sdd-wrap                 Actualiza memoria, commit y PR
/sdd-status [TICKET-ID]   Muestra el estado actual del ticket (solo lectura)
```

Los cambios en curso viven en `.docs/changes/active/<ticket-id>/`.
Al cerrar, se archivan en `.docs/changes/archive/`.

Tickets `quick-fix` saltan `/sdd-spec` y `/sdd-plan`.

## Configuración

La configuración del flujo vive en `.spec/config.yml`.

## Reglas

- No inventes contexto. Si falta un CONTEXT.md, dilo.
- Checkpoints humanos después de `/sdd-spec` y antes de `/sdd-wrap`.
- Alimenta la memoria al cerrar.
- No uses comandos fuera de orden.
