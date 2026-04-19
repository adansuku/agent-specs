# AGEX-009: Eliminar heredocs de `install.sh` y copiar desde la fuente

## Historia
Como mantenedor del framework agex, quiero que `install.sh` copie los archivos directamente desde el repo clonado en vez de embeber heredocs, para que exista una única fuente de verdad y sea imposible que el instalador divergue de los archivos canónicos en `.spec/` y `CLAUDE.md`.

## Objetivo
Eliminar la duplicación estructural entre `.spec/` / `CLAUDE.md` (fuente canónica) y los heredocs de `install.sh` (copia embebida). El nuevo `install.sh` se convierte en un thin wrapper alrededor de `cp -r`, preservando la idempotencia y la estructura generada en el repo destino.

## Contexto
Hoy `install.sh` tiene ~1334 líneas, de las cuales ~1290 son heredocs `cat > <archivo> <<'EOF' ... EOF` que reproducen literalmente `.spec/commands/*.md`, `.spec/skills/*/SKILL.md`, `.spec/config.yml` y `CLAUDE.md`. Cada edición en un archivo canónico obliga a una edición simétrica en el heredoc, y el drift es un hecho probado:

- **AGEX-004** migró `.docs/changes/<ticket>/` → `.docs/changes/active/<ticket>/`. Los heredocs de comandos se actualizaron; el heredoc de `CLAUDE.md` no.
- **AGEX-005** surgió precisamente para arreglar ese drift; quedó obsoleto y se eliminó.
- **AGEX-008** duplicó trabajo: el rename "libnova.spec → agex" se hizo en 5 archivos fuente **y** en sus heredocs correspondientes (verificados con `diff` fuente↔heredoc).

El CONTEXT.md del servicio agex (`.docs/services/agex/CONTEXT.md:134-137`) ya eligió "symlinks en lugar de copias" para `.claude/` → `.spec/` exactamente por este mismo razonamiento. Este ticket extiende el principio al mecanismo de instalación.

El ticket marca este cambio como decisión arquitectónica (primer ADR del repo).

## Alcance
### En alcance
- Reescribir `install.sh` para que use `cp -r` y `cp` sobre archivos de su propio directorio (`SCRIPT_DIR`), eliminando todos los heredocs.
- Detectar fuentes en `SCRIPT_DIR` y fallar rápido si no existen (mensaje de error explícito).
- Actualizar `INSTALL.md` para reflejar el nuevo flujo ("clona agex, ejecuta `bash /ruta/a/agex/install.sh` desde tu repo destino").
- Crear `ADR-0001-install-sh-copy-from-source.md` en `.docs/adr/`.
- Actualizar `.docs/services/agex/CONTEXT.md` en `/sdd-wrap` para registrar la decisión.

### Fuera de alcance
- Renombrar el framework (AGEX-007 Ori/DevSpec) — independiente; el nombre `agex` se mantiene literal en este ticket.
- Flags CLI nuevos (`--help`, `--dry-run`, `--src`) — solo se añade detección por `SCRIPT_DIR`.
- Generador de `install.sh` (alternativa B) — descartada.
- Fallback a modo heredoc si faltan fuentes — descartado; fallar rápido es parte del diseño.
- Cambios en la estructura generada en el repo destino — idéntica a la actual.
- Copiar `INSTALL.md` o `README.md` al repo destino — son docs del framework, no del repo instalado.

## Decisiones cerradas
- **Alternativa A** (copia desde repo-fuente) elegida sobre B (generador) y C (status quo).
- `install.sh` copia únicamente `.spec/` (completo) y `CLAUDE.md`. No copia `INSTALL.md`, `README.md`, `notes.md` ni otros docs de agex.
- Sigue creando estructura vacía: `.docs/{adr,services,post-mortems,specs,changes/{active,archive}}`, `.docs/glossary.md`, `.docs/changes/active/.gitkeep`, `notes.md`, symlinks `.claude/{commands,skills,agents} → ../.spec/*`.
- Invocación estándar: `bash /ruta/a/agex/install.sh` desde el repo destino (cwd). El script resuelve sus fuentes vía `SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)` y usa `$PWD` como destino.
- Si `$SCRIPT_DIR/.spec/` no existe, el script falla con código ≠ 0 y mensaje: `✗ No encuentro <SCRIPT_DIR>/.spec/. Ejecuta este script desde un clone del repo agex.`
- INSTALL.md se actualiza en este mismo ticket (no se difiere).
- ADR-0001 en inglés: `ADR-0001-install-sh-copy-from-source.md`.
- No ADR adicional.

