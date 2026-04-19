# nova-spec Quick Reference

## Comandos

`/nova-start <TICKET>` → classify, branch, load context
`/nova-spec` → close requirements, generate spec
`/nova-plan` → plan + tasks
`/nova-build` → execute tasks one-by-one
`/nova-review` → final review against spec
`/nova-wrap` → commit, PR, update memory
`/nova-status` → show ticket status

Quick-fix: `/nova-start` → `/nova-build` → `/nova-wrap`

## Estructura

```
├── novaspec/        # Framework
│   ├── commands/  # /nova-*
│   ├── skills/     # Auto-loaded
│   └── templates/
├── context/
│   ├── adr/       # ADRs
│   ├── services/  # CONTEXT.md
│   └── changes/   # Active/archive specs
└── AGENTS.md      # Project instructions
```

## Reglas

- No saltar pasos del flujo
- No inventar contexto (preguntar si falta)
- Checkpoints humanos: después de `/nova-spec`, antes de `/nova-wrap`
- Alimentar memoria al cerrar

## Config

`novaspec/config.yml` — branch pattern, types, base branch