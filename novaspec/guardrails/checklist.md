# Guardrails — Checklist

**Orden de ejecución: 1 → 2 → 3 → 4 → 5**

## 1. branch-pattern
Verifica rama de ticket activa. Extrae `<ticket-id>` de la rama git actual.
- Debe seguir patrón `(feature|fix|arch)/<TICKET>-<slug>` en `novaspec/config.yml`.
- ⛔ **Para.** Ejecuta `/nova-start <TICKET>` primero.

## 2. proposal-exists
Verifica spec redactada.
- Debe existir `.docs/changes/active/<ticket-id>/proposal.md`.
- ⛔ **Para.** Ejecuta `/nova-spec` primero.

## 3. plan-and-tasks-exist
Verifica plan y tareas. Excepción quick-fix (rama `fix/`).
- Si **no quick-fix**: deben existir `plan.md` + `tasks.md`.
- Si **quick-fix**: puedes continuar sin ellos.
- ⛔ **Para.** Ejecuta `/nova-plan` primero.

## 4. all-tasks-done
Verifica tareas completadas. Excepción quick-fix sin `tasks.md`.
- Si **existe tasks.md**: no debe haber `- [ ]` pendientes.
- ⛔ **Para.** Ejecuta `/nova-build` primero.

## 5. review-approved
Verifica review aprobado.
- Debe existir `review.md` con línea `✓ Listo para /nova-wrap`.
- ⛔ **Para.** Ejecuta `/nova-review` primero.