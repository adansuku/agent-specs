# Review: NOVA-9

## Cumplimiento de spec
- [✓] `grep -r '\.docs/' . --exclude-dir=archive` → 0 resultados
- [✓] `install.sh` crea `context/` (3 ocurrencias actualizadas: `mkdir -p`, `touch glossary`, `touch .gitkeep`)
- [✓] `context/` existe y `.docs/` eliminado
- [✓] Find-and-replace cubrió todos los archivos en alcance: 7 comandos, guardrails, 3 skills, 2 templates, 2 READMEs, `CONTEXT.md`
- [✓] Anomalía resuelta: 4 archivos extra detectados en characterization (`.claudeignore`, `.gitignore`, `AGENTS.md`, `INSTALL.md`) y actualizados correctamente
- [✓] ADRs en `context/adr/` actualizados (estaban fuera de `archive/`, dentro del criterio de aceptación)

## Convenciones
- Sin incidencias. El replace es mecánico y consistente en todos los archivos.
- 71 archivos en el diff: 54 son renombrados por `git mv` (0 líneas cambiadas), 17 tienen sustituciones reales. Proporción correcta.

## ADRs
- **ADR-0001** (install.sh copia desde fuente): el cambio en `install.sh` es coherente — sigue creando la estructura `mkdir -p` pero con el nuevo nombre. No hay conflicto.
- **ADR-0002** (naming nova-spec): este ticket es una extensión natural del espíritu del ADR (nombres visibles, sin leading dot). Sin conflicto.
- Sin violaciones.

## Riesgos
- **Repos ya instalados** (previsto en spec): breaking change documentado como decisión cerrada. Mitigación pendiente: el README no documenta aún el comando de migración (`git mv .docs context/`). Es una sugerencia, no bloqueante.
- **ADRs con referencias históricas**: se actualizaron referencias como "ver `.docs/services/agex/CONTEXT.md`" en ADR-0001. Las referencias a rutas de archivo histórico (`context/changes/archive/AGEX-009/...`) son ahora técnicamente correctas (el git mv movió esos archivos), aunque el texto describe eventos pasados. Sin impacto funcional.

## Bloqueantes
- Ninguno.

## Sugerencias
- Añadir nota de migración en `INSTALL.md` o `README.quickref.md`: `git mv .docs context/` para repos que actualicen desde una versión anterior.

## Veredicto
✓ Listo para /nova-wrap
