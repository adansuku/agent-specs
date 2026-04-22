# nova-spec Quick Reference

## Comandos

`/nova-start <TICKET>` → classify, branch, load context
`/nova-spec` → close requirements, generate spec
`/nova-plan` → tasks (plan + tareas)
`/nova-build` → execute tasks one-by-one
`/nova-review` → final review against spec
`/nova-wrap` → commit, PR, update memory
`/nova-status` → show ticket status

Quick-fix: `/nova-start` → `/nova-build` → `/nova-wrap`

## Estructura

```
├── novaspec/          # Framework
│   ├── commands/      # /nova-*
│   ├── skills/        # Auto-loaded
│   ├── agents/        # Subagents
│   ├── guardrails/    # Shared pre-conditions
│   └── templates/
├── context/
│   ├── decisions/     # Un hecho por archivo; archived/ no se auto-lee
│   ├── gotchas/       # Trampas no obvias
│   ├── services/      # <svc>.md planos, ≤80 líneas
│   └── changes/       # Specs active/archive
└── AGENTS.md          # Project instructions
```

## Reglas

- No saltar pasos del flujo
- No inventar contexto (preguntar si falta)
- Checkpoints humanos: después de `/nova-spec`, antes de `/nova-wrap`
- Alimentar memoria al cerrar

## Config

`novaspec/config.yml` — branch pattern, types, base branch
