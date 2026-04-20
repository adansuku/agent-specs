# Review: NOVA-37

## Cumplimiento de spec

- [✓] `ls context/` sin `adr`, `glossary.md`, `post-mortems`: verificado — salida `backlog changes decisions gotchas services`.
- [✓] `wc -l context/services/agex.md` ≤ 80: medido 55 líneas (`context/services/agex.md`).
- [✓] Criterio canónico `grep -rn "context/adr\|glossary\|post-mortem\|ADR-000\|write-adr" novaspec/ AGENTS.md`: vacío.
- [✓] Guardrail `old-decision-archived` existe (`novaspec/guardrails/old-decision-archived.md`) y está referenciado desde `novaspec/commands/nova-wrap.md:10` y listado como #6 en `novaspec/guardrails/checklist.md:31-34`.
- [✓] Estructura nueva creada: `context/decisions/` (con 9 archivos + `archived/.gitkeep` + `.gitkeep`), `context/gotchas/.gitkeep`.
- [✓] Supersede = `git mv` + `> Supersedes:` documentado en `novaspec/skills/write-decision/SKILL.md:20-26` y validado por guardrail.
- [✓] Skill renombrada `write-adr` → `write-decision` y sus referencias actualizadas (`AGENTS.md:18`, `novaspec/commands/nova-wrap.md:21`).
- [✓] `decisions/archived/` presente pero excluida explícitamente en `novaspec/agents/context-loader.md:15-18` y `novaspec/agents/nova-review-agent.md:20`.
- [✓] Criterio spec "`grep -r "ADR-000" context/decisions/` vacío": verificado tras corrección. `context/decisions/patron-subagentes.md:31` actualizado de `| Naming | kebab-case (ADR-0002) |` a `| Naming | kebab-case (ver decisions/naming-nova-spec.md) |`.

## Convenciones

- Consistencia del modelo nuevo en los archivos tocados por el plan: OK. Naming concept-case para decisiones extraídas (`symlinks-vs-copia`, `guardrails-por-paso`, etc.) cumple la regla.
- `context/services/agex.md` sigue el template declarado en tasks 3.1 (Qué hace / Interfaces / Lo que no es obvio / Decisiones relevantes) con punteros `→ decisions/<file>.md`. Sin duplicar contenido.
- Plantilla `context/decisions/install-sh-copia-desde-fuente.md` aún contiene secciones ceremoniales heredadas del viejo formato ADR (Fecha/Estado/Ticket, Contexto, Decisión, Consecuencias, Alternativas) y menciona `.spec/` y `.docs/adr/` en su cuerpo (líneas 11, 21, 44-45, 52, 57-58, 72-73, 77-81, 88-89). Esto no rompe ningún criterio duro de la spec (`similarity index 98%` con el archivo original) y no estaba listado como edición en el plan (2.4 acotaba solo al título). Observación: el archivo migrado arrastra vocabulario del modelo viejo pero no se clasifica como bloqueante porque la spec solo exigió quitar el prefijo `ADR-NNNN` del título.
- `AGENTS.md:27` sigue diciendo "Base branch: `main`" mientras `novaspec/config.yml:13` fue cambiado a `develop`. Inconsistencia interna, pero ambos cambios están fuera del alcance de NOVA-37.

## Decisiones

- Sin contradicciones con `context/decisions/*.md` (decisiones vivas post-migración): las decisiones extraídas son coherentes con la nueva estructura; el propio cambio es el que las establece.
- `context/decisions/patron-subagentes.md` y `install-sh-copia-desde-fuente.md` mantienen referencias internas a `ADR-0002`, `ADR-0001`, `.spec/` y `.docs/adr/` — información histórica preservada. No entra en conflicto con ninguna decisión viva, pero contradice parcialmente el criterio de éxito de la propia spec (ver Cumplimiento).

## Riesgos

- Forward-reference `context/decisions/memoria-sencilla.md` aparece en `AGENTS.md:43` y `novaspec/README.arch.md:30`. El archivo NO existe aún. Spec dice explícitamente que se creará en `/nova-wrap`. Observación prevista, **no bloqueante**.
- Cambios no previstos en el alcance de la spec:
  - `novaspec/config.yml:13` `base: main` → `base: develop` (no mencionado en proposal/plan/tasks).
  - `.gitignore` añade `.env` (no mencionado en proposal/plan/tasks).
  Ambos son cambios menores sin riesgo técnico pero violan la regla "no propongas cambios fuera del alcance de la spec" y contaminan el diff del ticket. El usuario debe decidir si los mantiene aquí o los mueve a otro ticket.
- Residuales por propagación incompleta en plantillas y comandos (todos fuera del alcance declarado del plan):
  - `novaspec/templates/review.md:9` (`## ADRs` como sección).
  - `novaspec/templates/proposal.md:36-37` (`ADRs referenciados`, `¿Requiere ADR nuevo?`).
  - `novaspec/templates/pr-body.md:10-11,19` (sección `ADRs`, checklist `ADR creado`).
  - `novaspec/templates/commit.md:6` (`ADRs: <ADR-NNNN si aplica>`).
  - `novaspec/templates/ticket-summary.md:11` (`ADRs:`).
  - `novaspec/commands/nova-review.md:2,33` (description + regla mencionan "ADRs").
  - `novaspec/skills/update-service-context/SKILL.md:58` (`No repitas ADRs; usa "Ver ADR-NNNN"`).
  Ninguno aparece en los criterios duros de la spec (que son específicos: `context/adr`, `glossary`, `post-mortem`, `ADR-000`, `write-adr`) y los templates no estaban listados en los "Archivos a tocar". Quedan como deuda técnica que previsiblemente se arrastre al próximo ticket que genere una `proposal.md` o `pr-body.md`. Observación, no bloqueante.
- Safety net: el plan declara rollback = `git checkout develop` y snapshot baseline (`/tmp/nova37-before.txt`, `/tmp/nova37-refs-before.txt`). Ejecutado según tasks 0.1 y 0.2. OK.

## Bloqueantes

Ninguno tras corrección. El bloqueante original (`context/decisions/patron-subagentes.md:31` con `ADR-0002`) se corrigió durante `/nova-review`: la fila se reescribió a `| Naming | kebab-case (ver decisions/naming-nova-spec.md) |`. Verificado con `grep -rn "ADR-000" context/decisions/` → vacío.

## Sugerencias (no bloqueantes) — decisiones del usuario

- **Propagar vocabulario "decisiones" a plantillas y `nova-review.md`**: ticket de seguimiento futuro (NOVA-38 o equivalente).
- **Limpiar referencias internas a `.spec/`/`docs/adr/` en archivos migrados**: futuro, junto con el anterior.
- **`.gitignore` (`+ .env`) y `novaspec/config.yml` (`base: main → develop`)**: se incluyen en el PR de NOVA-37 (confirmado por el usuario). Justificar en el commit message como setup acompañante.
- **Forward-reference a `context/decisions/memoria-sencilla.md`**: el archivo se creará en `/nova-wrap`.

## Veredicto

✓ Listo para /nova-wrap
