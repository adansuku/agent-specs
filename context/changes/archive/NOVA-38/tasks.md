# Tareas: NOVA-38

- [x] 1. Audit de secretos en historial: `git log -p | grep -iE 'token|secret|password|api_key|jira_api'` y revisar hits. Si hay, detener y rotar antes de seguir — historial del repo
- [x] 2. Smoke baseline: `mkdir /tmp/nova-smoke-pre && cd /tmp/nova-smoke-pre && git init && bash <ruta>/install.sh --target claude`, verificar estructura creada. Estado de referencia pre-cambios — sin cambios al repo
- [x] 2b. Fix `install.sh`: reemplazar `mkdir -p context/{adr,services,post-mortems,...}` + `touch context/glossary.md` por `mkdir -p context/{decisions,gotchas,services,changes/{active,archive}}` en ambas ramas (claude y opencode). Re-verificar con un smoke rápido — `install.sh`
- [x] 3. Añadir `notes.md` al `.gitignore`; revisar si falta algún otro local file. Verificar con `git check-ignore notes.md` — `.gitignore`
- [x] 4. Crear ADR `context/decisions/convencion-context-git-vs-local.md` (≤ 50 líneas): qué de `context/` va en git vs local, aplicable a este repo y a consumidores — archivo nuevo
- [x] 5. Crear `CONTRIBUTING.md` mínimo: cómo proponer cambios, convención de ramas, dónde abrir issues — archivo nuevo
- [x] 6. Reescribir `README.md` para lector externo: qué es nova-spec, por qué, quickstart (clone + `bash install.sh`), enlaces a `INSTALL.md` y `CONTRIBUTING.md` — `README.md`
- [x] 6b. Fix `install.sh`: no filtrar `novaspec/config.yml` del maintainer. (a) backup del `config.yml` del destino si existe, (b) `rm -f novaspec/config.yml` tras la copia, (c) restaurar el backup o hacer `cp config.example.yml config.yml` en instalación limpia. Aplica a ambas ramas (claude y opencode) — `install.sh`
- [x] 7. Smoke test final: `mkdir /tmp/nova-smoke-post && cd /tmp/nova-smoke-post && git init && bash <ruta>/install.sh --target claude`, verificar estructura + abrir Claude Code + ejecutar `/nova-status` (debe reportar "no hay ticket activo"). Registrar evidencia (salida + output de `ls -la .claude/`) en `context/changes/active/NOVA-38/smoke-test.md` — archivo nuevo

      Nota: la parte de "abrir Claude Code + /nova-status" queda pendiente de verificación manual por el usuario (documentada en smoke-test.md §Verificación manual pendiente). Debe completarse antes de T9.
- [x] 8. Rename del repo en GitHub: `gh repo rename nova-spec --repo adansuku/NovaSpec` y `git remote set-url origin git@github.com:adansuku/nova-spec.git`; verificar `git push --dry-run` — remote
- [x] 9. Hacer público: `gh repo edit adansuku/nova-spec --visibility public --accept-visibility-change-consequences`; smoke test desde clone limpio de la URL pública para confirmar que todo sigue funcionando — GitHub + verificación

      Nota: el repo ya estaba público al llegar a T9. T9 ejecutada de facto por estado previo; sigue siendo válido hacer smoke desde clone público.
