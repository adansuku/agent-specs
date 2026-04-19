## Review: AGEX-007

### Cumplimiento de spec
- [✓] `grep -rn "openaccess-conventions"` sobre código (excluyendo `.git`, `worktrees` y `.docs/backlog/`) devuelve 0
- [✓] `sdd-do.md` conserva una línea sobre convenciones (opción B elegida)
- Backlog (`.docs/backlog/README.md`, `.docs/backlog/AGEX-007-*.md`) aún referencia la cadena; se limpia al archivar el ticket en /sdd-wrap

### Convenciones
- Idioma español preservado
- Viñeta + frase imperativa corta, coherente con las otras líneas del bloque "Ejecutar una tarea"
- Fuente canónica (`.spec/commands/sdd-do.md:53`) y heredoc (`install.sh:461`) sincronizados 1:1

### ADRs
- `.docs/adr/` vacío — sin conflictos posibles

### Riesgos
- El heredoc en `install.sh` usa delimitador `'EOF'` (no interpolado) — el cambio es puro texto estático, sin riesgo de expansión
- `install.sh` es idempotente: re-instalar regenera `.spec/commands/sdd-do.md` con la línea nueva. Instalaciones existentes no se tocan hasta re-ejecutar el script.
- `.claude/worktrees/*` contiene copias antiguas, pero están en `.gitignore` y no se publican

### Bloqueantes
- Ninguno

### Sugerencias
- `install.sh` duplica el contenido de `.spec/commands/*.md` vía heredocs; cualquier cambio obliga a sincronizar ambos. AGEX-009 aborda justo esa forma del instalador.
- Al archivar en /sdd-wrap, quitar la fila de AGEX-007 en `.docs/backlog/README.md:13`.

### Veredicto
✓ Listo para /sdd-wrap
