# Plan: AGEX-003

## Estrategia

El cambio se reduce a crear un único archivo de comando:
`.spec/commands/sdd-status.md`. El comando es de solo lectura y no toca
código de producción, por lo que no hay riesgo de regresión. La lógica
de inferencia de estado se codifica en el propio prompt del comando,
siguiendo el mismo patrón que los otros comandos del framework.

## Archivos a tocar

Ninguno. El cambio es puramente aditivo.

## Archivos nuevos

- `.spec/commands/sdd-status.md`: prompt del nuevo comando con lógica de
  detección de estado, casos de uso y formato de salida.

## Dependencias entre cambios

Sin dependencias. Tarea única.

## Safety net

- **Reversibilidad**: borrar `.spec/commands/sdd-status.md` revierte
  completamente. No toca archivos existentes.
- **Qué puede romperse**: nada. El archivo nuevo no es importado ni referenciado
  por ningún otro componente del framework hasta que el usuario lo invoca.
- **Plan de rollback**: `git rm .spec/commands/sdd-status.md`.

## Characterization tests

No aplica. No se modifica código existente.

## Verificación

| Criterio de éxito | Cómo verificar |
|---|---|
| Archivo existe | `ls .spec/commands/sdd-status.md` |
| Detecta ticket de la rama | Invocar `/sdd-status` en rama con patrón |
| Detecta ticket con argumento | Invocar `/sdd-status AGEX-003` |
| Muestra paso correcto | Comparar salida con artefactos presentes en disco |
| Progreso de tareas en paso `do` | Invocar con `tasks.md` parcialmente marcado |
| Ticket archivado | `/sdd-status AGEX-001` |
| Sin ticket activo | Invocar en rama `main` |
| Sin modificaciones | `git diff` antes y después de invocar |
