#!/usr/bin/env bash
# agex bootstrap
# Crea toda la estructura + contenido de comandos y skills.
# Uso: bash install.sh

set -e

echo "→ Creando estructura de agex..."

# Directorios
mkdir -p .spec/{commands,skills,agents}
mkdir -p .spec/skills/{load-context,close-requirement,write-adr,update-service-context}
mkdir -p .docs/{adr,services,post-mortems,specs,changes/{active,archive}}
mkdir -p .claude

# Archivos base
touch .docs/glossary.md
touch .docs/changes/active/.gitkeep
touch notes.md

# Symlinks (.claude/ hacia .spec/)
cd .claude
[ -L commands ] || ln -s ../.spec/commands commands
[ -L skills ]   || ln -s ../.spec/skills skills
[ -L agents ]   || ln -s ../.spec/agents agents
cd ..

# ============================================================
# CONFIG
# ============================================================

cat > .spec/config.yml <<'EOF'
# agex — configuración del framework
branch:
  pattern: "{type}/{ticket}-{slug}"
  types:
    quick-fix: fix
    feature: feature
    architecture: arch
  ticket_case: upper    # upper | lower
  base: main            # rama base del flujo (checkout en /sdd-start, --base en /sdd-wrap)
EOF

# ============================================================
# CLAUDE.md
# ============================================================

cat > CLAUDE.md <<'EOF'
# Proyecto con agex

Este repo usa el flujo **agex** (SDD) para cualquier cambio no trivial.

## Memoria arquitectónica

Antes de empezar cualquier ticket, carga el contexto relevante:

1. `.docs/services/<servicio>/CONTEXT.md` — qué hace cada servicio
2. `.docs/adr/` — decisiones arquitectónicas vigentes
3. `.docs/specs/` — specs consolidadas (source of truth)
4. `.docs/glossary.md` — términos del dominio

## Flujo de trabajo

```
/sdd-start <TICKET>       Arranca el flujo, clasifica, carga contexto
/sdd-spec                 Genera la spec (qué cambia y por qué)
/sdd-plan                 Genera plan y tareas
/sdd-do                   Implementa tareas
/sdd-review               Valida spec, convenciones y ADRs
/sdd-wrap                 Actualiza memoria, commit y PR
/sdd-status [TICKET-ID]   Muestra el estado actual del ticket (solo lectura)
```

Los cambios en curso viven en `.docs/changes/active/<ticket-id>/`.
Al cerrar, se archivan en `.docs/changes/archive/`.

Tickets `quick-fix` saltan `/sdd-spec` y `/sdd-plan`.

## Configuración

La configuración del flujo vive en `.spec/config.yml`.

## Reglas

- No inventes contexto. Si falta un CONTEXT.md, dilo.
- Checkpoints humanos después de `/sdd-spec` y antes de `/sdd-wrap`.
- Alimenta la memoria al cerrar.
- No uses comandos fuera de orden.
EOF

# ============================================================
# COMMANDS
# ============================================================

cat > .spec/commands/sdd-start.md <<'EOF'
---
description: Arranca el flujo agex desde un ticket de Jira
argument-hint: <TICKET-ID>
---

Eres el orquestador inicial del flujo agex.

El usuario te ha pasado el ticket: **$ARGUMENTS**

Tu trabajo es preparar el terreno antes de que se escriba spec o código.
No implementes nada. No propongas spec. Solo orquesta.

## Pasos

### 1. Obtener el ticket

Si existe la skill `jira-integration`, úsala para bajar el ticket.
Si no, pide al usuario que pegue:
- título
- descripción
- criterios de aceptación
- comentarios relevantes

### 2. Clasificar el ticket

- **quick-fix**: bug menor, typo, config. < 2h. No requiere spec formal.
- **feature**: funcionalidad acotada, refactor de módulo. 2h-3d. Flujo completo.
- **architecture**: migración, rewrite, decisión de calado. > 3d. Requiere ADR.

Si dudas entre dos, elige la más conservadora.
Declara tu clasificación con razonamiento breve.

### 3. Identificar servicios afectados

Deduce qué servicios toca el ticket (`.docs/services/<nombre>/`).
Si no está claro, pregunta con opciones concretas.

### 4. Crear rama de git

Lee `.spec/config.yml`:
- `branch.pattern` para el nombre de rama (default `{type}/{ticket}-{slug}`).
- `branch.base` para la rama base del flujo. Resolución:
  - Si la clave **existe**: usa ese valor. Si la rama no existe en git,
    deja que `git checkout` falle con su error nativo.
  - Si la clave **falta** (instalación vieja): intenta `develop`.
    - Si `develop` existe: úsala, pero avisa al usuario:
      "Usando `develop` como fallback. Añade `branch.base` a
      `.spec/config.yml` para fijarla."
    - Si `develop` no existe: lista las ramas locales (`git branch`),
      pregunta al usuario cuál usar y recomienda escribirla en
      `.spec/config.yml`. No sigas hasta tener respuesta.

