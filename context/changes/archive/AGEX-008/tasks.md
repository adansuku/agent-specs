# Tareas: AGEX-008

- [x] 1. Renombrar `.spec/config.yml` y su heredoc — `.spec/config.yml:1`, `install.sh:33`
- [x] 2. Renombrar `.spec/commands/sdd-start.md` y su heredoc — `.spec/commands/sdd-start.md:2,6`, `install.sh:97,101`
- [x] 3. Renombrar `CLAUDE.md` y su heredoc — `CLAUDE.md:1,3`, `install.sh:49,51`
- [x] 4. Renombrar `INSTALL.md` — `INSTALL.md:1,3,15,31,166,235`
- [x] 5. Corregir partes de `install.sh` fuera de heredocs — `install.sh:2,4,8,1327,1334` (header, `Uso:`, echo inicial, echo final, ejemplo `OA-1234` → `PROJ-123`)
- [x] 6. Verificar criterios de éxito — grep (libnova, OA-1234, bootstrap-libnova-spec), diff fuente/heredoc (sdd-start, CLAUDE.md, config.yml), smoke test en `/tmp`
