## Review: AGEX-009 (re-ejecutado tras resolver B1)

### Cumplimiento de spec
- [✓] `wc -l install.sh` = **51** ≤ 80
- [✓] `grep -c "<<'EOF'" install.sh` = **0**
- [✓] `grep -c "cp -R"` = **1** ≥ 1
- [✓] Test funcional: smoke test en tmp genera árbol equivalente al baseline (22 archivos, symlinks correctos). Única diferencia documentada: `.spec/agents/.gitkeep` copiado por `cp -R` (consecuencia esperada del modelo "copia desde fuente").
- [✓] Test anti-drift: marker en `.spec/commands/sdd-start.md`, re-instalación, marker presente en destino. Archivo fuente restaurado bit-exact (`git diff --quiet` = 0).
- [✓] Test fallo controlado (orphan): `install.sh` huérfano → exit 1 + stderr `✗ No encuentro .../.spec/ o .../CLAUDE.md...`.
- [✓] Test fallo controlado (cwd == SCRIPT_DIR, **nuevo tras B1**): ejecutar desde `$SCRIPT_DIR` → exit 1 + stderr `✗ No ejecutes install.sh desde el propio repo agex (SCRIPT_DIR == PWD)`, y `.spec/` intacto.
- [Pendiente] ADR-0001 y actualización de CONTEXT.md → `/sdd-wrap`.

### Convenciones
- Idioma español preservado en comentarios y mensajes de error.
- Shebang, `set -e`, estructura seccionada conservadas.
- `cp -R` (POSIX portable entre BSD/macOS y GNU/Linux).
- `rm -rf .spec` antes de `cp -R` evita el gotcha de macOS "dst/src ya existe → copia recursiva dentro"; el guard nuevo impide que `rm -rf` destruya la fuente en el edge case.
- `SCRIPT_DIR` resuelto canónicamente con `cd "$(dirname "${BASH_SOURCE[0]}")" && pwd`.
- Mensajes de error a stderr, exit ≠ 0, mensaje de ayuda en segunda línea.
- Sin dead code, sin prints debug, sin imports sobrantes.

### ADRs
- `.docs/adr/` vacío. Sin ADRs vigentes → sin conflictos. Este ticket crea ADR-0001 en `/sdd-wrap`.

### Riesgos
- Resuelto B1: la combinación `rm -rf .spec` + `cp -R` ya no es destructiva en el edge case `$PWD == $SCRIPT_DIR` gracias al guard en `install.sh:16-20`.
- Anomalía operativa anotada como aprendizaje: `head -n -N` no existe en BSD/macOS; usar `sed -i '' -e '$d'` para quitar líneas del final en scripts portables.
- Ningún otro efecto colateral detectado.

### Bloqueantes
- Ninguno.

### Sugerencias
- Actualizar en `/sdd-wrap` la sección "Edge case — invocar con `SCRIPT_DIR == PWD`" de `proposal.md` (cuando se archive): el comportamiento pasó de "inocuo" a "aborta con error claro". El mensaje del guard puede documentarse también en `INSTALL.md` > "Problemas comunes".
- `cp -R src/. dst/` (trailing dot) sería una alternativa no-destructiva aunque fuente = destino; se descartó a favor del guard explícito para fallar temprano con mensaje claro.

### Veredicto
✓ Listo para /sdd-wrap