Default por tipo: `feature/<TICKET>-<slug>`, `fix/<TICKET>-<slug>`,
`arch/<TICKET>-<slug>`.

Antes de crear:
- verifica working tree limpio
- haz `git checkout <base>` y `git pull` sobre la rama base resuelta
- si la rama de ticket ya existe, pregunta: continuar o abortar

### 5. Cargar contexto

Invoca la skill `load-context` con los servicios identificados.

### 6. Resumen y siguiente paso

Presenta:

```
## Ticket: <TICKET-ID> — <título>

**Clasificación**: <tipo>
**Razón**: <2-3 líneas>

**Servicios afectados**: <lista>
**Rama creada**: <nombre>

**Contexto cargado**:
- CONTEXT.md: <lista>
- ADRs: <lista o "ninguno">
- Specs: <lista o "ninguna">
- Restricciones clave: <lista>

**Huecos de documentación**: <lista o "ninguno">

**Próximo paso**: <comando>
```

Próximo paso:
- quick-fix → `/sdd-do`
- feature → `/sdd-spec`
- architecture → `/sdd-spec` (avisa: requerirá ADR en /sdd-wrap)

## Reglas

- No escribas código aquí.
- No inventes contexto. Si falta info, pregunta.
- Si el working tree está sucio, para.
EOF

cat > .spec/commands/sdd-spec.md <<'EOF'
---
description: Genera la spec del cambio a partir del ticket y el contexto cargado
---

Eres el encargado de generar la spec técnica del ticket actual.

## Guardrail

**Ejecuta esto antes de cualquier otro paso.**

1. Lee la rama git actual (`git branch --show-current`).
2. Comprueba que sigue el patrón `(feature|fix|arch)/<TICKET>-<slug>`
   definido en `.spec/config.yml`.
3. Si la rama es `main`, `master`, `claude/*` u otra sin patrón de ticket:

   ```
   ⛔ Guardrail: no hay rama de ticket activa.
   Ejecuta /sdd-start <TICKET> primero.
   ```
   **Para aquí. No sigas.**

4. Si la rama sigue el patrón, extrae el `<TICKET>` del nombre de rama
   y úsalo como ticket-id para el resto del comando.

## Precondición

Debe haberse ejecutado `/sdd-start` antes. Si no detectas rama creada y
contexto cargado, pide al usuario que ejecute `/sdd-start <TICKET>` primero.

## Pasos

### 1. Invocar close-requirement

Invoca la skill `close-requirement` para:
- cerrar decisiones mediante preguntas
- anclar defaults en el código existente
- iterar hasta que no queden ambigüedades

**No sigas al paso 2 hasta que el usuario confirme** que las decisiones
están cerradas.

### 2. Redactar la spec

Crea `.docs/changes/active/<ticket-id>/proposal.md`:

```
# <TICKET-ID>: <título>

## Historia
Como <actor>, quiero <capacidad>, para <resultado>.

## Objetivo
<qué hace posible>

## Contexto
<problema y por qué importa>

## Alcance
### En alcance
- <items>
### Fuera de alcance
- <items>

## Decisiones cerradas
- <lista>

## Comportamiento esperado
- Normal: <...>
- Edge cases: <...>
- Fallo: <...>

## Output esperado
<...>

## Criterios de éxito
- <observables>

## Impacto arquitectónico
- Servicios afectados: <lista>
- ADRs referenciados: <lista o "ninguno">
- ¿Requiere ADR nuevo?: sí | no | posible

## Verificación sin tests automatizados
### Flujo manual
1. <pasos reproducibles>

### Qué mirar
- Logs: <...>
- DB: <...>
- API/UI: <...>

## Riesgos
- <riesgo>: <mitigación>
```

### 3. Checkpoint humano

Muestra la spec y di:

> "Spec generada en `.docs/changes/active/<ticket-id>/proposal.md`.
>  Revísala antes de `/sdd-plan`."

No avances automáticamente.

## Reglas

- No redactes spec sin pasar por `close-requirement`.
- Si el ticket es quick-fix, avisa: "¿seguro que necesita spec formal?"
- Si el archivo ya existe, pregunta si sobrescribir.
EOF

cat > .spec/commands/sdd-plan.md <<'EOF'
---
description: Genera plan de implementación y tareas a partir de la spec aprobada
---

