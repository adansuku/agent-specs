# AGEX-004: Reorganizar `.docs/changes/` con subcarpeta `active/` y hacer la rama base configurable

## Historia

Como desarrollador que usa el framework agex, quiero que los tickets en
curso vivan en `.docs/changes/active/<id>/` y que la rama base del flujo
sea configurable en `.spec/config.yml`, para que la organización del
repo sea simétrica y legible, y para que el framework funcione en repos
cuya rama principal no se llame `main`.

## Objetivo

Explicitar dos elementos que hoy están implícitos en el flujo:

1. **Ubicación de tickets activos**: hoy conviven con la carpeta
   `archive/`; se mueven a una subcarpeta dedicada `active/` para que el
   árbol `.docs/changes/` tenga dos hijos simétricos (`active/`,
   `archive/`).
2. **Rama base del flujo**: hoy `main` está implícito en el agente y en
   `CLAUDE.md`; se parametriza en `.spec/config.yml` bajo `branch.base`
   con default `main`.

## Contexto

El ticket observa que visualmente `archive/` se mezcla con los tickets
activos en el árbol de archivos (`AGEX-001/`, `archive/`,
`AGEX-005/`…), lo que dificulta ver de un vistazo qué está en curso.

Durante `/sdd-start` de este mismo ticket se detectó que la rama base
está hardcoded implícitamente: el agente hace `git checkout main` y
`gh pr create` usa el default del repo. En un repo con default branch
distinto (p. ej. `develop` como integración y `main` como estable), el
framework produciría ramas desde la base equivocada. El ticket se
amplió para cerrar ese gap en el mismo PR, aprovechando que ambos
cambios tocan la misma superficie (config + comandos + docs) y son
reorganización de estructura implícita → explícita.

## Alcance

### En alcance

