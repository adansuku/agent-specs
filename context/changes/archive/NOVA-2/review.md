# Review: NOVA-2

## Cumplimiento de spec

- [✓] Crear `novaspec/agents/context-loader.md`: el archivo existe con la lógica correcta; recibe `$ARGUMENTS` (lista de servicios), lee CONTEXT.md/decisions.md/incidents.md por servicio, escanea ADRs y devuelve el bloque de 4 campos (Servicios, ADRs, Huecos, Preguntas).
- [✓] Actualizar `nova-start.md` paso 5: la referencia a la skill `load-context` fue sustituida por invocación del agente `novaspec/agents/context-loader.md` con los servicios como argumentos.
- [✓] Eliminar `novaspec/skills/load-context/SKILL.md`: el archivo fue eliminado. El directorio `novaspec/skills/load-context/` ya no existe en disco.
- [✓] El resumen devuelto mantiene los mismos 4 bloques que la skill: Servicios, ADRs, Huecos, Preguntas.
- [✓] Edge case `.docs/` ausente: el agente devuelve resumen vacío sin bloquear (paso 1 del agente).
- [✗] Criterio "actualizar CONTEXT.md del servicio agex en /nova-wrap": la spec lo lista en alcance pero es explícitamente una tarea de /nova-wrap, no de esta rama. No hay violación; el criterio se cumple al momento apropiado.

## Convenciones

- `context-loader.md` sigue el mismo patrón de frontmatter (`description`, `argument-hint`) que `nova-review-agent.md`, consistente con el resto de agentes.
- La instrucción de terminación ("Devuelve solo el bloque `## Contexto cargado`") es coherente con el patrón "no interactúes con el usuario" establecido en `nova-review-agent.md`.
- La línea de cierre de `novaspec/skills/load-context/SKILL.md` en la versión original carecía de newline final (`\ No newline at end of file`). El archivo fue eliminado; no hay residuo.
- Sin dead code, prints ni imports sobrantes.

## ADRs

- **ADR-0001** (install.sh copia desde la fuente): `install.sh` copia `novaspec/` completo. Al eliminar `novaspec/skills/load-context/`, la próxima ejecución de `install.sh` ya no copiará la skill al repo destino. Comportamiento consistente con la decisión; no hay violación.
- **ADR-0002** (naming nova-spec, prefijo `/nova-*`, carpeta `novaspec/`): el nuevo agente vive en `novaspec/agents/`, se invoca por ruta directa desde `nova-start.md`. Sin conflicto.
- Sin conflictos con ADRs vigentes.

## Riesgos

- **Symlinks rotos en repos instalados previamente**: repos que ya tienen `.claude/skills/load-context → ../novaspec/skills/load-context` quedarán con symlink roto tras ejecutar `install.sh` desde la nueva fuente. La spec lo documenta explícitamente en "Riesgos" (proposal.md línea 60) y el plan lo registra como "qué puede romperse" (plan.md línea 22). El CHANGELOG debería documentar este impacto; no existe CHANGELOG.md en la rama ni hay tarea para ello en tasks.md. Es una omisión menor, no bloqueante dado que el propio ADR-0001 ya establece que actualizar requiere re-ejecutar `install.sh`.
- **Safety net implementado**: reversibilidad por `git checkout` y `git revert` documentados en plan.md. Sin cambios estructurales en install.sh ni en otros comandos del flujo.
- **Paso 5 de nova-start es instrucción para el agente orquestador**, no código ejecutable: la verificación end-to-end de que el resumen tiene 4 bloques es manual (tarea 5 en tasks.md). Esto es correcto dado el carácter markdown-first del framework.

## Bloqueantes

Ninguno.

## Sugerencias

- Considerar añadir una nota en CHANGELOG.md (o en `.docs/services/agex/CONTEXT.md`) sobre el symlink roto en instalaciones previas, dado que la spec lo identificó como riesgo conocido y actualmente no hay rastro documentado fuera de plan.md.
- `context-loader.md` paso 3 dice "Lista solo los que tengan conexión con los servicios. No fuerces conexiones." — criterio subjetivo para un agente LLM. Podría acotarse con "lista todos los ADR encontrados si hay ≤ 5; filtra por palabras clave del servicio si hay > 5", pero está fuera del alcance de esta spec.

## Veredicto

✓ Listo para /nova-wrap