Traduces la spec en un plan ejecutable.

## Guardrail

**Ejecuta esto antes de cualquier otro paso.**

1. Lee la rama git actual y extrae el `<ticket-id>`.
   Si la rama no sigue el patrón `(feature|fix|arch)/<TICKET>-<slug>`:

   ```
   ⛔ Guardrail: no hay rama de ticket activa.
   Ejecuta /sdd-start <TICKET> primero.
   ```
   **Para aquí. No sigas.**

2. Comprueba que existe `.docs/changes/active/<ticket-id>/proposal.md`.
   Si no existe:

   ```
   ⛔ Guardrail: no existe proposal.md para <ticket-id>.
   Ejecuta /sdd-spec primero.
   ```
   **Para aquí. No sigas.**

## Precondición

Debe existir `.docs/changes/active/<ticket-id>/proposal.md`.

## Pasos

### 1. Leer la spec

Identifica servicios afectados, decisiones cerradas, criterios de éxito.

### 2. Generar plan.md

Crea `.docs/changes/active/<ticket-id>/plan.md`:

```
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
```

### 3. Generar tasks.md

Crea `.docs/changes/active/<ticket-id>/tasks.md`:

```
# Tareas: <TICKET-ID>

- [ ] 1. <tarea concreta> — <archivo(s)>
- [ ] 2. <tarea concreta> — <archivo(s)>
```

Reglas:
- cada tarea ejecutable en 15-60 min
- orden ejecutable
- incluir characterization tests antes de modificar código
- usar checkboxes `- [ ]`

### 4. Checkpoint humano

> "Plan y tareas generados. Revísalos. Ejecuta `/sdd-do` cuando estés listo."

## Reglas

- Las tareas deben salir del plan, no inventarlas.
- Si detectas decisiones no cubiertas en la spec, para.
- Para quick-fix el plan puede ser muy breve.
EOF

cat > .spec/commands/sdd-do.md <<'EOF'
---
description: Implementa las tareas del plan una a una con review incremental
---

Ejecutas `tasks.md` en orden, tarea a tarea.

## Guardrail

**Ejecuta esto antes de cualquier otro paso.**

1. Lee la rama git actual y extrae el `<ticket-id>`.
   Si la rama no sigue el patrón `(feature|fix|arch)/<TICKET>-<slug>`:

   ```
   ⛔ Guardrail: no hay rama de ticket activa.
   Ejecuta /sdd-start <TICKET> primero.
   ```
   **Para aquí. No sigas.**

2. Comprueba si la rama empieza por `fix/` (quick-fix).
   - Si **no es quick-fix**: comprueba que existen
     `.docs/changes/active/<ticket-id>/plan.md` y
     `.docs/changes/active/<ticket-id>/tasks.md`.
     Si falta alguno:

     ```
     ⛔ Guardrail: no existe plan.md o tasks.md para <ticket-id>.
     Ejecuta /sdd-plan primero.
     ```
     **Para aquí. No sigas.**

   - Si **es quick-fix**: puedes continuar aunque no existan
     `plan.md` ni `tasks.md`. Salta directamente al paso 4.

## Precondición

Debe existir `.docs/changes/active/<ticket-id>/tasks.md`.

**Excepción**: si el ticket es `quick-fix`, puedes operar sin tasks.md.
Implementa directamente y salta al paso 4.

## Pasos

### 1. Leer tasks.md

Identifica la primera sin marcar (`- [ ]`).
Si todas están marcadas, avisa: "ejecuta `/sdd-review`".

### 2. Ejecutar una tarea

- Lee archivos relevantes antes de modificar
- Implementa el cambio
- Sigue las convenciones del repo circundante
- Characterization tests: escribir antes de tocar producción

No modifiques fuera del alcance de la tarea. Si hace falta, pregunta.

### 3. Review incremental

- ¿Cumple el criterio?
- ¿He roto algo adyacente?
- ¿Sigue convenciones?
- ¿Efectos no deseados?

Si hay problema, corrige antes de marcar.

### 4. Marcar completada

Actualiza `tasks.md`: `- [ ]` → `- [x]`.

Muestra al usuario:
- tarea completada
- archivos tocados (rutas concretas)
- anomalías detectadas

### 5. Siguiente tarea o parada

**Si quedan tareas**:
> "Tarea N completada. ¿Sigo con N+1 o paramos?"

**Si era la última**:
> "Todas completadas. Ejecuta `/sdd-review`."

## Reglas

- Una tarea a la vez. No encadenes sin permiso.
- Si una tarea es más grande de lo previsto, para.
- Si descubres decisión no cerrada, para.
- No hagas commit aquí (eso es `/sdd-wrap`).
- No actualices `.docs/adr/` ni `.docs/services/` aquí.
EOF

