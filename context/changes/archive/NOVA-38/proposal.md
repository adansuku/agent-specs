<!-- Mantén esta spec ≤ 60 líneas. Bullets y tablas, no prosa. Se carga en cada turno de nova-build. -->
# NOVA-38: Oficializar nova-spec como repo público único

## Historia
Como autor del framework, quiero publicar nova-spec como un solo repo open-source con convenciones claras de qué es distribuible y qué es local, para desbloquear la prueba en el equipo de libnova sin duplicar infra.

## Objetivo
Dejar el repo `adansuku/nova-spec` listo para que cualquier proyecto externo (empezando por libnova) clone, ejecute `install.sh` y empiece a usar `/nova-*` sin fricción.

## Contexto
El ticket original proponía split en dos repos (oficial + dev). Análisis posterior descartó esa opción: `install.sh` ya no copia `context/` al proyecto destino (solo `novaspec/` + `CLAUDE.md`), por lo que la "contaminación" que motivaba el split no existe. Dos repos reintroducirían el drift que AGEX-009 acabó eliminando. Un solo repo público es más simple, dogfoodea el framework y ofrece `context/changes/archive/` como ejemplos vivos.

## Alcance
### En alcance
- Renombrar repo GitHub `adansuku/NovaSpec` → `adansuku/nova-spec`.
- Reescribir `README.md` para lector externo (qué es, por qué, cómo instalar).
- Actualizar `.gitignore` (añadir `notes.md` como mínimo; revisar resto).
- Añadir `CONTRIBUTING.md` mínimo.
- ADR nueva: convención "qué de `context/` va en git, qué es local" (aplica al repo y a cualquier consumidor).
- Fix `install.sh`: crea estructura obsoleta (`adr/`, `post-mortems/`, `glossary.md`) en vez de la actual (`decisions/`, `gotchas/`, `services/`). Descubierto en smoke baseline.
- Fix `install.sh`: al copiar `novaspec/` filtra `novaspec/config.yml` del maintainer al destino. Debe excluirlo, preservar el `config.yml` que tenga el destino, y bootstrap desde `config.example.yml` en instalación limpia.
- Smoke test end-to-end de `install.sh` en repo scratch vacío.
- Hacer repo público (`gh repo edit --visibility public`) como último paso.

### Fuera de alcance
- Split en dos repos (descartado).
- Repo "showcase" para alumnos/compañeros (ticket aparte más adelante).
- Traducción a inglés → NOVA-39.
- CI/CD de release → follow-up.
- Piloto real en el repo de libnova → follow-up, no bloquea cierre.

## Decisiones cerradas
- Un solo repo público, no split.
- Nombre final GitHub: `adansuku/nova-spec` (kebab, alineado con AGEX-016).
- Publicación al final del ticket, no al inicio.
- Smoke test = repo scratch + `install.sh` + arranque de Claude Code + `/nova-start` dummy.
- `context/` del repo nova-spec permanece en git (dogfood/ejemplo vivo).

## Comportamiento esperado
- Normal: clonar `nova-spec` → `bash install.sh` desde repo destino vacío → estructura creada y `/nova-*` disponibles.
- Edge: ejecutar `install.sh` dentro del propio `nova-spec` → sigue abortando (decision AGEX-009 intacta).
- Fallo: sin Claude Code instalado → `install.sh` deja los archivos; el usuario resuelve al abrir Claude.

## Output esperado
- Repo GitHub renombrado, público, con README que se entiende sin contexto previo.
- `.gitignore`, `CONTRIBUTING.md`, ADR convenciones presentes.
- Evidencia del smoke test registrada en `review.md` de este ticket.

## Criterios de éxito
- `adansuku/nova-spec` accesible públicamente; URL vieja redirige.
- Usuario externo puede clonar + instalar + lanzar `/nova-start` sin leer código interno.
- `.gitignore` cubre `notes.md`; no quedan archivos personales tracked.
- ADR explica la convención en ≤ 50 líneas.

## Impacto arquitectónico
- Servicios afectados: `agex` (toca estructura, README, install).
- ADRs referenciados: `install-sh-copia-desde-fuente`, `naming-nova-spec`, `context-contenedor-unico-memoria`, `symlinks-vs-copia`.
- ¿Requiere ADR nuevo?: sí — "convención qué va en git vs local en `context/`".

## Verificación sin tests automatizados
### Flujo manual
1. `mkdir /tmp/nova-smoke && cd /tmp/nova-smoke && git init`.
2. `bash /Users/adan/Workspace/novaspec/install.sh` → opción Claude.
3. Verificar: existen `novaspec/`, `CLAUDE.md`, `AGENTS.md`, `context/{decisions,services,changes/{active,archive}}`, `.claude/{commands,skills,agents}` como symlinks.
4. Abrir Claude Code en `/tmp/nova-smoke` → ejecutar `/nova-status` → debe reportar "no hay ticket activo".
5. `gh repo rename nova-spec` y luego `gh repo edit --visibility public`.
6. Desde otra máquina/clone: clonar la URL pública y repetir pasos 1-4.

### Qué mirar
- Logs: salida de `install.sh` sin errores, estructura listada al final.
- Filesystem: symlinks válidos (`ls -la .claude/`).
- Claude Code: los 7 `/nova-*` aparecen en el selector.

## Riesgos
- Rename de repo rompe clones existentes → GitHub redirige, mitigado.
- README mal calibrado para externos → revisión humana antes de publicar.
- Publicar con secretos en historial → `.env` ya gitignored; revisar `git log -p` antes de `--visibility public`.
