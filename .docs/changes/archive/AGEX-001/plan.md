# Plan: AGEX-001

## Estrategia

Un único archivo nuevo. Se lee el estado real del repo (comandos, skills,
config, install.sh, README) y se sintetiza en el CONTEXT.md sin inventar.
Una sola pasada; sin dependencias internas.

## Archivos a tocar

- Ninguno existente.

## Archivos nuevos

- `.docs/services/agex/CONTEXT.md`: memoria de servicio del framework.
  Requiere crear el directorio `.docs/services/agex/` primero.

## Dependencias entre cambios

- No hay. El CONTEXT.md es el único artefacto a crear.

## Safety net

- **Reversibilidad**: archivo nuevo en documentación. Para revertir:
  `rm -rf .docs/services/agex/` o revertir el commit.
- **Qué puede romperse**: nada en runtime. Ningún comando ni skill depende
  de la existencia del CONTEXT.md para ejecutarse.
- **Plan de rollback**: revertir el commit.

## Characterization tests

N/A. No se modifica código existente.

## Verificación

Por cada criterio de éxito de la spec:

1. **Archivo existe**: `ls .docs/services/agex/CONTEXT.md`
2. **Describe qué hace**: leer la sección "Qué hace".
3. **Lista 6 comandos y 4 skills**: `grep -c "sdd-" CONTEXT.md` ≥ 6;
   `grep -c "skill" CONTEXT.md` ≥ 4.
4. **Menciona install.sh y symlinks**: `grep -E "install\.sh|symlink" CONTEXT.md`.
5. **Decisiones clave**: leer sección "Decisiones clave", ≥ 3 puntos.
6. **Sin "Contratos públicos" literal pero con sección de interfaz**:
   buscar la sección adaptada.