cat > .spec/commands/sdd-review.md <<'EOF'
---
description: Code review final del cambio contra spec, convenciones y ADRs
---

Revisor final antes de cerrar el ticket.

## Guardrail

**Ejecuta esto antes de cualquier otro paso.**

1. Lee la rama git actual y extrae el `<ticket-id>`.
   Si la rama no sigue el patrón `(feature|fix|arch)/<TICKET>-<slug>`:

   ```
   ⛔ Guardrail: no hay rama de ticket activa.
   Ejecuta /sdd-start <TICKET> primero.
   ```
   **Para aquí. No sigas.**

2. Comprueba si es quick-fix (rama `fix/`) y si existe
   `.docs/changes/active/<ticket-id>/tasks.md`.
   - Si **existe `tasks.md`**: comprueba que no quede ningún `- [ ]`
     sin marcar. Si quedan tareas pendientes:

     ```
     ⛔ Guardrail: hay N tarea(s) sin completar en tasks.md.
     Ejecuta /sdd-do para completarlas primero.
     ```
     **Para aquí. No sigas.**

   - Si **no existe `tasks.md`** y es quick-fix: continúa.
   - Si **no existe `tasks.md`** y no es quick-fix:

     ```
     ⛔ Guardrail: no existe tasks.md para <ticket-id>.
     Ejecuta /sdd-plan primero.
     ```
     **Para aquí. No sigas.**

## Precondición

- Todas las tareas de `tasks.md` marcadas `[x]`
- Rama del ticket con cambios sin commitear

## Pasos

### 1. Preparar el review

Lee:
- `.docs/changes/active/<ticket-id>/proposal.md`
- `.docs/changes/active/<ticket-id>/plan.md`
- `.docs/changes/active/<ticket-id>/tasks.md`
- ADRs relevantes en `.docs/adr/`
- Diff de los cambios

### 2. Ejecutar review en 4 ejes

**Cumplimiento de spec**
- ¿Implementa lo descrito?
- ¿Cubre todos los criterios?
- ¿Desviaciones sin justificar?

**Convenciones**
- ¿Estilo del código circundante?
- ¿Nombres según convención?
- ¿Dead code, prints, imports sobrantes?

**ADRs**
- ¿Contradice algún ADR vigente?
- Violación sin justificar → **BLOQUEANTE**

**Riesgos**
- ¿Efectos colaterales no previstos?
- ¿Falta el safety net del plan?

### 3. Reporte

```
## Review: <TICKET-ID>

### Cumplimiento de spec
- [✓/✗] Criterio 1: <detalle>

### Convenciones
- <hallazgos o "sin incidencias">

### ADRs
- <o "sin conflictos">

### Riesgos
- <o "ninguno">

### Bloqueantes
- <deben resolverse antes de /sdd-wrap>

### Sugerencias
- <mejoras opcionales>

### Veredicto
✓ Listo para /sdd-wrap
— o —
✗ Requiere ajustes
```

**Persiste el reporte**: escribe el reporte completo (con el veredicto
incluido) en `.docs/changes/active/<ticket-id>/review.md`. Este archivo es
leído por `/sdd-wrap` para verificar que el review fue aprobado.

### 4. Checkpoint humano

Si hay bloqueantes → pide resolverlos.
Si no → "Review OK. Ejecuta `/sdd-wrap`."

## Reglas

- No modifiques código aquí.
- Cita archivo y línea al señalar problemas.
- Violación de ADR sin justificar siempre es bloqueante.
- No propongas cambios fuera del alcance.
EOF

cat > .spec/commands/sdd-wrap.md <<'EOF'
---
description: Cierra el ticket — actualiza memoria, archiva spec, commit y PR
---

Este es el paso que alimenta la memoria arquitectónica.
**Sin este paso, el sistema no aprende.**

## Guardrail

**Ejecuta esto antes de cualquier otro paso.**

1. Lee la rama git actual y extrae el `<ticket-id>`.
   Si la rama no sigue el patrón `(feature|fix|arch)/<TICKET>-<slug>`:

   ```
   ⛔ Guardrail: no hay rama de ticket activa.
   Ejecuta /sdd-start <TICKET> primero.
   ```
   **Para aquí. No sigas.**

2. Comprueba que existe `.docs/changes/active/<ticket-id>/review.md`.
   Si no existe:

   ```
   ⛔ Guardrail: no existe review.md para <ticket-id>.
   Ejecuta /sdd-review primero.
   ```
   **Para aquí. No sigas.**

