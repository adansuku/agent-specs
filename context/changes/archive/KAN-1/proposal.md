<!-- Mantén esta spec ≤ 60 líneas. Bullets y tablas, no prosa. Se carga en cada turno de nova-build. -->
# KAN-1: Extraer /nova-review a subagente

## Historia
Como usuario de nova-spec, quiero que el code review se ejecute en un subagente aislado, para que el diff, los ADRs y la spec no contaminen el contexto principal de la conversación.

## Objetivo
Aislar la fase de review en un contexto separado, reduciendo tokens en el hilo principal.

## Contexto
`nova-review.md` carga inline diff, spec completa y ADRs — los elementos más pesados del flujo. Ejecutarlo en el contexto principal hace que esos tokens persistan en todos los turnos posteriores hasta `/nova-wrap`.

## Alcance
### En alcance
- Crear `novaspec/agents/nova-review-agent.md` con la lógica de review
- Reescribir `nova-review.md` para lanzar el agente y mostrar resumen
- Actualizar `nova-build.md`: ejecutar tareas en secuencia automáticamente, parar solo ante bloqueantes o decisiones no cerradas
- Actualizar `CONTEXT.md` del servicio agex en `/nova-wrap`

### Fuera de alcance
- Cambios en `install.sh` (copia `novaspec/` entero, incluye `agents/` automáticamente)

## Decisiones cerradas
- Agente definido en archivo `.md` en `novaspec/agents/` (patrón framework, referenciado por ruta)
- Subagente escribe `review.md` directamente en `.docs/changes/active/<ticket>/`
- Input al subagente: solo `ticket-id`; el agente lee diff, spec y ADRs por su cuenta
- `nova-review.md` lanza el agente, espera, y muestra resumen con siguiente paso

## Comportamiento esperado
- Normal: `nova-review.md` lanza `nova-review-agent` con el ticket-id → agente lee artefactos → escribe `review.md` → comando padre muestra resumen
- Edge: si faltan artefactos (proposal.md, tasks.md), el agente emite error descriptivo y no escribe `review.md`
- Fallo: si el agente no puede escribir el archivo, el padre reporta el fallo al usuario

## Output esperado
- `novaspec/agents/nova-review-agent.md` (nuevo)
- `nova-review.md` reducido a orquestación + guardrail + resumen
- `.docs/changes/active/<ticket>/review.md` producido por el subagente

## Criterios de éxito
- El contexto principal no contiene diff ni contenido de ADRs tras ejecutar `/nova-review`
- `review.md` se genera con el mismo contenido que antes (4 ejes: spec, convenciones, ADRs, riesgos)
- El guardrail de `/nova-wrap` (`review-approved.md`) sigue funcionando sin cambios

## Impacto arquitectónico
- Servicios afectados: agex
- ADRs referenciados: ADR-0002 (naming), ADR-0001 (install.sh)
- ¿Requiere ADR nuevo?: posible — primer uso del patrón subagente en el framework

## Verificación sin tests automatizados
### Flujo manual
1. Completar un ticket de prueba hasta `/nova-review`
2. Ejecutar `/nova-review` y verificar que el hilo principal no muestra diff ni ADRs
3. Comprobar que `.docs/changes/active/<ticket>/review.md` existe y tiene los 4 ejes
4. Ejecutar `/nova-wrap` y verificar que el guardrail `review-approved.md` lo detecta

### Qué mirar
- Logs: output del subagente en el panel de herramientas de Claude Code
- API/UI: `review.md` generado con línea `✓ Listo para /nova-wrap`

## Riesgos
- Subagente sin acceso a herramientas de escritura: verificar que el agente tiene `Write` disponible en su contexto
- Patrón nuevo sin precedente en el repo: documentar en CONTEXT.md al cerrar
