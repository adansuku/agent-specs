# Guardrail: review-approved

Verifica que el review del ticket existe y tiene veredicto ✓.

1. Comprueba que existe `.docs/changes/active/<ticket-id>/review.md`.
   Si no existe:

   ```
   ⛔ Guardrail: no existe review.md para <ticket-id>.
   Ejecuta /sdd-review primero.
   ```
   **Para aquí. No sigas.**

2. Lee `.docs/changes/active/<ticket-id>/review.md` y busca la línea
   `✓ Listo para /sdd-wrap`. Si no aparece esa línea:

   ```
   ⛔ Guardrail: el review de <ticket-id> no tiene veredicto ✓.
   Resuelve los bloqueantes y vuelve a ejecutar /sdd-review.
   ```
   **Para aquí. No sigas.**
