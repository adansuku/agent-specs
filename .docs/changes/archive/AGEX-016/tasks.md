# Tareas: AGEX-016

- [x] 1. Characterization: capturar baseline de referencias actuales — `.spec/`, `CLAUDE.md`, `README.md`, `INSTALL.md`, `install.sh`
- [x] 2. `git mv .spec/ nova/` — renombrar directorio raíz
- [x] 3. Renombrar archivos de comandos: `git mv nova/commands/sdd-*.md nova/commands/nova-*.md` (7 archivos)
- [x] 4. Actualizar symlinks `.claude/`: apuntar a `../nova/*` en vez de `../.spec/*`
- [x] 5. Actualizar contenido de `nova/commands/nova-*.md` — sustituir `/sdd-*` → `/nova-*` y `.spec/` → `nova/` (7 archivos)
- [x] 6. Actualizar `nova/guardrails/branch-pattern.md` — `.spec/config.yml` → `nova/config.yml`
- [x] 7. Actualizar `install.sh` — rutas `.spec` → `nova` y symlinks
- [x] 8. Actualizar `CLAUDE.md` — "agex" → "nova-spec", `/sdd-*` → `/nova-*`, `.spec/` → `nova/`
- [x] 9. Actualizar `README.md` — ídem
- [x] 10. Actualizar `INSTALL.md` — ídem
- [x] 11. Actualizar `.docs/backlog/README.md` — "agex" → "nova-spec"
- [x] 12. Verificación final: greps de criterios de éxito + smoke test de install.sh
