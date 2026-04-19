# AGEX-002: Guardrails en el flujo SDD

## Historia

Como agente ejecutando el flujo SDD, quiero que cada comando valide que
el paso anterior se completó correctamente antes de ejecutarse, para que
los errores se detecten inmediatamente con un mensaje claro en lugar de
producir resultados incoherentes o silenciosos.

## Objetivo

Añadir una sección de guardrail al inicio de cada comando `/sdd-*` que
compruebe las precondiciones estructurales necesarias y aborte con un
mensaje de error accionable si no se cumplen.

## Contexto

Los comandos del flujo SDD asumen que el paso anterior se ejecutó, pero
ninguno verifica activamente que sea así. Un agente puede invocar
`/sdd-plan` sin haber generado `proposal.md`, o `/sdd-wrap` sin que el
review tenga veredicto ✓, produciendo trabajo incoherente o pérdida de
pasos críticos (memoria arquitectónica, ADRs).

El problema es especialmente grave en `/sdd-wrap`: si se ejecuta sin
review aprobado, el ticket se cierra sin validación formal.

## Alcance

### En alcance

- Añadir bloque **## Guardrail** al inicio de cada uno de los 5 comandos
  que tienen precondiciones: `sdd-spec`, `sdd-plan`, `sdd-do`,
  `sdd-review`, `sdd-wrap`
- Cada guardrail define: qué comprobar, cómo inferir el ticket-id, y el
  mensaje de error exacto a emitir
- Añadir paso en `sdd-review` para persistir el reporte en
  `.docs/changes/<ticket-id>/review.md` (necesario para que `sdd-wrap`
  pueda verificar el veredicto)
- `sdd-start` no necesita guardrail (es el primer paso)

### Fuera de alcance

- Crear scripts de shell o código ejecutable; los guardrails son
  instrucciones en lenguaje natural dentro de los archivos Markdown
- Modificar `config.yml` ni la estructura de directorios
- Añadir tests automatizados (el runtime es Claude, no hay test harness)
- Cambiar el comportamiento de los pasos cuando las precondiciones sí se
  cumplen

## Decisiones cerradas

- **Cómo inferir el ticket-id**: a partir de la rama git actual. El
  agente extrae el ticket-id del nombre de rama con el patrón
  `{type}/{TICKET}-{slug}` definido en `config.yml`. Si la rama no sigue
  el patrón, el guardrail de `sdd-spec` falla (señal de que `sdd-start`
  no se ejecutó).
- **Dónde escribir el review**: `sdd-review` persiste su reporte en
  `.docs/changes/<ticket-id>/review.md`. `sdd-wrap` lee ese archivo y
  busca la línea `✓ Listo para /sdd-wrap`. Si no existe el archivo o no
  contiene esa línea, aborta.
- **Formato del mensaje de error**: línea única, prefijo `⛔ Guardrail:`,
  seguido de qué falta y qué comando ejecutar. Ejemplo:
  `⛔ Guardrail: no existe proposal.md. Ejecuta /sdd-spec primero.`
- **Comportamiento ante quick-fix**: `sdd-do` ya tiene excepción para
  quick-fix (puede operar sin tasks.md). El guardrail respeta esa
  excepción: si la rama es `fix/` y no existe tasks.md, permite continuar.
- **Verificación de `sdd-review`**: comprueba que en `tasks.md` no quede
  ningún `- [ ]` sin marcar. Si queda alguno, aborta indicando cuántas
  tareas faltan.

## Comportamiento esperado

- **Normal**: el agente ejecuta los comandos en orden. Cada guardrail
  pasa silenciosamente (sin output extra) y el comando continúa su flujo
  habitual.
- **Edge case — quick-fix sin tasks.md**: `sdd-do` y `sdd-review`
  permiten continuar si la rama es `fix/` y no existe `tasks.md`.
  `sdd-review` en ese caso omite la comprobación de checkboxes.
- **Fallo**: el comando emite `⛔ Guardrail: <motivo>. Ejecuta <comando>
  primero.` y se detiene. No ejecuta ningún paso posterior.

## Output esperado

- 5 archivos Markdown modificados: `sdd-spec.md`, `sdd-plan.md`,
  `sdd-do.md`, `sdd-review.md`, `sdd-wrap.md`
- Cada uno con un bloque `## Guardrail` como primera sección después del
  frontmatter
- `sdd-review.md` con paso adicional para escribir `review.md`

## Criterios de éxito

- Invocar `/sdd-spec` sin rama de ticket activa produce `⛔ Guardrail`
- Invocar `/sdd-plan` sin `proposal.md` produce `⛔ Guardrail`
- Invocar `/sdd-do` sin `plan.md` ni `tasks.md` (y no siendo quick-fix)
  produce `⛔ Guardrail`
- Invocar `/sdd-review` con tareas pendientes (`- [ ]`) produce
  `⛔ Guardrail` indicando cuántas faltan
- Invocar `/sdd-wrap` sin `review.md` con veredicto `✓` produce
  `⛔ Guardrail`
- Cuando las precondiciones se cumplen, el comportamiento de cada
  comando es idéntico al actual (sin regresión)

## Impacto arquitectónico

- Servicios afectados: agex (comandos en `.spec/commands/`)
- ADRs referenciados: ninguno
- ¿Requiere ADR nuevo?: no. Es una mejora defensiva de comandos
  existentes, no una decisión de arquitectura nueva.

## Verificación sin tests automatizados

### Flujo manual

1. Desde main, ejecutar `/sdd-plan` sin haber corrido `/sdd-start`.
   Verificar que aparece `⛔ Guardrail`.
2. Ejecutar `/sdd-start AGEX-TEST`. Luego ejecutar `/sdd-plan` sin haber
   corrido `/sdd-spec`. Verificar `⛔ Guardrail`.
3. Ejecutar `/sdd-spec`. Luego `/sdd-do` sin `/sdd-plan`. Verificar
   `⛔ Guardrail`.
4. Ejecutar `/sdd-plan`. Luego `/sdd-review` con tareas pendientes.
   Verificar `⛔ Guardrail` con número de tareas.
5. Ejecutar `/sdd-do` hasta completar todas las tareas. Luego
   `/sdd-wrap` sin `/sdd-review`. Verificar `⛔ Guardrail`.
6. Ejecutar flujo completo en orden. Verificar que ningún guardrail se
   dispara y el flujo termina correctamente.

### Qué mirar

- Logs: N/A (runtime es Claude Code, sin logs de proceso)
- DB: N/A
- API/UI: la respuesta de Claude al invocar cada comando

## Riesgos

- **Falso negativo en detección de rama**: si el agente no puede leer la
  rama git actual (contexto muy limitado), el guardrail de `sdd-spec`
  puede no dispararse. Mitigación: el guardrail también comprueba si
  existe `.docs/changes/` con algún ticket activo.
- **`review.md` no generado en flujos anteriores**: tickets iniciados
  antes de este cambio no tendrán `review.md`. Mitigación: el guardrail
  de `sdd-wrap` acepta tanto `review.md` con `✓` como la ausencia del
  archivo si el usuario confirma explícitamente que el review fue OK.
