# Guardrail: all-tasks-done

Verifica que `tasks.md` no tiene tareas pendientes. Tiene excepción para
tickets `quick-fix` sin `tasks.md`.

Comprueba si es quick-fix (rama `fix/`) y si existe
`.docs/changes/active/<ticket-id>/tasks.md`:

- Si **existe `tasks.md`**: comprueba que no quede ningún `- [ ]` sin
  marcar. Si quedan tareas pendientes:

  ```
  ⛔ Guardrail: hay N tarea(s) sin completar en tasks.md.
  Ejecuta /sdd-do para completarlas primero.
  ```
  **Para aquí. No sigas.**

- Si **no existe `tasks.md`** y es quick-fix: continúa.
- Si **no existe `tasks.md`** y no es quick-fix:

  ```
  ⛔ Guardrail: no existe tasks.md para <ticket-id>.
  Ejecuta /sdd-plan primero.
  ```
  **Para aquí. No sigas.**
