# Review: AGEX-016

## Cumplimiento de spec

- [✓] `.spec/` renombrado a `novaspec/` con `git mv` — historial preservado
- [✓] 7 comandos renombrados: `sdd-*.md` → `nova-*.md`
- [✓] Symlinks `.claude/` apuntan a `../novaspec/*`
- [✓] Contenido de comandos: sin referencias a `/sdd-*` ni `.spec/`
- [✓] Guardrails actualizados: `novaspec/config.yml` y comandos `/nova-*`
- [✓] `install.sh` actualizado: guarda, rutas, symlinks, mensajes
- [✓] `CLAUDE.md`, `README.md`, `INSTALL.md` actualizados completamente
- [✓] `backlog/README.md` actualizado: "agex" → "nova-spec"
- [✓] Criterio grep: 0 referencias a `sdd-`, `.spec/`, `agex` en archivos activos
- [✓] Smoke test: `install.sh` crea `novaspec/` con `nova-*.md` y symlinks correctos
- [~] Desviación declarada: carpeta final es `novaspec/` (no `nova/` de la spec original) — decisión tomada por el usuario durante `/nova-build`, dentro de alcance

## Convenciones

- Sin incidencias. Todos los rename con `git mv` (historial limpio).
- El estado interno `do` en `nova-status.md` se mantiene como nombre de paso (`novaspec/commands/nova-status.md:111`) — correcto, es el estado del flujo, no el comando.
- `novaspec/config.yml` — comentario de la línea 9 actualizado a `/nova-start` y `/nova-wrap`.

## ADRs

- ADR-0001 (install.sh copia desde fuente): el mecanismo `cp -R` se mantiene intacto, solo cambian las rutas. Sin conflicto.

## Riesgos

- Repos que ya tengan `.spec/` instalado (instalaciones previas de agex) no se migran automáticamente — fuera de alcance declarado y esperado.
- El `rm -rf novaspec` en `install.sh` es correcto: borra el novaspec existente antes de copiar la versión nueva desde la fuente, igual que hacía antes con `.spec/`.

## Bloqueantes

Ninguno.

## Sugerencias

- El título de AGEX-015 en `backlog/README.md` aún dice "nova-wrap limpia el archivo de backlog al cerrar" — correcto tras la actualización, pero el ticket en sí todavía referencia `sdd-wrap` en su contenido interno (`AGEX-015.md`). Es cosmético y fuera de alcance.

## Veredicto

✓ Listo para /nova-wrap
