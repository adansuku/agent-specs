# Review: NOVA-38

Revisión basada en `git diff HEAD` (working tree + staged) — la rama no tiene commits nuevos vs `develop`; /nova-build no commitea.

## Cumplimiento de spec

- [✓] **Repo público en `adansuku/nova-spec`**: `gh repo view adansuku/nova-spec --json visibility,name` → `{"name":"nova-spec","visibility":"PUBLIC"}`. URL vieja redirige (verificado en smoke-test.md).
- [✓] **`README.md` reescrito para lector externo**: `README.md:1-74` tiene estructura Qué es / Por qué / Quickstart / Flujo / Comandos / Principios / Documentación / Dogfood / Licencia. El quickstart describe el flujo clone-y-ejecutar (`git clone ~/tools/nova-spec` + `bash ~/tools/nova-spec/install.sh`), consistente con la decisión `install-sh-copia-desde-fuente.md`.
- [✓] **`.gitignore` cubre `notes.md`**: `git check-ignore notes.md` → match. Añadidos además `.DS_Store`, `*.swp`, `*.swo` (razonables, alineados con la tabla "local" de la ADR nueva).
- [✓] **`CONTRIBUTING.md` presente**: 52 líneas, cubre cómo proponer cambios, convención de ramas (`feature|fix|arch/<TICKET>-<slug>`), estilo (español, markdown atómico, commits convencionales), dónde abrir issues. Enlaza a la ADR nueva.
- [✓] **ADR nueva `convencion-context-git-vs-local.md`**: 45 líneas (< 50 exigidos). Clasifica cada pieza de `context/` y anexos como git o local con justificación, alternativas descartadas, coste aceptado y consecuencias. Declara aplicabilidad al repo y a consumidores.
- [✓] **Fix T2b `install.sh` estructura context/**: `install.sh:177,222` usa `mkdir -p context/{decisions,gotchas,services,changes/{active,archive}}` en ambas ramas (claude+opencode); desaparecen `adr/`, `post-mortems/`, `glossary.md`. Coherente con `memoria-sencilla.md`.
- [✓] **Fix T6b `install.sh` leak de `novaspec/config.yml`**: `install.sh:158-170` (claude) y `install.sh:204-216` (opencode) implementan backup→rm→restore o bootstrap desde `config.example.yml`. Smoke verifica que tras fresh install el `config.yml` del destino no contiene datos del maintainer y que una reinstalación preserva el `config.yml` editado del destino (smoke-test.md §Verificaciones automáticas, filas 7-8).
- [✓] **Smoke test end-to-end**: `context/changes/active/NOVA-38/smoke-test.md` documenta comandos, exit 0, estructura resultante y 8/8 verificaciones automáticas OK. Parte interactiva (`/nova-status` en Claude Code) queda pendiente como verificación manual explícita — aceptable según el argumento del runner.
- [✓] **`notes.md` untracked**: `git rm --cached notes.md` ejecutado; el archivo sigue en disco pero fuera del tree. `.gitignore` lo cubre para que no vuelva a ser staged.
- [✓] **`--visibility public` como último paso**: el repo ya estaba público al llegar a T9 (hallazgo #4 en smoke). T9 queda cubierta por estado previo; el audit T1 retroactivo no encontró secretos.

## Convenciones

- Estilo markdown coherente con el resto de `context/decisions/` (sin frontmatter, nombre-concepto, tablas breves, sección "Alternativas descartadas" / "Coste aceptado" / "Consecuencias"). La ADR nueva sigue el patrón de `memoria-sencilla.md`.
- Lenguaje: todo en español, alineado con `CONTRIBUTING.md:41` ("el framework se escribe en español").
- `install.sh`: los fixes respetan el estilo circundante — variables locales `DEST_CONFIG_BACKUP`, comentarios en español, numeración `[1/6]`...`[6/6]` intacta, estructura espejo entre ramas claude/opencode.
- Sin dead code, prints de debug ni imports sobrantes.
- `README.md` actualiza el `alt` del logo a `nova-spec` (kebab) consistente con `naming-nova-spec.md`.
- Convención de nombre de archivo de decisión (kebab, concepto, no numerado) respetada: `convencion-context-git-vs-local.md`.

## ADRs

- **Coherente con `install-sh-copia-desde-fuente.md`**: el quickstart del README refleja el modelo "clonar repo fuente + ejecutar install.sh desde destino". Los fixes al `install.sh` no reintroducen heredocs ni rompen la propiedad de fuente única.
- **Coherente con `symlinks-vs-copia.md`**: los symlinks `.claude/{commands,skills,agents} → ../novaspec/*` se siguen creando tras los fixes. No se tocó esa lógica.
- **Coherente con `naming-nova-spec.md`**: repo renombrado a `adansuku/nova-spec` (kebab), README y CONTRIBUTING usan `nova-spec`/`/nova-*`.
- **Coherente con `context-contenedor-unico-memoria.md` y `memoria-sencilla.md`**: `install.sh` ahora crea `context/{decisions,gotchas,services,changes/...}` — la nomenclatura canónica post-NOVA-37 —; desaparecen `adr/`, `post-mortems/`, `glossary.md`. La nueva ADR clasifica explícitamente `decisions/`, `gotchas/`, `services/`, `changes/{active,archive}/` como git.
- **Coherente con `guardrails-por-paso.md`, `patron-subagentes.md`, `checkpoints-humanos-obligatorios.md`, `quick-fix-salta-spec-y-plan.md`, `templates-externos-a-comandos.md`**: no tocadas; el cambio es 100% docs/install/ADR, no toca lógica de `/nova-*`.

Sin conflictos con decisiones vivas.

## Riesgos

- **LICENSE marcada como "próximamente" en README** (`README.md:77`). Al estar el repo público sin LICENSE, legalmente el código está "all rights reserved" por defecto. No es bloqueante de NOVA-38 (la spec no incluye LICENSE en alcance), pero conviene abrir follow-up.
- **`origin/develop` va 1 commit detrás de `develop` local** (`e47f6fe`). Housekeeping declarado fuera de alcance en smoke-test.md §hallazgo 5. Un smoke desde clone público hoy no contiene el fix de T2b/T6b; queda correcto tras merge de esta rama.
- **Verificación interactiva de `/nova-status` pendiente**: smoke-test.md §"Verificación manual pendiente" deja 3 checks que requieren abrir Claude Code. No son bloqueantes del review según el argumento del runner, pero deben completarse antes de `/nova-wrap` (la propia tasks.md §Nota T7 lo refuerza).
- **No se generó `.gitignore` en el destino del smoke**: la propia ADR lo declara como follow-up explícito (`convencion-context-git-vs-local.md:44`), aceptado. Sin impacto en NOVA-38.
- Sin efectos colaterales no previstos. Los fixes del installer son idempotentes (backup+restore preserva ediciones del destino en reinstalaciones).

## Bloqueantes

Ninguno.

## Sugerencias

- Abrir ticket de follow-up para `LICENSE` (MIT) — coherente con que el repo ya es público y el README lo promete.
- Abrir ticket de follow-up para que `install.sh` escriba un `.gitignore` base en el destino cubriendo los ítems "local" de la ADR (ya referenciado en `convencion-context-git-vs-local.md:44` como follow-up).
- Abrir ticket de housekeeping para empujar `e47f6fe` a `origin/develop` (fuera de NOVA-38, ya documentado).
- Opcional: en `CONTRIBUTING.md:31` ("Base: `develop`. `main` se actualiza desde `develop` en release.") podría enlazarse a una futura ADR de branching si se formaliza; hoy es convención implícita suficiente.
- Opcional: el bloque `#安装 para Claude Code` en `install.sh:154` tiene un carácter CJK suelto (preexistente, no introducido por este ticket) — cosmético.

## Veredicto

✓ Listo para /nova-wrap
