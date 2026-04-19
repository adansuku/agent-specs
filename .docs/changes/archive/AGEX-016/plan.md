# Plan: AGEX-016

## Estrategia
Usar `git mv` para renombrar la carpeta `.spec/` → `nova/` y los archivos de
comandos, preservando historial git. Inmediatamente después actualizar los
symlinks `.claude/` para que Claude Code no pierda los comandos. El resto son
sustituciones de texto sistemáticas con grep de verificación final.

El orden importa: rename → symlinks → contenido → documentación → verificación.

## Archivos a tocar

### Rename (git mv)
- `.spec/` → `nova/` (directorio completo)
- `nova/commands/sdd-do.md` → `nova/commands/nova-build.md`
- `nova/commands/sdd-plan.md` → `nova/commands/nova-plan.md`
- `nova/commands/sdd-review.md` → `nova/commands/nova-review.md`
- `nova/commands/sdd-spec.md` → `nova/commands/nova-spec.md`
- `nova/commands/sdd-start.md` → `nova/commands/nova-start.md`
- `nova/commands/sdd-status.md` → `nova/commands/nova-status.md`
- `nova/commands/sdd-wrap.md` → `nova/commands/nova-wrap.md`

### Symlinks (actualización)
- `.claude/commands` → `../nova/commands`
- `.claude/skills` → `../nova/skills`
- `.claude/agents` → `../nova/agents`

### Contenido — sustitucioes de texto
- `nova/commands/nova-*.md` (7 archivos) — `/sdd-*` → `/nova-*`, `.spec/` → `nova/`
- `nova/guardrails/branch-pattern.md` — `.spec/config.yml` → `nova/config.yml`
- `install.sh` — `rm -rf .spec`, `cp -R ... .spec`, symlinks `../.spec/`
- `CLAUDE.md` — "agex" → "nova-spec", `/sdd-*` → `/nova-*`, `.spec/` → `nova/`
- `README.md` — ídem
- `INSTALL.md` — ídem
- `.docs/backlog/README.md` — "agex" → "nova-spec"

## Archivos nuevos
Ninguno.

## Dependencias entre cambios

1. **`git mv .spec/ nova/`** — primero. Sin esto nada más tiene sentido.
2. **Rename comandos** — inmediatamente después del mv, aún dentro de nova/.
3. **Actualizar symlinks** — antes de tocar contenido, para restaurar
   funcionalidad de Claude Code en la rama.
4. **Contenido de comandos y guardrails** — orden indiferente entre sí.
5. **install.sh** — independiente del contenido, puede ir en paralelo.
6. **Documentación** (CLAUDE.md, README.md, INSTALL.md, backlog) — al final.
7. **Verificación** — siempre última.

## Safety net
- Reversibilidad: `git checkout -- .` + `git clean -fd` revierte todo;
  o `git revert` tras commit.
- Qué puede romperse: symlinks `.claude/` rotos entre tarea 1 y tarea 3
  (Claude Code sin comandos temporalmente — solo en la rama de trabajo).
- Plan de rollback: `git mv nova/ .spec/` + restaurar symlinks.

## Characterization tests
- [ ] Verificar referencias actuales: `grep -rn "sdd-\|\.spec/\|agex" .spec/ CLAUDE.md README.md INSTALL.md install.sh` — capturar lista baseline

## Verificación
1. `grep -r "sdd-\|\.spec/" nova/ CLAUDE.md README.md INSTALL.md install.sh` → 0 resultados
2. `grep -r "agex" nova/ CLAUDE.md README.md INSTALL.md install.sh` → 0 resultados
3. `bash install.sh` en `/tmp/nova-test` → crea `nova/`, no `.spec/`
4. `ls -la /tmp/nova-test/.claude/` → symlinks apuntan a `../nova/*`
