## Review: AGEX-002

### Cumplimiento de spec

- [✓] `/sdd-spec` sin rama activa → `⛔ Guardrail`: `sdd-spec.md:14-20` comprueba patrón de rama y emite el mensaje correcto
- [✓] `/sdd-plan` sin `proposal.md` → `⛔ Guardrail`: `sdd-plan.md:20-27` comprueba existencia del archivo
- [✓] `/sdd-do` sin `plan.md`/`tasks.md` → `⛔ Guardrail`: `sdd-do.md:21-30` con excepción quick-fix correctamente implementada (`sdd-do.md:32-33`)
- [✓] `/sdd-review` con tareas pendientes → `⛔ Guardrail`: `sdd-review.md:22-29` comprueba `- [ ]` restantes; maneja los 3 casos (tasks.md existe, quick-fix sin tasks.md, no quick-fix sin tasks.md)
- [✓] `/sdd-wrap` sin `review.md` con `✓` → `⛔ Guardrail`: `sdd-wrap.md:21-38` en dos pasos: existencia del archivo y presencia de la línea `✓ Listo para /sdd-wrap`
- [✓] `sdd-review` persiste reporte en `review.md`: `sdd-review.md:105-107` añade instrucción explícita
- [✓] Sin regresión: el cuerpo de cada comando posterior al `## Guardrail` es idéntico al original

### Convenciones

- Posición consistente: `## Guardrail` siempre es la primera sección tras el lead, antes de `## Precondición`
- Prefijo `⛔ Guardrail:` uniforme en todos los mensajes de error
- Frases de acción (`Ejecuta /sdd-X primero`) en todos los mensajes
- Idioma español en todo el contenido nuevo ✓
- Sin dead code ni texto sobrante

### ADRs

- Sin conflictos (no hay ADRs vigentes en `.docs/adr/`)

### Riesgos

- Redundancia benigna en `sdd-spec`: la sección `## Precondición` original ya decía "pide al usuario que ejecute sdd-start". El nuevo guardrail es más preciso; no hay conflicto.
- Detección de rama en worktrees: el guardrail de `sdd-spec` menciona `claude/*` como rama sin patrón de ticket. Correcto para el entorno actual.

### Bloqueantes

Ninguno.

### Sugerencias

- En un ticket futuro podría extraerse la detección de rama a una skill `guardrail-check` reutilizable (fuera del alcance de AGEX-002).

### Veredicto

✓ Listo para /sdd-wrap
