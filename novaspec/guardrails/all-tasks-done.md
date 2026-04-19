# Guardrail: all-tasks-done

Verifica que `tasks.md` no tiene tareas pendientes. Tiene excepción para
tickets `quick-fix` sin `tasks.md`.

Comprueba si es quick-fix (rama `fix/`) y si existe
`.docs/changes/active/<ticket-id>/tasks.md`:

- Si **existe `tasks.md`**: comprueba que no quede ningún `- [ ]` sin
  marcar. Si quedan tareas pendientes:

  ⛔ **Para.** Hay tareas `- [ ]` sin completar en `tasks.md`. Ejecuta `/nova-build` primero.

- Si **no existe `tasks.md`** y es quick-fix: continúa.
- Si **no existe `tasks.md`** y no es quick-fix:

  ⛔ **Para.** No existe `tasks.md` para `<ticket-id>`. Ejecuta `/nova-plan` primero.
