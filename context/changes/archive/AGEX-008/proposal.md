# AGEX-008: Renombrar `libnova.spec` → `agex`

## Historia
Como mantenedor del framework agex, quiero que no queden referencias al nombre anterior `libnova.spec` en los archivos trackeados, para que quien instale el framework vea un producto coherente y sin residuos del piloto.

## Objetivo
Completar la renombración del framework (declarada fuera de alcance en AGEX-004), dejando el repo internamente consistente: un solo nombre (`agex`), un solo ejemplo (`PROJ-123`), y `install.sh` con su propio nombre correcto.

## Contexto
El framework se renombró de `libnova.spec` a `agex` (Agent Experience) durante el piloto. AGEX-004 lo declaró explícitamente out-of-scope. Hoy quedan 23 ocurrencias de "libnova" en código trackeado distribuidas en 6 archivos. Adicionalmente, `install.sh:4` hace referencia a un script inexistente (`bootstrap-libnova-spec.sh`) en su comentario de uso, y `install.sh:1334` muestra el ejemplo `OA-1234` (heredado del piloto libnova).

`install.sh` duplica contenido de las fuentes canónicas en `.spec/commands/*.md` vía heredocs; ambos lados deben cambiarse y quedar sincronizados. AGEX-009 aborda esa duplicación estructural en otro ticket — aquí se asume que la duplicación existe.

## Alcance
### En alcance
- `install.sh`: header, `Uso:` (corrección a `bash install.sh`), echo inicial, 3 heredocs (config.yml, CLAUDE.md, sdd-start.md), echo final, ejemplo `OA-1234` → `PROJ-123`.
- `INSTALL.md`: título, 3 menciones en el cuerpo, "siguiente paso", referencia final (6 menciones).
- `CLAUDE.md`: título y primera línea (2 menciones).
- `.spec/config.yml:1`: comentario header.
- `.spec/commands/sdd-start.md`: frontmatter `description` y cuerpo (2 menciones).

### Fuera de alcance
- `.docs/services/agex/CONTEXT.md` (líneas 167-173): se actualiza en `/sdd-wrap` vía skill `update-service-context`, no aquí.
- `.docs/backlog/*`: ignorado por git, referencias históricas; no forma parte del repo efectivo.
- `.docs/changes/archive/*`: histórico, intocable.
- Renombrar el directorio `.spec/` a `.agex/` u otro: decisión anterior ya tomada (mantener `.spec/`).
- Estructura heredoc vs copia de `install.sh`: lo aborda AGEX-009.

## Decisiones cerradas
- Ejemplo genérico: `OA-1234` → `PROJ-123`.
- `install.sh:4`: `# Uso: bash bootstrap-libnova-spec.sh` → `# Uso: bash install.sh`.
- CONTEXT.md se actualiza en `/sdd-wrap`, no en `/sdd-do`.
- Criterio de éxito excluye `.docs/changes/archive/` **y** `.docs/backlog/`.
- No requiere ADR nuevo (la decisión del nombre se tomó durante el piloto; este ticket es su ejecución).
- Wording: "flujo agex" en prosa descriptiva; "agex" en títulos y rótulos.

## Comportamiento esperado
- **Normal**: Tras instalar con `bash install.sh`, el repo destino recibe `CLAUDE.md`, `.spec/config.yml` y `.spec/commands/sdd-start.md` con el nombre `agex` en cada mención. El mensaje final de `install.sh` dice `✓ agex instalado` y sugiere `/sdd-start PROJ-123`.
- **Edge case — re-instalación**: `install.sh` es idempotente; re-ejecutar sobrescribe los archivos generados con el texto nuevo sin tocar `.docs/` ni trabajos en curso.
- **Edge case — instalación previa con texto viejo**: quien tenga un repo instalado antes de este ticket debe re-ejecutar `install.sh` para obtener el texto actualizado. No se escribe lógica de migración.
- **Fallo**: ninguno nuevo. El rename es puro texto estático; no toca lógica.

