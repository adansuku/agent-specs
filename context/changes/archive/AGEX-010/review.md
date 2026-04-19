## Review: AGEX-010

### Cumplimiento de spec
- [✓] `ls .spec/guardrails/` = exactamente 5 archivos: `branch-pattern.md`, `proposal-exists.md`, `plan-and-tasks-exist.md`, `all-tasks-done.md`, `review-approved.md`.
- [✓] `grep -c "⛔ Guardrail" .spec/commands/*.md` = **0** en los 7 archivos (los 5 modificados + `sdd-start.md` + `sdd-status.md` que nunca tuvieron).
- [✓] `grep -c "⛔ Guardrail" .spec/guardrails/*.md` = **7** (2+1+1+1+2), ≥ 5.
- [✓] `grep -l "Para aquí. No sigas." .spec/commands/*.md` = **0 matches**; la frase migra íntegramente a `.spec/guardrails/`.
- [✓] **Regresión textual contra baseline**: `diff` entre mensajes `⛔ Guardrail` en `.spec/guardrails/` y `/tmp/agex-010-snapshot/error-messages-before.txt` = 0. Los 7 mensajes pre-refactor aparecen literalmente (mismo texto, mismo comando de recuperación).
- [✓] Reducción de líneas en comandos: **116 eliminadas, 30 añadidas** = neto -86 líneas. Criterio cualitativo "del orden de 100 líneas menos" cumplido.
- [✓] **Smoke install**: `bash /Users/adan/Workspace/agex/install.sh` en tmpdir; exit 0; `.spec/guardrails/` presente en destino con los 5 archivos; `diff -r` fuente↔destino = `IDENTICAL`. Valida que el directorio nuevo se distribuye automáticamente vía ADR-0001 sin tocar `install.sh`.
- [Pendiente] Actualización de `.docs/services/agex/CONTEXT.md` → `/sdd-wrap` (nueva subsección "Guardrails" en "Componentes" + "Última actualización").

### Convenciones
- Idioma español preservado en todos los archivos nuevos.
- Tono imperativo conservado: `**Ejecuta esto antes de cualquier otro paso.**` en cada comando; `**Para aquí. No sigas.**` en cada archivo de guardrail.
- Formato uniforme en los 5 archivos de `.spec/guardrails/`: título `# Guardrail: <nombre>`, descripción one-liner, instrucción imperativa, bloque de error literal (fencing con ```), frase de parada.
- Patrón del nuevo bloque `## Guardrail` en comandos es consistente: intro + lista numerada que cita rutas explícitas + menciona excepciones relevantes (`sdd-do` y `sdd-review` mencionan el caso quick-fix para que el modelo componga).
- Sin dead code, sin prints debug, sin imports.

### ADRs
- **ADR-0001** (install.sh copia desde la fuente): no se contradice, se **aprovecha**. `cp -R "$SCRIPT_DIR/.spec" .` copia todo `.spec/` incluyendo el nuevo subdirectorio `guardrails/` sin modificación alguna a `install.sh`. Verificado con `diff -r` entre fuente y destino tras instalar: IDENTICAL.
- Sin otros ADRs. Sin conflictos.

### Riesgos
- **No-determinismo residual**: idéntico al patrón existente de skills invocadas por texto (`load-context`, `close-requirement`, `write-adr`, `update-service-context`). Documentado en `proposal.md` como aceptado; los tests manuales del criterio futuros deben ejercer cada guardrail para confirmar que el modelo sigue las referencias.
- **Sobrecarga cognitiva al leer un comando**: abrir `/sdd-wrap.md` ya no muestra el texto del guardrail inline. Mitigación: el comando cita la ruta explícita (`.spec/guardrails/review-approved.md`) y describe brevemente qué hace — un lector interesado tiene la ruta en el primer bloque.
- **`.docs/backlog/AGEX-007.md` y `analisis.md`**: modificaciones/archivos no pertenecen a este ticket (WIP del usuario); quedan fuera del commit.
- Sin efectos colaterales detectados.

### Bloqueantes
- Ninguno.

### Sugerencias (para `/sdd-wrap`)
- Actualizar `.docs/services/agex/CONTEXT.md`:
  - Añadir subsección en "Componentes": `### Guardrails (/.spec/guardrails/)` con lista y breve descripción de los 5 archivos.
  - Opcional: viñeta en "Decisiones clave" sobre el patrón de guardrails compartidos + referencia a AGEX-010 (sin ADR, es estructura interna).
  - "Última actualización": 2026-04-19 — AGEX-010.
- Tras el merge, considerar una pequeña verificación manual del no-determinismo: ejercer cada uno de los 5 guardrails (provocar el error, ver que el mensaje exacto sale) en una próxima iteración del flujo real.

### Veredicto
✓ Listo para /sdd-wrap
