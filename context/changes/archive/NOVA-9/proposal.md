<!-- Mantén esta spec ≤ 60 líneas. Bullets y tablas, no prosa. Se carga en cada turno de nova-build. -->
# NOVA-9: Renombrar `.docs/` a `context/`

## Historia
Como usuario de nova-spec, quiero que la memoria arquitectónica viva en `context/`, para que sea visible en el explorador de archivos y refleje su propósito.

## Objetivo
Renombrar el directorio `.docs/` a `context/` y eliminar todas las referencias al nombre antiguo en comandos, skills, templates, install.sh y CONTEXT.md.

## Contexto
`.docs/` es invisible por convención de sistema operativo (leading dot). El directorio contiene la memoria arquitectónica del proyecto y merece un nombre descriptivo y visible.

## Alcance
### En alcance
- `git mv .docs context/` en el repo
- Find-and-replace de `.docs/` → `context/` en todos los archivos de `novaspec/` (comandos, skills, templates, guardrails)
- Actualizar `install.sh` para crear `context/` en lugar de `.docs/`
- Actualizar `CONTEXT.md` del servicio `agex`

### Fuera de alcance
- Contenido de `context/changes/archive/` (inmutable por convención)
- Script de migración automática para repos ya instalados

## Decisiones cerradas
- Breaking change limpio: quien migre ejecuta `git mv .docs context/` manualmente; el README documenta el comando
- `archive/` no se toca; el grep de verificación lo excluye explícitamente
- Los artefactos de este ticket se crean en `.docs/changes/active/NOVA-9/`; el `git mv` los mueve junto con el árbol

## Comportamiento esperado
- Normal: después del cambio, `context/` existe y `.docs/` no existe; todos los comandos funcionan
- Edge cases: repos instalados con `.docs/` siguen funcionando hasta que el usuario ejecute la migración manual
- Fallo: si algún archivo queda con referencia a `.docs/`, el criterio de aceptación lo detecta con grep

## Output esperado
- Directorio `context/` con la misma estructura que tenía `.docs/`
- Cero referencias a `.docs/` en el repo (excluyendo `context/changes/archive/`)
- `install.sh` crea `context/` en repos nuevos

## Criterios de éxito
- `grep -r '\.docs/' . --exclude-dir=archive` → 0 resultados
- `bash install.sh` en repo vacío crea `context/` sin `.docs/`
- `/nova-status` y `/nova-wrap` funcionan correctamente tras el cambio

## Impacto arquitectónico
- Servicios afectados: `agex`
- ADRs referenciados: ADR-0001 (install.sh), ADR-0002 (naming)
- ¿Requiere ADR nuevo?: posible — si se considera decisión de naming con impacto en repos instalados

## Verificación sin tests automatizados
### Flujo manual
1. Ejecutar `grep -r '\.docs/' . --exclude-dir=archive` → debe dar 0 resultados
2. Clonar repo en directorio limpio, ejecutar `bash install.sh`, verificar que crea `context/` y no `.docs/`
3. Ejecutar `/nova-status NOVA-9` desde rama del ticket → debe funcionar sin errores

### Qué mirar
- Logs: salida de `install.sh` — debe mostrar `context/` en el output final
- API/UI: comandos `/nova-status` y `/nova-wrap` sin errores de ruta

## Riesgos
- Referencias ocultas en binarios o archivos ignorados por git: mitigación — el grep cubre todos los archivos rastreados
- Repos ya instalados se rompen al actualizar novaspec/: mitigación — documentar migración de una línea en CHANGELOG/README
