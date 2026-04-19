# Review: AGEX-004

## Cumplimiento de spec

### Criterios de éxito observables

- [✓] **Criterio 1** (grep 0 coincidencias fuera de `active/`/`archive/`): verificado en tarea 19. 0 refs a `\.docs/changes/<` y 0 a `\.docs/changes/[A-Z]` fuera de archive.
- [✓] **Criterio 2** (`ls .docs/changes/` muestra solo `active/` y `archive/`): confirmado.
- [✓] **Criterio 3** (`.spec/config.yml` contiene `branch.base`): línea 9, valor `main`.
- [⏳] **Criterio 4** (simulación de `/sdd-start` con ticket de prueba): requiere repo externo post-merge. Lógica revisada en `.spec/commands/sdd-start.md:38-59` e `install.sh:104-138`; la resolución `branch.base` → `develop` → prompt es correcta.
- [⏳] **Criterio 5** (`/sdd-wrap` de AGEX-004 archiva y abre PR con `--base`): se verificará al ejecutar `/sdd-wrap`. Logic revisada en `.spec/commands/sdd-wrap.md:74` (move desde `active/`) y `:89-95` (`gh pr create --base`).

### Decisiones cerradas (proposal.md)

- [✓] #1 Nombres en inglés: `active/`, `archive/`.
- [✓] #2 Fallback a `develop` (actualizado durante `/sdd-do`): reflejado en ambos comandos y en los heredocs de `install.sh`.
- [✓] #3 `branch.base` aplica a `/sdd-start` y `/sdd-wrap`.
- [✓] #4 Sin soporte dual de rutas: clean break completo.
- [✓] #5 `install.sh` íntegro — se actualizó además la deuda pre-existente de AGEX-002 (guardrails) y AGEX-003 (heredoc de `sdd-status`), por opción B aprobada en conversación.
- [✓] #6 AGEX-004 como primer ticket bajo convención nueva: carpeta movida a `.docs/changes/active/AGEX-004/` en tarea 18. Redacción anterior ("lógica vieja") corregida en el proposal.
- [✓] #7 `.gitkeep` solo en `active/`.

### Alcance fuera-de-proposal ejecutado (con aprobación explícita)

- Full sync de `install.sh`: añadidos los `## Guardrail` de AGEX-002 a los 5 heredocs existentes y añadido el heredoc completo de `sdd-status` (AGEX-003). Cierra deuda pre-existente del instalador.
- Full sync de `README.md` e `INSTALL.md` con `/sdd-status` en tabla de comandos y número de comandos 6→7.
- `CONTEXT.md` del servicio ampliado con fila `review.md` y nota sobre partición `active/` ↔ `archive/`.

## Convenciones

- Markdown consistente (tablas alineadas, encabezados uniformes).
- Español en prosa, inglés en nombres de carpetas (per decisión #1).
- `.gitkeep` vacío (convención estándar).
- `install.sh` usa `<<'EOF'` (expansión desactivada) — mantenido.
- Paridad byte-a-byte entre heredocs y archivos canónicos verificada en tarea 20 (7 comandos + `config.yml` + `CLAUDE.md`).

## ADRs

Sin conflictos. `.docs/adr/` vacío; no se requiere ADR nuevo (decisión explícita del proposal: reorganización implícita → explícita, sin cambio de modelo mental).

## Riesgos

- **Divergencia install.sh ↔ .spec/commands/**: mitigado en tarea 20 — diff byte-a-byte con 0 divergencias.
- **Bootstrap del propio ticket**: mitigado — tarea 18 movió la carpeta a `active/` antes del wrap.
- **Repos con `config.yml` antiguo**: mitigado con fallback a `develop` + prompt si no existe.
- **Referencias olvidadas**: criterio #1 con 0 coincidencias.

## Bloqueantes

Ninguno. La spec se cumple y los riesgos están mitigados.

## Anomalías pre-`/sdd-wrap` (fuera de alcance AGEX-004)

Al inspeccionar `git status` para el review, hay cambios que **no pertenecen a este ticket** y no deben entrar en su commit:

- `.docs/glossary.md` eliminado: no tocado por ninguna tarea de AGEX-004. Probablemente borrado fuera de esta sesión (no aparecía como eliminado en el `git status` inicial). **Revisar si se restaura o se confirma el borrado en ticket aparte.**
- `notes.md` con línea añadida "- Añadir el skill de jia como configurable en config.yml": feedback ajeno al ticket. **Revisar si se queda como nota de cuaderno o se extrae.**
- Directorios untracked no relacionados: `.spec/commands/opsx/`, `.spec/skills/openspec-*/`, `openspec/`, `.claude/worktrees/`. **No deben añadirse al commit.**

`/sdd-wrap` debe stage-ear solo los cambios del ticket (`git add -p` o selección explícita), no `git add -A`.

## Sugerencias (opcionales)

- El feedback en `notes.md` sobre la skill `jira-integration` configurable en `config.yml` es un ticket potencial futuro.
- La deuda de "libnova.spec" → "agex" en comentarios de `install.sh` (líneas 2, 8, 32, 47 y dentro de heredocs) sigue pendiente, fuera de alcance como indica el proposal.

## Veredicto

✓ Listo para /sdd-wrap
