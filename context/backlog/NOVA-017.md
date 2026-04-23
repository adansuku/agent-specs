# NOVA-017 — `/nova-analyst` opcional para elicitación profunda pre-spec

**Tipo**: feature
**Prioridad**: media
**Estimación**: media (3-4h)

## Problema

`close-requirement` (skill actual) hace preguntas estructuradas ancladas
en código, pero está optimizado para cerrar decisiones concretas de un
ticket **que ya tiene forma** (¿esta opción o la otra?). Cuando el ticket
llega muy vago — "mejorar performance", "rediseñar onboarding", "algo
falla en prod" — las preguntas correctas no son sobre opciones sino sobre
el problema: qué es éxito, qué queda fuera, quién se ve afectado, qué
alternativas ya se descartaron.

Resultado hoy:

- El humano se ve obligado a auto-elicitarse antes de `/nova-spec`, o
- `/nova-spec` genera una spec que responde mal la pregunta de negocio.

Frameworks como BMAD resuelven esto con una fase previa de **Analyst**.
Nova-spec no tiene equivalente y la diferencia se nota en tickets tipo
`architecture` o `feature` abiertos.

## Propuesta

Añadir `/nova-analyst` como **comando opcional pre-spec** (fuera del flujo
por defecto, igual que `/nova-init`), invocable cuando el ticket sea muy
abierto. No es un agente nuevo, no es una persona — es un prompt más
dentro del mismo patrón del resto del framework.

### Forma

- Archivo `novaspec/commands/nova-analyst.md` (≤80 LOC).
- Ejecuta una entrevista de 6 preguntas estructuradas:
  1. **Objetivo de negocio** (1 frase)
  2. **Criterio de éxito medible** (métrica + umbral)
  3. **No-objetivos** (qué explícitamente queda fuera)
  4. **Stakeholders afectados** (quién nota el cambio)
  5. **Riesgos** (de no hacer / de hacerlo mal)
  6. **Alternativas descartadas** y por qué (fuerza a evitar la primera idea)
- Output: `context/changes/active/<ticket>/analysis.md`.
- Sin multi-agente. Sin personas. Sin role-play.

### Integración con el flujo

- `/nova-start` detecta tickets vagos (heurística: descripción < 200
  caracteres, o campos clave de Jira vacíos) y sugiere —no obliga—
  ejecutar `/nova-analyst` antes de `/nova-spec`.
- `/nova-spec` detecta `analysis.md` si existe y lo usa como contexto
  adicional en `proposal.md`; si no existe, funciona como hoy.
- El flujo estándar (ticket bien formado) **no carga nada extra**:
  presupuesto de tokens intacto para el 80% de los casos.

## Por qué NO hacer un agente

- Un subagente aísla contexto pesado. Esta fase es **100% conversación
  humana**; no hay diff, ADRs ni código que aislar del orquestador.
- Agregar un agente aquí sería role-play vacío (el patrón de BMAD que
  rechazamos). Mantener "1 comando = 1 prompt corto".
- Si crece > 80 LOC o se quiere paralelizar con otras fases, se promueve
  a agente en un segundo ticket — NOVA-014 absorbería esa decisión.

## Por qué NO meterlo dentro de `/nova-spec`

- `/nova-spec` ya carga `close-requirement` implícitamente. Inyectar aquí
  una segunda entrevista (profunda + detallada) alarga un comando que
  debe quedarse ≤ 40 LOC.
- Hacerlo opcional por flag es menos descubrible que un comando nombrado.
- Separarlos mantiene la heurística "un comando = una intención".

## Criterio de aceptación

1. `novaspec/commands/nova-analyst.md` existe, ≤ 80 LOC, con guardrail
   de precondiciones (rama activa, ticket cargado).
2. `/nova-analyst` escribe `context/changes/active/<ticket>/analysis.md`
   con las 6 secciones rellenadas.
3. `/nova-spec` lee `analysis.md` si existe y lo referencia explícitamente
   en la sección "Contexto" de `proposal.md`.
4. `/nova-start` muestra un aviso (no bloqueante) sugiriendo
   `/nova-analyst` cuando la descripción del ticket es < 200 caracteres.
5. Un ticket bien formado (descripción > 200 chars, campos completos)
   **no pasa por `/nova-analyst`** y no carga su prompt.
6. Regenerar: `/nova-analyst` sobre un ticket con `analysis.md` existente
   pide confirmación antes de sobrescribir.

## Riesgos

- **Solapamiento con `close-requirement`**: analyst es Q&A sobre el
  problema; close-requirement es Q&A sobre las opciones. Si la distinción
  no se sostiene en la práctica (los usuarios se confunden cuándo cuál),
  fusionar en un flujo escalonado único.
- **`analysis.md` obsoleto**: si el humano edita el ticket en Jira después
  de `/nova-analyst`, el análisis queda stale. `/nova-spec` debe avisar
  si detecta desfase (hash del ticket vs hash guardado en `analysis.md`).

## Referencias

- BMAD-METHOD "Analyst phase" — inspira la lista de 6 preguntas, no el
  modelo multi-agente.
- NOVA-005 — si `close-requirement` se reclasifica como subcomando de
  `/nova-spec`, `/nova-analyst` queda como único entry point de
  elicitación externa al flujo estándar (más limpio).
- NOVA-014 — si se aprueba, `/nova-analyst` podría delegar en un
  `analyst` agente también; hoy no justifica el coste.
