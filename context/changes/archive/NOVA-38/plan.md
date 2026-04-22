# Plan: NOVA-38

## Estrategia
Docs, `.gitignore`, una ADR nueva, fix de `install.sh` (descubierto en smoke baseline) y rename+publish en GitHub. No se toca lógica de los `/nova-*`. El smoke test valida `install.sh` después del fix. Publicar es la última acción, irreversible en términos de exposición, así que va tras verificación.

## Archivos a tocar
- `README.md`: reescritura completa pensada en lector externo (qué es, por qué, quickstart + enlace a `INSTALL.md`, link a `CONTRIBUTING.md`).
- `.gitignore`: añadir `notes.md`; revisar que no falte ningún local file evidente.
- `install.sh`: dos fixes.
  1. Sustituir `mkdir -p context/{adr,services,post-mortems,changes/{active,archive}}` + `touch context/glossary.md` por `mkdir -p context/{decisions,gotchas,services,changes/{active,archive}}`.
  2. No filtrar `novaspec/config.yml` del maintainer: preservar el del destino si existe, borrar el copiado desde la fuente, y bootstrap desde `config.example.yml` en instalaciones limpias.
  Ambos fixes aplican a las dos ramas (claude y opencode).

## Archivos nuevos
- `CONTRIBUTING.md`: guía mínima — cómo proponer cambios, convención de ramas (`feature|fix|arch/TICKET-slug`), dónde abrir issues (GitHub Issues o Jira NOVA).
- `context/decisions/convencion-context-git-vs-local.md`: ADR documentando qué de `context/` va en git (memoria compartida: `decisions/`, `services/`, `changes/archive/`, `changes/active/`, `gotchas/`) y qué es local (`notes.md`, `backlog/`, `.env`, `novaspec/config.yml`). Aplica tanto a este repo como a cualquier consumidor.

## Acciones fuera del árbol (no son archivos)
- `gh repo rename nova-spec` sobre `adansuku/NovaSpec`.
- `git remote set-url origin git@github.com:adansuku/nova-spec.git`.
- `gh repo edit --visibility public` — último paso del ticket.

## Dependencias entre cambios
1. Audit de secretos en historial → **antes** de cualquier otra acción (bloquea publicación si aparece algo).
2. Cambios en árbol (`.gitignore`, README, CONTRIBUTING, ADR) → pueden ir en cualquier orden entre sí.
3. Smoke test → después de que el árbol esté limpio; valida el estado final.
4. Rename repo → puede hacerse temprano o tarde; GitHub redirige la URL anterior.
5. `--visibility public` → **siempre último**, tras smoke test OK y rename hecho.

## Safety net
- Reversibilidad: rename → `gh repo rename NovaSpec` lo devuelve. Público → `gh repo edit --visibility private` lo oculta. Edits de docs → `git revert`.
- Qué puede romperse: que el historial contenga secretos y queden públicos; que el rename rompa clones en otras máquinas (GitHub redirige HTTPS+SSH, pero mejor avisar).
- Plan de rollback: si aparece secreto post-publicación → `gh repo edit --visibility private` inmediato, rotar el secreto, luego `git filter-repo` y re-publicar.

## Characterization tests
Antes de modificar código existente:
- [ ] Smoke baseline: `install.sh` funciona en repo scratch limpio **antes** de tocar docs/gitignore. Estado de referencia.

## Verificación
Cómo verificar cada criterio de éxito de la spec:

| CA | Cómo se verifica |
|---|---|
| Repo público en `adansuku/nova-spec` | `gh repo view adansuku/nova-spec --json visibility,name` devuelve `public` y nombre nuevo |
| Install end-to-end en repo limpio | Flujo manual del proposal §Verificación, pasos 1-4 |
| README claro para externos | Lectura en crudo: ¿se entiende sin saber nada? Revisión humana |
| `.gitignore` cubre `notes.md` | `git check-ignore notes.md` devuelve match |
| ADR convención en ≤ 50 líneas | `wc -l` sobre el archivo |
| URL vieja redirige | `gh repo view adansuku/NovaSpec` sigue resolviendo al repo renombrado |
