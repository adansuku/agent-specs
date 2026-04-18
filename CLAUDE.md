# Proyecto con libnova.spec

Este repo usa el flujo **libnova.spec** (SDD) para cualquier cambio no trivial.

## Memoria arquitectónica

Antes de empezar cualquier ticket, carga el contexto relevante:

1. `.docs/services/<servicio>/CONTEXT.md` — qué hace cada servicio
2. `.docs/adr/` — decisiones arquitectónicas vigentes
3. `.docs/specs/` — specs consolidadas (source of truth)
4. `.docs/glossary.md` — términos del dominio

## Flujo de trabajo

```
/sdd-start <TICKET>    Arranca el flujo, clasifica, carga contexto
/sdd-spec              Genera la spec (qué cambia y por qué)
/sdd-plan              Genera plan y tareas
/sdd-do                Implementa tareas
/sdd-review            Valida spec, convenciones y ADRs
/sdd-wrap              Actualiza memoria, commit y PR
```

Los cambios en curso viven en `.docs/changes/<ticket-id>/`.
Al cerrar, se archivan en `.docs/changes/archive/`.

Tickets `quick-fix` saltan `/sdd-spec` y `/sdd-plan`.

`/sdd-plan` invoca la skill `collaborative-decision` para cerrar contigo
tres decisiones (estrategia, granularidad, safety net) antes de redactar
el plan. Es la primera skill horizontal del framework: pensada para ser
reutilizada por cualquier comando que necesite cerrar un punto de
decisión con el desarrollador en vez de resolverlo en silencio.

## Configuración

La configuración del flujo vive en `.spec/config.yml`.

## Reglas

- No inventes contexto. Si falta un CONTEXT.md, dilo.
- Checkpoints humanos después de `/sdd-spec` y antes de `/sdd-wrap`.
- Alimenta la memoria al cerrar.
- No uses comandos fuera de orden.
- **Carpetas y ficheros se nombran siempre en inglés**, aunque el
  contenido esté en español. Aplica a todo el repo: skills, ADRs,
  specs, archivos de servicio, etc.
