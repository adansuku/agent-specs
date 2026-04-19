# Review: AGEX-003

## Cumplimiento de spec

- [✓] Criterio 1: existe `.spec/commands/sdd-status.md`
- [✓] Criterio 2: acepta `$ARGUMENTS` como ticket-id explícito; sin argumento
  extrae el ticket de la rama git (Paso 1, líneas 10-36)
- [✓] Criterio 3a: muestra título (Paso 4) leído de `proposal.md`
- [✓] Criterio 3b: muestra paso actual (Paso 3, tabla de inferencia)
- [✓] Criterio 3c: muestra rama git actual (Paso 6, campo "Rama")
- [✓] Criterio 3d: muestra progreso de tareas cuando paso = `do` (Paso 5-6)
- [✓] Criterio 3e: muestra siguiente comando recomendado (Paso 6, tabla)
- [✓] Criterio 4: sin ticket activo → avisa y lista tickets abiertos (Paso 1, líneas 18-36)
- [✓] Criterio 5: ticket archivado → lo encuentra en `archive/` e informa (Pasos 2-3)
- [✓] Criterio 6: regla explícita "No modifiques ningún archivo" (líneas 118-123)

## Convenciones

- Frontmatter YAML correcto; `argument-hint: [TICKET-ID]` con corchetes indica
  argumento opcional, coherente con otros comandos.
- `$ARGUMENTS` correcto según el patrón de `sdd-start.md`.
- Idioma español en toda la salida. Coherente con el framework.
- Estructura (pasos numerados → reglas al final) sigue el patrón de los demás
  comandos sin desviaciones.

## ADRs

Sin conflictos. No hay ADRs vigentes en `.docs/adr/`.

## Riesgos

- Listado de tickets abiertos con "paso inferido" por cada uno implica ejecutar
  la inferencia de estado de forma iterativa. El comando no especifica cómo
  hacerlo en el caso del listado. Impacto bajo: el LLM puede ejecutar la lógica
  inline, pero podría ser ambiguo. Mitigación: es comportamiento documentado
  como complementario, no como requisito estricto del criterio 4.

## Bloqueantes

Ninguno.

## Sugerencias

- (Opcional) Aclarar en la tabla de siguientes comandos que cuando el paso es
  `do` y `tasks.md` no tiene ningún checkbox (case raro), el siguiente es
  `/sdd-do` sin el sufijo "continuar", para evitar confusión semántica.
- (Opcional) Añadir al Paso 1 que cuando se pasa argumento explícito, la rama
  actual puede ser cualquiera (no se valida patrón de rama), para documentar
  explícitamente ese caso de uso.

## Veredicto

✓ Listo para /sdd-wrap
