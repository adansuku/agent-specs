# Plan: <TICKET-ID>

## Estrategia
<2-3 líneas sobre cómo abordar el cambio>

## Archivos a tocar
- `<ruta>`: <qué se modifica>

## Archivos nuevos
- `<ruta>`: <qué contiene>

## Dependencias entre cambios
<si el orden importa, explícalo>

## Safety net
- Reversibilidad: <feature flag | toggle | cómo revertir>
- Qué puede romperse: <específico>
- Plan de rollback: <pasos>

## Characterization tests
Antes de modificar código existente:
- [ ] Test de <comportamiento>
- [ ] Test de <edge case>

## Verificación
Cómo verificar cada criterio de éxito de la spec.
