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
   - Lista los directorios bajo `context/changes/active/`.
   - Si hay tickets abiertos, muestra:

     ```
     No hay ticket activo en la rama actual.

     Tickets abiertos:
     - <TICKET-ID>: <paso inferido>
     ```

   - Si no hay ninguno, muestra:

     ```
     No hay ticket activo y no hay tickets abiertos en context/changes/active/.
     Ejecuta /nova-start <TICKET> para comenzar.
     ```

   - En ambos casos, **termina aquí**.

## Paso 2 — Localizar los artefactos

Busca los artefactos del ticket en este orden de prioridad:

1. **Archivado**: existe `context/changes/archive/<ticket-id>/` → paso = `archivado`
2. **Activo**: directorio `context/changes/active/<ticket-id>/`

Si no existe ninguno de los dos:

```
Ticket <ticket-id> no encontrado.
No existe context/changes/active/<ticket-id>/ ni context/changes/archive/<ticket-id>/
```

Termina aquí.

## Paso 3 — Inferir el paso actual

Evalúa en orden (el primero que aplica gana):

| Condición | Paso | Siguiente |
|---|---|---|
| Directorio en `archive/` | `archivado` | — |
| Existe `review.md` | `wrap` | `/nova-wrap` |
| `tasks.md` sin `- [ ]` pendientes | `review` | `/nova-review` |
| `tasks.md` con algún `- [ ]` | `do` | `/nova-build` |
| `plan.md` sin `tasks.md` | `plan` | `/nova-build` |
| `proposal.md` sin `plan.md` | `spec` | `/nova-plan` |
| Sin `proposal.md` | `start` | `/nova-spec` |

## Paso 4 — Leer el título

Si existe `proposal.md`, extrae el título de la primera línea `# <TICKET>: <título>`.
Si no existe o no se puede leer, usa `(sin título)`.

## Paso 5 — Calcular progreso de tareas

Solo si el paso es `do` o `review`:
- Cuenta líneas con `- [x]` → tareas completadas
- Cuenta líneas con `- [ ]` → tareas pendientes
- Total = completadas + pendientes

## Paso 6 — Mostrar el reporte

Usa la estructura de `novaspec/templates/status-report.md` como referencia.
Incluye `Progreso` solo si el paso es `do`; usa `Archivado` en lugar de
`Siguiente` si el paso es `archivado`. El campo `Siguiente` viene de la
columna homónima del Paso 3.

## Reglas

- **No modifiques ningún archivo** bajo ninguna circunstancia.
- Si un artefacto existe pero no se puede parsear, reporta
  `(no se pudo leer <archivo>)` y continúa con lo que tengas.
- No hagas suposiciones sobre el estado: infiere solo desde los archivos.
- Si hay ambigüedad, elige el paso más conservador (el anterior en el flujo).
