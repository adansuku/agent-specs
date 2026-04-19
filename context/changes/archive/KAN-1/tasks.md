# Tareas: KAN-1

- [x] 1. Characterization: ejecutar `/nova-review` actual en ticket de prueba y confirmar output — manual
- [x] 2. Crear `novaspec/agents/nova-review-agent.md` con lógica completa de review (4 ejes + escritura review.md) — `novaspec/agents/`
- [x] 3. Reescribir `novaspec/commands/nova-review.md` para lanzar el agente con ticket-id y mostrar resumen — `novaspec/commands/nova-review.md`
- [x] 4. Verificar que `review.md` generado contiene `✓ Listo para /nova-wrap` — manual
- [x] 5. Verificar que el guardrail de `/nova-wrap` detecta el `review.md` sin cambios — manual
- [x] 6. Actualizar `novaspec/commands/nova-build.md`: ejecución en secuencia, parar solo ante bloqueantes — ya aplicado
