# Plan: AGEX-011

## Estrategia
Eliminar todas las referencias a `.docs/specs/` en el orden menos arriesgado:
primero verificar el estado actual (characterization), luego tocar cada archivo
de menor a mayor visibilidad, y finalizar borrando el directorio físico.

## Archivos a tocar
- `install.sh:30` — quitar `specs` del `mkdir -p`
- `CLAUDE.md:11` — quitar línea 3 de la lista de memoria arquitectónica
- `INSTALL.md:79` — quitar línea `specs/` del diagrama de árbol
- `README.md:96` — quitar línea `specs/` del diagrama de árbol
- `README.md:124` — quitar `.docs/specs/` de la tabla de capas de memoria
- `.spec/commands/sdd-wrap.md:51` — quitar paso 4 de consolidación
- `.spec/commands/sdd-wrap.md:109` — quitar línea "Specs consolidadas" del template
- `.spec/skills/load-context/SKILL.md:39` — quitar mención a `.docs/specs/`
- `.spec/skills/close-requirement/SKILL.md:19` — quitar mención a `.docs/specs/`

## Archivos eliminados
- `.docs/specs/.gitkeep` (y el directorio si queda vacío)

## Dependencias entre cambios
No hay dependencias de orden entre los archivos. Se pueden hacer en cualquier
secuencia. Conviene verificar el estado actual antes de tocar código.

## Safety net
- Reversibilidad: `git revert` o `git checkout -- <archivo>`; todo es texto
- Qué puede romperse: nada funcional — solo referencias documentales
- Plan de rollback: `git checkout -- .` descarta todos los cambios

## Characterization tests
Antes de modificar `install.sh`:
- [ ] Verificar que `mkdir -p .docs/{adr,services,post-mortems,specs,changes/{active,archive}}` crea `specs/` actualmente

## Verificación
1. `grep -r "docs/specs" install.sh CLAUDE.md INSTALL.md README.md .spec/` → sin resultados
2. `bash install.sh` en tmpdir → `ls .docs/` no contiene `specs/`
3. `.docs/specs/` no existe en el repo (o está vacío y fuera de git)
