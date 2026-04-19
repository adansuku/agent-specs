# NOVA-001: Extraer plantillas de reporte a novaspec/templates/

## Historia
Como agente ejecutando un comando nova-spec, quiero leer una plantilla
externa en lugar de procesar un skeleton inline, para gastar menos tokens
en formato y más en decisión.

## Objetivo
Reducir el volumen de cada comando extrayendo los skeletons de salida
(proposal, plan, tasks, review, commit, PR body, ticket summary) a archivos
de plantilla en `novaspec/templates/`. Cada comando instruye al modelo a
leer la plantilla antes de generar la salida.

## Contexto
Los 7 comandos `nova-*.md` suman 691 LOC. Una parte significativa son
bloques de formato inline (tablas, skeletons markdown, templates de commit
y PR). El LLM gasta tokens de contexto leyendo "cómo debe verse la salida"
en vez de razonar sobre "qué debe decidir". Externalizar los skeletons
reduce el tamaño de cada comando y centraliza el formato en un único lugar.

## Alcance

### En alcance
- Crear `novaspec/templates/` con 7 archivos skeleton:
  `proposal.md`, `plan.md`, `tasks.md`, `review.md`,
  `commit.md`, `pr-body.md`, `ticket-summary.md`
- Modificar los 7 comandos para referenciar su plantilla por ruta
  en lugar de incluir el skeleton inline
- Las plantillas se distribuyen con `install.sh` (viven en `novaspec/`)

### Fuera de alcance
- Cambiar la lógica de los comandos (guardrails, pasos, reglas)
- Mejorar el contenido de los comandos más allá de la extracción
- Actualizar `.docs/services/agex/CONTEXT.md` (hueco separado)

## Decisiones cerradas
- **Mecanismo**: instrucción de texto en el comando — `"Usa novaspec/templates/X.md como estructura"`. Mismo patrón que los guardrails. No determinista pero idiomático.
- **Contenido de plantillas**: skeleton limpio con secciones y placeholders. Las instrucciones de qué escribir quedan en el comando; solo el formato se externaliza.
- **Criterio de LOC**: indicativo por archivo — cada comando debe bajar ≥30 líneas respecto al baseline. Baseline: nova-build 73, nova-plan 84, nova-review 96, nova-spec 99, nova-start 98, nova-status 122, nova-wrap 119.

## Comportamiento esperado
- Normal: el modelo lee `novaspec/templates/proposal.md`, genera el archivo con esa estructura rellenando los placeholders.
- Edge case: si el modelo no carga la plantilla, la salida puede no seguir la estructura exacta. Mitigación: primera ejecución manual de verificación end-to-end.
- Fallo: ninguno esperado en los archivos en sí — son Markdown estático.

## Output esperado
- `novaspec/templates/` con 7 archivos skeleton
- 7 comandos reducidos (cada uno ≥30 LOC menos)
- `wc -l novaspec/commands/nova-*.md` total baja de 691

## Criterios de éxito
1. Cada `nova-*.md` tiene ≥30 líneas menos que su baseline
2. Cada comando contiene una referencia explícita a su plantilla en `novaspec/templates/`
3. Ejecución manual del flujo completo sin regresión observable en la estructura de los artefactos generados

## Impacto arquitectónico
- Servicios afectados: framework nova-spec
- ADRs referenciados: ADR-0002 (novaspec/ como carpeta canónica)
- ¿Requiere ADR nuevo?: no — es extracción de formato, no decisión arquitectónica nueva

## Verificación sin tests automatizados
### Flujo manual
1. `wc -l novaspec/commands/nova-*.md` — confirmar reducción ≥30 por archivo
2. Ejecutar `/nova-start NOVA-TEST` en un repo de prueba
3. Verificar que el ticket summary generado sigue la estructura de `novaspec/templates/ticket-summary.md`
4. Ejecutar `/nova-spec` y verificar que `proposal.md` generado sigue el skeleton

### Qué mirar
- Que los artefactos generados tengan las secciones esperadas
- Que los comandos no tengan skeletons inline duplicados con las plantillas

## Riesgos
- **Consistencia del modelo**: el mecanismo de referencia por texto no es determinista. Mitigación: verificación end-to-end obligatoria antes de cerrar el ticket.
- **Plantilla no encontrada**: si `novaspec/templates/` no existe en el repo destino (instalación antigua), el modelo no puede leerla. Mitigación: las plantillas se distribuyen con `install.sh` y `cp -R novaspec/`.
