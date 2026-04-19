# Guardrail: branch-pattern

Verifica que hay una rama de ticket activa y extrae `<ticket-id>`.

Lee la rama git actual y extrae el `<ticket-id>`.
Si la rama no sigue el patrón `(feature|fix|arch)/<TICKET>-<slug>`
definido en `novaspec/config.yml`:

⛔ **Para.** No hay rama de ticket activa. Ejecuta `/nova-start <TICKET>` primero.

Si la rama sigue el patrón, extrae el `<TICKET>` del nombre de rama y
úsalo como `<ticket-id>` para el resto del comando.
