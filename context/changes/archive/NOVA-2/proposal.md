<!-- Mantén esta spec ≤ 60 líneas. Bullets y tablas, no prosa. Se carga en cada turno de nova-build. -->
# NOVA-2: Convertir load-context en subagente

## Historia
Como usuario de nova-spec, quiero que la carga de contexto ocurra en un agente aislado, para que los CONTEXT.md y ADRs no contaminen el hilo principal.

## Objetivo
Aislar la lectura de servicios y ADRs en un contexto separado; el hilo principal solo recibe el resumen estructurado.

## Contexto
La skill `load-context` (51 LOC) lee múltiples CONTEXT.md y ADRs directamente en el contexto del orquestador. Todo ese material persiste durante todo el flujo aunque solo se use el resumen final.

## Alcance
### En alcance
- Crear `novaspec/agents/context-loader.md`: recibe lista de servicios, devuelve resumen estructurado (CONTEXT.md + ADRs + Huecos + Preguntas)
- Actualizar `nova-start.md`: invocar el agente en lugar de la skill, pasarle los servicios identificados
- Eliminar `novaspec/skills/load-context/` (directorio y SKILL.md)
- Actualizar `CONTEXT.md` del servicio agex en `/nova-wrap`

### Fuera de alcance
- Cambios en `install.sh` (copia `novaspec/` entero; la eliminación de la skill se propaga automáticamente)
- Cambios en otros comandos del flujo

## Decisiones cerradas
- Agente devuelve texto al padre (no escribe archivo en disco)
- `nova-start` pasa la lista de servicios como input al agente
- Skill `load-context` se elimina; `nova-start` referencia el agente por ruta directamente
- Resumen incluye: CONTEXT.md de cada servicio + ADRs relevantes + Huecos + Preguntas

## Comportamiento esperado
- Normal: `nova-start` identifica servicios → lanza `context-loader` con lista → agente lee artefactos → devuelve resumen → `nova-start` lo muestra al usuario
- Edge: servicio sin CONTEXT.md → agente lo reporta en "Huecos" y continúa
- Fallo: si `.docs/services/` no existe, el agente avisa y devuelve resumen vacío sin bloquear

## Output esperado
- `novaspec/agents/context-loader.md` (nuevo)
- `nova-start.md` actualizado (invoca agente, elimina referencia a skill)
- `novaspec/skills/load-context/` eliminado

## Criterios de éxito
- El hilo principal no contiene el contenido de CONTEXT.md ni ADRs tras ejecutar `/nova-start`
- El resumen devuelto tiene los mismos 4 bloques que la skill actual (Servicios, ADRs, Huecos, Preguntas)
- `/nova-start` funciona end-to-end sin la skill `load-context`

## Impacto arquitectónico
- Servicios afectados: agex
- ADRs referenciados: ADR-0001, ADR-0002, patrón KAN-1
- ¿Requiere ADR nuevo?: no — patrón subagente ya establecido en KAN-1

## Verificación sin tests automatizados
### Flujo manual
1. Ejecutar `/nova-start <ticket>` en un repo con `load-context` eliminada
2. Verificar que el hilo principal muestra solo el resumen estructurado
3. Verificar que los 4 bloques del resumen están presentes

### Qué mirar
- API/UI: resumen con secciones Servicios, ADRs, Huecos, Preguntas

## Riesgos
- Repos instalados con versión anterior tienen `load-context` en `.claude/skills/` como symlink: al actualizar con `install.sh` el symlink apuntará a un directorio eliminado → documentar en CHANGELOG
