# Symlinks desde `.claude/` al contenido canónico

**Fecha**: anterior a 2026-04-19 (extraído de `services/agex/CONTEXT.md` histórico)

## Decisión

`.claude/commands` y `.claude/skills` son symlinks hacia `novaspec/commands` y `novaspec/skills`. El contenido canónico vive en `novaspec/`; `.claude/` solo apunta.

## Alternativa descartada

Copiar los archivos de `novaspec/` a `.claude/` durante `install.sh`.

## Por qué

Copias divergen: cada actualización del framework obliga a reinstalar y cualquier edit accidental en `.claude/` se pierde silenciosamente. Symlinks hacen que Claude Code vea siempre la fuente canónica.

## Coste aceptado

Symlinks rompen si el repo se mueve a otro disco sin resolver. Aceptable: `install.sh` es idempotente y reconstruye.
