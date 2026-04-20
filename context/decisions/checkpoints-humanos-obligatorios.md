# Checkpoints humanos entre fases del flujo

**Fecha**: ~2026-04 (flujo inicial nova-spec)

## Decisión

El flujo nova-spec **no avanza automáticamente** tras `/nova-spec` y antes de `/nova-wrap`. El usuario debe invocar explícitamente el siguiente comando.

## Alternativa descartada

Pipeline auto-ejecutable: `/nova-start` lanza spec → plan → build → review → wrap en cadena.

## Por qué

La premisa del framework es "no piloto automático": el usuario conserva control de cuándo se cierra una decisión y cuándo un cambio entra en el código. Un pipeline automático destruye los puntos donde el humano valida que la dirección es correcta.

## Coste aceptado

Más fricción por ticket; varios comandos en vez de uno. Intencional: la fricción es el mecanismo de control.
