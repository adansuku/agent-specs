# Plan: AGEX-004

## Estrategia

Cambio de estructura implícita → explícita en dos ejes: rutas de tickets
activos (`active/<id>/`) y rama base del flujo (`branch.base` en
`.spec/config.yml`). No cambia el comportamiento del framework, solo
renombra rutas y hace configurable la base.

El ticket es autorreferente: su propia spec vive en `.docs/changes/AGEX-004/`
(ruta vieja) y se archivará con la lógica vieja durante `/sdd-wrap`. El
código nuevo empieza a usar `active/` en el siguiente ticket.

## Archivos a tocar

- `.spec/config.yml` — añadir clave `branch.base: main`.
- `.spec/commands/sdd-start.md` — leer `branch.base` de config (fallback
  `main`) y hacer `git checkout` contra esa rama en el paso de crear rama.
- `.spec/commands/sdd-wrap.md` — pasar `--base <branch.base>` a
  `gh pr create`. Actualizar rutas `<ticket>/` → `active/<ticket>/` y
  `archive/<ticket>/`.
- `.spec/commands/sdd-spec.md` — rutas `<ticket>/` → `active/<ticket>/`.
- `.spec/commands/sdd-plan.md` — rutas `<ticket>/` → `active/<ticket>/`.
- `.spec/commands/sdd-do.md` — rutas `<ticket>/` → `active/<ticket>/`.
- `.spec/commands/sdd-review.md` — rutas `<ticket>/` → `active/<ticket>/`.
- `.spec/commands/sdd-status.md` — rutas `<ticket>/` → `active/<ticket>/`.
- `install.sh` — en este archivo conviven tres capas que hay que mantener
  alineadas:
  1. `mkdir -p` inicial: añadir `.docs/changes/active/` (y `.gitkeep`).
  2. Heredoc del `config.yml` embebido: añadir `branch.base: main`.
  3. Heredocs de los 7 comandos: deben coincidir byte a byte con
     `.spec/commands/*.md` tras los cambios.
- `.docs/services/agex/CONTEXT.md` — tabla "Memoria arquitectónica
  generada" con rutas nuevas; sección de configuración con `branch.base`.
- `CLAUDE.md` (raíz) — referencias a rutas en la sección "Flujo de trabajo".
- `README.md` (raíz) — referencias a rutas de ejemplo.
- `INSTALL.md` (raíz) — referencias a rutas post-instalación.

## Archivos nuevos

- `.docs/changes/active/.gitkeep` — placeholder para versionar el
  directorio vacío.

## Dependencias entre cambios

El orden importa dentro del PR:

1. `.spec/config.yml` primero — sin la clave, la lógica de lectura en
   comandos no tiene referente.
2. Comandos (`sdd-start`, `sdd-wrap`) que leen `branch.base` — antes que
   el resto, porque son los que consumen la config.
3. Resto de comandos con cambios de rutas — cambio mecánico, sin
   dependencias internas.
4. `.docs/changes/active/.gitkeep` — puede ir en cualquier momento, pero
   conviene tenerlo antes de verificar con `ls`.
5. `install.sh` al final del bloque de código del framework — tiene que
   reflejar el estado final de todo lo anterior (config + comandos).
6. Docs (`CONTEXT.md`, `CLAUDE.md`, `README.md`, `INSTALL.md`) al final
   del PR — describen lo que ya existe en el resto del PR.

**Autorreferencia**: este ticket vive inicialmente en
`.docs/changes/AGEX-004/`. Como los comandos actualizados solo conocen
la ruta nueva, la implementación mueve la carpeta a
`.docs/changes/active/AGEX-004/` al final (ver tasks.md). Así AGEX-004
pasa a ser el primer ticket bajo la convención nueva y `/sdd-wrap`
funciona sin excepciones. Las tareas que tocan rutas en archivos de
framework no deben confundir la ruta de `.docs/changes/AGEX-004/` con
las referencias `<ticket-id>` genéricas en `.spec/commands/*`.

## Safety net

- **Reversibilidad**: `git revert` del merge commit. No hay estado
  runtime, solo YAML y Markdown.
- **Qué puede romperse**:
  - Instalaciones nuevas si los heredocs de `install.sh` quedan
    desfasados respecto a `.spec/commands/*.md`.
  - Comandos del framework si la lectura de `branch.base` falla y no
    hace fallback silencioso a `main`.
  - Tickets en curso si alguno usa rutas viejas — no aplica: AGEX-005
    ya está archivado y AGEX-004 se archiva vía lógica vieja durante
    su propio `/sdd-wrap`.
- **Plan de rollback**: revert del PR. Los tickets archivados no se
  tocan. Si alguien ya ejecutó `install.sh` con la versión nueva en un
  repo externo, con revertir el repo agex y re-instalar queda limpio.

## Characterization tests

No hay tests automatizados en agex. Antes de modificar el código:

- [ ] Ejecutar `grep -rn "\.docs/changes/" .spec/ *.md install.sh`
      y guardar la salida como baseline (para comparar después).
- [ ] Ejecutar `cat .spec/config.yml` y guardar el contenido previo.
- [ ] Listar `.docs/changes/` y anotar su contenido actual.

No hay "tests de comportamiento" que escribir antes; la verificación es
manual y se describe abajo.

## Verificación

Por criterio de éxito de la spec:

1. **Grep sin rutas viejas**:
   ```
   grep -rn "\.docs/changes/[A-Z]" .spec/ CLAUDE.md README.md INSTALL.md install.sh
   ```
   Debe devolver **0 coincidencias** (excluyendo `.docs/changes/archive/`
   que no se toca y la propia `AGEX-004/` que vive en ruta vieja hasta
   `/sdd-wrap`).

2. **Estructura del directorio**:
   ```
   ls .docs/changes/
   ```
   Debe mostrar `active/` y `archive/`. `AGEX-004/` desaparecerá tras
   `/sdd-wrap`.

3. **Config explícita**:
   ```
   grep "branch.base" .spec/config.yml
   ```
   Debe mostrar `branch.base: main`.

4. **Simulación post-implementación** (antes de `/sdd-wrap`):
   Leer manualmente los cambios en `sdd-start.md` y `sdd-wrap.md` y
   confirmar que la lógica de `branch.base` está presente. Simulación
   real de un ticket nuevo se hará tras mergear en un repo externo.

5. **Paridad install.sh ↔ .spec/commands/**:
   Para cada comando, comparar el heredoc de `install.sh` con el archivo
   de `.spec/commands/` correspondiente. Deben ser idénticos salvo
   el indentado/escape del heredoc.

6. **Propia auto-verificación**: el `/sdd-wrap` de este ticket debe
   archivar `AGEX-004/` a `archive/AGEX-004/` y crear el PR con
   `--base main`. Se verifica en el propio wrap.