3. Lee `.docs/changes/active/<ticket-id>/review.md` y busca la línea
   `✓ Listo para /sdd-wrap`.
   Si no aparece esa línea:

   ```
   ⛔ Guardrail: el review de <ticket-id> no tiene veredicto ✓.
   Resuelve los bloqueantes y vuelve a ejecutar /sdd-review.
   ```
   **Para aquí. No sigas.**

## Precondición

- `/sdd-review` con veredicto ✓
- Sin bloqueantes pendientes

## Pasos

### 1. Detectar decisión arquitectónica

Si se tomó una decisión relevante, invoca skill `write-adr`.

> "¿Documentamos esta decisión como ADR?
>  - Sí, crear ADR-NNNN
>  - No, es menor
>  - Ya existe: ADR-NNNN"

### 2. Actualizar CONTEXT.md

Para cada servicio modificado, invoca skill `update-service-context`.

> "¿Ha cambiado el comportamiento del servicio X?
>  - Sí, actualizar CONTEXT.md
>  - No, cambio interno sin impacto externo"

### 3. Otros rastros

> "¿Añadimos algo a...?
>  - decisions.md del servicio
>  - incidents.md del servicio
>  - glossary.md"

### 4. Archivar spec

- Consolida contenido relevante en `.docs/specs/<capability>/`
- Mueve `.docs/changes/active/<ticket-id>/` → `.docs/changes/archive/<ticket-id>/`

### 5. Commit

```
<tipo>(<scope>): <resumen>

<cuerpo opcional>

Refs: <TICKET-ID>
ADRs: <ADR-NNNN si aplica>
```

Si hay muchos cambios, propón agrupar en commits lógicos.

### 6. Crear PR

Resuelve la rama base igual que `/sdd-start`:
- Lee `branch.base` de `.spec/config.yml`.
- Si la clave falta, intenta `develop`; si tampoco existe, pregunta al
  usuario y recomienda fijar `branch.base` en `.spec/config.yml`.

Crea el PR con `gh pr create --base <base-resuelta> --title "<título>"
--body "<descripción>"`.

**Título**: `<TICKET-ID>: <título>`

**Descripción**:
```
## Ticket
<link a Jira>

## Resumen
<qué cambia y por qué>

## Spec
.docs/changes/archive/<ticket-id>/proposal.md

## ADRs
- ADR-NNNN: <título> (si aplica)

## Verificación manual
<pasos del plan>

## Checklist
- [x] Spec archivada
- [x] CONTEXT.md actualizado
- [x] ADR creado (si aplicaba)
- [x] Review sin bloqueantes
```

### 7. Resumen final

```
## Ticket <TICKET-ID> cerrado

- Spec archivada: <ruta>
- Specs consolidadas: <rutas>
- ADRs creados: <lista o "ninguno">
- CONTEXT.md actualizados: <lista o "ninguno">
- Commits: <número>
- PR: <link>
```

## Reglas

- No saltes el paso de memoria.
- Si el usuario dice "no" a todo, avisa: "cerramos sin memoria, ¿seguro?"
- No ejecutes commits ni PR sin confirmación.
- Si algo falla, para y reporta.
EOF

cat > .spec/commands/sdd-status.md <<'EOF'
---
description: Muestra el estado actual de un ticket en el flujo SDD
argument-hint: [TICKET-ID]
---

Eres un comando de **solo lectura**. No modificas ningún archivo.
Tu única función es inspeccionar artefactos en disco y reportar el estado.

## Paso 1 — Resolver el ticket-id

Si el usuario pasó un argumento (`$ARGUMENTS` no está vacío), úsalo como
`<ticket-id>`.

Si no hay argumento:
1. Lee la rama git actual (`git branch --show-current`).
2. Si la rama sigue el patrón `(feature|fix|arch)/<TICKET>-<slug>`,
   extrae `<TICKET>` como `<ticket-id>`.
3. Si la rama **no** sigue ese patrón:
   - Lista los directorios bajo `.docs/changes/active/`.
   - Si hay tickets abiertos, muestra:

     ```
     No hay ticket activo en la rama actual.

     Tickets abiertos:
     - <TICKET-ID>: <paso inferido>
     ```

   - Si no hay ninguno, muestra:

     ```
     No hay ticket activo y no hay tickets abiertos en .docs/changes/active/.
     Ejecuta /sdd-start <TICKET> para comenzar.
     ```

   - En ambos casos, **termina aquí**.

## Paso 2 — Localizar los artefactos

Busca los artefactos del ticket en este orden de prioridad:

1. **Archivado**: existe `.docs/changes/archive/<ticket-id>/` → paso = `archivado`
2. **Activo**: directorio `.docs/changes/active/<ticket-id>/`

