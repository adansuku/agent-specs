<p align="center">
  <img src="img/novaspec-logo.svg" alt="novaspec" width="480">
</p>

<p align="center">
  <strong>Spec-Driven Development (SDD)</strong> framework for Claude Code.
</p>

---

## Quick Start

```bash
bash install.sh  # En repo destino
claude           # Abre en raíz
/nova-start PROJ-123
```

Ver [INSTALL.md](./INSTALL.md) para instalación completa.

---

## Flujo

```
/nova-start → /nova-spec → /nova-plan → /nova-build → /nova-review → /nova-wrap
```

| Comando | Qué hace |
|---|---|
| `/nova-start <TICKET>` | Clasifica, rama, carga contexto |
| `/nova-spec` | Cierra requisitos, genera spec |
| `/nova-plan` | Plan + tareas |
| `/nova-build` | Ejecuta tareas una a una |
| `/nova-review` | Code review final |
| `/nova-wrap` | Commit, PR, actualiza memoria |
| `/nova-status` | Estado del ticket |

Quick-fix: `start` → `build` → `wrap`

---

## Docs

- Referencia rápida: `novaspec/README.quickref.md`
- Arquitectura: `novaspec/README.arch.md`
- Instalación: [INSTALL.md](./INSTALL.md)

---

## Reglas

- No saltar pasos
- No inventar contexto (preguntar si falta)
- Checkpoint humano post-spec y pre-wrap
- Alimentar memoria al cerrar

---

## Estado

Piloto en curso. Feedback en `notes.md`.