# Patrón de subagentes para operaciones pesadas

**Fecha**: 2026-04-19
**Estado**: Aceptada
**Tickets**: KAN-1 (nova-review), NOVA-2 (load-context)

## Contexto

Algunos pasos del flujo nova-spec cargan material voluminoso en el contexto
principal: diff completo, múltiples CONTEXT.md, ADRs, spec, plan. Este
contenido persiste durante todos los turnos siguientes de la conversación
(efecto "sticky"), multiplicando el coste en token-turns aunque solo se
use el resumen final.

Medición en KAN-1: cargar `/nova-review` inline costaba ~6.250 tokens ×
5 turnos restantes = ~31.250 token-turns. Con subagente: ~300 token-turns
en el hilo principal.

## Decisión

Las operaciones que cargan artefactos voluminosos se extraen a archivos
en `novaspec/agents/`. El comando padre invoca el agente con el mínimo
input necesario; el agente opera en contexto aislado y devuelve solo
el output útil (resumen, veredicto, etc.).

### Convenciones del patrón

| Aspecto | Regla |
|---|---|
| Ubicación | `novaspec/agents/<nombre>-agent.md` o `novaspec/agents/<nombre>.md` |
| Naming | kebab-case (ver `decisions/naming-nova-spec.md`) |
| Input | Mínimo necesario: ticket-id, lista de servicios, etc. |
| Output | Solo el resultado útil: resumen, veredicto, texto estructurado |
| Escritura en disco | Permitida si el output es un artefacto del flujo (ej. `review.md`) |
| Herencia de contexto | Ninguna — el agente parte de cero cada ejecución |

### Cuándo usar subagente vs. skill vs. inline

| Situación | Mecanismo |
|---|---|
| Operación carga >2 archivos voluminosos (diff, ADRs, CONTEXT.md) | Subagente |
| Operación ligera, contextual, interactiva con el usuario | Skill o inline |
| Validación de precondición (guardrail) | Inline en el comando |

## Alternativas descartadas

| Alternativa | Motivo |
|---|---|
| Comprimir el contenido antes de cargarlo en el hilo principal | Reduce tokens pero no elimina la contaminación sticky; el hilo sigue pagando por cada turno |
| Skill en lugar de agente | Las skills se ejecutan en el mismo contexto; no aíslan tokens |
| Pasar contexto preparado desde el padre al agente | El padre seguiría cargando el material pesado — derrota el propósito |
| Feature flags para deshabilitar carga | Añade complejidad operacional sin beneficio arquitectónico |

## Consecuencias

- El agente no hereda el contexto del padre: para operaciones cortas añade
  overhead de inicialización innecesario.
- Cada ejecución del agente tiene coste propio (~25k–30k tokens); el ahorro
  es en el hilo principal, no en tokens totales.
- Los repos instalados con versiones anteriores que tenían skills en
  `.claude/skills/` como symlinks necesitan re-ejecutar `install.sh` para
  que los symlinks apunten a la estructura actualizada.

## Agentes implementados

| Agente | Ticket | Input | Output |
|---|---|---|---|
| `nova-review-agent.md` | KAN-1 | ticket-id | escribe `review.md`, devuelve veredicto |
| `context-loader.md` | NOVA-2 | lista de servicios | devuelve resumen estructurado |