Si no existe ninguno de los dos:

```
Ticket <ticket-id> no encontrado.
No existe .docs/changes/active/<ticket-id>/ ni .docs/changes/archive/<ticket-id>/
```

Termina aquí.

## Paso 3 — Inferir el paso actual

Evalúa los artefactos en este orden (el primero que aplica gana):

| Condición | Paso inferido |
|---|---|
| Directorio en `archive/` | `archivado` |
| Existe `review.md` | `wrap` (listo para `/sdd-wrap`) |
| Existe `tasks.md` y **todas** las líneas `- [x]` (ninguna `- [ ]`) | `review` (listo para `/sdd-review`) |
| Existe `tasks.md` con al menos una `- [ ]` | `do` (en progreso) |
| Existe `tasks.md` sin ningún checkbox | `do` (sin tareas ejecutadas) |
| Existe `plan.md` pero no `tasks.md` | `plan` (plan sin tareas) |
| Existe `proposal.md` pero no `plan.md` | `spec` (spec sin plan) |
| No existe `proposal.md` | `start` (solo rama, sin spec) |

## Paso 4 — Leer el título

Si existe `proposal.md`, extrae el título de la primera línea `# <TICKET>: <título>`.
Si no existe o no se puede leer, usa `(sin título)`.

## Paso 5 — Calcular progreso de tareas

Solo si el paso es `do` o `review`:
- Cuenta líneas con `- [x]` → tareas completadas
- Cuenta líneas con `- [ ]` → tareas pendientes
- Total = completadas + pendientes

## Paso 6 — Mostrar el reporte

Usa este formato exacto:

```
## Estado del ticket <TICKET-ID>

Título     : <título>
Rama       : <rama git actual>
Paso actual: <paso>
Siguiente  : <siguiente comando>
```

Si el paso es `do`, añade debajo de "Paso actual":
```
Progreso   : <N completadas> / <M totales> tareas
```

Si el paso es `archivado`, sustituye "Siguiente" por:
```
Archivado  : .docs/changes/archive/<ticket-id>/
```

### Tabla de siguientes comandos

| Paso | Siguiente comando |
|---|---|
| `start` | `/sdd-spec` |
| `spec` | `/sdd-plan` |
| `plan` | `/sdd-do` |
| `do` | `/sdd-do` (continuar) |
| `review` | `/sdd-review` |
| `wrap` | `/sdd-wrap` |
| `archivado` | — (ticket cerrado) |

## Reglas

- **No modifiques ningún archivo** bajo ninguna circunstancia.
- Si un artefacto existe pero no se puede parsear, reporta
  `(no se pudo leer <archivo>)` y continúa con lo que tengas.
- No hagas suposiciones sobre el estado: infiere solo desde los archivos.
- Si hay ambigüedad, elige el paso más conservador (el anterior en el flujo).
EOF

# ============================================================
# SKILLS
# ============================================================

cat > .spec/skills/load-context/SKILL.md <<'EOF'
---
name: load-context
description: Carga contexto arquitectónico antes de trabajar en un ticket.
  Úsala cuando se empieza una nueva tarea, se modifica un servicio, o cuando
  el usuario menciona un servicio, un ticket, o dice "vamos a trabajar en".
---

# Cargar contexto arquitectónico

Tu trabajo: reunir contexto relevante antes de que se escriba spec o código.
Si falta documentación, **pregunta al usuario** antes de asumir nada.

## Pasos

### 1. Verifica que exista `.docs/`

Si no existe:
- Avisa al usuario
- Ofrece crear la estructura base
- Pregunta si continuar sin memoria arquitectónica

**No bloquees al usuario.** Si no hay `.docs/`, el flow sigue funcionando.

### 2. Identifica servicios afectados

Si no tienes claro qué servicios toca, pregunta con opciones concretas.

### 3. Lee lo que exista

Para cada servicio:
- `.docs/services/<servicio>/CONTEXT.md`
- `.docs/services/<servicio>/decisions.md`
- `.docs/services/<servicio>/incidents.md`

Si falta archivo, anótalo como "no documentado". Ofrece crearlo al final.

### 4. Busca ADRs y specs

Escanea `.docs/adr/` y `.docs/specs/`.
Si no encuentras nada claro, dilo. No fuerces conexiones.

### 5. Presenta resumen + preguntas abiertas

```
## Contexto cargado

**Servicios**:
- <servicio>: <resumen 1 línea> | no documentado

**ADRs relevantes**:
- ADR-NNNN: <título>

**Specs actuales**:
- <path>: <1 línea>

**Restricciones a preservar**:
- <lista>

**Huecos detectados**:
- <qué falta>

**Preguntas**:
- <si hay ambigüedad>
```

