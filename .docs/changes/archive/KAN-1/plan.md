# Plan: KAN-1

## Estrategia
Crear el archivo agente `novaspec/agents/nova-review-agent.md` con toda la lógica de review (los 4 ejes + escritura de `review.md`). Después simplificar `nova-review.md` para que solo lance el agente con el ticket-id y muestre el resumen. El contrato de salida (`review.md` con `✓ Listo para /nova-wrap`) no cambia.

## Archivos a tocar
- `novaspec/commands/nova-review.md`: eliminar lógica de review; añadir invocación del agente + resumen
- `novaspec/commands/nova-build.md`: cambiar de "una tarea + pedir permiso" a "ejecutar en secuencia, parar solo ante bloqueantes"

## Archivos nuevos
- `novaspec/agents/nova-review-agent.md`: lógica completa de review (lee artefactos, ejecuta 4 ejes, escribe review.md)

## Dependencias entre cambios
1. Crear el agente primero (T1)
2. Modificar `nova-review.md` después (T2) — depende de T1 para poder referenciar la ruta del agente

## Safety net
- Reversibilidad: `nova-review.md` actual está en git; `git checkout` restaura en segundos
- Qué puede romperse: guardrail `review-approved.md` lee `review.md` — si el agente no lo escribe o cambia su formato, `/nova-wrap` se bloquea
- Plan de rollback: `git checkout novaspec/commands/nova-review.md` + borrar `novaspec/agents/`

## Characterization tests
El framework no tiene tests automatizados. Verificación manual antes de modificar:
- [ ] Ejecutar `/nova-review` en un ticket de prueba con el archivo actual y confirmar que genera `review.md` con `✓ Listo para /nova-wrap`
- [ ] Confirmar que `/nova-wrap` detecta ese `review.md` correctamente (guardrail pasa)

## Verificación
- El hilo principal no muestra diff ni contenido de ADRs al ejecutar `/nova-review`
- `.docs/changes/active/<ticket>/review.md` existe con los 4 ejes y el veredicto
- `/nova-wrap` pasa el guardrail `review-approved.md` sin cambios en ese archivo
