# Review: NOVA-40

> Base del diff: `git diff origin/develop...HEAD` está vacío (la rama aún no tiene
> commits); este review se basa en `git diff HEAD` (working tree + untracked) que
> es el delta que verá el PR tras `/nova-wrap`.
>
> Archivos cubiertos:
> - Nuevos: `novaspec/commands/nova-init.md`, `novaspec/templates/init-project.md`,
>   `novaspec/templates/init-service.md`, `context/changes/active/NOVA-40/{proposal,tasks,smoke-test}.md`.
> - Modificados: `README.md`, `context/services/novaspec.md`.

## Cumplimiento de spec

- [✓] **Comando `novaspec/commands/nova-init.md` existe** con cabecera YAML, precondiciones, 6 pasos, reglas. Estilo consistente con `novaspec/commands/nova-status.md` (description + argument-hint, "Eres un comando…", pasos numerados, sección Reglas final).
- [✓] **Plantillas externas** en `novaspec/templates/init-project.md` y `novaspec/templates/init-service.md` — respeta `decisions/templates-externos-a-comandos.md`.
- [✓] **Escaneo heurístico**: Paso 1 lista los 6 marcadores de la spec (`package.json`, `pyproject.toml`, `go.mod`, `Gemfile`, `Cargo.toml`, `composer.json`) top-level; Paso 2 mismo set en `services/|apps/|packages/*` con "no escanees fuera" explícito.
- [✓] **Extracción de scripts + Makefile**: Paso 1 lo especifica; placeholder `{{DETECTED_COMMANDS}}` en `init-project.md:18`.
- [✓] **Project + N services**: Paso 3 prepara `project.md` y un `<svc>.md` por servicio detectado; plantillas tienen las secciones de la spec (Qué es / Arquitectura / Testing / Comandos útiles / Restricciones / Posibles decisiones en project; Qué hace / Interfaces / Dependencias / Lo que no es obvio / Decisiones / Última actualización en service).
- [✓] **Idempotencia vía `.draft.md`**: Paso 4 escribe `<basename>.draft.md` si ya existe, con sufijos numéricos si también choca. Verificado en smoke Caso 2 (`md5` match originales, se generan `project.draft.md`, `api.draft.md`, `web.draft.md`).
- [✓] **Checkpoint humano**: Paso 5 presenta lista + preview ~20 líneas + `[y/N]` antes de escribir — respeta `decisions/checkpoints-humanos-obligatorios.md`.
- [✓] **Precondiciones edge**: context/ no existe → abort; PWD == repo nova-spec → abort (detecta `novaspec/commands/nova-start.md` adyacente); working tree sucio → warn no bloqueante.
- [✓] **Docs actualizados**: `README.md` pasa de 7 a 8 comandos en la tabla y añade nota "opcional, se usa una sola vez"; `context/services/novaspec.md` pasa de "7 slash commands" a "8", añade fila `/nova-init` y actualiza el listado de templates — se mantiene en 58 líneas (≤80 per `memoria-sencilla.md`).
- [✓] **Criterio de éxito "context-loader sin Huecos"**: smoke-test.md:78-89 registra `project ✓, api ✓, web ✓` sin Huecos tras bootstrap en `/tmp/nova-init-monorepo`.
- [✓] **No sobrescribe existentes**: smoke Caso 2 confirma el hash original intacto.
- [✓] **TODOs explícitos**: ambas plantillas marcan `[TODO: …]` en cada campo no inferible; el header HTML-comment `<!-- Generado por /nova-init. Revisa y elimina los TODO antes de commitear. -->` guía al humano.

Sin desviaciones no justificadas. Los 11 checkboxes de `tasks.md` están marcados.

## Convenciones

- **Estilo comando**: `nova-init.md` replica el patrón de `nova-status.md` (cabecera YAML idéntica, tono imperativo, pasos numerados con guión largo, tabla markdown de marcadores, sección `## Reglas` final con bullets). Consistente.
- **Plantillas**: `init-service.md` ≤ 80 líneas (27) y replica el esquema de `context/services/novaspec.md` (Qué hace / Interfaces / Dependencias / Lo que no es obvio / Decisiones / Última actualización). `init-project.md` 28 líneas, coherente.
- **Placeholders `{{…}}`**: convención uniforme en ambas plantillas (`{{DETECTED_COMMANDS}}`, `{{SERVICE_NAME}}`, `{{MANIFEST}}`, `{{TOOLCHAIN}}`, `{{DATE}}`).
- **Bug fix del `{{DATE}}`**: `init-service.md:27` usaba `NOVA-40 — bootstrap…` hardcodeado. Corregido durante build a `{{DATE}} — bootstrap con /nova-init`; correcto: el ticket que creó la plantilla no debe aparecer como metadato del consumidor.
- **Sin dead code / prints / imports sobrantes** (todo markdown).
- **Argument-hint vacío** en `nova-init.md:3` (`argument-hint:`): no recibe argumentos, así que el valor vacío es intencionalmente honesto. Consistente con `nova-wrap` / `nova-spec` / `nova-plan` (revisar si estos también usan `argument-hint:` vacío sería consistente; no es bloqueante).

