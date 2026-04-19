---
description: Arranca el flujo nova-spec desde un ticket de Jira
argument-hint: <TICKET-ID>
---

Eres el orquestador inicial del flujo nova-spec.

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

Lee `novaspec/config.yml`:
- `branch.pattern` para el nombre de rama (default `{type}/{ticket}-{slug}`).
- `branch.base` para la rama base del flujo. Resolución:
  - Si la clave **existe**: usa ese valor. Si la rama no existe en git,
    deja que `git checkout` falle con su error nativo.
  - Si la clave **falta** (instalación vieja): intenta `develop`.
    - Si `develop` existe: úsala, pero avisa al usuario:
      "Usando `develop` como fallback. Añade `branch.base` a
      `novaspec/config.yml` para fijarla."
    - Si `develop` no existe: lista las ramas locales (`git branch`),
      pregunta al usuario cuál usar y recomienda escribirla en
      `novaspec/config.yml`. No sigas hasta tener respuesta.

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
- quick-fix → `/nova-build`
- feature → `/nova-spec`
- architecture → `/nova-spec` (avisa: requerirá ADR en /nova-wrap)

## Reglas

- No escribas código aquí.
- No inventes contexto. Si falta info, pregunta.
- Si el working tree está sucio, para.
