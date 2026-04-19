#!/usr/bin/env bash
# nova-spec bootstrap
# Copia novaspec/ y CLAUDE.md desde el repo nova-spec clonado localmente.
# Uso: bash /ruta/a/nova-spec/install.sh   (ejecutar desde el repo destino)

set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

if [ ! -d "$SCRIPT_DIR/novaspec" ] || [ ! -f "$SCRIPT_DIR/CLAUDE.md" ]; then
  echo "✗ No encuentro ${SCRIPT_DIR}/novaspec/ o ${SCRIPT_DIR}/CLAUDE.md." >&2
  echo "  Ejecuta este script desde un clone del repo nova-spec." >&2
  exit 1
fi

if [ "$SCRIPT_DIR" = "$PWD" ]; then
  echo "✗ No ejecutes install.sh desde el propio repo nova-spec (SCRIPT_DIR == PWD)." >&2
  echo "  Posiciónate en el repo destino y ejecuta: bash \"$SCRIPT_DIR/install.sh\"" >&2
  exit 1
fi

echo "→ Creando estructura de nova-spec..."

# Contenido canónico (sobrescritura idempotente desde la fuente)
rm -rf novaspec
cp -R "$SCRIPT_DIR/novaspec" .
cp "$SCRIPT_DIR/CLAUDE.md" ./CLAUDE.md

# Memoria arquitectónica: estructura y archivos vacíos (no toca los existentes)
mkdir -p .docs/{adr,services,post-mortems,changes/{active,archive}}
touch .docs/glossary.md
touch .docs/changes/active/.gitkeep
touch notes.md

# Symlinks .claude/ hacia novaspec/
mkdir -p .claude
cd .claude
[ -L commands ] || ln -s ../novaspec/commands commands
[ -L skills ]   || ln -s ../novaspec/skills skills
[ -L agents ]   || ln -s ../novaspec/agents agents
cd ..

echo ""
echo "✓ nova-spec instalado"
echo ""
echo "Estructura creada:"
tree -a -L 3 -I '.git' 2>/dev/null || find . -maxdepth 3 -not -path '*/\.git*' | sort
echo ""
echo "Siguiente paso:"
echo "  Abre Claude Code en este directorio y prueba:"
echo "    /nova-start PROJ-123"
