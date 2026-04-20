# Memoria sencilla: decisions + gotchas + services planos

**Fecha**: 2026-04-20
**Ticket**: NOVA-37

## Decisión

La memoria arquitectónica del framework vive en tres directorios bajo `context/`:

- `context/decisions/` — un archivo por decisión técnica con alternativa real.
- `context/gotchas/` — un archivo por trampa no obvia descubierta durante un build.
- `context/services/<svc>.md` — un archivo plano por servicio, tope duro ≤80 líneas.

**Reglas de escritura:**
- Un hecho, un archivo. Nunca se actualiza un archivo con información nueva; se crea otro y se supersede el viejo.
- Nombre = índice. `install-sh-copia-desde-fuente.md`, no `ADR-0001.md`. Grep por concepto, no por número.
- Sin frontmatter, sin índice global, sin glossary.
- Supersede explícito: nueva decisión empieza con `> Supersedes: old-file.md`; la vieja se mueve a `context/decisions/archived/` con `git mv`.
- Default: no escribir. La mayoría de tickets no genera memoria.

**Reglas de lectura:**
- Agentes (`context-loader`, `load-context`, `nova-start`) **nunca** auto-cargan `context/decisions/archived/`.
- Presupuesto de `load-context`: ≤3000 tokens. Obliga a seleccionar 3-5 archivos relevantes por nombre, no leer todo.

**Canonical source:** este archivo. `AGENTS.md`, los `README.*` del framework y los docs apuntan aquí, no duplican contenido.

## Alternativas descartadas

| Alternativa | Por qué no |
|---|---|
| Mantener `adr/` + numeración `ADR-NNNN` | Dos puertas para el mismo concepto; el número oculta el tema; grep por concepto es más rápido |
| Conservar `glossary.md` | Los términos se definen donde se usan; un glosario se ha mantenido vacío en la práctica |
| Conservar `post-mortems/` como directorio persistente | El narrativo es efímero (PR/Slack); lo que persiste es la decision o gotcha derivada |
| `CONTEXT.md` grande por servicio con sección "Decisiones clave" | Concentra decisiones como bullets sin archivo propio; rompe atomicidad; crece monótonamente |
| Carpeta por servicio (`services/<svc>/CONTEXT.md`) | Fomenta acumular; el tope ≤80 obliga a sacar contenido a decisions/gotchas |
| Supersede vía `git rm` sin `archived/` | Pierde la papelera visible que un humano puede consultar con `ls` sin saber git |
| Pre-commit hook global para validar supersede | Determinista pero añade bash al harness; incompatible con instalación portable. Un guardrail markdown referenciado desde `/nova-wrap` es suficiente |

## Por qué

El framework nova-spec se diseña para ser seguible por cualquier equipo sin tooling externo. La memoria debe responder a dos preguntas:

1. ¿Por qué hicimos X? → `decisions/`
2. ¿Qué no es obvio leyendo el código? → `gotchas/`

Si algo no responde a ninguna de las dos, no va en memoria. El contrato es deliberadamente simple: archivos markdown atómicos, nombres-concepto, grep como índice. Con esto se elimina la ceremonia (ADR-NNNN, frontmatter, generadores, vistas) sin perder trazabilidad.

## Coste aceptado

- **Descubribilidad decae si el corpus crece.** `grep` funciona hasta ~50-100 archivos; más allá, aparecen falsos positivos. Mitigación: default "no escribir" + supersede + tope de líneas en services/. Si el corpus se dispara, se re-evalúa.
- **Supersede exige 3 pasos manuales** (crear nuevo, `git mv` viejo a archived/, línea `> Supersedes:`). Guardrail `old-decision-archived` valida la invariante; no impide el olvido, solo lo detecta antes del merge.
- **Archived/ crece monótonamente.** Aceptado: es papelera visible, no se auto-carga, no afecta token budget. Si estorba, se purga manualmente en un ticket futuro.
- **Riesgo de regresión:** alguien añade "consejos útiles de memoria" en `AGENTS.md` en vez de crear una decision. Contramedida: esta decisión lo declara explícitamente anti-patrón. No hay guardrail automatizado para ello.

## Consecuencias para el framework

- Desaparecen: `context/adr/`, `context/glossary.md`, `context/post-mortems/`, `context/services/<svc>/CONTEXT.md`.
- Aparecen: `context/decisions/` (con `archived/`), `context/gotchas/`, `context/services/<svc>.md` plano.
- Skill `write-adr` → `write-decision`, sin numeración, concept-naming.
- Guardrail `old-decision-archived` referenciado desde `/nova-wrap`.
- `AGENTS.md`, `novaspec/README.arch.md`, `novaspec/README.quickref.md` describen el modelo con 3-5 líneas y apuntan a este archivo como fuente canónica.
- Las plantillas (`proposal.md`, `pr-body.md`, `commit.md`, etc.) y `nova-review.md` aún referencian "ADR" — drift semántico pendiente, queda para ticket de seguimiento.
