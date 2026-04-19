# nova-spec — AGENTS.md del framework

> Este repo usa CLAUDE.md como stub → AGENTS.md es el archivo de instrucciones.

This repo is the **nova-spec framework itself** — a Spec-Driven Development (SDD) system for Claude Code. It's designed to be installed into other projects.

## What is nova-spec

Framework that orchestrates ticket-to-PR workflow with 7 slash commands: `/nova-start` → `/nova-spec` → `/nova-plan` → `/nova-build` → `/nova-review` → `/nova-wrap` → `/nova-status`.

## Key commands

- `/nova-start <TICKET>` — classify ticket, create branch, load context
- `/nova-spec` — close requirements, generate spec (uses `close-requirement` skill)
- `/nova-plan` — create plan + tasks
- `/nova-build` — execute tasks one-by-one
- `/nova-review` — final code review
- `/nova-wrap` — commit, PR, update memory (uses `write-adr`, `update-service-context`)

Quick-fixes skip `/nova-spec` and `/nova-plan`.

## Branch config

In `novaspec/config.yml`:
- Pattern: `{type}/{ticket}-{slug}` (e.g., `feature/AGEX-123-new-feature`)
- Types: bugfix, hotfix, feature, documentation, refactor, chore, architecture
- Base branch: `main`

## Memory structure

```
context/
├── adr/                    # Architectural Decision Records
├── services/                # Per-service CONTEXT.md
├── changes/
│   ├── active/             # Active ticket specs
│   └── archive/            # Closed ticket specs
└── glossary.md            # Domain terms
```

## Symlinks

Claude Code discovers commands via `.claude/` symlinks pointing to `novaspec/`.

## Working here

This repo uses itself. When modifying nova-spec:
1. Test changes in a worktree or sandbox project
2. Verify symlinks work: `ls -la .claude/`
3. Run through a full ticket cycle

## Reference

- Full docs: [README.md](./README.md)
- Installation: [INSTALL.md](./INSTALL.md)
- Commands: `novaspec/commands/*.md`
- Skills: `novaspec/skills/*/SKILL.md`