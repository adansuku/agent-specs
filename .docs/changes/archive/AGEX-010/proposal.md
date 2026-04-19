# AGEX-010: Extraer guardrails a archivos compartidos bajo `.spec/guardrails/`

## Historia
Como mantenedor del framework agex, quiero que la lógica de guardrails viva en un único sitio referenciable desde los comandos, para que al cambiar la detección de artefactos o el formato de las ramas no tenga que editar cinco archivos con riesgo de drift.

## Objetivo
Eliminar la duplicación del bloque `## Guardrail` presente en `sdd-spec.md`, `sdd-plan.md`, `sdd-do.md`, `sdd-review.md` y `sdd-wrap.md`, extrayéndola a archivos Markdown compartidos bajo `.spec/guardrails/`. Cada comando referenciará por texto los archivos que le aplican; la composición sustituye al bloque inline.

## Contexto
Los guardrails se introdujeron en AGEX-002 como "validación activa" antes de ejecutar cualquier paso de un comando (ver `.docs/services/agex/CONTEXT.md:31-33, 151-156`). Desde entonces, el bloque vive duplicado en los 5 comandos no-`/sdd-start`. AGEX-004 hizo evidente el coste: un cambio de rutas tocó 7 archivos.

Investigación previa (vía `claude-code-guide`) sobre el mecanismo de Claude Code:
- **Los slash commands no soportan includes/transclusion**: cada `.md` en `.claude/commands/` se carga verbatim. No existe `@include`.
- **Las skills no se invocan de forma determinista desde un comando**: el modelo decide. `/skill args` es posible pero su ejecución depende del juicio del modelo — no fuerza invocación.
- **Los hooks de `settings.json`** sí son deterministas pero corren bash fuera del modelo; serían una regresión de lenguaje declarativo a lenguaje imperativo, y no viajan con `install.sh` (no se distribuyen).

Conclusión: **no hay forma 100% determinista** de compartir un guardrail mediante markdown en Claude Code. Ni la opción A (skill parametrizable) ni la opción C (archivo referenciado) eliminan ese no-determinismo. Sin embargo:

- El patrón actual **inline** también depende de que el modelo respete el bloque `## Guardrail`. No es más determinista que una referencia textual bien redactada.
- El patrón actual del repo ya invoca **4 skills por texto** (`load-context`, `close-requirement`, `write-adr`, `update-service-context`); delegar al modelo la decisión de seguir instrucciones por referencia es un patrón **aceptado**.

Por tanto, trasladar el texto del guardrail a archivos compartidos **no debilita** los guardrails más de lo que el patrón actual ya los debilita, y sí elimina el drift.

## Alcance

### En alcance
- Crear directorio `.spec/guardrails/` con un archivo Markdown por **tipo de precondición**, de forma composable:
  - `branch-pattern.md` — detectar rama activa, validar patrón `(feature|fix|arch)/<TICKET>-<slug>`, extraer `<ticket-id>`.
  - `proposal-exists.md` — verificar `.docs/changes/active/<ticket-id>/proposal.md` existe.
  - `plan-and-tasks-exist.md` — verificar `plan.md` y `tasks.md` existen (con excepción para quick-fix).
  - `all-tasks-done.md` — verificar que `tasks.md` no tiene ninguna línea `- [ ]` sin marcar (con excepción para quick-fix sin `tasks.md`).
  - `review-approved.md` — verificar que `review.md` existe y contiene la línea `✓ Listo para /sdd-wrap`.
- Modificar los 5 comandos (`sdd-spec.md`, `sdd-plan.md`, `sdd-do.md`, `sdd-review.md`, `sdd-wrap.md`) para sustituir el bloque `## Guardrail` inline por una sección que referencia por texto los archivos de `.spec/guardrails/` que le aplican, en orden, indicando los parámetros específicos (p. ej. "si el ticket es quick-fix, salta...").
- Preservar el formato del mensaje de error (`⛔ Guardrail: ...`) y la instrucción "Para aquí. No sigas." en los archivos compartidos.
- Documentar la decisión en `CONTEXT.md` (`/sdd-wrap`): nueva sección en "Componentes" o en "Decisiones clave" mencionando `.spec/guardrails/`.

### Fuera de alcance
- Hooks en `settings.json`: se evaluaron y descartaron por complejidad + no-distribución vía `install.sh`.
- Skill `validate-sdd-state` parametrizable: descartada por el no-determinismo de skill invocation.
- Tests automatizados del guardrail (el framework no tiene suite; verificación es manual).
- Cambios en `install.sh`: tras AGEX-009 ya copia `.spec/` completo; el nuevo `.spec/guardrails/` se distribuye automáticamente.
- Cambios en `sdd-start.md` y `sdd-status.md`: no tienen bloque `## Guardrail` activo (sdd-start es el arranque; sdd-status es solo-lectura con su propia lógica de "detectar estado").
- Renombrar el framework (AGEX-007): ticket separado.

