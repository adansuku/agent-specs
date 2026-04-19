# Plan: NOVA-001

## Estrategia
Crear `novaspec/templates/` con los skeletons de salida actualmente inline en los comandos, luego editar cada comando para referenciar su plantilla por ruta en lugar de incluir el bloque. Primero templates (riesgo cero, archivos nuevos), después ediciones de comandos una a una.

## Archivos nuevos
- `novaspec/templates/proposal.md` — skeleton del proposal para nova-spec
- `novaspec/templates/plan.md` — skeleton de plan.md para nova-plan
- `novaspec/templates/tasks.md` — skeleton de tasks.md para nova-plan
- `novaspec/templates/review.md` — skeleton del reporte de review para nova-review
- `novaspec/templates/commit.md` — template del mensaje de commit para nova-wrap
- `novaspec/templates/pr-body.md` — template del cuerpo del PR para nova-wrap
- `novaspec/templates/ticket-summary.md` — skeleton del resumen inicial para nova-start
- `novaspec/templates/status-report.md` — formato del reporte de estado para nova-status

## Archivos a tocar
- `novaspec/commands/nova-spec.md` — eliminar skeleton inline (líneas 36-84), añadir referencia a `templates/proposal.md`
- `novaspec/commands/nova-plan.md` — eliminar skeletons plan + tasks (líneas 30-68), añadir referencias
- `novaspec/commands/nova-review.md` — eliminar template de reporte (líneas 55-80), añadir referencia
- `novaspec/commands/nova-wrap.md` — eliminar commit template + PR body (líneas 55-100), añadir referencias
- `novaspec/commands/nova-start.md` — eliminar ticket summary skeleton (líneas 69-87), añadir referencia
- `novaspec/commands/nova-status.md` — eliminar formato del reporte (líneas 85-114), añadir referencia
- `novaspec/commands/nova-build.md` — extracción mínima posible; puede no alcanzar ≥30 LOC (ver Riesgos)

## Dependencias entre cambios
Crear todos los templates antes de editar los comandos. Las ediciones de comandos son independientes entre sí.

## Safety net
- Reversibilidad: git revert — los archivos template son nuevos y las ediciones de comandos son pura sustracción de bloques
- Qué puede romperse: el modelo no carga el template y genera salida con estructura incorrecta
- Plan de rollback: `git checkout novaspec/commands/nova-*.md` restaura los comandos; los templates quedan como archivos muertos pero inofensivos

## Characterization tests
No aplica — no hay código de producción; los "tests" son verificación manual del flujo.

## Verificación
1. `wc -l novaspec/commands/nova-*.md` — confirmar reducción ≥30 por archivo (excepto nova-build, ver Riesgos)
2. Cada comando contiene `novaspec/templates/<nombre>.md` como referencia explícita
3. Ejecución manual: `/nova-start NOVA-TEST` → verificar que ticket-summary sigue `templates/ticket-summary.md`
4. Ejecución manual: `/nova-spec` → verificar que `proposal.md` generado sigue el skeleton

## Riesgos
- **nova-build sin skeleton sustancial**: el archivo tiene 73 LOC pero no tiene bloques de formato relevantes extraíbles (solo mensajes de progreso ~12 líneas). Es probable que no alcance -30 LOC. El criterio es indicativo — se acepta como desviación conocida y se documenta.
- **nova-status**: tiene ~30 líneas de formato de tabla extraíbles → se añade `templates/status-report.md` (no listado en spec original, extensión necesaria para cumplir criterio).
