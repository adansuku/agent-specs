---
description: Bootstrap de context/services/ en un repo existente — genera borradores con TODO
argument-hint:
---

Eres un comando de **solo lectura del árbol + escritura de borradores**.
No modificas código. No tocas `context/decisions/`. No haces commit ni PR.
Tu única función es escanear heurísticamente el repo y generar borradores de
`context/services/project.md` y `context/services/<svc>.md` para que el
humano los retoque antes del primer `/nova-start`.

## Precondiciones

Antes de cualquier escaneo, valida en orden:

1. **`context/` existe** en el repo destino (`$PWD/context/`). Si no, aborta con:

   ```
   ✗ context/ no existe en este repo. Ejecuta install.sh antes de /nova-init.
   ```

2. **No estás dentro del propio repo `nova-spec`**. Si `$PWD` contiene
   `novaspec/commands/nova-start.md` (es decir, el repo fuente), aborta con:

   ```
   ✗ No puedo ejecutarme en el propio repo nova-spec.
     Usa /nova-init en un repo donde nova-spec está INSTALADO, no en el origen.
   ```

3. **Working tree**: no es estricto, pero avisa si hay cambios sin commitear:

   ```
   ⚠ Working tree sucio. Los borradores se crean igualmente; revísalos con
     git status para no mezclarlos con cambios en curso.
   ```

## Paso 1 — Escanear la raíz

Detecta marcadores de lenguaje/stack en `$PWD` (solo top-level, sin recursión):

| Marcador | Toolchain |
|---|---|
| `package.json` | Node.js |
| `pyproject.toml` | Python |
| `go.mod` | Go |
| `Gemfile` | Ruby |
| `Cargo.toml` | Rust |
| `composer.json` | PHP |

Comando: `ls $PWD | grep -E '^(package\.json|pyproject\.toml|go\.mod|Gemfile|Cargo\.toml|composer\.json)$'`.

Si hay `package.json` en la raíz, extrae la sección `scripts` (jq o parse manual).
Si hay `Makefile` en la raíz, extrae targets con `grep -E '^[a-zA-Z][a-zA-Z0-9_-]*:' Makefile | head -20`.

Guarda el listado combinado como `{{DETECTED_COMMANDS}}` para sustituir en la plantilla.

## Paso 2 — Detectar servicios

Para cada directorio convencional `services/`, `apps/`, `packages/`:
- Si existe, lista sus subdirs (`ls $PWD/<dir>` sin recursión profunda).
- Para cada subdir, busca los mismos marcadores del Paso 1.
- Si al menos un marcador matchea, el subdir es un **servicio detectado**.
  Registra: nombre (nombre del subdir), ruta, toolchain, manifest.

**No escanees** fuera de esos 3 directorios convencionales.

## Paso 3 — Preparar borradores en memoria

Para **project.md**:
- Lee `novaspec/templates/init-project.md`.
- Sustituye `{{DETECTED_COMMANDS}}` por el listado del Paso 1 (bullets
  `- npm run <script>` o `- make <target>`). Si no hay nada, pon `[TODO: añade comandos útiles del proyecto]`.
- El resto de TODOs quedan tal cual.

Para cada servicio detectado, prepara **`<nombre>.md`**:
- Lee `novaspec/templates/init-service.md`.
- Sustituye `{{SERVICE_NAME}}`, `{{MANIFEST}}` (ruta al manifest detectado),
  `{{TOOLCHAIN}}` (p. ej. `Node.js (package.json)`), `{{DATE}}` (fecha hoy YYYY-MM-DD).

## Paso 4 — Aplicar idempotencia

Para cada archivo a escribir bajo `context/services/`:
- Si **no existe** → escribir con el nombre pensado (`project.md`, `<svc>.md`).
- Si **ya existe** → escribir `<basename>.draft.md` (p. ej. `project.draft.md`).
  Si `.draft.md` también existe, añade sufijo numérico `.draft-2.md`, `.draft-3.md`, etc.

Nunca sobrescribes.

## Paso 5 — Checkpoint humano

Antes de escribir nada al disco, presenta:

```
Voy a crear estos archivos en context/services/:

  - project.md                (nuevo)
  - <svc1>.md                 (nuevo)
  - <svc2>.md                 (nuevo)

Preview de project.md (primeras 20 líneas):
<snippet>

Preview de <svc1>.md (primeras 20 líneas):
<snippet>

¿Continuar? [y/N]
```

Si el usuario responde algo distinto de `y` / `Y` / `yes`, aborta sin escribir.

## Paso 6 — Escribir y resumen

Tras `y`, escribe los archivos. Luego muestra:

```
✓ Creados N archivos en context/services/:
  - project.md
  - <svc>.md (xN)

Pendiente rellenar (busca TODO en los archivos):
  - Arquitectura objetivo
  - Testing policy
  - Restricciones
  - Decisiones relevantes por servicio

Siguiente paso: edita los TODO y luego ejecuta /nova-start <TICKET>.
```

## Reglas

- **Solo lectura del árbol del repo**; solo escribes bajo `context/services/`.
- **No crees archivos en `context/decisions/`** bajo ninguna circunstancia (solo sugiere como bullets en `project.md`).
- **No ejecutes `git add/commit/push`**; eso pertenece a `/nova-wrap` del primer ticket.
- **No escanees fuera** de raíz + `services/|apps/|packages/*`.
- **No sobrescribas** archivos existentes: usa `.draft.md`.
- Si no detectas nada reconocible, el `project.md` generado debe ser honesto — muchos TODO + pregunta al usuario si quiere listar servicios manualmente.
