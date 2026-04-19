# Changelog

## [1.0.0] — 2026-04-19

Primera release pública de **NovaSpec**, framework de Spec-Driven Development (SDD) para Claude Code.

### Added

- Flujo completo de 6 comandos: `nova-start` → `nova-spec` → `nova-plan` → `nova-build` → `nova-review` → `nova-wrap`
- Skills reutilizables: `load-context`, `close-requirement`, `write-adr`, `update-service-context`
- Guardrails de precondición por comando (branch-pattern, proposal, plan+tasks, all-tasks-done, review-approved)
- Templates de artefactos: `proposal.md`, `plan.md`, `tasks.md`, `ticket-summary.md`, `status-report.md`
- `novaspec/config.yml` — configuración centralizada de branch pattern, rama base y skill de Jira
- `install.sh` — instalación del framework en cualquier repo via symlinks
- Integración Jira configurable vía `config.yml` (`jira.skill`)
- `.claudeignore` para excluir archive y backlog del contexto de Claude

### Changed

- Guardrails consolidados de 5 archivos individuales a un único `checklist.md`
- Cabecera de guardrail colapsada de 4 líneas a 1 línea por comando
- Skills reducidas ~45% eliminando ejemplos redundantes
- README dividido en guía rápida + `README.quickref.md` + `README.arch.md`
- `CLAUDE.md` consolidado en `AGENTS.md`

### Performance

- Reducción de tokens del framework ~33% respecto al prototipo inicial
- `.claudeignore` previene indexación del archive (~228 KB)

---

*Formato: [Keep a Changelog](https://keepachangelog.com/). Versioning: [SemVer](https://semver.org/).*
