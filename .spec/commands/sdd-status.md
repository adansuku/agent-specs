---
description: Muestra el estado actual de un ticket en el flujo SDD
argument-hint: [TICKET-ID]
---

Eres un comando de **solo lectura**. No modificas ningún archivo.
Tu única función es inspeccionar artefactos en disco y reportar el estado.

## Paso 1 — Resolver el ticket-id

Si el usuario pasó un argumento (`$ARGUMENTS` no está vacío), úsalo como
`<ticket-id>`.

Si no hay argumento:
1. Lee la rama git actual (`git branch --show-current`).
2. Si la rama sigue el patrón `(feature|fix|arch)/<TICKET>-<slug>`,
   extrae `<TICKET>` como `<ticket-id>`.
3. Si la rama **no** sigue ese patrón:
   - Lista los directorios bajo `.docs/changes/` (excluyendo `archive/`).
   - Si hay tickets abiertos, muestra:

     ```
     No hay ticket activo en la rama actual.

     Tickets abiertos:
     - <TICKET-ID>: <paso inferido>
     ```

   - Si no hay ninguno, muestra:

     ```
     No hay ticket activo y no hay tickets abiertos en .docs/changes/.
     Ejecuta /sdd-start <TICKET> para comenzar.
     ```

   - En ambos casos, **termina aquí**.

## Paso 2 — Localizar los artefactos

Busca los artefactos del ticket en este orden de prioridad:

1. **Archivado**: existe `.docs/changes/archive/<ticket-id>/` → paso = `archivado`
2. **Activo**: directorio `.docs/changes/<ticket-id>/`

Si no existe ninguno de los dos:

```
Ticket <ticket-id> no encontrado.
No existe .docs/changes/<ticket-id>/ ni .docs/changes/archive/<ticket-id>/
```

Termina aquí.

## Paso 3 — Inferir el paso actual

Evalúa los artefactos en este orden (el primero que aplica gana):

| Condición | Paso inferido |
|---|---|
| Directorio en `archive/` | `archivado` |
| Existe `review.md` | `wrap` (listo para `/sdd-wrap`) |
| Existe `tasks.md` y **todas** las líneas `- [x]` (ninguna `- [ ]`) | `review` (listo para `/sdd-review`) |
| Existe `tasks.md` con al menos una `- [ ]` | `do` (en progreso) |
| Existe `tasks.md` sin ningún checkbox | `do` (sin tareas ejecutadas) |
| Existe `plan.md` pero no `tasks.md` | `plan` (plan sin tareas) |
| Existe `proposal.md` pero no `plan.md` | `spec` (spec sin plan) |
| No existe `proposal.md` | `start` (solo rama, sin spec) |

## Paso 4 — Leer el título

Si existe `proposal.md`, extrae el título de la primera línea `# <TICKET>: <título>`.
Si no existe o no se puede leer, usa `(sin título)`.

## Paso 5 — Calcular progreso de tareas

Solo si el paso es `do` o `review`:
- Cuenta líneas con `- [x]` → tareas completadas
- Cuenta líneas con `- [ ]` → tareas pendientes
- Total = completadas + pendientes

## Paso 6 — Mostrar el reporte

Usa este formato exacto:

```
## Estado del ticket <TICKET-ID>

Título     : <título>
Rama       : <rama git actual>
Paso actual: <paso>
Siguiente  : <siguiente comando>
```

Si el paso es `do`, añade debajo de "Paso actual":
```
Progreso   : <N completadas> / <M totales> tareas
```

Si el paso es `archivado`, sustituye "Siguiente" por:
```
Archivado  : .docs/changes/archive/<ticket-id>/
```

### Tabla de siguientes comandos

| Paso | Siguiente comando |
|---|---|
| `start` | `/sdd-spec` |
| `spec` | `/sdd-plan` |
| `plan` | `/sdd-do` |
| `do` | `/sdd-do` (continuar) |
| `review` | `/sdd-review` |
| `wrap` | `/sdd-wrap` |
| `archivado` | — (ticket cerrado) |

## Reglas

- **No modifiques ningún archivo** bajo ninguna circunstancia.
- Si un artefacto existe pero no se puede parsear, reporta
  `(no se pudo leer <archivo>)` y continúa con lo que tengas.
- No hagas suposiciones sobre el estado: infiere solo desde los archivos.
- Si hay ambigüedad, elige el paso más conservador (el anterior en el flujo).
