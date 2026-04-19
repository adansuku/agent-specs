# Tareas: AGEX-004

## Baseline (antes de tocar nada)

- [x] 1. Snapshot de baseline — `grep -rn "\.docs/changes/" .spec/ *.md install.sh > /tmp/agex-004-baseline.txt` y revisar que refleja el estado actual

## Config y comandos que consumen config

- [x] 2. Añadir `branch.base: main` a `.spec/config.yml` — `.spec/config.yml`
- [x] 3. Añadir lectura de `branch.base` en `/sdd-start` (fallback silencioso a `main`) y usarlo en el paso de checkout de rama base — `.spec/commands/sdd-start.md`
- [x] 4. Añadir `--base <branch.base>` al `gh pr create` de `/sdd-wrap` y actualizar sus rutas `<ticket>/` → `active/<ticket>/` y el move a `archive/<ticket>/` — `.spec/commands/sdd-wrap.md`

## Cambios de rutas en el resto de comandos

- [x] 5. Actualizar rutas a `active/<ticket>/` en `/sdd-spec` — `.spec/commands/sdd-spec.md`
- [x] 6. Actualizar rutas a `active/<ticket>/` en `/sdd-plan` — `.spec/commands/sdd-plan.md`
- [x] 7. Actualizar rutas a `active/<ticket>/` en `/sdd-do` — `.spec/commands/sdd-do.md`
- [x] 8. Actualizar rutas a `active/<ticket>/` en `/sdd-review` — `.spec/commands/sdd-review.md`
- [x] 9. Actualizar rutas a `active/<ticket>/` en `/sdd-status` — `.spec/commands/sdd-status.md`

## Filesystem

- [x] 10. Crear `.docs/changes/active/.gitkeep` — `.docs/changes/active/.gitkeep`

## install.sh (tres capas alineadas)

- [x] 11. Actualizar `mkdir -p` inicial de `install.sh` para incluir `.docs/changes/active/` y su `.gitkeep` — `install.sh`
- [x] 12. Añadir `branch.base: main` al heredoc del `config.yml` embebido en `install.sh` — `install.sh`
- [x] 13a. Sincronizar heredoc `CLAUDE.md` (añadir `/sdd-status`, rutas `active/`) — `install.sh`
- [x] 13b. Sincronizar heredoc `sdd-start` (lógica `branch.base` con fallback) — `install.sh`
- [x] 13c. Sincronizar heredoc `sdd-spec` (`## Guardrail` + rutas `active/`) — `install.sh`
- [x] 13d. Sincronizar heredoc `sdd-plan` (`## Guardrail` + rutas `active/`) — `install.sh`
- [x] 13e. Sincronizar heredoc `sdd-do` (`## Guardrail` + rutas `active/`) — `install.sh`
- [x] 13f. Sincronizar heredoc `sdd-review` (`## Guardrail` + rutas `active/`) — `install.sh`
- [x] 13g. Sincronizar heredoc `sdd-wrap` (`## Guardrail` + rutas `active/` + `--base <branch.base>`) — `install.sh`
- [x] 13h. Añadir heredoc nuevo de `sdd-status` en `install.sh` — `install.sh`

## Docs (raíz y servicio)

- [x] 14. Actualizar `CONTEXT.md` de agex: tabla "Memoria arquitectónica generada" con rutas `active/` y sección de configuración con `branch.base` — `.docs/services/agex/CONTEXT.md`
- [x] 15. Actualizar referencias de rutas en `CLAUDE.md` — `CLAUDE.md`
- [x] 16. Actualizar referencias de rutas en `README.md` (+ `/sdd-status` en tabla de comandos) — `README.md`
- [x] 17. Actualizar referencias de rutas en `INSTALL.md` (+ full sync: 7 comandos, árbol `active/`, `base: main`) — `INSTALL.md`

## Autorreferencia (último paso antes de verificar)

- [x] 18. Mover `.docs/changes/AGEX-004/` → `.docs/changes/active/AGEX-004/` (mv simple: la carpeta no estaba tracked todavía) para que `/sdd-wrap` encuentre este ticket en la ruta nueva

## Verificación final

- [x] 19. Ejecutar los greps de criterio de éxito (1 y 3 de `plan.md`) y confirmar 0 coincidencias fuera de `archive/`
- [x] 20. Diff byte a byte entre cada heredoc de comando en `install.sh` y el `.spec/commands/<nombre>.md` equivalente — corregir divergencias
