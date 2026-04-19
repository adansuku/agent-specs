# Proyecto con nova-spec

Este repo usa el flujo **nova-spec** (SDD) para cualquier cambio no trivial.

## Memoria arquitectónica

Antes de empezar cualquier ticket, carga el contexto relevante:

1. `.docs/services/<servicio>/CONTEXT.md` — qué hace cada servicio
2. `.docs/adr/` — decisiones arquitectónicas vigentes
3. `.docs/glossary.md` — términos del dominio

## Flujo de trabajo

```
/nova-start <TICKET>      Arranca el flujo, clasifica, carga contexto
/nova-spec                Genera la spec (qué cambia y por qué)
/nova-plan                Genera plan y tareas
/nova-build               Implementa tareas
/nova-review              Valida spec, convenciones y ADRs
/nova-wrap                Actualiza memoria, commit y PR
/nova-status [TICKET-ID]  Muestra el estado actual del ticket (solo lectura)
```

Los cambios en curso viven en `.docs/changes/active/<ticket-id>/`.
Al cerrar, se archivan en `.docs/changes/archive/`.

Tickets `quick-fix` saltan `/nova-spec` y `/nova-plan`.

## Configuración

La configuración del flujo vive en `novaspec/config.yml`.

## Reglas

- No inventes contexto. Si falta un CONTEXT.md, dilo.
- Checkpoints humanos después de `/nova-spec` y antes de `/nova-wrap`.
- Alimenta la memoria al cerrar.
- No uses comandos fuera de orden.
