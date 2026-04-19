## Review: AGEX-008

### Cumplimiento de spec
- [✓] `grep -rn "libnova"` sobre código (excluyendo `.git`, `archive/`, `backlog/`, `worktrees/`, los artefactos propios del ticket en `.docs/changes/active/AGEX-008/` y CONTEXT.md que se actualiza en /sdd-wrap) = 0
- [✓] `grep -rn "OA-1234"` sobre código (mismas exclusiones) = 0
- [✓] `grep -n "bootstrap-libnova-spec" install.sh` = 0
- [✓] `diff` fuente↔heredoc para `.spec/config.yml` ↔ `install.sh:33`, `CLAUDE.md` ↔ `install.sh:49`, `.spec/commands/sdd-start.md` ↔ `install.sh:97` = 0 en los tres casos
- [✓] Smoke test `bash install.sh` en `/tmp`: exit 0, log incluye `→ Creando estructura de agex...`, `✓ agex instalado`, `/sdd-start PROJ-123`, y los archivos generados (`CLAUDE.md`, `.spec/config.yml`, `.spec/commands/sdd-start.md`) contienen 0 ocurrencias de "libnova"

### Convenciones
- Wording consistente: "framework agex", "flujo agex", "Proyecto con agex", "✓ agex instalado"
- Idioma español preservado en todos los cambios
- Formato de cada archivo intacto: frontmatter YAML de `sdd-start.md`, headings `#` de markdown, comentarios `#` de YAML/Bash
- Sin dead code, sin prints de debug, sin imports sobrantes
- `install.sh` conserva el marcador `\ No newline at end of file` (el archivo original ya lo tenía; preservado)

### ADRs
- `.docs/adr/` vacío — sin conflictos posibles

### Riesgos
- **Invariante fuente↔heredoc**: verificado con `diff` en las tres parejas. Pasa.
- **`.claude/worktrees/`**: copias locales siguen con texto antiguo, pero están en `.gitignore` y no se publican. Sin impacto.
- **Instalaciones previas**: no se tocan hasta re-ejecutar `install.sh`. Comportamiento documentado en la spec como esperado.
- **Shebang y set -e de `install.sh`**: intactos.

### Bloqueantes
- Ninguno

### Sugerencias
- `/sdd-wrap` debe ejecutar explícitamente:
  1. Actualizar `.docs/services/agex/CONTEXT.md:167-173` para quitar/reformular la "peculiaridad" del rename (ya no es pendiente).
  2. Archivar `.docs/changes/active/AGEX-008/` → `.docs/changes/archive/AGEX-008/` (así desaparecerán las últimas ocurrencias de "libnova" y "OA-1234" del grep de código activo).
  3. Borrar localmente `.docs/backlog/AGEX-008-rename-libnova-a-agex.md` y su fila en `.docs/backlog/README.md` (ignorado por git, solo higiene local).

### Veredicto
✓ Listo para /sdd-wrap