## Cuándo preguntar vs asumir

**Pregunta si**:
- Servicio sin CONTEXT.md
- Dos interpretaciones posibles del alcance
- Decisión arquitectónica implícita
- Falta `.docs/` entero

**Asume si**:
- La info está clara en los archivos leídos
- El usuario ya respondió antes en la conversación

## Ofertas al usuario

Cuando detectes huecos, ofrece acciones concretas:
- "¿Creo CONTEXT.md inicial para X?"
- "¿Documentamos esto como ADR?"

**No las ejecutes sin confirmación.**

## Reglas

- No inventes contexto.
- No bloquees si falta `.docs/`.
- Preguntas concretas con opciones.
EOF

cat > .spec/skills/close-requirement/SKILL.md <<'EOF'
---
name: close-requirement
description: Convierte un ticket o idea vaga en un requisito técnicamente cerrado
  y revisable por un senior, mediante preguntas estructuradas ancladas en el
  código existente. Úsala antes de redactar una spec formal.
---

# Cerrar requisito

Transforma ticket vago en requisito con decisiones cerradas.

Optimiza para **claridad, completitud y decisiones cerradas**.

## Contexto previo

Antes de preguntar, lee:
- `.docs/services/<servicio>/CONTEXT.md` de servicios afectados
- `.docs/adr/` — ADRs que puedan aplicar
- `.docs/specs/` — specs actuales
- `.docs/glossary.md` — términos del dominio

## Comportamiento

### 1. Entender la petición

Identifica brevemente: qué quiere, qué problema resuelve, qué no está claro.

### 2. Hacer preguntas clarificadoras

Objetivo: **forzar decisiones**, no explorar.

Reglas:
- tono conversacional
- tantas preguntas como hagan falta
- cada una resuelve decisión concreta
- prefiere trade-offs (A vs B) a abiertas
- siempre que puedas, incluye default sugerido

### Dimensiones obligatorias

1. **Forma de la solución** (nuevo endpoint vs extender existente)
2. **Output esperado**
3. **Comportamiento** (normal, edge cases, fallo)
4. **Actor y contexto de uso**
5. **Límites del alcance**
6. **Criterios de éxito**

### Defaults anclados en código

Antes de proponer un default:
- inspecciona código existente
- identifica patrones actuales
- referencia archivos y rutas concretas

Evita sugerencias genéricas si hay evidencia en el código.

### 3. Iterar hasta cerrar

- Respuestas incompletas → vuelve a preguntar
- Ambigüedad → vuelve a preguntar
- No avances con decisiones abiertas

### 4. Confirmar antes de redactar

> "Todo claro. ¿Redacto el requisito final?"

No redactes todavía.

### 5. Redactar solo tras confirmación

## Output

### Si quedan decisiones abiertas

```
## Entendimiento
<lo que crees que quiere>

## Preguntas
1. <pregunta>
   Default sugerido: <anclado en código>
```

### Si todo claro pero no confirmado

```
## Estado
Todas las decisiones claras.

## Confirmación
¿Redacto el requisito final?
```

### Si confirmado

```
# Requisito: <título>

## Historia
Como <actor>, quiero <capacidad>, para <resultado>.

## Objetivo
## Contexto
## Alcance (en / fuera)
## Decisiones cerradas
## Comportamiento esperado (normal / edge / fallo)
## Output esperado
## Criterios de éxito
```

## Reglas

- No escribas código
- No asumas decisiones que faltan
- No redactes si quedan decisiones abiertas
- Responde en el idioma del usuario
EOF

cat > .spec/skills/write-adr/SKILL.md <<'EOF'
---
name: write-adr
description: Crea un Architectural Decision Record (ADR) cuando se toma una
  decisión técnica relevante. Úsala cuando el usuario elige entre alternativas,
  cambia un patrón, introduce una dependencia nueva.
---

# Escribir un ADR

Crea un ADR en `.docs/adr/`.

## Cuándo crear ADR

Crea si:
- Elección entre alternativas técnicas
- Cambio de patrón establecido
- Nueva dependencia
- Decisión que otro dev debería conocer en 6 meses
- Deprecación de ADR anterior

**No crees** para bug fixes, cosmética, patrones ya documentados.

## Pasos

### 1. Numerar

Escanea `.docs/adr/`. Usa el siguiente número (`NNNN`, 4 dígitos).

### 2. Nombre del archivo

`NNNN-kebab-case-titulo.md`

Ejemplo: `0005-migrar-auth-a-oauth.md`

