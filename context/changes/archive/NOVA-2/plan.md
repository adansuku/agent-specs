# Plan: NOVA-2

## Estrategia
Crear `novaspec/agents/context-loader.md` con la lógica de `load-context` adaptada para subagente (recibe servicios como input, devuelve resumen estructurado). Luego actualizar `nova-start.md` para invocar el agente en lugar de la skill. Finalmente eliminar `novaspec/skills/load-context/`. El output del agente mantiene paridad con el resumen actual de la skill.

## Archivos a tocar
- `novaspec/commands/nova-start.md`: reemplazar invocación de skill por invocación del agente con lista de servicios

## Archivos nuevos
- `novaspec/agents/context-loader.md`: lógica de carga de contexto como subagente

## Archivos a eliminar
- `novaspec/skills/load-context/SKILL.md`
- `novaspec/skills/load-context/` (directorio)

## Dependencias entre cambios
1. Crear el agente (T2) — base de todo lo demás
2. Actualizar `nova-start.md` (T3) — depende de T2
3. Eliminar la skill (T4) — después de verificar que nova-start funciona sin ella

## Safety net
- Reversibilidad: `git checkout novaspec/commands/nova-start.md` + `git checkout novaspec/skills/load-context/`
- Qué puede romperse: repos instalados con symlink `.claude/skills/load-context → ../novaspec/skills/load-context` quedarán con symlink roto tras `install.sh`
- Plan de rollback: `git revert` del commit

## Characterization tests
- [ ] Documentar el output actual de `load-context` invocada manualmente (formato exacto del resumen de 4 bloques)

## Verificación
- `/nova-start` ejecutado end-to-end produce el mismo resumen de 4 bloques sin cargar CONTEXT.md inline
- El hilo principal no contiene el contenido raw de los CONTEXT.md
