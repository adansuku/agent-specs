# Instalación de agex

Guía para instalar el framework agex en cualquier repositorio.

---

## Requisitos previos

- Git
- Claude Code instalado
- Bash (macOS, Linux o WSL en Windows)
- Un repositorio donde instalar el framework (puede estar vacío o tener
  contenido previo)

> **Nota sobre Windows**: los symlinks que usa agex requieren
> permisos especiales en Windows nativo (Developer Mode o admin). Se
> recomienda usar **WSL** para evitar fricción.

---

## Instalación rápida

### 1. Clonar el repo `agex` en local

```bash
git clone <url-del-repo-agex> /ruta/a/agex
```

`install.sh` copia el contenido desde su propia ubicación, así que
necesitas tener el repo accesible en disco. El destino puede estar en
cualquier parte.

### 2. Posicionarse en el repo destino

```bash
cd /ruta/a/tu/repo
```

### 3. Ejecutar con ruta absoluta al script

```bash
bash /ruta/a/agex/install.sh
```

El script detecta su propia ubicación (`SCRIPT_DIR`) y copia desde
allí `.spec/` y `CLAUDE.md` al directorio actual. El destino es `$PWD`.

Es idempotente: ejecutarlo varias veces regenera `.spec/` y `CLAUDE.md`
desde la fuente, pero **no toca** `.docs/`, `notes.md` ni los archivos
de trabajo en `.docs/changes/`.

Si ejecutas el script desde un directorio donde no encuentra sus fuentes
(`.spec/` y `CLAUDE.md` en su mismo `SCRIPT_DIR`), aborta con un mensaje
de error y exit distinto de cero.

---

## Qué se instala

```
.
├── CLAUDE.md                    Ancla del repo, lo primero que Claude lee
├── notes.md                     Notas de uso (para iteración)
│
├── .spec/                       Contenido canónico del framework
│   ├── config.yml               Convenciones (ramas, tipos de ticket)
│   ├── commands/                7 slash commands `/sdd-*`
│   ├── skills/                  4 skills autocargadas por contexto
│   └── agents/                  Vacío, para sub-agents futuros
│
├── .claude/                     Symlinks para que Claude Code descubra los comandos
│   ├── commands -> ../.spec/commands
│   ├── skills   -> ../.spec/skills
│   └── agents   -> ../.spec/agents
│
└── .docs/                       Memoria arquitectónica
    ├── adr/                     Architectural Decision Records
    ├── services/                CONTEXT.md por servicio
    ├── changes/
    │   ├── active/              Specs en curso (tickets abiertos)
    │   └── archive/             Specs archivadas al cerrar ticket
    ├── post-mortems/
    └── glossary.md              Términos del dominio
```

---

## Verificación

### 1. Symlinks de `.claude/`

```bash
ls -la .claude/
```

Debes ver tres flechas `->`:

```
agents   -> ../.spec/agents
commands -> ../.spec/commands
skills   -> ../.spec/skills
```

### 2. Comandos en Claude Code

Abre Claude Code en la raíz del repo:

```bash
claude
```

Teclea `/` y comprueba que aparecen los 7 comandos en el autocomplete:

- `/sdd-start`
- `/sdd-spec`
- `/sdd-plan`
- `/sdd-do`
- `/sdd-review`
- `/sdd-wrap`
- `/sdd-status`

### 3. Primer ticket

Recomendado: empieza con un ticket pequeño y de bajo riesgo.

```
/sdd-start TICKET-ID
```

El comando te guía paso a paso.

---

## Personalización

### Convenciones de rama

Edita `.spec/config.yml`:

```yaml
branch:
  pattern: "{type}/{ticket}-{slug}"
  types:
    quick-fix: fix
    feature: feature
    architecture: arch
  ticket_case: upper    # upper | lower
  base: main            # rama base del flujo
```

`branch.base` controla contra qué rama se crea cada rama de ticket en
`/sdd-start` y contra cuál se abre el PR en `/sdd-wrap`. Default seguro
para repos convencionales; cámbialo a `develop` u otra si tu repo usa
otra rama de integración.

### Documentar tus servicios

Por cada servicio relevante de tu proyecto, crea:

```
.docs/services/<nombre-servicio>/CONTEXT.md
```

La skill `update-service-context` te genera la plantilla la primera vez
que la invocas para un servicio nuevo.

### Cargar decisiones previas

Si tu proyecto ya tiene decisiones arquitectónicas, documenta las más
importantes como ADRs en `.docs/adr/`. La skill `write-adr` te guía con
el formato.

---

## Actualización del framework

Para actualizar agex en un repo ya instalado, actualiza tu clone
local del repo agex (`git pull`) y vuelve a ejecutar el script desde
tu repo destino:

```bash
cd /ruta/a/agex && git pull
cd /ruta/a/tu/repo && bash /ruta/a/agex/install.sh
```

El script sobrescribe `.spec/` y `CLAUDE.md` con la versión de la
fuente. **No toca** `.docs/`, `notes.md` ni los archivos de trabajo
en `.docs/changes/`.

> Si has personalizado algún comando o skill en el repo destino, haz
> commit de tus cambios antes de actualizar, o trabaja en una rama
> separada para reconciliar.

---

## Desinstalación

```bash
rm -rf .spec .claude .docs
rm -f CLAUDE.md notes.md
```

> Esto borra también toda la memoria arquitectónica (`.docs/`). Si
> quieres conservarla, muévela antes a otro sitio.

---

## Problemas comunes

### Los comandos no aparecen en Claude Code

1. Verifica los symlinks: `ls -la .claude/`.
2. Cierra y reabre Claude Code (a veces cachea el listado).
3. Verifica que los archivos en `.spec/commands/` tienen frontmatter
   válido (con `description:` al menos).

### "No encuentro la skill `load-context`"

- Verifica que existe `.spec/skills/load-context/SKILL.md`.
- Verifica que el frontmatter tiene `name:` y `description:`.
- Asegúrate de que el symlink `.claude/skills` apunta a
  `../.spec/skills`.

### Symlinks rotos al clonar el repo

Si clonas en otra máquina y los symlinks no funcionan:

```bash
git config core.symlinks true
git reset --hard HEAD
```

En Windows nativo, los symlinks necesitan **Developer Mode** activado o
permisos de administrador. La alternativa recomendada es **WSL**.

### `install.sh` falla con "permission denied"

Ejecuta con `bash` explícito en vez de hacerlo ejecutable:

```bash
bash install.sh
```

---

## Siguiente paso

Lee [README.md](./README.md) para entender el flujo completo de
agex.