### 3. Preguntar datos clave

Si falta info, pregunta:

> "Necesito:
>  1. Título corto (<60 chars)
>  2. Alternativas consideradas y por qué se descartaron
>  3. Consecuencias negativas aceptadas
>  4. ¿Deprecia algún ADR anterior?"

No inventes.

### 4. Plantilla

```
# ADR-NNNN: <título>

## Estado
Propuesto | Aceptado | Deprecado — YYYY-MM-DD

## Contexto
<Situación que llevó a la decisión. 2-4 líneas.>

## Decisión
<Qué se decide. Directo.>

## Alternativas consideradas
- **<Opción A>**: <por qué se descartó>
- **<Opción B>**: <por qué se descartó>

## Consecuencias
### Positivas
### Negativas
### Neutras

## Relacionado
- ADRs: <o "ninguno">
- Specs: <rutas>
- Tickets: <TICKET-ID>

## Notas
```

### 5. Mostrar antes de guardar

> "Este es el ADR. ¿Lo guardo tal cual, ajustamos, o cancelamos?"

Solo escribe tras confirmación.

### 6. Deprecación

Si este ADR reemplaza otro:
- En el nuevo: `Relacionado → ADRs: ADR-NNNN (deprecado por este)`
- En el antiguo: estado `Deprecado — YYYY-MM-DD` + `Reemplazado por: ADR-NNNN`

Pregunta antes de modificar el antiguo.

## Reglas

- No inventes alternativas ni consecuencias.
- Título en sentencia, no Title Case.
- Estado inicial típicamente `Aceptado`.
- Secciones breves.
EOF

cat > .spec/skills/update-service-context/SKILL.md <<'EOF'
---
name: update-service-context
description: Actualiza el CONTEXT.md de un servicio cuando su comportamiento,
  responsabilidades o integraciones han cambiado. Úsala al cerrar un ticket
  que modifica un servicio.
---

# Actualizar CONTEXT.md de servicio

## Cuándo actualizar

Si el cambio:
- Añade/quita responsabilidades
- Modifica contratos públicos (endpoints, formatos)
- Cambia integraciones con otros servicios
- Introduce/elimina dependencias relevantes
- Cambia comportamiento observable desde fuera

**No actualices** para cambios internos sin impacto externo.

## Pasos

### 1. Verificar si existe

**Si no existe**:
> "No hay CONTEXT.md para <servicio>. ¿Lo creamos?
>  - Sí, crear con plantilla
>  - No, saltar"

**Si existe**: léelo entero antes de proponer cambios.

### 2. Identificar qué cambia

Compara estado anterior vs nuevo. Identifica:
- Secciones obsoletas
- Secciones que necesitan añadir info
- Información nueva sin encaje

### 3. Plantilla

```
# Servicio: <nombre>

## Qué hace
<2-3 líneas. Responsabilidad principal.>

## Por qué existe
<1-2 líneas.>

## Contratos públicos
### Inputs
- <endpoint / mensaje / trigger>: <descripción>

### Outputs
- <endpoint / evento / respuesta>: <descripción>

## Dependencias
### De los que depende
- <servicio>: <para qué>

### Que dependen de este
- <servicio>: <para qué>

## Datos que maneja

## Decisiones clave
- Ver ADRs: <lista>
- Decisiones locales: `.docs/services/<servicio>/decisions.md`

## Peculiaridades conocidas

## Incidentes
- Ver `.docs/services/<servicio>/incidents.md`

## Última actualización
YYYY-MM-DD — <ticket>
```

### 4. Proponer diff al usuario

```
## Cambios propuestos

### Sección: <nombre>
- [antes] <contenido>
- [después] <contenido>

### Sección nueva: <nombre>
<contenido>
```

> "¿Aplico, ajustamos, o cancelamos?"

Solo escribe tras confirmación.

### 5. Actualizar fecha

```
## Última actualización
<YYYY-MM-DD> — <TICKET-ID>
```

## Reglas

- No inventes responsabilidades ni dependencias.
- Si es interno sin impacto externo, no actualices.
- CONTEXT.md corto. Si crece, parte en archivos separados.
- No repitas lo que está en ADRs. Usa `Ver ADR-NNNN`.
- Presente, no pasado.
EOF

# ============================================================
# FINAL
# ============================================================

echo ""
echo "✓ agex instalado"
echo ""
echo "Estructura creada:"
tree -a -L 3 -I '.git' 2>/dev/null || find . -maxdepth 3 -not -path '*/\.git*' | sort
echo ""
echo "Siguiente paso:"
echo "  Abre Claude Code en este directorio y prueba:"
echo "    /sdd-start PROJ-123"