- Crear `.docs/changes/active/` con `.gitkeep`.
- Actualizar las referencias de `.docs/changes/<ticket>/` a
  `.docs/changes/active/<ticket>/` en:
  - Los 7 comandos en `.spec/commands/`.
  - Skills en `.spec/skills/` que referencien esas rutas.
  - `CLAUDE.md`, `README.md`, `INSTALL.md`.
  - `CONTEXT.md` del servicio `agex` (tabla de "Memoria arquitectónica
    generada").
  - `install.sh` — tanto el `mkdir -p` inicial como los heredocs
    embebidos que contienen los textos canónicos de comandos y docs.
- Añadir `branch.base: main` a `.spec/config.yml` y al heredoc
  equivalente en `install.sh`.
- Hacer que `/sdd-start` lea `branch.base` antes de hacer `checkout`.
- Hacer que `/sdd-wrap` pase `--base <branch.base>` a `gh pr create`.

### Fuera de alcance

- Otros estados del ticket (`paused/`, `aborted/`).
- Renombrar o mover carpetas ya existentes en `archive/`
  (AGEX-001..005).
- Automatizar migración retrospectiva de tickets archivados.
- Limpiar las referencias a `libnova.spec` que quedan en
  `install.sh` (bug conocido, ticket aparte).
- Sistema de validación/error para valores arbitrarios en
  `.spec/config.yml` (seguimos confiando en edición manual del YAML).

## Decisiones cerradas

1. **Nombres en inglés** (regla del repo). `active/` y `archive/` ya
   cumplen; no hay debate.
2. **Fallback a `develop` si falta `branch.base` en `config.yml`**. Si
   `develop` existe en el repo, el comando la usa y avisa al usuario
   recomendando fijar `branch.base` en `.spec/config.yml`. Si `develop`
   tampoco existe, el comando lista las ramas locales y pregunta cuál
   usar (también recomendando escribirla en `config.yml`). Si
   `branch.base` está presente pero apunta a una rama inexistente,
   `git checkout` falla con su error nativo (sin validación custom).
   El valor por defecto escrito por `install.sh` sigue siendo `main`
   (convención más universal); el fallback a `develop` solo aplica cuando
   la clave falta (instalaciones antiguas).
3. **`branch.base` se aplica tanto en `/sdd-start` como en
   `/sdd-wrap`**. El primero lo usa para la rama nueva; el segundo
   para `gh pr create --base`. Consistencia total: si un repo tiene
   default branch distinto a la rama estable, el framework sigue siendo
   correcto.
4. **Sin soporte dual de rutas** en los guardrails durante la
   transición. No hay tickets en curso (AGEX-005 se archivó antes de
   este merge), así que el clean break no tiene coste.
5. **`install.sh` se actualiza íntegro**, incluyendo los heredocs
   embebidos. Es la fuente canónica del bootstrap; si queda desfasado,
   las instalaciones nuevas nacen rotas.
6. **Orden de implementación**: primero `.spec/config.yml` + lógica de
   lectura en comandos; luego rutas; luego `install.sh`; al final
   `CONTEXT.md`, `README.md`, `CLAUDE.md`. La spec del propio ticket
   vive inicialmente en `.docs/changes/AGEX-004/` (ruta antigua) y, tras
   actualizar los comandos, se mueve a `.docs/changes/active/AGEX-004/`
   como último paso de implementación. Así AGEX-004 es el primer ticket
   bajo la convención nueva (no el último bajo la vieja) y `/sdd-wrap`
   funciona sin excepciones. **Nota**: la redacción anterior ("se
   archivará con la lógica vieja") era inconsistente con la decisión #4
   — los slash commands se leen del disco en invocación, no coexisten
   versiones.
7. **`.gitkeep` solo en `active/`**. `archive/` ya tiene contenido, no
   necesita placeholder. Se mantiene la asimetría mínima en el filesystem.

## Comportamiento esperado

- **Normal**:
  - `/sdd-start <TICKET>` lee `branch.base` de `.spec/config.yml`
    (default `main`), hace checkout de esa rama, pull, y crea
    `<type>/<TICKET>-<slug>` desde ahí. Artefactos del ticket se crean
    bajo `.docs/changes/active/<TICKET>/`.
  - `/sdd-plan`, `/sdd-do`, `/sdd-review` leen y escriben en
    `.docs/changes/active/<TICKET>/`.
  - `/sdd-wrap` mueve `.docs/changes/active/<TICKET>/` →
    `.docs/changes/archive/<TICKET>/` y ejecuta
    `gh pr create --base <branch.base>`.

- **Edge cases**:
  - **`branch.base` ausente**: el comando intenta `develop`. Si existe,
    la usa y avisa al usuario. Si no existe, lista ramas locales y
    pregunta cuál usar. En ambos casos recomienda escribir `branch.base`
    en `.spec/config.yml`.
  - **Rama base no existe en el repo**: `git checkout` falla con el
    error nativo de git. No se añade validación custom.
  - **`.docs/changes/active/` no existe** al ejecutar `/sdd-start`:
    el comando la crea si falta (igual que hoy crea
    `.docs/changes/<id>/`).
  - **Tickets ya en `.docs/changes/archive/<id>/`**: intactos. Los
    guardrails y comandos no los tocan.

- **Fallo**:
  - Si `gh pr create --base X` falla porque `X` no existe en el remoto,
    el error del `gh` se propaga. El usuario ajusta `branch.base` y
    reintenta.

## Output esperado

- `.spec/config.yml` con una clave nueva `branch.base: main`.
- `.docs/changes/active/.gitkeep` versionado.
- Las 7 referencias de comandos `.spec/commands/*.md` actualizadas a
  `.docs/changes/active/<ticket-id>/`.
- Referencias actualizadas en skills, `CLAUDE.md`, `README.md`,
  `INSTALL.md`, `CONTEXT.md`, `install.sh`.
- `/sdd-start` y `/sdd-wrap` con instrucciones explícitas para leer
  `branch.base`.

## Criterios de éxito

Observables:

1. `grep -r "\.docs/changes/<" .spec/ CLAUDE.md README.md INSTALL.md install.sh` (rutas sin `active/` o `archive/`) devuelve **0 coincidencias**.
2. `ls .docs/changes/` muestra solo `active/` y `archive/`.
3. `.spec/config.yml` contiene la clave `branch.base`.
4. Ejecutar `/sdd-start` en un ticket de prueba crea la rama desde
   `branch.base` y pone los artefactos en `.docs/changes/active/<id>/`.
5. Ejecutar `/sdd-wrap` sobre AGEX-004 mueve la carpeta a
   `.docs/changes/archive/AGEX-004/` y el PR apunta a `branch.base`.

## Impacto arquitectónico

- Servicios afectados: `agex` (único).
- ADRs referenciados: ninguno (el directorio `.docs/adr/` está vacío).
- ¿Requiere ADR nuevo?: **no**. Es reorganización de estructura
  implícita → explícita, sin cambio de modelo mental del framework.

## Verificación sin tests automatizados

### Flujo manual

1. Tras implementar, hacer checkout de la rama de este ticket.
2. Ejecutar `grep -r "\.docs/changes/[A-Z]" .` en el repo y verificar
   que no queda ninguna referencia sin `active/` o `archive/` intermedia
   (excluyendo tickets ya archivados y la propia carpeta `AGEX-004/` que
   vive en ruta vieja hasta `/sdd-wrap`).
3. Ejecutar `cat .spec/config.yml` y verificar la clave `branch.base`.
4. Simular un `/sdd-start TEST-999`:
   - Confirmar que crea rama desde `main` (o lo que indique
     `branch.base`).
   - Confirmar que genera `.docs/changes/active/TEST-999/` en los
     siguientes comandos del flujo.
5. En `/sdd-wrap` de AGEX-004, confirmar que:
   - La carpeta `.docs/changes/AGEX-004/` (ruta vieja) se mueve a
     `.docs/changes/archive/AGEX-004/`.
   - `gh pr create --base main` se ejecuta correctamente.

### Qué mirar

- **Filesystem**: `.docs/changes/active/` existe y está versionada con
  `.gitkeep`. `.docs/changes/archive/` intacta.
- **Config**: `.spec/config.yml` tiene `branch.base: main`.
- **Comandos**: los heredocs de `install.sh` y los archivos en
  `.spec/commands/` están alineados.
- **Git**: al crear una rama de prueba, parte del commit correcto
  (`git log --oneline <branch.base>..HEAD` muestra solo commits nuevos).

## Riesgos

- **Divergencia `install.sh` ↔ `.spec/commands/`**: el script contiene
  los textos canónicos embebidos. Si solo se actualizan los archivos
  en `.spec/commands/` y no el heredoc, las instalaciones nuevas nacen
  rotas. Mitigación: la tarea de `/sdd-plan` incluye explícitamente
  actualizar ambos orígenes y el review verifica que coinciden.

- **Bootstrap del propio ticket**: la spec de AGEX-004 se escribe en
  `.docs/changes/AGEX-004/` (ruta vieja). Mitigación: una tarea
  explícita mueve la carpeta a `.docs/changes/active/AGEX-004/` como
  último paso de implementación, antes de `/sdd-wrap`. `/sdd-wrap`
  encuentra la carpeta en la ruta nueva y archiva con la lógica nueva,
  sin excepciones ni soporte dual.

- **Repos ya instalados con config.yml antiguo**: si `branch.base`
  falta, el comando intenta `develop` y si no existe pregunta al
  usuario recomendando editar `config.yml`. Mitigación: decisión #2.
  El review comprueba que los comandos contemplan la ausencia de la
  clave y que existe el prompt cuando ni `develop` ni valor explícito
  resuelven.

- **Referencias olvidadas**: dado que hay ≥29 ocurrencias de
  `.docs/changes/` repartidas, es fácil dejar una sin actualizar.
  Mitigación: criterio de éxito #1 (grep con 0 coincidencias) es
  bloqueante en `/sdd-review`.