## Comportamiento esperado
- **Normal**: en un repo destino vacío o existente, `bash /ruta/a/agex/install.sh` crea/actualiza `.spec/` y `CLAUDE.md` (copiados desde `SCRIPT_DIR`), genera la estructura `.docs/`, crea los symlinks `.claude/*`, y emite `✓ agex instalado` seguido del mensaje "Siguiente paso". Mismo output visible que la versión actual, misma estructura resultante.
- **Edge case — re-instalación**: `cp -r` sobrescribe los archivos generados con las versiones actuales de `SCRIPT_DIR`. `.docs/`, `notes.md` y `.docs/changes/` no se tocan (respetado por omisión: esos paths no aparecen como destinos de `cp` en el script nuevo).
- **Edge case — `SCRIPT_DIR` sin `.spec/`**: script falla con mensaje claro y exit ≠ 0. No deja estado parcial en el destino.
- **Edge case — symlinks existentes en `.claude/`**: la comprobación `[ -L commands ] || ln -s ...` se preserva del script actual.
- **Edge case — invocar con `SCRIPT_DIR == PWD`** (es decir, ejecutar el script desde dentro del propio repo agex): el script sobrescribiría sus propias fuentes con copias de sí mismas; teóricamente inocuo pero poco útil. El comportamiento es idempotente, no se añade protección adicional.
- **Fallo**: `cp` falla por permisos o disco lleno → script aborta por `set -e` (ya presente en línea 6 del script actual).

## Output esperado
- `install.sh` reducido de ~1334 líneas a ~40-60 líneas.
- `INSTALL.md` con la sección "Instalación rápida" reescrita para reflejar clone + ruta absoluta.
- `.docs/adr/ADR-0001-install-sh-copy-from-source.md` nuevo, formato estándar (contexto, decisión, consecuencias, alternativas consideradas).
- Sin cambios en `.spec/` ni `CLAUDE.md` ni `.docs/services/agex/CONTEXT.md` (éste se actualiza en `/sdd-wrap`).

## Criterios de éxito
- `wc -l install.sh` devuelve ≤ 80 (reducción ≥ 95%).
- `grep -c "<<'EOF'" install.sh` = 0 (no quedan heredocs).
- `grep -c "cp -r" install.sh` ≥ 1 (mecanismo nuevo presente).
- **Test funcional**: en `/tmp/agex-test-dest` (vacío), ejecutar `bash /Users/adan/Workspace/agex/install.sh` y verificar:
  - Exit 0.
  - `.spec/config.yml`, `.spec/commands/*.md`, `.spec/skills/*/SKILL.md`, `CLAUDE.md` existen y su contenido es idéntico (`diff`) al de `SCRIPT_DIR`.
  - `.claude/commands`, `.claude/skills`, `.claude/agents` son symlinks válidos hacia `../.spec/*`.
  - `.docs/` tiene la estructura esperada y `notes.md` existe.
  - Último mensaje del log: `✓ agex instalado`.
- **Test anti-drift** (fundamento del ticket): editar una línea de `.spec/commands/sdd-start.md` en el repo agex, re-ejecutar `bash install.sh` en el destino, verificar que el cambio aparece en el `.spec/commands/sdd-start.md` del destino. Sin editar nada en `install.sh`.
- **Test fallo controlado**: ejecutar `install.sh` copiado a un directorio vacío sin `.spec/` hermano; exit ≠ 0 y mensaje claro en stderr.
- `ADR-0001-install-sh-copy-from-source.md` existe y sigue el formato estándar.

