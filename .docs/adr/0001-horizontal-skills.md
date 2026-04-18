# ADR-0001: Skills horizontales

## Estado
Aceptado — 2026-04-18

## Contexto

Hasta AGEX-004, cada skill del framework pertenecía a una fase concreta
del flujo SDD:

- `load-context` → `/sdd-start`
- `close-requirement` → `/sdd-spec`
- `write-adr`, `update-service-context` → `/sdd-wrap`

En AGEX-005 se introduce `collaborative-decision`, una skill pensada
para ser invocada desde **varios comandos** (de momento `/sdd-plan`;
está previsto adoptarla también en `/sdd-do` y `/sdd-review`).

Esto rompe la correspondencia 1:1 entre skill y fase. Sin criterio
explícito, el patrón puede replicarse de formas divergentes y erosionar
la legibilidad del framework.

## Decisión

Se distinguen dos tipos de skills:

- **Verticales**: pertenecen a una fase concreta del flujo. Su
  `description` en el frontmatter menciona el comando o fase donde
  aplican (`load-context`, `close-requirement`, `write-adr`,
  `update-service-context`).

- **Horizontales**: reutilizables por varios comandos. Su `description`
  explicita que pueden invocarse desde distintos comandos, sin atar a
  una fase. Ejemplo canónico: `collaborative-decision`.

Ambos tipos usan el mismo formato de `SKILL.md` (frontmatter con `name`
y `description` + cuerpo en prosa). No se introduce ningún contrato
estructurado (YAML, delimitadores) entre comando y skill: la invocación
es conversacional, siguiendo el patrón ya establecido por
`close-requirement`.

## Alternativas consideradas

- **Contrato estructurado (YAML) entre comando y skill**: se descartó en
  AGEX-005 Decisión 1. Habría exigido parsers y delimitadores
  explícitos, sobreingeniería para la primera iteración. Si el uso real
  revela la necesidad, se revisará con un ADR posterior.

- **No distinguir tipos**: invisibiliza el patrón. Sin nomenclatura,
  futuras skills horizontales se añadirían sin criterio común y el
  framework perdería coherencia.

- **Crear una carpeta aparte `.spec/skills/horizontal/`**: se descartó
  por introducir fricción sin valor práctico. Claude Code descubre las
  skills por frontmatter, no por ubicación. Mantener un único
  directorio plano simplifica el descubrimiento.

## Consecuencias

### Positivas
- Habilita la adopción de `collaborative-decision` desde `/sdd-do` y
  `/sdd-review` en tickets futuros sin rediseñar el contrato.
- Documenta una convención antes de que se replique de forma
  divergente.
- Futuros ADRs pueden referenciar esta distinción sin re-explicarla.

### Negativas
- Añade un concepto (tipo de skill) que hay que comunicar. Mitigación:
  se refleja en `.docs/services/agex/CONTEXT.md` y en el glossary.

### Neutras
- La distinción es documental, no mecánica: Claude Code no trata
  distinto a una skill por ser horizontal o vertical.

## Relacionado

- ADRs: ninguno (primer ADR del repo).
- Specs: `.docs/changes/archive/AGEX-005/proposal.md`.
- Tickets: AGEX-005.

## Notas

El criterio "vertical vs horizontal" se evalúa al introducir cada skill
nueva. Si una skill vertical empieza a ser invocada desde otros
comandos, puede reclasificarse a horizontal documentando el cambio en
un ADR nuevo.
