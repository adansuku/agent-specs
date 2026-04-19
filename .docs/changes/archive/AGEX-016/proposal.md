# AGEX-016: Renombrar framework a nova-spec

## Historia
Como mantenedor del framework, quiero renombrar agex a nova-spec con comandos
`/nova-*`, para que el framework tenga identidad propia que honre a Libnova y
sea reconocible en cualquier CLI de IA.

## Objetivo
Reemplazar toda la identidad `agex` / `sdd-*` / `.spec/` por `nova-spec` /
`nova-*` / `nova/` en el código activo del framework, sin tocar el histórico
de tickets archivados.

## Contexto
El nombre `agex` es un acrónimo interno sin significado externo. `nova-spec`
honra a Libnova (impulsor del proyecto) y describe el propósito del framework:
especificación guiada por agentes de IA. Los comandos `/sdd-*` son opacos;
`/nova-*` son autoexplicativos y portables entre Claude Code, Gemini CLI y
cualquier CLI que use archivos planos como comandos.

## Alcance

### En alcance
- Renombrar carpeta `.spec/` → `nova/` (con todas sus subcarpetas y archivos)
- Renombrar archivos de comandos: `sdd-*.md` → `nova-*.md`
- Actualizar symlinks `.claude/`: `../.spec/*` → `../nova/*`
- Actualizar `install.sh`: rutas y symlinks
- Actualizar referencias internas en comandos, skills y guardrails
- Actualizar `CLAUDE.md`, `README.md`, `INSTALL.md`
- Actualizar `README.md` del backlog
- Reemplazar "agex" como nombre del framework → "nova-spec" en texto de prosa

### Fuera de alcance
- Archivos en `.docs/changes/archive/` (registro histórico — intactos)
- Prefijos de tickets AGEX-NNN (histórico — intactos)
- Contenido interno de archivos `.docs/backlog/AGEX-*.md` (documentos de ticket)
- Nombre del repositorio en GitHub

## Decisiones cerradas
- **Nombre del framework en prosa**: `nova-spec` (minúsculas, con guión)
- **Carpeta**: `nova/` sin punto — visible y descubrible
- **Comandos**: `/nova-start`, `/nova-spec`, `/nova-plan`, `/nova-build`,
  `/nova-review`, `/nova-wrap`, `/nova-status` (kebab-case)
- **Sin sintaxis `:`**: incompatible con Claude Code para comandos de proyecto
- **`CLAUDE.md`**: actualizar — es el ejemplo canónico del framework
- **Backlog**: solo actualizar `README.md`, no el contenido de tickets

## Comportamiento esperado
- Normal: `install.sh` ejecutado en repo destino crea `nova/` con todos los
  archivos renombrados y symlinks `.claude/` apuntando a `nova/`
- Edge case: repos que ya tengan `.spec/` instalado — no se migran
  automáticamente (fuera de alcance)
- Fallo: si un archivo interno queda con referencia a `.spec/` o `sdd-`,
  el grep de verificación lo detecta

## Output esperado
- `nova/commands/nova-*.md` — 7 archivos de comandos
- `nova/skills/` — 4 skills sin cambio de nombre
- `nova/guardrails/` — 5 guardrails sin cambio de nombre
- `nova/config.yml` — actualizado
- `.claude/commands` → `../nova/commands`
- Documentación coherente con el nuevo naming

## Criterios de éxito
1. `grep -r "sdd-\|\.spec/" nova/ CLAUDE.md README.md INSTALL.md install.sh` → 0 resultados
2. `grep -r "agex" CLAUDE.md README.md INSTALL.md install.sh nova/` → 0 resultados (salvo comentarios históricos explícitos)
3. `bash install.sh` en directorio limpio crea `nova/` sin `.spec/`
4. Symlinks `.claude/commands`, `.claude/skills`, `.claude/agents` apuntan a `nova/`

## Impacto arquitectónico
- Servicios afectados: ninguno (framework puro)
- ADRs referenciados: ADR-0001 (install.sh `cp -R` — el mecanismo se mantiene, solo cambian las rutas)
- ¿Requiere ADR nuevo?: sí — documentar decisión de naming (nova-spec, nova/, /nova-*)

## Verificación sin tests automatizados
### Flujo manual
1. `grep -r "sdd-\|\.spec/\|agex" nova/ CLAUDE.md README.md INSTALL.md install.sh`
2. `mkdir -p /tmp/nova-test && cd /tmp/nova-test && bash /ruta/agex/install.sh`
3. `ls /tmp/nova-test/nova/` — debe mostrar commands, skills, guardrails, config.yml
4. `ls -la /tmp/nova-test/.claude/` — symlinks deben apuntar a `../nova/*`

### Qué mirar
- Que `/nova-start` esté disponible en Claude Code tras reiniciar
- Que los guardrails referencien rutas `nova/` no `.spec/`

## Riesgos
- **Volumen de cambios**: muchos archivos a tocar en una sola rama. Mitigación:
  hacer el rename de carpeta con `git mv` para preservar historial, luego
  actualizar referencias con búsqueda sistemática.
- **Referencias cruzadas internas**: los comandos se citan entre sí (`/sdd-plan`,
  `/sdd-wrap`, etc.). Mitigación: grep post-cambio como criterio de éxito.
- **Symlinks**: si el rename de `.spec/` se hace antes de actualizar los symlinks,
  Claude Code queda sin comandos. Mitigación: actualizar symlinks en la misma tarea.