## Decisiones cerradas
- **Mecanismo**: archivos Markdown compartidos en `.spec/guardrails/<variante>.md`, referenciados por texto desde cada comando (opción C del close-requirement).
- **Parametrización**: un archivo por **tipo de precondición** (opción Y). Composables: `/sdd-wrap` referencia `branch-pattern.md` + `review-approved.md`; `/sdd-do` referencia `branch-pattern.md` + `plan-and-tasks-exist.md`.
- **No se crea skill nueva**. `.spec/guardrails/` es material de soporte, no una quinta skill. El CONTEXT.md seguirá declarando 4 skills semánticas; `.spec/guardrails/` se añade a "Componentes" como categoría propia.
- **Formato de referencia en el comando**: sección `## Guardrail` que empieza por "Antes de cualquier otro paso, aplica en orden los siguientes guardrails:" seguido de una lista con rutas explícitas y los parámetros del comando (tipo esperado, quick-fix sí/no, etc.).
- **Mensajes de error**: preservados literalmente en los archivos de `.spec/guardrails/`. Cada archivo define su propio mensaje `⛔ Guardrail: <motivo>. Ejecuta <comando>.` y el comando de recuperación concreto.
- **No ADR nuevo**: la decisión es de estructura interna del framework, no de calado arquitectónico comparable a ADR-0001.

## Comportamiento esperado
- **Normal**: un usuario ejecuta `/sdd-wrap` en una rama correcta con `review.md` aprobado. El comando referencia `.spec/guardrails/branch-pattern.md` + `review-approved.md`; el modelo los lee (los archivos están en `.claude/skills`... no, espera: están en `.spec/guardrails/`, accesibles por ruta relativa desde la raíz del repo donde corre Claude Code). Modelo valida ambos y continúa con el paso 1.
- **Edge case — rama `main`**: el guardrail `branch-pattern.md` detecta patrón no válido. Emite `⛔ Guardrail: no hay rama de ticket activa. Ejecuta /sdd-start <TICKET> primero.` y el comando se detiene.
- **Edge case — `/sdd-do` en rama quick-fix sin `tasks.md`**: `plan-and-tasks-exist.md` contempla la excepción: salta a la implementación directa. Sin cambio respecto al comportamiento actual.
- **Edge case — archivo `.spec/guardrails/<variante>.md` ausente**: si el comando hace referencia a un archivo que no existe (instalación corrupta), el modelo debería reportarlo. No se espera que ocurra en instalaciones normales porque `install.sh` copia `.spec/` completo.
- **Fallo**: comportamiento idéntico al actual — el modelo emite el mensaje `⛔ Guardrail` y detiene. El hecho de leer la condición desde un archivo externo no cambia la fiabilidad (el patrón ya es así para skills como `close-requirement`).

## Output esperado
- **Archivos nuevos**: 5 archivos en `.spec/guardrails/` (ver "En alcance").
- **Archivos modificados**: los 5 comandos `sdd-spec.md`, `sdd-plan.md`, `sdd-do.md`, `sdd-review.md`, `sdd-wrap.md`. Cada uno pierde el bloque `## Guardrail` extenso (~20-30 líneas) y gana una sección corta (~5-10 líneas) que referencia los archivos compartidos y sus parámetros.
- **Reducción de líneas agregadas** en `.spec/commands/`: del orden de 100 líneas menos en total.
- **No hay cambios en**: `.spec/skills/` (ninguna skill nueva), `install.sh` (ya copia `.spec/` completo), `.spec/commands/sdd-start.md` y `.spec/commands/sdd-status.md`.

## Criterios de éxito
- `ls .spec/guardrails/` devuelve exactamente: `branch-pattern.md`, `proposal-exists.md`, `plan-and-tasks-exist.md`, `all-tasks-done.md`, `review-approved.md`.
- En cada uno de los 5 comandos modificados, el bloque `## Guardrail` contiene **solo** referencias a archivos de `.spec/guardrails/` y parámetros específicos. No duplica lógica inline.
- `grep -l "Para aquí. No sigas." .spec/commands/*.md` devuelve **0** (la frase migra a `.spec/guardrails/`).
- `grep -c "⛔ Guardrail" .spec/commands/*.md` suma **0** en los 5 comandos (los mensajes viven en los archivos compartidos).
- `grep -c "⛔ Guardrail" .spec/guardrails/*.md` suma **≥ 5** (un mensaje por archivo).
- Cambiar una ruta de artefactos en `proposal-exists.md` (p. ej. `.docs/changes/active/<id>/proposal.md` → `.docs/changes/active/<id>/spec.md`) se refleja automáticamente en `/sdd-plan` sin tocar el comando. Verificable manualmente con `grep` antes/después.
- **Regresión funcional**: ejecutar `/sdd-wrap` sobre una rama sin `review.md` debe seguir emitiendo el mismo tipo de error (`⛔ Guardrail: no existe review.md...`) que antes del refactor. Igual para los otros 4 comandos.
- **Smoke install**: tras el cambio, `bash /ruta/a/agex/install.sh` en un tmpdir genera también `.spec/guardrails/` con los 5 archivos.