## Impacto arquitectónico
- **Servicios afectados**: `agex` (único).
- **ADRs referenciados**: ninguno anterior (repo sin ADRs).
- **¿Requiere ADR nuevo?**: **sí**, ADR-0001 obligatorio por ser decisión estructural y primer ADR del repo.
- **Consecuencias en CONTEXT.md de agex**:
  - Sección "Instalación" (líneas 98-112) debe reflejar que `install.sh` copia desde `SCRIPT_DIR`, no desde heredocs.
  - Añadir decisión "install.sh copia desde fuente" en "Decisiones clave" (paralela a "Symlinks en lugar de copias").
  - Estas ediciones van en `/sdd-wrap`, no en `/sdd-do`.

## Verificación sin tests automatizados
### Flujo manual
1. Aplicar el nuevo `install.sh` y `INSTALL.md`.
2. Crear directorio temporal: `mkdir -p /tmp/agex-dest-$$ && cd /tmp/agex-dest-$$`.
3. Ejecutar: `bash /Users/adan/Workspace/agex/install.sh`.
4. Verificar exit 0, mensaje final "✓ agex instalado", `/sdd-start PROJ-123` en el mensaje.
5. Verificar archivos: `diff -r /Users/adan/Workspace/agex/.spec /tmp/agex-dest-$$/.spec` → sin diferencias.
6. Verificar `diff /Users/adan/Workspace/agex/CLAUDE.md /tmp/agex-dest-$$/CLAUDE.md` → sin diferencias.
7. Verificar symlinks: `readlink .claude/commands` = `../.spec/commands` (y skills/agents).
8. Test anti-drift: editar temporalmente un archivo en `.spec/commands/sdd-start.md` del repo agex (una palabra), re-ejecutar install en otro tmpdir, verificar que la palabra aparece. Revertir.
9. Test fallo: `cp /Users/adan/Workspace/agex/install.sh /tmp/orphan/ && cd /tmp/orphan && bash install.sh`; debe salir con error legible sobre `.spec/` no encontrado.
10. Limpiar `/tmp/agex-dest-*` y `/tmp/orphan`.

### Qué mirar
- **Logs del install**: secuencia habitual de echos (`→ Creando estructura...`, `✓ agex instalado`). Sin warnings de `cp` por falta de permisos o archivos faltantes.
- **Estructura del destino**: `tree -L 3 -a -I '.git'` debe mostrar `.spec/`, `.claude/*` (como symlinks), `.docs/` con subdirectorios, `CLAUDE.md`, `notes.md`.
- **Contenido de archivos**: `diff -r` entre `SCRIPT_DIR/.spec/` y `$PWD/.spec/` debe ser idéntico.
- **No tocar**: `.docs/`, `notes.md` preexistentes en el destino (si hubiera).

## Riesgos
- **Ejecución accidental dentro del propio repo agex**: `cp -r SCRIPT_DIR/.spec/ .` cuando `$PWD == SCRIPT_DIR` es inocuo (copia de sí mismo) pero puede confundir al usuario. Mitigación: documentar en INSTALL.md que el comando debe ejecutarse desde el repo **destino**. No se añade guard-rail extra para no introducir complejidad.
- **Symlinks en Windows nativo**: sin cambios — el riesgo ya existía con el install.sh actual y está documentado en INSTALL.md:15-17. Mitigación: no introducimos riesgo nuevo.
- **Permisos de escritura**: `cp -r` falla con `set -e`; el usuario verá stderr. Mitigación: mensaje de ayuda al fallo (opcional, fuera de alcance).
- **Repo agex movido tras instalar**: tras la instalación inicial, el destino no depende de `SCRIPT_DIR`. Solo las re-ejecuciones (actualización del framework) requieren que `SCRIPT_DIR` siga siendo válido. Mitigación: documentar en INSTALL.md la sección "Actualización del framework".
- **Instalaciones existentes antes de este ticket**: quien instaló con la versión heredoc tiene el framework funcionando igual; solo al querer actualizar necesita clonar el repo. Mitigación: `install.sh` es idempotente igual; no se toca la instalación existente hasta que el usuario re-ejecute.
- **Breaking change para integradores automatizados**: si alguien descargaba `install.sh` solo (raw URL) y lo ejecutaba, ahora deberá clonar. Mitigación: mencionar explícitamente en INSTALL.md. Aceptable según alcance declarado por el ticket ("evaluar si archivo único descargable sigue siendo requisito real" — decidido: no).
