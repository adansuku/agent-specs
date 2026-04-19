#!/usr/bin/env bash
#
# nova-spec installer — Interactivo
# Instala nova-spec en Claude Code o OpenCode.
#
# Uso: bash install.sh [opciones]
#   -t, --target    claude|opencode  Destino (prompt si no se especifica)
#   -w, --worktrees             Crear worktrees (solo Claude Code)
#   -h, --help               Mostrar ayuda
#
# Sin opciones: modo interactivo
#

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
TARGET=""
WORKTREES=false

# Parsear argumentos
while [[ $# -gt 0 ]]; do
  case $1 in
    -t|--target)
      TARGET="$2"
      shift 2
      ;;
    -w|--worktrees)
      WORKTREES=true
      shift
      ;;
    -h|--help)
      echo "Uso: $0 [opciones]"
      echo ""
      echo "Opciones:"
      echo "  -t, --target DESTINO  Destino: claude|opencode"
      echo "  -w, --worktrees     Crear worktrees (solo Claude Code)"
      echo "  -h, --help        Mostrar esta ayuda"
      echo ""
      echo "Sin opciones: modo interactivo"
      exit 0
      ;;
    *)
      echo "Opción desconocida: $1"
      exit 1
      ;;
  esac
done

# Verificar que estamos en el repo correcto
if [[ ! -d "$SCRIPT_DIR/novaspec" ]] || [[ ! -f "$SCRIPT_DIR/AGENTS.md" ]]; then
  echo -e "${RED}✗ No encuentro novaspec/ o AGENTS.md en $SCRIPT_DIR${NC}" >&2
  echo "  Ejecuta este script desde el repo nova-spec." >&2
  exit 1
fi

# Verificar que NO estamos en el propio repo nova-spec
if [[ "$SCRIPT_DIR" == "$PWD" ]]; then
  echo -e "${BLUE}📁 ¿Dónde quieres instalar nova-spec?${NC}"
  echo ""
  echo "Directorio actual: $PWD"
  echo ""
  echo "Opciones:"
  echo "  (1) Escribir ruta manual"
  echo "  (2) Navegar hacia arriba (cd ..)"
  echo "  (3) Cancelar"
  echo ""
  read -p "→ " -n 1 choice
  echo ""

  case $choice in
    1)
      echo ""
      echo "Escribe la ruta absoluta o relativa:"
      read -e DEST_DIR
      if [[ -z "$DEST_DIR" ]]; then
        echo -e "${RED}✗ Ruta vacía${NC}"
        exit 1
      fi
      if [[ ! -d "$DEST_DIR" ]]; then
        mkdir -p "$DEST_DIR"
      fi
      cd "$DEST_DIR"
      echo -e "${GREEN}→ Instalando en: $(pwd)${NC}"
      ;;
    2)
      cd ..
      echo -e "${GREEN}→ Cambiado a: $(pwd)${NC}"
      echo "Ejecuta de nuevo: bash \"$SCRIPT_DIR/install.sh\""
      exit 0
      ;;
    3)
      echo "Cancelado."
      exit 0
      ;;
    *)
      echo -e "${RED}✗ Opción inválida${NC}"
      exit 1
      ;;
  esac
fi

#
# Modalidad interactiva si TARGET no está definido
#
if [[ -z "$TARGET" ]]; then
  echo -e "${BLUE}🎯 nova-spec installer${NC}"
  echo "─────────────────"
  echo ""
  echo "¿Destino?"
  echo "  (1) Claude Code"
  echo "  (2) OpenCode"
  echo ""
  read -p "→ " -n 1 choice
  echo ""

  case $choice in
    1) TARGET="claude" ;;
    2) TARGET="opencode" ;;
    *)
      echo -e "${RED}Opción inválida: $choice${NC}"
      exit 1
      ;;
  esac

  if [[ "$TARGET" == "claude" ]]; then
    echo ""
    read -p "¿Crear worktrees para múltiples tickets? (y/N) " -n 1 confirm
    echo ""
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      WORKTREES=true
    fi
  fi
fi

# Validar TARGET
if [[ "$TARGET" != "claude" ]] && [[ "$TARGET" != "opencode" ]]; then
  echo -e "${RED}✗ Destino inválido: $TARGET${NC}" >&2
  echo "  Usa: claude o opencode"
  exit 1
fi

echo ""
echo -e "${BLUE}→ Instalando para $TARGET...${NC}"
echo ""

#
#安装 para Claude Code
#
if [[ "$TARGET" == "claude" ]]; then
  echo -e "${YELLOW}[1/6] Copiando novaspec/${NC}"
  rm -rf novaspec
  cp -R "$SCRIPT_DIR/novaspec" .

  echo -e "${YELLOW}[2/6] Copiando AGENTS.md${NC}"
  cp "$SCRIPT_DIR/AGENTS.md" ./AGENTS.md
  cp "$SCRIPT_DIR/CLAUDE.md" ./CLAUDE.md

  echo -e "${YELLOW}[3/6] Creando estructura context/${NC}"
  mkdir -p context/{adr,services,post-mortems,changes/{active,archive}}
  touch context/glossary.md
  touch context/changes/active/.gitkeep

  echo -e "${YELLOW}[4/6] Creando symlinks .claude/${NC}"
  mkdir -p .claude
  cd .claude
  [[ -L commands ]] || ln -s ../novaspec/commands commands
  [[ -L skills ]]   || ln -s ../novaspec/skills skills
  [[ -L agents ]]   || ln -s ../novaspec/agents agents
  cd ..

  echo -e "${YELLOW}[5/6] Configurando git worktrees${NC}"
  mkdir -p .git/worktrees
  touch .git/worktrees/.gitkeep

  if [[ "$WORKTREES" == true ]]; then
    echo -e "${YELLOW}  ↳ Worktrees habilitados${NC}"
  fi

  echo -e "${YELLOW}[6/6] Creando notes.md${NC}"
  touch notes.md

#
# 安装 para OpenCode
#
elif [[ "$TARGET" == "opencode" ]]; then
  echo -e "${YELLOW}[1/5] Copiando novaspec/${NC}"
  rm -rf novaspec
  cp -R "$SCRIPT_DIR/novaspec" .

  echo -e "${YELLOW}[2/5] Copiando AGENTS.md${NC}"
  cp "$SCRIPT_DIR/AGENTS.md" ./AGENTS.md

  echo -e "${YELLOW}[3/5] Creando estructura context/${NC}"
  mkdir -p context/{adr,services,post-mortems,changes/{active,archive}}
  touch context/glossary.md
  touch context/changes/active/.gitkeep

  echo -e "${YELLOW}[4/5] Creando symlinks .opencode/${NC}"
  mkdir -p .opencode
  cd .opencode
  [[ -L commands ]] || ln -s ../novaspec/commands commands
  [[ -L skills ]]   || ln -s ../novaspec/skills skills
  [[ -L agents ]]   || ln -s ../novaspec/agents agents
  cd ..

  echo -e "${YELLOW}[5/5] Configurando OpenCode${NC}"
  if [[ ! -f .opencode/settings.local.json ]]; then
    cat > .opencode/settings.local.json << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "skill": {
      "*": "allow"
    }
  }
}
EOF
  fi

  touch notes.md
fi

echo ""
echo -e "${GREEN}✓ nova-spec instalado para $TARGET${NC}"
echo ""
echo "Estructura creada:"
ls -la . | grep -E '^(d|l)' | head -10
echo ""
echo "Siguiente paso:"
echo "  Abre $TARGET en este directorio y prueba:"
echo "    /nova-start PROJ-123"