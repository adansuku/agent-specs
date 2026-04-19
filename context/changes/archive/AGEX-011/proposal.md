# AGEX-011: Eliminar capa .docs/specs/ (nunca usada)

## Historia
Como mantenedor del framework agex, quiero eliminar `.docs/specs/` del flujo
y de la documentación, para que el modelo mental sea más simple y sin capas fantasma.

## Objetivo
Simplificar la arquitectura de documentación eliminando una capa que no aporta
valor real y que ha generado confusión sobre dónde vive el source of truth.

## Contexto
Tras 4+ tickets archivados (AGEX-005 a AGEX-010), el directorio `.docs/specs/`
nunca fue escrito. El source of truth real son:
- `.docs/changes/active/<ticket-id>/proposal.md` — durante el desarrollo
- `.docs/changes/archive/<ticket-id>/` — tras el cierre

La capa "consolidada" era una abstracción prematura sin mecanismo de escritura
definido ni usuario real.

## Alcance
### En alcance
- Eliminar `.docs/specs/` (directorio y `.gitkeep`)
- Eliminar el paso "Consolidar en `.docs/specs/`" de `sdd-wrap.md`
- Eliminar referencias en `CLAUDE.md`, `INSTALL.md`, `README.md`
- Eliminar `specs` del `mkdir -p` en `install.sh`
- Eliminar referencias en `CONTEXT.md` y `load-context/SKILL.md` si existen

### Fuera de alcance
- Cambiar el flujo SDD (proposal/plan/tasks/review se mantienen)
- Redefinir un mecanismo alternativo de consolidación

## Decisiones cerradas
- **Opción B (eliminar)** sobre opción A (definir): la capa no ha demostrado
  valor en ningún ticket real; añadirla tiene coste de mantenimiento sin beneficio
  demostrado.
- No se crea mecanismo sustituto: si en el futuro se necesita, se diseñará con
  un caso de uso real.

## Comportamiento esperado
- Normal: `sdd-wrap` ya no tiene paso de consolidación; el cierre es más simple.
- Edge case: proyectos que ya tengan `.docs/specs/` con contenido no se ven
  afectados (agex no toca directorios existentes con contenido).
- Fallo: ninguno esperado — son cambios de texto en Markdown y shell.

## Output esperado
- `.docs/specs/` eliminado del repo y de la documentación
- `sdd-wrap.md` sin paso 4 de consolidación ni línea "Specs consolidadas"
- `install.sh` sin `specs` en el `mkdir -p`
- `CLAUDE.md`, `INSTALL.md`, `README.md` actualizados

## Criterios de éxito
- `grep -r "docs/specs" .spec/ .docs/ install.sh CLAUDE.md INSTALL.md README.md` → sin resultados relevantes
- `install.sh` ejecutado en proyecto nuevo no crea `.docs/specs/`
- Documentación coherente: no se menciona una capa que no existe

## Impacto arquitectónico
- Servicios afectados: ninguno (framework agex, no servicios de producto)
- ADRs referenciados: ADR-0001 (indirectamente — install.sh)
- ¿Requiere ADR nuevo?: no (es eliminación de abstracción sin alternativa)

## Verificación sin tests automatizados
### Flujo manual
1. Ejecutar `grep -r "docs/specs" install.sh CLAUDE.md INSTALL.md README.md .spec/`
2. Verificar que no hay resultados (salvo el directorio archive si existe)
3. Ejecutar `bash install.sh` en directorio temporal y verificar que no crea `specs/`

### Qué mirar
- Que `sdd-wrap` no mencione consolidación
- Que `CLAUDE.md` no liste `.docs/specs/` como capa de memoria
- Que los diagramas de `INSTALL.md` y `README.md` no incluyan `specs/`

## Riesgos
- Proyectos existentes con `specs/` vacío: el directorio queda huérfano pero no
  rompe nada. Mitigación: el usuario puede borrarlo manualmente si quiere.
