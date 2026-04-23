# NOVA-018 — Hardening de `install.sh` para repos con `.claude/` existente

**Tipo**: feature (arquitectura del installer)
**Prioridad**: alta (bloqueador para compartir con equipo)
**Estimación**: media (3-4h)

## Problema

El `install.sh` actual asume un destino prístino o cuasi-prístino. Los
proyectos reales casi siempre ya tienen `.claude/` con contenido propio
(commands, skills, agents, `AGENTS.md`, `CLAUDE.md`). El installer hoy:

- **Sobrescribe `AGENTS.md` y `CLAUDE.md`** sin aviso (líneas 331-332).
  Si el compañero tenía los suyos, los pierde.
- **No distribuye `.claudeignore`**. El repo destino indexa `archive/` y
  `backlog/` completos en el context de Claude, inflando tokens.
- **Numeración `[N/6]` rota** cuando `--target both` (sale `[4/6]` y
  `[5/6]` dos veces).
- **Symlinks huérfanos al actualizar**: si se elimina una skill del
  framework upstream, su symlink queda apuntando a nada; el installer
  no los purga.
- **Uninstall destructivo**: el procedimiento documentado
  (`rm -rf .claude/`) borra también las skills y comandos del usuario.
- **`rm -rf novaspec` sin confirmación**: si el usuario tiene
  casualmente un directorio `novaspec/` por otra razón, se elimina.
- **Sin dry-run**: el usuario no puede ver qué va a cambiar antes de
  aplicarlo.

El parche de per-ítem symlinks + detección de colisión (ya aplicado en
`install.sh`) resuelve solo una parte. El resto queda abierto.

## Propuesta

Siete cambios concretos sobre `install.sh` + una adición a
`INSTALL.md`. En orden de prioridad:

### 1. Backup de `AGENTS.md` y `CLAUDE.md` antes de sobrescribir

```bash
for f in AGENTS.md CLAUDE.md; do
  if [[ -f "$f" ]]; then
    if ! diff -q "$SCRIPT_DIR/$f" "$f" >/dev/null 2>&1; then
      cp "$f" "$f.bak.$(date +%Y%m%d-%H%M%S)"
      echo "  ℹ $f preexistente → backup a $f.bak.…"
    fi
  fi
  cp "$SCRIPT_DIR/$f" "./$f"
done
```

### 2. Copiar `.claudeignore` al destino

Añadir paso: `cp "$SCRIPT_DIR/.claudeignore" ./.claudeignore` (con misma
lógica de backup si ya existe).

### 3. Numeración dinámica `[N/TOTAL]`

Calcular TOTAL según `TARGET` al arrancar (claude=5, opencode=6,
both=7). Variable `STEP=0` incrementada antes de cada echo.

### 4. Cleanup de symlinks huérfanos al actualizar

Al principio de la fase de symlinks, por cada `.claude/{commands,skills,agents}/`:

```bash
find "$dst" -maxdepth 1 -type l -lname '*/novaspec/*' | while read -r l; do
  [[ -e "$l" ]] || rm -f "$l"   # solo si target no existe
done
```

Solo borra symlinks que apuntan a `novaspec/` y están rotos —
nunca toca symlinks o archivos ajenos.

### 5. Uninstall limpio como sub-comando

```bash
bash install.sh --uninstall
```

Implementación:

```bash
find .claude .opencode -maxdepth 2 -type l -lname '*/novaspec/*' -delete 2>/dev/null
rm -rf novaspec
# AGENTS.md / CLAUDE.md se dejan intactos: el usuario decide.
# context/ se deja intacto: memoria arquitectónica no debe borrarse.
echo "Uninstall completo. context/ y AGENTS.md/CLAUDE.md se han conservado."
```

### 6. Confirmación antes de `rm -rf novaspec/`

```bash
if [[ -d novaspec && ! -f novaspec/config.example.yml ]]; then
  # existe pero no parece nuestro
  echo "⚠ Existe un directorio 'novaspec/' que no parece de nova-spec."
  read -r -p "¿Eliminar y reemplazar? [y/N] " confirm
  [[ "$confirm" == "y" ]] || exit 1
fi
```

### 7. Dry-run previo

```bash
bash install.sh --dry-run
```

Lista:
- Qué symlinks se crearían (y cuáles ya existen con el target correcto).
- Qué archivos se sobrescribirían (con diff breve).
- Qué colisiones de nombre se detectan.
- Exit 0 sin tocar nada.

### 8. Actualizar `INSTALL.md`

Añadir secciones:
- "¿Qué pasa si ya tengo `.claude/` en mi proyecto?" con explicación de
  coexistencia.
- Uninstall correcto.
- Dry-run.
- Retirar la sección actual de "Desinstalación" que es destructiva.

## Criterio de aceptación

1. Instalar sobre un repo con `AGENTS.md`, `CLAUDE.md`,
   `.claude/commands/<propio>.md`, `.claude/skills/<propio>/` y
   `.claude/agents/<propio>.md` no destruye nada del usuario. Se genera
   `AGENTS.md.bak.*` y `CLAUDE.md.bak.*` automáticamente si había
   diferencias.
2. Con `--target both`, la numeración de pasos es consecutiva sin
   repetir.
3. Actualizar cuando upstream ha eliminado una skill deja la instalación
   limpia (sin symlinks rotos apuntando a `novaspec/`).
4. `bash install.sh --uninstall` elimina solo los artefactos de
   nova-spec; las skills/commands/agents propios del usuario y
   `context/` siguen intactos.
5. `bash install.sh --dry-run` imprime un resumen y no modifica el
   filesystem (comprobable con `git status` después).
6. `INSTALL.md` tiene sección explícita de coexistencia y el uninstall
   destructivo actual queda eliminado.

## Fuera de scope

- Migración a plugin nativo de Claude Code (tema propio, proponer como
  NOVA-019 si se quiere evaluar).
- Internacionalización del framework (separado).
- `jira-integration` hardcodeado a proyecto `NOVA` (ticket aparte: el
  problema no es del installer).

## Referencias

- `install.sh` en HEAD tras el fix de symlinks per-ítem.
- Conversación del 2026-04-23: auditoría de readiness para compartir
  con equipo (7 bloqueadores A-G identificados, de los cuales D-E y G
  quedan en este ticket).
