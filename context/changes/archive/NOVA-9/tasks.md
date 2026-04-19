# Tareas: NOVA-9

- [x] 1. Characterization: registrar todos los archivos con `.docs/` y verificar estructura del directorio — `grep + ls .docs/`
- [x] 2. `git mv .docs context/` — renombrar el árbol completo
- [x] 3. Find-and-replace `.docs/` → `context/` en los 7 comandos — `novaspec/commands/*.md`
- [x] 4. Find-and-replace `.docs/` → `context/` en guardrails y skills — `novaspec/guardrails/checklist.md`, `novaspec/skills/*/SKILL.md`
- [x] 5. Find-and-replace `.docs/` → `context/` en templates y READMEs — `novaspec/templates/`, `novaspec/README.*.md`
- [x] 6. Actualizar `install.sh` — sustituir 3 ocurrencias de `.docs/` → `context/`
- [x] 7. Actualizar `context/services/agex/CONTEXT.md` — reemplazar todas las referencias a `.docs/`
- [x] 8. Verificación final: `grep -r '\.docs/' . --exclude-dir=archive --exclude-dir='.git'` → 0 resultados