## Output esperado
Cambios de texto únicamente:
- Archivos editados (ver "En alcance"): 23 ocurrencias de "libnova" sustituidas + 1 ocurrencia de `OA-1234` sustituida + 1 corrección de nombre de script.
- `.docs/changes/active/AGEX-008/`: `proposal.md`, `plan.md`, `tasks.md`, `review.md` (ciclo normal del flujo).

## Criterios de éxito
- `grep -r "libnova" . --include="*.md" --include="*.sh" --include="*.yml" --exclude-dir=.git --exclude-dir=.docs/changes/archive --exclude-dir=.docs/backlog --exclude-dir=.claude/worktrees` devuelve 0.
- `grep -r "OA-1234" . --exclude-dir=.git --exclude-dir=.docs/backlog --exclude-dir=.claude/worktrees` devuelve 0.
- `grep -n "bootstrap-libnova-spec" install.sh` devuelve 0.
- `.spec/commands/sdd-start.md` (fuente canónica) y el heredoc `install.sh:97-...` que lo reproduce tienen el mismo texto salvo delimitadores del heredoc (verificación manual o diff).
- Instalar en un repo vacío con `bash install.sh` genera un `CLAUDE.md` cuyo título es `# Proyecto con agex` y un mensaje final `✓ agex instalado`.

## Impacto arquitectónico
- Servicios afectados: `agex` (único).
- ADRs referenciados: ninguno (directorio vacío).
- ¿Requiere ADR nuevo?: no.
- CONTEXT.md a actualizar en `/sdd-wrap`: `.docs/services/agex/CONTEXT.md` — quitar la viñeta "Peculiaridades conocidas" que describe el rename pendiente (líneas 167-173), reformulándola como nota histórica cerrada o eliminándola si ya no aporta.

## Verificación sin tests automatizados
### Flujo manual
1. Aplicar cambios en los 5 archivos fuente.
2. Ejecutar los tres `grep` del criterio de éxito y verificar que dan 0.
3. `diff <(sed -n '/cat > .spec\/commands\/sdd-start.md/,/^EOF$/p' install.sh | sed '1d;$d') .spec/commands/sdd-start.md` → debe ser vacío.
4. `diff <(sed -n '/cat > CLAUDE.md/,/^EOF$/p' install.sh | sed '1d;$d') CLAUDE.md` → debe ser vacío.
5. En un directorio tmp: `bash /Users/adan/Workspace/agex/install.sh` y comprobar:
   - `grep "libnova" CLAUDE.md .spec/config.yml .spec/commands/sdd-start.md` → 0.
   - Último mensaje impreso: `✓ agex instalado`.

### Qué mirar
- **Logs de `install.sh`**: primer echo debe decir "agex", último echo debe decir "✓ agex instalado", línea de ejemplo debe ser `/sdd-start PROJ-123`.
- **Archivos generados en el repo destino**: títulos y primeras líneas del `CLAUDE.md` y del comentario de `config.yml`.
- **No ejecutar**: tests unitarios; no hay.

## Riesgos
- **Desincronización fuente/heredoc**: cambiar solo un lado deja `install.sh` divergente de `.spec/commands/`. Mitigación: el plan obliga a tocar pares fuente/heredoc juntos; la verificación incluye un `diff` entre ambos.
- **Sustitución ciega**: un `sed -i 's/libnova.spec/agex/g'` global podría cambiar ocurrencias en `.docs/changes/archive/` (histórico) o en strings con contexto diferente. Mitigación: edit dirigido por archivo, no reemplazo masivo.
- **Acentos y mayúsculas**: "libnova" aparece solo en minúsculas y siempre como `libnova.spec` o `libnova`. Mitigación: grep case-sensitive como criterio.
- **Ejemplo `PROJ-123` colisiona con otro ejemplo en el código**: grep previo confirmó que `PROJ-123` no aparece en ningún archivo trackeado. Sin colisión.
