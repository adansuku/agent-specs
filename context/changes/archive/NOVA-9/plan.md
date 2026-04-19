# Plan: NOVA-9

## Estrategia
Primero verificar el estado actual (characterization), luego hacer el `git mv` atómico, después find-and-replace en todos los archivos afectados, y finalmente actualizar `install.sh` y `CONTEXT.md`. El orden importa: el `git mv` debe ir antes que los find-and-replace para que git rastree el movimiento correctamente.

## Archivos a tocar
- `install.sh`: sustituir 3 ocurrencias de `.docs/` → `context/`
- `novaspec/commands/nova-build.md`: referencias a `.docs/changes/active/`
- `novaspec/commands/nova-plan.md`: referencias a `.docs/changes/active/`
- `novaspec/commands/nova-review.md`: referencias a `.docs/changes/active/`
- `novaspec/commands/nova-spec.md`: referencias a `.docs/changes/active/`
- `novaspec/commands/nova-start.md`: referencias a `.docs/changes/active/`
- `novaspec/commands/nova-status.md`: referencias a `.docs/`
- `novaspec/commands/nova-wrap.md`: referencias a `.docs/changes/`
- `novaspec/guardrails/checklist.md`: referencias a `.docs/`
- `novaspec/skills/close-requirement/SKILL.md`: referencias a `.docs/`
- `novaspec/skills/load-context/SKILL.md`: referencias a `.docs/`
- `novaspec/skills/write-adr/SKILL.md`: referencias a `.docs/`
- `novaspec/templates/pr-body.md`: referencias a `.docs/`
- `novaspec/templates/status-report.md`: referencias a `.docs/`
- `novaspec/README.arch.md`: referencias a `.docs/`
- `novaspec/README.quickref.md`: referencias a `.docs/`
- `.docs/services/agex/CONTEXT.md`: toda la documentación del servicio menciona `.docs/`

## Archivos nuevos
- Ninguno

## Dependencias entre cambios
1. **Characterization** — ejecutar greps de verificación antes de tocar nada
2. **`git mv .docs context/`** — debe ir primero para que git registre el rename del árbol completo (incluye `active/NOVA-9/`)
3. **Find-and-replace en novaspec/** — después del mv, actualizar todas las referencias
4. **`install.sh`** — actualizar para crear `context/`
5. **`context/services/agex/CONTEXT.md`** — actualizar al final (ya en su nueva ubicación)
6. **Verificación final** — grep de 0 resultados + prueba manual de install.sh

## Safety net
- Reversibilidad: `git mv context/ .docs/` + `git checkout` revierte todo
- Qué puede romperse: cualquier referencia a `.docs/` no encontrada por el grep (ej. archivos binarios, `.gitignore`)
- Plan de rollback: `git reset --hard HEAD` si el grep de verificación falla

## Characterization tests
Antes de modificar nada:
- [ ] `grep -r '\.docs/' . --exclude-dir=archive --exclude-dir='.git' -l` → registrar lista completa de archivos afectados
- [ ] Verificar que `.docs/` existe y tiene la estructura esperada (`adr/`, `services/`, `changes/`)

## Verificación
- `grep -r '\.docs/' . --exclude-dir=archive --exclude-dir='.git'` → 0 resultados
- `bash install.sh` en repo limpio crea `context/` (verificar con `ls -la`)
- `git status` limpio tras el cambio
