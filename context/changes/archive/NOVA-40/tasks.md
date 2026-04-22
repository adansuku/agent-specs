# Plan + tareas: NOVA-40

## Estrategia
Flujo lineal sin código de producción: 2 plantillas nuevas → 1 comando nuevo que las usa → smokes manuales en repo scratch (happy path, idempotencia, edge cases) → actualizar docs (7→8 comandos). Todo markdown; el único riesgo real es que las heurísticas del comando no hagan lo prometido en la spec, por eso los smokes cubren los 3 casos de la spec (normal, edge monolito, edge sin contexto).

## Archivos a tocar
- `README.md`: añadir `/nova-init` a la tabla de comandos; pasar "7 slash commands" → "8".
- `context/services/novaspec.md`: añadir `/nova-init` a la tabla (≤80 líneas, reemplazar, no acumular).

## Archivos nuevos
- `novaspec/templates/init-project.md`: skeleton de `project.md` con secciones Qué es / Arquitectura objetivo / Testing policy / Comandos útiles / Restricciones / Posibles decisiones. TODOs explícitos donde la heurística no puede inferir.
- `novaspec/templates/init-service.md`: skeleton de `<svc>.md` ≤80 líneas (per `memoria-sencilla.md`) con secciones Qué hace / Interfaces públicas / Dependencias / Lo que no es obvio / Decisiones relevantes. TODOs explícitos.
- `novaspec/commands/nova-init.md`: orquestador. Precondiciones (context/ existe, no estamos en el propio repo nova-spec). Escaneo top-level + `services/|apps/|packages/*`. Detección de manifests y extracción de scripts/targets. Aplicación de plantillas. Idempotencia `.draft.md`. Checkpoint humano final.
- `context/changes/active/NOVA-40/smoke-test.md`: evidencia de los 3 escenarios manuales.

## Safety net
- Reversibilidad: todo markdown; `git revert` del commit borra el comando y las plantillas; el repo vuelve a tener 7 comandos.
- Qué puede romperse: nada en producción. Riesgo acotado a que `/nova-init` no se comporte según spec; en ese caso los smokes fallan y se itera.
- Plan de rollback: `git revert <sha>` del commit de NOVA-40.

## Characterization tests (o verificación)
Antes de modificar código existente:
- [ ] **Baseline referencial**: inspeccionar `novaspec/commands/nova-status.md` (comando solo-lectura existente) como patrón de estilo para el nuevo `nova-init.md`. No es test, es fijar el formato que seguiremos.

## Tareas (15–60 min)
- [x] 1. **Baseline de referencia**: leer `novaspec/commands/nova-status.md` y `novaspec/commands/nova-start.md` para fijar el estilo de los orquestadores (estructura de pasos, formato de guardrail/precondición/reglas). Dejar apuntadas 3-5 convenciones a replicar — sin escribir nada aún.
- [x] 2. **Plantilla `init-project.md`**: crear `novaspec/templates/init-project.md` con las 6 secciones de la spec. Usa `[TODO: …]` marcados explícitos donde la heurística no inferirá (Arquitectura objetivo, Testing policy, Restricciones). Incluir `<!-- Generado por /nova-init. Revisa y elimina los TODO. -->` como primera línea.
- [x] 3. **Plantilla `init-service.md`**: crear `novaspec/templates/init-service.md` ≤80 líneas, mismas convenciones que los services/ vivos (ver `context/services/novaspec.md` como referencia). TODOs en todos los campos no inferibles. Header con `<!-- Generado por /nova-init. Revisa y elimina los TODO. -->`.
- [x] 4. **Comando `nova-init.md` — esqueleto y precondiciones**: crear `novaspec/commands/nova-init.md` con: cabecera (description, argument-hint si aplica), precondiciones (context/ existe; PWD != SCRIPT_DIR nova-spec; working tree limpio no es estricto), reglas. Sin lógica de escaneo aún.
- [x] 5. **Comando — lógica de escaneo**: añadir al comando los pasos de escaneo: (a) detectar manifests en raíz (`package.json`, `pyproject.toml`, `go.mod`, `Gemfile`, `Cargo.toml`, `composer.json`); (b) listar subdirs de `services/|apps/|packages/` y detectar manifests dentro; (c) extraer `scripts` de `package.json` (raíz) y targets de `Makefile` (raíz) si existen. Todo con Bash; sin recursión fuera de los 3 dirs convencionales.
- [x] 6. **Comando — generación + idempotencia**: añadir los pasos que (a) rellenan `init-project.md` con los datos detectados dejando TODOs en el resto; (b) por cada servicio detectado, rellenan `init-service.md`; (c) si existe `<archivo>.md` escribir `<archivo>.draft.md` en su lugar; (d) presentan checkpoint humano con lista de archivos + preview de primeras ~20 líneas y piden `y/n` antes de escribir.
- [x] 7. **Smoke happy path**: crear `/tmp/nova-init-monorepo` (monorepo scratch con `packages/a/package.json`, `packages/b/package.json`, `Makefile` raíz, `pyproject.toml` raíz). Ejecutar `install.sh` + `/nova-init`. Verificar: `project.md` con scripts+targets extraídos, `packages/a.md` y `packages/b.md` generados con TODOs. Registrar evidencia.
- [x] 8. **Smoke idempotencia**: sobre el mismo `/tmp/nova-init-monorepo`, ejecutar `/nova-init` de nuevo. Verificar que crea `project.draft.md`, `a.draft.md`, `b.draft.md` sin tocar originales. Registrar.
- [x] 9. **Smoke edge cases**: (a) `/tmp/nova-init-mono` con solo un `package.json` en raíz (sin services/apps/packages) → solo `project.md`; (b) eliminar `context/` de ese dir y re-ejecutar → debe abortar con "ejecuta install.sh primero"; (c) ejecutar `/nova-init` desde `/Users/adan/Workspace/novaspec` → debe abortar por PWD == SCRIPT_DIR. Registrar los 3 casos.
- [x] 10. **Actualizar docs**: `README.md` (añadir `/nova-init` a la tabla, texto pasa de "siete" a "ocho" comandos); `context/services/novaspec.md` (añadir fila en la tabla, verificar ≤80 líneas).
- [x] 11. **Verificación final con context-loader**: ejecutar mentalmente / con dummy `/nova-start` en `/tmp/nova-init-monorepo` post-`/nova-init` para confirmar que el `context-loader` lee `services/project.md` y no reporta "Huecos" sobre servicios no documentados. Registrar en smoke-test.md.
- [x] 12. **Mejora `/nova-plan`**: clarificar en `novaspec/commands/nova-plan.md` que las tareas no deben escribir en `services/|decisions/|gotchas/` (eso es `/nova-wrap`). Mejora descubierta durante esta misma ejecución — evita que otros planes futuros repitan la violación. Añadida en `/nova-wrap`.
