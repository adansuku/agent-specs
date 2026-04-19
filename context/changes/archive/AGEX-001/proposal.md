# AGEX-001: Crear el CONTEXT.md del framework agex

## Historia

Como dev o agente que trabaja en un repo con agex instalado, quiero un
CONTEXT.md que describa qué es el framework, qué componentes tiene y qué
decisiones se han tomado, para poder entenderlo y trabajar con él sin
tener que reconstruir ese conocimiento leyendo todos los archivos.

## Objetivo

Documentar agex como servicio en su propia memoria arquitectónica:
qué hace, por qué existe, sus componentes, cómo se instala y las
decisiones tomadas durante su construcción.

## Contexto

agex (anteriormente libnova.spec) es un framework de Spec-Driven
Development que estructura el ciclo de trabajo de Claude Code. Lleva
al menos un ticket piloto ejecutado (LNS-001, ya archivado y borrado)
pero carece de su propio CONTEXT.md. Cualquier agente que cargue
contexto del servicio no encontrará nada. Este ticket cierra ese hueco.

## Alcance

### En alcance

- Crear `.docs/services/agex/CONTEXT.md` con:
  - Qué hace agex y por qué existe
  - Sus componentes: 6 comandos `/sdd-*`, 4 skills, `config.yml`
  - Cómo se instala (vía `install.sh` y symlinks)
  - Decisiones clave tomadas hasta ahora
  - Peculiaridades conocidas
  - Fecha de última actualización

### Fuera de alcance

- Modificar ningún comando, skill, script ni configuración del framework
- Crear documentación adicional (glossary, ADRs, decisiones.md)
- Documentar repos destino donde está instalado agex

## Decisiones cerradas

- Se usa la plantilla de `update-service-context` adaptada: se omite la
  sección "Contratos públicos" (agex no expone API externa) y se sustituye
  por "Interfaz con el usuario" (los comandos `/sdd-*` como punto de
  entrada).
- Se documenta la evolución del nombre (libnova.spec → agex) como
  peculiaridad, sin entrar en detalles de renombrado.
- Granularidad: comprensible para un dev o agente sin contexto previo.
  Sin inventar ni extrapolar más allá de lo observable en el repo.
- Las "decisiones clave" del CONTEXT.md referencian ADRs futuros cuando
  los haya; por ahora se listan en prosa breve.

## Comportamiento esperado

- **Normal**: un agente ejecuta `load-context` en un ticket que toca agex,
  lee el CONTEXT.md y tiene suficiente información para trabajar.
- **Edge case**: el framework evoluciona y el CONTEXT.md queda desfasado.
  Mitigación: cualquier ticket que modifique agex debe actualizar el
  CONTEXT.md en `/sdd-wrap` (regla ya en el flujo).
- **Fallo**: N/A. Es documentación; la verificación es lectura humana.

## Output esperado

- `.docs/services/agex/CONTEXT.md` creado.
- Sin cambios en ningún otro archivo del framework.

## Criterios de éxito

- El archivo existe en la ruta correcta.
- Describe qué hace agex en 2-3 líneas sin ambigüedad.
- Lista los 6 comandos y las 4 skills con una línea de descripción cada uno.
- Menciona el mecanismo de instalación (`install.sh` + symlinks).
- Incluye al menos 3 decisiones clave tomadas durante la construcción.
- Usa la plantilla adaptada (sin "Contratos públicos" literal).
- Presente, no pasado. Sin errores de coherencia interna.

## Impacto arquitectónico

- Servicios afectados: agex (el propio framework).
- ADRs referenciados: ninguno (no existen aún).
- ¿Requiere ADR nuevo?: no. Crear un CONTEXT.md no es una decisión
  técnica de calado. No introduce dependencias ni cambia patrones.

## Verificación sin tests automatizados

### Flujo manual

1. Leer `.docs/services/agex/CONTEXT.md` completo.
2. Verificar que describe los 6 comandos y las 4 skills.
3. Verificar que menciona `install.sh` y symlinks.
4. Verificar que lista decisiones clave.
5. Ejecutar `load-context` mentalmente: ¿con este archivo un agente
   podría trabajar en agex sin preguntar nada obvio?

### Qué mirar

- Logs: N/A.
- DB: N/A.
- API/UI: N/A. Es documentación.

## Riesgos

- **Drift futuro**: el CONTEXT.md puede quedar desfasado si se añaden
  comandos o skills sin actualizar este archivo. Mitigación: el flujo
  `/sdd-wrap` pregunta explícitamente por actualizaciones de CONTEXT.md.
