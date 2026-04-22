<!-- Mantén esta spec ≤ 60 líneas. Bullets y tablas, no prosa. Se carga en cada turno de nova-build. -->
# NOVA-40: Añadir `/nova-init` para bootstrap de `context/` en repos existentes

## Historia
Como usuario que acaba de instalar nova-spec en un repo existente, quiero un comando que escanee heurísticamente el repo y genere borradores mínimos en `context/services/`, para poder arrancar el flujo sin redactar desde cero.

## Objetivo
Pasar de "`context/` vacío tras `install.sh`" a "borradores útiles de `project.md` y N servicios detectados" en <5 min y 1 comando.

## Contexto
`install.sh` crea la estructura `context/{decisions,gotchas,services,changes/{active,archive}}` vacía. El primer `/nova-start` espera al menos un `services/<svc>.md` para que `context-loader` funcione; sin él, el usuario debe redactar manualmente. `/nova-init` rellena ese gap generando borradores, sin inventar decisiones.

## Alcance
### En alcance
- Comando nuevo `novaspec/commands/nova-init.md`.
- Plantillas externas `novaspec/templates/init-project.md` y `novaspec/templates/init-service.md`.
- Escaneo top-level + subdirs de `services/`, `apps/`, `packages/` buscando manifests (`package.json`, `pyproject.toml`, `go.mod`, `Gemfile`, `Cargo.toml`, `composer.json`).
- Generación de `context/services/project.md` (Qué es / Arquitectura objetivo / Testing policy / Comandos útiles / Restricciones) y `context/services/<svc>.md` para cada servicio detectado.
- Sección "Comandos útiles" extrae `scripts` de `package.json` y targets de `Makefile` si existen; si no, TODO.
- Idempotencia: si un archivo ya existe → escribir `<nombre>.draft.md` sin preguntar. No sobrescribe.
- Checkpoint humano final: lista de archivos a crear + preview de primeras ~20 líneas + `y/n` antes de escribir.
- Actualizar `README.md` y `context/services/novaspec.md` (pasa de 7 a 8 comandos).

### Fuera de alcance
- Crear decisiones en `context/decisions/` (solo sugerir bullets en `project.md`).
- Integraciones Jira. Mover carpetas del repo. Subagente (heurística es ligera).
- Recursión profunda / leer árboles completos.

## Decisiones cerradas
- Escaneo top-level + 1 nivel dentro de `services/|apps/|packages/` (no recursivo general).
- Idempotencia vía `.draft.md` sin preguntar; humano decide al releer.
- "Servicio" = subdir de `services/|apps/|packages/` con manifest propio.
- Sin subagente; heurística inline en el comando (< 2 artefactos voluminosos, per `decisions/patron-subagentes.md`).
- Plantillas externas en `novaspec/templates/` (per `decisions/templates-externos-a-comandos.md`).
- Checkpoint humano obligatorio antes de escribir (per `decisions/checkpoints-humanos-obligatorios.md`).

## Comportamiento esperado
- Normal: genera `project.md` + N `<svc>.md` con TODOs claros.
- Edge — monorepo sin `services/|apps/|packages/`: solo `project.md`.
- Edge — `context/` no existe: error amable "ejecuta `install.sh` primero", abort.
- Edge — ejecución dentro del propio repo nova-spec: abort con mensaje, igual patrón que `install.sh`.
- Fallo — sin manifests reconocibles: `project.md` con TODOs en todas las secciones + pregunta "¿quieres listar los servicios manualmente?".

## Output esperado
- `context/services/project.md` o `project.draft.md`.
- 0-N `context/services/<svc>.md` o `<svc>.draft.md`.
- Resumen final con lista de archivos creados + "qué falta por rellenar" (los TODOs).

## Criterios de éxito
- En un repo real con monorepo estándar, `/nova-init` produce borradores útiles en <5 min.
- No sobrescribe ningún archivo existente sin confirmación (verificable: ejecutar dos veces → segundo run crea `.draft.md`).
- Los borradores contienen TODOs explícitos donde la heurística no infiere (ningún campo se inventa).
- `context-loader` puede leer `project.md` o `<svc>.md` tras un `/nova-init` y completar su bucle sin "Huecos: novaspec no documentado".

## Impacto arquitectónico
- Servicios afectados: `novaspec`.
- ADRs referenciados: `checkpoints-humanos-obligatorios`, `templates-externos-a-comandos`, `patron-subagentes`, `convencion-context-git-vs-local`, `memoria-sencilla`.
- ¿Requiere ADR nuevo?: no — el ticket aplica decisiones existentes; no introduce un patrón nuevo.

## Verificación sin tests automatizados
### Flujo manual
1. Instalar nova-spec en un repo scratch (monorepo pnpm con `packages/a`, `packages/b`): `bash install.sh --target claude`.
2. Abrir Claude Code, ejecutar `/nova-init`.
3. Confirmar en el checkpoint; revisar archivos generados.
4. Re-ejecutar `/nova-init` → verificar que crea `.draft.md` sin tocar los originales.
5. Ejecutar `/nova-start TEST-1` → `context-loader` debe reportar `novaspec` ✓ sin "Huecos".

### Qué mirar
- Filesystem: archivos creados bajo `context/services/` con TODOs explícitos.
- Logs del checkpoint: muestran preview coherente antes de escribir.
- Contenido: ningún dato inventado (URLs, arquitectura, decisiones).

## Riesgos
- **Heurísticas falsas** (detecta servicio donde no hay): mitigación → TODOs marcados, checkpoint humano antes de escribir, default `.draft.md` en re-runs.
- **Repo gigante que ralentiza el escaneo**: mitigación → solo top-level + 1 nivel dentro de 3 dirs específicos.
- **Drift con nuevos comandos**: añadir `/nova-init` obliga a tocar README y `services/novaspec.md`; se incluye en tasks.