## Impacto arquitectónico
- **Servicios afectados**: `agex` (único).
- **ADRs referenciados**: ADR-0001 (install.sh copia desde la fuente) — el nuevo directorio se distribuye automáticamente por `cp -R`.
- **¿Requiere ADR nuevo?**: **no**. Cambio estructural interno, no decisión transversal de alto nivel.
- **CONTEXT.md a actualizar en `/sdd-wrap`**:
  - Sección "Componentes" (líneas 37-82): añadir apartado `### Guardrails (/.spec/guardrails/)` con la lista de archivos.
  - Sección "Decisiones clave" (líneas 132-163): opcional — añadir viñeta "Guardrails como archivos compartidos" explicando la elección C+Y y la alternativa descartada (hooks).
  - "Última actualización": 2026-04-19 → AGEX-010.

## Verificación sin tests automatizados

### Flujo manual
1. Aplicar los cambios: 5 archivos nuevos + 5 comandos modificados.
2. Ejecutar los 3 greps del criterio de éxito (archivos en `.spec/guardrails/`, mensajes migrados).
3. En un tmpdir: `bash /Users/adan/Workspace/agex/install.sh` — verificar que `.spec/guardrails/` existe en el destino y que el `diff -r` entre fuente y destino es vacío.
4. Regresión manual (para cada uno de los 5 comandos):
   - `/sdd-spec` desde rama `main` → esperar `⛔ Guardrail: no hay rama de ticket activa. Ejecuta /sdd-start <TICKET> primero.`
   - `/sdd-plan` sin `proposal.md` en una rama de ticket → esperar `⛔ Guardrail: no existe proposal.md...`
   - `/sdd-do` sin `plan.md`/`tasks.md` en rama feature → esperar `⛔ Guardrail: no existe plan.md o tasks.md...`
   - `/sdd-review` con una línea `- [ ]` pendiente en `tasks.md` → esperar `⛔ Guardrail: hay N tarea(s) sin completar...`
   - `/sdd-wrap` sin `review.md` → esperar `⛔ Guardrail: no existe review.md...`
5. Cada uno de los 5 debe producir el mismo texto de error que producía antes del refactor.
6. Caso de uso en paralelo: modificar la ruta en `proposal-exists.md`, disparar `/sdd-plan`, comprobar que el mensaje refleja la nueva ruta.

### Qué mirar
- **Contenido de los comandos**: los 5 archivos modificados deben pasar de ~100 líneas de guardrail total a ~30-50 líneas de referencias.
- **Contenido de `.spec/guardrails/`**: cada archivo autoexplicativo (título, qué comprueba, qué emite si falla, con qué comando se recupera).
- **Instalación en destino**: `.claude/skills` sigue siendo symlink hacia `.spec/skills` (sin cambios). No hay symlink nuevo para `guardrails/`; los comandos hacen referencia por ruta relativa a `.spec/guardrails/<variante>.md`.
- **No tocar**: `notes.md`, otros archivos de `.docs/`.

## Riesgos
- **No-determinismo residual**: el modelo puede "olvidar" seguir la referencia. Mitigación: el patrón actual (bloque inline) depende del mismo no-determinismo; redactar los archivos compartidos con el mismo tono imperativo ("**Ejecuta esto antes de cualquier otro paso.**", "**Para aquí. No sigas.**") minimiza la diferencia.
- **Sintaxis de referencia** en los comandos: si usamos `@path/to/file` (no soportado) el modelo podría confundirse. Mitigación: usar lenguaje natural explícito — "Lee el archivo `.spec/guardrails/branch-pattern.md` y aplica su contenido con `<artefacto>=<x>`". Probado vía `load-context` y `close-requirement` que el modelo sigue instrucciones así.
- **Deriva entre archivos de guardrail y CONTEXT.md / INSTALL.md**: si luego se añade `guardrails/` al diagrama de "Qué se instala" en INSTALL.md (fuera de alcance aquí), debería actualizarse en otro ticket. Este ticket deja el diagrama intacto y es intencional (el diagrama ya lo genera `install.sh` dinámicamente vía `tree`).
- **Sobrecarga cognitiva para el lector del comando**: abrir un comando ya no muestra el guardrail completo; hay que abrir otro archivo. Mitigación: cada comando cita la ruta y el mensaje de error esperado, de forma que el lector no tiene que abrir el archivo salvo que quiera auditar la lógica.
- **Rollback**: si el refactor genera bugs sutiles en los guardrails, volver al estado anterior es `git revert` limpio (solo toca archivos del framework, no código de usuario).
