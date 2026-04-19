# ADR-0001: `install.sh` copia desde la fuente en vez de embeber heredocs

**Fecha**: 2026-04-19
**Estado**: Aceptada
**Ticket**: AGEX-008 (contexto) y AGEX-009 (decisión e implementación)

## Contexto

El script `install.sh` del framework `agex` vivía en dos modos posibles:

1. **Heredocs embebidos** (estado previo): `install.sh` contenía el contenido literal de `.spec/config.yml`, `.spec/commands/*.md`, `.spec/skills/*/SKILL.md` y `CLAUDE.md` dentro de bloques `cat > file <<'EOF' ... EOF`. El archivo era autocontenido (~1334 líneas), descargable como un único artefacto.

2. **Copia desde la fuente** (alternativa): `install.sh` realiza `cp -R` desde su propia ubicación (`SCRIPT_DIR`) hacia el repo destino (`$PWD`). Requiere tener el repo `agex` clonado localmente para ejecutarlo.

El modelo de heredocs generó drift real, no hipotético:

- **AGEX-004** (reorganizar `context/changes/` con `active/` y `archive/`) migró las rutas en los heredocs de comandos pero olvidó sincronizar el heredoc de `CLAUDE.md`.
- **AGEX-005** fue creado específicamente para arreglar ese drift; se marcó obsoleto y se eliminó en cuanto otros tickets resolvieron el síntoma indirectamente.
- **AGEX-008** (rename `libnova.spec` → `agex`) duplicó trabajo: el cambio se aplicó en las 5 fuentes canónicas **y** en sus heredocs correspondientes, obligando a mantener un invariante `fuente == heredoc` con `diff` manual.

El framework ya aplicó un principio análogo en otro punto: `.claude/` contiene symlinks a `.spec/` precisamente para **evitar divergencia** entre la fuente y lo que ve el agente (ver `context/services/agex/CONTEXT.md` > "Symlinks en lugar de copias"). Coherentemente, el mecanismo de instalación debería seguir el mismo patrón.

## Decisión

`install.sh` copia `.spec/` (completo) y `CLAUDE.md` desde `SCRIPT_DIR` (su propio directorio canónico) al directorio de trabajo actual. No mantiene copia embebida del contenido.

Mecanismo:

- `SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)` — ubicación canónica del script.
- `rm -rf .spec && cp -R "$SCRIPT_DIR/.spec" .` — copia idempotente, evita el gotcha de macOS `cp -R src dst/` cuando `dst/src` ya existe.
- `cp "$SCRIPT_DIR/CLAUDE.md" ./CLAUDE.md` — copia del ancla del repo destino.
- La estructura vacía (`context/*`, `notes.md`, symlinks `.claude/*`) se sigue generando con `mkdir -p` y `ln -s`.

Dos guards tempranos abortan con `exit 1`:

- Si `$SCRIPT_DIR/.spec/` o `$SCRIPT_DIR/CLAUDE.md` no existen → script "huérfano" sin fuentes.
- Si `$PWD == $SCRIPT_DIR` → el `rm -rf .spec` destruiría la fuente.

La invocación canónica desde el repo destino es:

```bash
bash /ruta/a/agex/install.sh
```

## Consecuencias

### Positivas

- **Fuente única de verdad**. Imposible que `install.sh` divergue de los archivos canónicos; la divergencia requeriría reescribir el propio `cp`.
- **Tamaño**: `install.sh` pasa de ~1334 líneas a ~51. Reducción del 96%. Cada cambio en un comando, skill, config o CLAUDE.md se refleja automáticamente en la próxima instalación.
- **Elimina una categoría entera de bugs**: AGEX-005 y AGEX-008 no vuelven a ocurrir por diseño.
- **Coherencia arquitectónica**: mismo principio que `.claude/` → `.spec/` (symlinks para evitar divergencia).

### Negativas

- **Requisito de clone local**: quien instala agex en un repo destino debe tener el repo `agex` clonado en disco. El modelo "descargar un solo archivo y ejecutarlo" deja de funcionar.
- **Actualización en dos pasos**: para actualizar una instalación, hay que hacer `git pull` en el clone fuente antes de re-ejecutar el script desde el destino.
- **Edge case destructivo mitigado con guard**: `rm -rf .spec` fue necesario para idempotencia en el caso normal; si el usuario ejecutase el script desde dentro del repo `agex` (`PWD == SCRIPT_DIR`), borraría la fuente. Se añadió un guard explícito que aborta con mensaje claro en ese escenario.

### Neutras

- **Consistencia con el archivo `.spec/agents/.gitkeep`**: al copiar con `cp -R`, el directorio `.spec/agents/` llega al destino con su `.gitkeep` en lugar de quedarse vacío. Funcionalmente irrelevante; el symlink `.claude/agents → ../.spec/agents` sigue resolviendo.

## Alternativas consideradas

### Alternativa B: generador que produce `install.sh` desde la fuente

Un script aparte lee `.spec/` y regenera los heredocs dentro de `install.sh` automáticamente. Mantiene la propiedad "archivo único descargable" pero añade una herramienta nueva al inventario del framework y a su mantenimiento.

**Descartada** por:
- Introduce complejidad (una herramienta más) para preservar una propiedad ("archivo único") cuyo valor real ya no era crítico.
- El drift entre generador y heredocs es posible si el generador no se ejecuta en cada cambio; requiere disciplina o un hook.
- Rompe la analogía directa con los symlinks de `.claude/`.

### Alternativa C: status quo + disciplina

Mantener los heredocs y confiar en `/sdd-review` y en la revisión humana para detectar drift.

**Descartada** por:
- AGEX-004 demostró que la disciplina falla en la práctica.
- `/sdd-review` no revisaba `diff fuente ↔ heredoc` de forma sistemática; habría requerido añadir esa verificación explícita a la skill, lo cual amplía su responsabilidad.
- Duplica trabajo cada vez que se toca un archivo canónico.

## Referencias

- Ticket: `context/changes/archive/AGEX-009/proposal.md`
- Review: `context/changes/archive/AGEX-009/review.md`
- Patrón análogo: `context/services/agex/CONTEXT.md` > "Decisiones clave" > "Symlinks en lugar de copias"
- Tickets relacionados (drift histórico): AGEX-004, AGEX-005 (obsoleto), AGEX-008
