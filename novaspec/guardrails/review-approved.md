# Guardrail: review-approved

Verifica que el review del ticket existe y tiene veredicto ✓.

1. Comprueba que existe `.docs/changes/active/<ticket-id>/review.md`.
   Si no existe:

   ⛔ **Para.** No existe `review.md` para `<ticket-id>`. Ejecuta `/nova-review` primero.

2. Lee `.docs/changes/active/<ticket-id>/review.md` y busca la línea
   `✓ Listo para /nova-wrap`. Si no aparece esa línea:

   ⛔ **Para.** El review de `<ticket-id>` no tiene veredicto ✓. Resuelve los bloqueantes y vuelve a `/nova-review`.
