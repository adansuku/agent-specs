# Plan: AGEX-009

## Estrategia
Capturar primero un snapshot del output del `install.sh` actual (characterization test) para tenerlo como oráculo. Luego reescribir `install.sh` de ~1334 líneas a ~50 líneas usando `cp -r` desde `SCRIPT_DIR`. Verificar que el nuevo instalador produce exactamente el mismo árbol de archivos que el snapshot. Actualizar INSTALL.md. Crear el ADR y actualizar CONTEXT.md en `/sdd-wrap`.

## Archivos a tocar
- `install.sh` — reescritura completa: sustituir los 10 heredocs `cat > X <<'EOF' ... EOF` y el bloque de echos iniciales por `cp -r "$SCRIPT_DIR/.spec" .` y `cp "$SCRIPT_DIR/CLAUDE.md" .`. Preservar: mkdir de `.docs/` y archivos vacíos, symlinks `.claude/*`, echos de usuario, set -e, shebang.
- `INSTALL.md` — secciones "Instalación rápida" (líneas 21-42), "Actualización del framework" (~164-175) y cualquier referencia a "copiar install.sh". Resto intacto.

## Archivos nuevos
- Ninguno en `/sdd-do`. Los artefactos del ticket (`proposal.md`, `plan.md`, `tasks.md`, `review.md`) ya existen en `.docs/changes/active/AGEX-009/`.
- En `/sdd-wrap`:
  - `.docs/adr/ADR-0001-install-sh-copy-from-source.md` — primer ADR del repo.

## Dependencias entre cambios
- Tarea 1 (snapshot) debe ejecutarse **antes** de la reescritura, con el `install.sh` actual todavía intacto, para capturar el comportamiento de referencia.
- Tareas 2 (reescritura) y 4 (INSTALL.md) son independientes entre sí, pero ambas deben preceder a la tarea 5 (verificación final).
- Tarea 3 (smoke test + diff contra snapshot) valida la tarea 2; va inmediatamente después.
- La creación del ADR y la actualización del CONTEXT.md se hacen en `/sdd-wrap`.

## Safety net
- **Reversibilidad**: `git revert` del commit del ticket restaura el `install.sh` completo y el INSTALL.md. `.spec/` y `CLAUDE.md` no se tocan en este ticket, así que el material canónico sobrevive a cualquier rollback.
- **Qué puede romperse**:
  - Si se olvida copiar `.spec/agents/` (directorio vacío), el símlink `.claude/agents` puede quedar colgando. Mitigación: `cp -r` copia directorios vacíos; si no, crear `.spec/agents/` con `mkdir -p` explícito como ahora.
  - Si `SCRIPT_DIR` se resuelve mal (symlinks en el path del script), `cp` copia archivos incorrectos. Mitigación: `SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)` es canónico y resuelve symlinks.
  - Si alguien ejecuta el nuevo install dentro del propio repo agex, `cp -r .spec/ .` intenta copiarse sobre sí mismo. Mitigación: `set -e` + mensaje de `cp` (aceptable, documentado en spec como "inocuo").
- **Plan de rollback**: `git reset --hard origin/main` sobre la rama del ticket antes de mergear; o `git revert <commit>` tras mergear. Ambas rutas restauran el `install.sh` heredoc-based sin side effects (el destino de una instalación previa no se toca).

## Characterization tests
Antes de tocar `install.sh`:
- [ ] Ejecutar `install.sh` actual en un tmpdir limpio y capturar:
  - Lista de archivos creados (`find . -type f -o -type l | sort`)
  - Hashes de todos los archivos (`find . -type f -exec sha256sum {} \;`)
  - Exit code, stdout/stderr del proceso
  - `readlink` de cada symlink en `.claude/`
- [ ] Guardar este snapshot como referencia en `/tmp/agex-snapshot-baseline/`. Es el oráculo contra el que se compara el nuevo instalador.

## Verificación
Mapeo 1:1 con los criterios de éxito de `proposal.md`:

- `wc -l install.sh` ≤ 80 → tarea 5.
- `grep -c "<<'EOF'" install.sh` = 0 → tarea 5.
- `grep -c "cp -r" install.sh` ≥ 1 → tarea 5.
- Test funcional (diff -r contra snapshot baseline) → tarea 3.
- Test anti-drift (editar .spec/, re-instalar, verificar cambio) → tarea 5.
- Test fallo controlado (install.sh huérfano sin .spec/ hermano) → tarea 5.
- ADR-0001 existe y formato correcto → `/sdd-wrap`.
