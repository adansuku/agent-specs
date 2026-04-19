# AGEX-003: /sdd-status — visibilidad del estado del flujo

## Historia
Como desarrollador usando agex, quiero saber en qué paso del flujo SDD está
un ticket, para poder retomarlo sin tener que adivinar el estado mirando
archivos manualmente.

## Objetivo
Proporcionar un comando de solo lectura que infiera y muestre el estado
actual de un ticket en el flujo SDD, incluyendo progreso de tareas y el
siguiente paso recomendado.

## Contexto
El flujo agex tiene 6 pasos secuenciales. Cuando el usuario cierra Claude Code
a medias, se queda sin tokens, o vuelve al día siguiente, no tiene forma
inmediata de saber en qué paso quedó. Tiene que inspeccionar manualmente
`.docs/changes/<ticket>/` para deducir el estado. Esto añade fricción y
riesgo de ejecutar comandos fuera de orden.

## Alcance

### En alcance
- Nuevo comando `/sdd-status` como archivo `.spec/commands/sdd-status.md`
- Detección automática del ticket desde la rama git si no se pasa argumento
- Inferencia del paso actual basada en artefactos presentes en disco
- Conteo de tareas completadas vs. totales cuando está en `/sdd-do`
- Soporte para tickets archivados en `.docs/changes/archive/<ticket>/`
- Listado de tickets abiertos cuando no hay ticket activo

### Fuera de alcance
- Modificar cualquier archivo (el comando es de solo lectura)
- Integración con Jira para mostrar datos del ticket en tiempo real
- Historial de ejecuciones o timestamps de cada paso
- Validación de coherencia de los artefactos (eso es trabajo de guardrails)

## Decisiones cerradas

- **Detección del paso**: se infiere por presencia de artefactos en disco
  en este orden: archivado → review.md → tasks.md con todos ✓ → tasks.md
  con algún ✓ → tasks.md sin ningún ✓ → plan.md → proposal.md → solo rama
- **Paso "do" vs "review-ready"**: si `tasks.md` existe y todas las tareas
  están marcadas `[x]`, el paso actual es `review` (listo para `/sdd-review`),
  no `do`. Si hay al menos una sin marcar, es `do`.
- **Sin argumento**: el comando extrae el ticket de la rama git actual
  (`(feature|fix|arch)/<TICKET>-<slug>`). Si la rama no sigue ese patrón,
  lista los tickets abiertos en `.docs/changes/` (excluye `archive/`).
- **Idioma**: toda la salida en español, coherente con el resto del framework.
- **No requiere ADR**: es un comando nuevo pero no introduce decisiones
  arquitectónicas de calado.

## Comportamiento esperado

### Normal
- Con ticket activo en rama: muestra ID, título (de `proposal.md` si existe),
  paso actual, rama, progreso de tareas (si aplica), siguiente comando.
- Sin argumento y rama sin patrón de ticket: avisa y lista tickets abiertos.
- Con ticket archivado: informa de que está cerrado y en qué ruta se archivó.

### Edge cases
- `proposal.md` no existe pero hay rama con patrón: paso = `start` (solo
  se ejecutó `/sdd-start`, no `/sdd-spec` todavía).
- `tasks.md` existe pero está vacío o sin checkboxes: tratar como
  `plan` (plan generado pero sin tareas ejecutadas).
- Ticket no encontrado ni en activos ni en archive: informar claramente.
- `.docs/changes/` vacío: informar que no hay tickets abiertos.

### Fallo
- El comando no modifica archivos. No hay estado que pueda corromperse.
- Si un artefacto esperado existe pero está malformado, reportar
  "no se pudo parsear <archivo>" y continuar con lo que se pueda leer.

## Output esperado

```
## Estado del ticket AGEX-003

Título    : /sdd-status — visibilidad del estado del flujo
Rama      : feature/AGEX-003-sdd-status
Paso actual: do  (en progreso)
Progreso  : 2 / 5 tareas completadas

Siguiente comando: /sdd-do
```

Variantes:
- Si archivado: `Paso actual: archivado → .docs/changes/archive/AGEX-003/`
- Si no hay ticket activo: lista de tickets en `.docs/changes/` con su paso

## Criterios de éxito

1. Existe `.spec/commands/sdd-status.md` con descripción y lógica completas.
2. Invocado como `/sdd-status AGEX-003` muestra el estado correcto del ticket.
3. Invocado como `/sdd-status` (sin argumento) en rama con patrón detecta
   el ticket automáticamente.
4. Detecta correctamente cada paso del flujo según los artefactos presentes.
5. Muestra progreso de tareas cuando está en paso `do`.
6. Informa de tickets archivados sin error.
7. Informa de ausencia de ticket activo y lista los abiertos.
8. No modifica ningún archivo.

## Impacto arquitectónico

- **Servicios afectados**: agex (nuevo comando en `.spec/commands/`)
- **ADRs referenciados**: ninguno
- **¿Requiere ADR nuevo?**: no — es un comando utilitario de solo lectura;
  no introduce patrones nuevos ni cambia decisiones existentes.

## Verificación sin tests automatizados

### Flujo manual

1. Con ticket activo en paso `spec`:
   ```
   git checkout feature/AGEX-003-sdd-status
   /sdd-status        # debe mostrar paso "spec", título del proposal.md
   /sdd-status AGEX-003  # mismo resultado con argumento explícito
   ```

2. Con ticket en paso `do` con tareas parciales:
   - Verificar que `tasks.md` tiene algunas `[x]` y otras `[ ]`
   - `/sdd-status` → debe mostrar `do (N/M tareas completadas)`

3. Con todas las tareas completadas:
   - Marcar todas las tareas como `[x]`
   - `/sdd-status` → debe mostrar paso `review`

4. Con ticket archivado:
   - `/sdd-status AGEX-001` → debe mostrar `archivado → .docs/changes/archive/AGEX-001/`

5. Sin ticket activo:
   - `git checkout main`
   - `/sdd-status` → debe listar tickets en `.docs/changes/`

### Qué mirar

- Salida del comando: formato y datos correctos para cada caso
- Archivos: confirmar que ningún archivo fue modificado tras la ejecución

## Riesgos

- **Parseo de checkboxes frágil**: si el formato de `tasks.md` varía,
  el conteo puede fallar. Mitigación: el propio framework genera `tasks.md`
  con formato consistente; documentar el patrón esperado `- [ ]` / `- [x]`.
- **Rama sin ticket activo**: el usuario puede invocar el comando en cualquier
  rama. Mitigación: el caso está cubierto (lista tickets abiertos).
