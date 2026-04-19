# Review: KAN-1

## Cumplimiento de spec

- [✓] `novaspec/agents/nova-review-agent.md` creado con lógica completa de review (4 ejes: spec, convenciones, ADRs, riesgos) y escritura de `review.md` en `.docs/changes/active/<ticket-id>/`.
- [✓] `nova-review.md` reducido a orquestación: 3 pasos (obtener ticket-id, lanzar agente, mostrar resumen). No carga diff, spec ni ADRs en el contexto principal.
- [✓] Input al subagente es solo el `ticket-id` (`$ARGUMENTS`, línea 8 del agente); el agente lee artefactos por su cuenta.
- [✓] Comportamiento edge cubierto: el agente emite `⛔ Review abortado: falta <archivo>` si faltan `proposal.md`, `plan.md` o `tasks.md` (líneas 23–26).
- [✓] Contrato de `review.md` intacto (`✓ Listo para /nova-wrap`); `review-approved.md` no requiere cambios.
- [✓] `nova-build.md` actualizado a ejecución en secuencia, parando solo ante bloqueantes (tarea 6 del plan, marcada `[x]`).
- [✓] El agente combina `git diff <branch.base>...HEAD` + `git diff HEAD` para cubrir tanto commits de la rama como cambios sin commitear (`nova-review-agent.md` paso 1, tercer bullet).
- [✗] Tareas manuales de verificación (1 y 4 en `tasks.md`) marcadas `[x]` sin evidencia documentada de ejecución. Riesgo operacional, no bloqueante de diseño.

## Convenciones

- Frontmatter YAML en `nova-review-agent.md` con `description` y `argument-hint`: consistente con el patrón de skills del repo.
- Nomenclatura `nova-review-agent.md` en `novaspec/agents/`: kebab-case conforme a ADR-0002.
- `nova-review.md` reducido mantiene la estructura estándar de comandos (frontmatter, secciones `## Guardrail`, `## Pasos`, `## Reglas`).
- `nova-build.md` sin dead code ni imports sobrantes.
- Inconsistencia menor en `nova-build.md` línea 57: "Tiene preguntas que necesitas responder" mezcla segunda persona respecto al resto del archivo. No bloqueante.

## ADRs

- **ADR-0001**: `install.sh` copia `novaspec/` completo desde la fuente. `novaspec/agents/` queda incluido automáticamente. Sin conflicto.
- **ADR-0002**: nombres kebab-case, carpeta `novaspec/` visible. `nova-review-agent.md` en `novaspec/agents/` cumple ambos criterios. Sin conflicto.

## Riesgos

- **Patrón subagente nuevo sin ADR**: `proposal.md` reconoce que podría requerirse un ADR ("primer uso del patrón subagente en el framework"). No se creó en este ticket. Riesgo bajo; la spec indica que se documentará en `CONTEXT.md` al cerrar.
- **`nova-build.md` no listado en `plan.md` como archivo a tocar**: la spec lo incluye en alcance y `tasks.md` lo recoge en tarea 6. Inconsistencia documental menor, no afecta el comportamiento.
- **`nova-review.md` no verifica existencia de `review.md` tras el agente**: si el agente falla silenciosamente, el usuario puede ver "Review OK" sin que el archivo exista; `/nova-wrap` fallaría después. Riesgo bajo dado que el agente emite mensaje de terminación explícito.

## Bloqueantes

Ninguno.

## Sugerencias

- `nova-build.md` línea 57: cambiar "Tiene preguntas que necesitas responder" por "Tienes preguntas que solo el usuario puede responder" para coherencia de persona.
- `nova-review.md` paso 3: añadir verificación de existencia de `review.md` tras el agente para detectar fallos de escritura antes de llegar a `/nova-wrap`.
- Documentar en `CONTEXT.md` el patrón subagente y directorio `novaspec/agents/` al cerrar (ya previsto en `proposal.md`).
- Considerar ADR para el patrón de subagentes como decisión de diseño del framework.

## Veredicto

✓ Listo para /nova-wrap
