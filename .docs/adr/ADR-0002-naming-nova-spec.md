# ADR-0002: Renombrar framework a nova-spec con comandos /nova-*

**Fecha**: 2026-04-19
**Estado**: Aceptada
**Ticket**: AGEX-016

## Contexto

El nombre `agex` era un acrónimo interno sin significado externo. Los
comandos `/sdd-*` (Spec-Driven Development) eran opacos para nuevos usuarios
y acoplaban el nombre de la metodología al nombre del framework.

Libnova impulsó la creación del framework. Se buscaba un nombre que honrara
ese origen y fuera reconocible y pronunciable.

## Decisión

- **Nombre del framework**: `nova-spec`
- **Carpeta de configuración**: `novaspec/` (sin punto, visible y descubrible)
- **Prefijo de comandos**: `/nova-*` en kebab-case

### Alternativas descartadas

| Alternativa | Motivo de descarte |
|---|---|
| `devspec` / `/ds-*` | Genérico, sin identidad propia |
| `/nova:start` (sintaxis colon) | No compatible con Claude Code para comandos de proyecto (solo plugins externos) |
| `.nova/` (con punto) | Oculta el directorio en Unix; dificulta descubrimiento en repos de equipo |
| `nova/` (sin `spec`) | Ambiguo sobre el propósito del framework |

### Compatibilidad con AI CLIs

`/nova-*` usa kebab-case, el estándar de facto en Claude Code, Gemini CLI y
OpenCode, donde los comandos derivan del nombre del archivo. El `:` está
reservado para namespacing de plugins en Claude Code y es inválido en nombres
de archivo en Windows.

## Consecuencias

- Instalaciones previas de `agex` (con `.spec/`) no se migran automáticamente.
  Para actualizar: ejecutar `install.sh` desde el repo `nova-spec` actualizado.
- Los archivos en `.docs/changes/archive/` mantienen referencias históricas a
  `sdd-*` y `.spec/` — se preservan como registro histórico, no se tocan.
- Prefijos de tickets `AGEX-NNN` se mantienen para el histórico existente.
