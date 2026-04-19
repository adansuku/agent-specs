# Guardrail: proposal-exists

Verifica que la spec del ticket ya está redactada.

Comprueba que existe `.docs/changes/active/<ticket-id>/proposal.md`.
Si no existe:

⛔ **Para.** No existe `proposal.md` para `<ticket-id>`. Ejecuta `/nova-spec` primero.
