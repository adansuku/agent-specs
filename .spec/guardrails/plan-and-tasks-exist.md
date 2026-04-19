# Guardrail: plan-and-tasks-exist

Verifica que el plan y la lista de tareas existen. Tiene excepción para
tickets `quick-fix`.

Comprueba si la rama empieza por `fix/` (quick-fix):

- Si **no es quick-fix**: comprueba que existen
  `.docs/changes/active/<ticket-id>/plan.md` y
  `.docs/changes/active/<ticket-id>/tasks.md`.
  Si falta alguno:

  ```
  ⛔ Guardrail: no existe plan.md o tasks.md para <ticket-id>.
  Ejecuta /sdd-plan primero.
  ```
  **Para aquí. No sigas.**

- Si **es quick-fix**: puedes continuar aunque no existan `plan.md` ni
  `tasks.md`. Salta directamente a la implementación.