Sin incidencias bloqueantes de estilo.

## Decisiones

Contraste contra `context/decisions/*.md` (sin entrar en `archived/`):

- `checkpoints-humanos-obligatorios.md` → **respetada**: Paso 5 pide `y/N` antes de cualquier escritura.
- `templates-externos-a-comandos.md` → **respetada**: plantillas viven en `novaspec/templates/`, no inline.
- `patron-subagentes.md` → **respetada**: la heurística no carga >2 artefactos voluminosos (lee `ls` + `package.json` + `Makefile` raíz + directorios de 3 carpetas), inline es lo correcto; la spec lo documenta.
- `memoria-sencilla.md` → **respetada**: `context/services/novaspec.md` sigue siendo 58 líneas (≤80); no se crean ADRs automáticos; Paso 3 project.md deja "Posibles decisiones" como bullets-TODO, no como archivos en `decisions/`; regla explícita en `## Reglas` del comando: "No crees archivos en `context/decisions/` bajo ninguna circunstancia".
- `convencion-context-git-vs-local.md` → **respetada**: los archivos generados (`context/services/project.md`, `<svc>.md`) pertenecen a la columna "git" (coordinación); el comando no toca `notes.md`, `.env` ni `backlog/`.
- `naming-nova-spec.md`, `install-sh-copia-desde-fuente.md`, `symlinks-vs-copia.md`, `repo-unico-vs-split.md`, `context-contenedor-unico-memoria.md`, `guardrails-por-paso.md`, `quick-fix-salta-spec-y-plan.md` → sin relación directa, sin conflicto.

Sin conflictos con decisiones vivas.

## Riesgos

- **Heurísticas falsas (detecta servicio inexistente)**: mitigado — checkpoint humano antes de escribir + default `.draft.md` en re-runs + TODOs explícitos si algo no se infiere.
- **Repo gigante ralentiza escaneo**: mitigado — escaneo acotado a raíz + `services/|apps/|packages/*` sin recursión profunda. El comando lo declara explícitamente (`No escanees fuera de esos 3 directorios convencionales`).
- **Drift en conteo de comandos** (`README.md` y `services/novaspec.md` mencionan "7" / "8"): actualizado en ambos sitios en este mismo diff. Riesgo residual: próximo comando añadido deberá acordarse de subirlo a 9 — no es de este ticket.
- **Ejecución dentro del repo fuente `nova-spec`**: mitigado por precondición 2 (detecta `novaspec/commands/nova-start.md` adyacente). Smoke Caso 5 lo cubre.
- **Context/ ausente**: mitigado por precondición 1. Smoke Caso 4 lo cubre.
- **Safety net** de `tasks.md` ("reversibilidad por `git revert`, rollback limpio") es válido: al ser 100% markdown + archivos nuevos + 2 docs tocados, un `git revert` del commit deja el repo en el estado pre-ticket sin efectos colaterales.
- **Verificación manual pendiente** (smoke-test.md:97-103): ejecutar `/nova-init` interactivamente vía Claude Code en un repo real. No es bloqueante para `/nova-wrap` (los 5 smokes automatizables ya pasan); el propio smoke-test la documenta como gate del usuario pre-merge. Queda claro en el artefacto.

Ninguno sin mitigar.

## Bloqueantes

- Ninguno.

## Sugerencias

- **Mensaje de abort PWD == repo nova-spec**: la precondición 2 detecta la condición vía `novaspec/commands/nova-start.md`. Si el usuario borra ese archivo o el repo fuente se renombra, la detección falla silenciosamente y el comando seguiría. Mitigación alternativa (opcional, no bloqueante): chequear también `novaspec/commands/nova-init.md` adyacente, o comparar `realpath $PWD` con un marker único. No es del scope del ticket; podría anotarse como follow-up si aparece algún problema en la verificación manual pendiente.
- **Plantilla `init-project.md` — "Qué es"**: la nota inline menciona "se infiere del README raíz si existe". El comando actual no tiene un Paso que extraiga la primera línea del README raíz para rellenar `[TODO: describe en una frase qué hace este proyecto]`. Es consistente (nada se inventa), pero la nota de la plantilla sugiere algo que no ocurre. Opcional: eliminar la mención "se infiere del README" de la plantilla, o añadir un Paso que extraiga la H1 del README como borrador (con TODO marcado). No bloquea.
- **Símbolos en los mensajes de abort**: `nova-init.md` usa `✗` para errores y `⚠` para warnings. Consistente con otros comandos. Nada que cambiar.
- **Tabla de marcadores duplicada** entre Paso 1 y Paso 2 (misma lista de 6 manifests). Se podría factorizar como "ver Paso 1", pero la repetición aquí ayuda a leer el Paso 2 independientemente. Dejar como está.

## Veredicto

✓ Listo para /nova-wrap
