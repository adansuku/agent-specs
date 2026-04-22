# Smoke test — NOVA-40

Evidencia de los CAs de la spec: `/nova-init` genera borradores útiles en <5 min, es idempotente via `.draft.md`, y aborta limpiamente en los 3 edge cases.

## Entorno

- **Fecha**: 2026-04-22
- **Máquina**: macOS darwin 23.3.0
- **Source nova-spec**: `/Users/adan/Workspace/novaspec` (branch `feature/NOVA-40-nova-init`)

## Caso 1 — Happy path (monorepo)

**Setup** (`/tmp/nova-init-monorepo`):

```
package.json       (scripts: dev, build, test)
Makefile           (targets: setup, lint, deploy)
pyproject.toml
packages/api/package.json  (service, scripts: start)
packages/web/package.json  (service)
```

**Ejecución**: `install.sh --target claude`, luego simular pasos de `/nova-init`.

**Resultado**:
| Check | Resultado |
|---|---|
| Precondición `context/` existe | ✅ |
| Precondición `PWD != repo nova-spec` | ✅ |
| Manifests raíz detectados | 2 (`package.json`, `pyproject.toml`) |
| Scripts de `package.json` extraídos | 3 (`dev`, `build`, `test`) |
| Targets de `Makefile` extraídos | 3 (`setup`, `lint`, `deploy`) |
| Servicios detectados en `packages/*` | 2 (`api`, `web`) |
| Archivos generados | `project.md` (33 líneas), `api.md`, `web.md` |
| Placeholders `{{…}}` sustituidos correctamente | ✅ (ver Hallazgos) |
| TODOs explícitos en campos no inferibles | ✅ |

## Caso 2 — Idempotencia (re-run)

Sobre el mismo `/tmp/nova-init-monorepo` tras Caso 1:

| Check | Resultado |
|---|---|
| Re-run no toca originales (`md5` match antes/después) | ✅ |
| Se crean `project.draft.md`, `api.draft.md`, `web.draft.md` | ✅ |
| Sin interacción con el usuario durante la regeneración | ✅ |

## Caso 3 — Edge: monolito sin monorepo

`/tmp/nova-init-monolito` con solo `package.json` raíz.

| Check | Resultado |
|---|---|
| Servicios detectados en `services/|apps/|packages/` | 0 ✅ |
| Solo `project.md` se generaría (sin `<svc>.md`) | ✅ |

## Caso 4 — Edge: sin `context/`

Eliminar `context/` de `/tmp/nova-init-monolito`.

| Check | Resultado |
|---|---|
| Precondición "context/ existe" falla | ✅ |
| El comando abortaría con mensaje `✗ context/ no existe...` | ✅ |

## Caso 5 — Edge: ejecución dentro del propio repo nova-spec

Desde `/Users/adan/Workspace/novaspec`.

| Check | Resultado |
|---|---|
| Se detecta `novaspec/commands/nova-start.md` adyacente | ✅ |
| Precondición "PWD != SCRIPT_DIR nova-spec" falla | ✅ |
| El comando abortaría explicando que se use en repo instalado, no en fuente | ✅ |

## Verificación final con `context-loader`

Tras `/nova-init` en el monorepo del Caso 1, se ejecutó el subagente `context-loader` con servicios `project api web` contra `/tmp/nova-init-monorepo`. Output:

```
## Contexto cargado

**Servicios**: project ✓, api ✓, web ✓
**Decisions leídas**: ninguna
**Gotchas leídas**: ninguna
**Huecos**: ninguno
**Preguntas**: ninguna
```

El criterio de éxito *"`context-loader` no reporta Huecos sobre servicios no documentados tras un `/nova-init`"* **se cumple**.

## Hallazgos

1. **Plantilla `init-service.md` hardcodeaba `NOVA-40` en "Última actualización"**. Corregido a `{{DATE}} — bootstrap con /nova-init` durante T7 — NOVA-40 es el ticket que creó el comando, no el ticket del consumidor.
2. **Sin pendientes de follow-up fuera de scope.** Los 3 edge cases están cubiertos; las heurísticas están acotadas a raíz + 3 directorios convencionales (no hay riesgo de repo gigante).

## Verificación manual pendiente por el usuario (pre-merge)

- [ ] Instalar nova-spec (rama `feature/NOVA-40-nova-init`) en un repo real tuyo y ejecutar `/nova-init` vía Claude Code. Validar:
  - checkpoint humano aparece y pide confirmación `[y/N]`,
  - los borradores generados se ven razonables,
  - preview de primeras ~20 líneas cabe y es legible.
- [ ] `/nova-start TEST-1` tras `/nova-init` → verificar que arranca sin quejarse del contexto.
