# Plan: AGEX-008

## Estrategia
Ediciones dirigidas archivo a archivo (sin `sed` global). Cada "pareja" fuente canónica en `.spec/` + su heredoc equivalente en `install.sh` se toca en la misma tarea, para que al terminar cada tarea el invariante `fuente == heredoc` se preserve. Los archivos sin duplicación (INSTALL.md, partes de install.sh fuera de heredocs) se agrupan en tareas propias.

## Archivos a tocar
- `.spec/config.yml` — comentario header línea 1.
- `.spec/commands/sdd-start.md` — `description` en frontmatter (línea 2) y primera línea del cuerpo (línea 6).
- `CLAUDE.md` — título (línea 1) y primera línea (línea 3).
- `INSTALL.md` — 6 menciones (título, cuerpo, "siguiente paso", referencia final).
- `install.sh` — 9 menciones de "libnova" + 1 de `OA-1234` + 1 de `bootstrap-libnova-spec.sh`, tanto fuera como dentro de heredocs.

## Archivos nuevos
Ninguno. Solo ediciones.

## Dependencias entre cambios
- Dentro de una tarea de "pareja fuente/heredoc", no importa el orden entre los dos lados, pero ambos deben cambiarse antes de cerrarla.
- La tarea de verificación va **al final**: depende de todas las anteriores.
- Resto de tareas son independientes entre sí.

## Safety net
- **Reversibilidad**: `git revert` o `git restore`. Todas las ediciones son texto estático en archivos de documentación/instalación.
- **Qué puede romperse**:
  - `install.sh` que queda inconsistente si solo se cambia fuente *o* heredoc, no ambos. Lo previene el agrupamiento por pareja.
  - `install.sh` que falla al ejecutarse por error de sintaxis Bash. Improbable: solo se cambian strings dentro de heredocs y comentarios.
- **Plan de rollback**: `git reset --hard origin/main` sobre la rama del ticket.

## Characterization tests
El propio criterio de éxito ya funciona como caracterización antes/después:

- Antes del cambio: `diff <(extraer-heredoc sdd-start install.sh) .spec/commands/sdd-start.md` → 0 (ambos lados con "libnova").
- Después del cambio: mismo diff → 0 (ambos lados con "agex").

No hace falta escribir tests nuevos. El framework no tiene suite de tests; la verificación es manual vía `grep` y `diff`.

## Verificación
Mapeo 1:1 contra los criterios de éxito de `proposal.md`:

- `grep -r "libnova" ... ` = 0 → tarea 6.
- `grep -r "OA-1234" ... ` = 0 → tarea 6.
- `grep -n "bootstrap-libnova-spec" install.sh` = 0 → tarea 6.
- `diff fuente heredoc` vacío para `sdd-start.md` y `CLAUDE.md` → tarea 6.
- Smoke test de `bash install.sh` en tmp con asserts de texto → tarea 6.
