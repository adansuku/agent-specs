# `quick-fix` como tipo ligero que salta spec y plan

**Fecha**: ~2026-04 (flujo inicial)

## Decisión

Los tickets clasificados como `quick-fix` (bug menor, typo, config, <2h) saltan `/nova-spec` y `/nova-plan`. El flujo pasa directo a `/nova-build`. `/nova-wrap` sigue actualizando memoria y creando commit/PR como siempre.

## Alternativa descartada

Flujo único para todos los tickets — spec y plan obligatorios incluso para bugs triviales.

## Por qué

Redactar spec y plan para cambiar una constante de configuración añade fricción sin generar aprendizaje. El valor de la spec está en decisiones cerradas; si no hay decisiones, no hay spec útil.

## Riesgo aceptado

Alguien clasifica como `quick-fix` un cambio que no lo es, y entra a producción sin spec. Mitigación: `/nova-start` declara la clasificación con razonamiento explícito; el humano puede objetar antes de crear la rama.
