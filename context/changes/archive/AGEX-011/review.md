# Review: AGEX-011

## Cumplimiento de spec

- [✓] Eliminar `specs` del `mkdir -p` en `install.sh` — hecho (`install.sh:30`)
- [✓] Eliminar línea `.docs/specs/` de `CLAUDE.md` — hecho
- [✓] Eliminar línea `specs/` del diagrama en `INSTALL.md` — hecho
- [✓] Eliminar `specs/` del diagrama y tabla en `README.md` — hecho (dos puntos)
- [✓] Eliminar paso de consolidación en `sdd-wrap.md` — hecho (línea 51 y 109)
- [✓] Eliminar mención en `load-context/SKILL.md` — hecho
- [✓] Eliminar mención en `close-requirement/SKILL.md` — hecho
- [✓] Eliminar `.docs/specs/.gitkeep` y directorio — hecho
- [✓] Criterio de éxito: `grep -r "docs/specs"` → sin resultados
- [✓] Criterio de éxito: `install.sh` en dir limpio no crea `specs/`

## Convenciones

- Sin incidencias. Los cambios son eliminaciones de líneas o sustituciones
  de texto simples. El estilo de los archivos modificados se mantiene intacto.
- `INSTALL.md` y `README.md` usan el mismo texto de cabecera del bloque `.docs/`:
  "Memoria arquitectónica" (sin "y specs") — coherente entre sí.

## ADRs

- ADR-0001 cubre `install.sh` (patrón `cp -R` desde fuente). El cambio
  elimina `specs` del `mkdir -p` sin tocar el mecanismo de copia — sin conflicto.
- Sin otros ADRs aplicables.

## Riesgos

- La eliminación de `.docs/backlog/AGEX-007.md` aparece en el working tree
  (el usuario la hizo manualmente). No es parte del alcance de AGEX-011 pero
  quedará en el mismo commit si no se separa. Decisión del usuario.
- Proyectos existentes que ya tengan `.docs/specs/` con contenido manual no
  se ven afectados: `install.sh` no borra directorios existentes.

## Bloqueantes

Ninguno.

## Sugerencias

- La sección "Busca ADRs y specs" en `load-context/SKILL.md:37` mantiene
  el título "specs" aunque ahora solo escanea `.docs/adr/`. Podría cambiarse
  a "Busca ADRs", pero es cosmético y fuera del alcance declarado.

## Veredicto

✓ Listo para /sdd-wrap
