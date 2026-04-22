# Smoke test — NOVA-38

Evidencia de la CA2 ("install probado end-to-end en repo limpio").

## Entorno

- **Fecha**: 2026-04-22
- **Máquina**: macOS darwin 23.3.0
- **Source**: `/Users/adan/Workspace/novaspec` (branch `arch/NOVA-38-oficializacion-split-repos`)
- **Target**: `/tmp/nova-smoke-post` (repo vacío con `git init`)

## Comandos ejecutados

```bash
rm -rf /tmp/nova-smoke-post && mkdir -p /tmp/nova-smoke-post
cd /tmp/nova-smoke-post && git init -q
bash /Users/adan/Workspace/novaspec/install.sh --target claude
```

Exit code: `0`.

## Estructura resultante (relevante)

```
.
├── AGENTS.md
├── CLAUDE.md
├── .claude/
│   ├── agents   -> ../novaspec/agents
│   ├── commands -> ../novaspec/commands
│   └── skills   -> ../novaspec/skills
├── context/
│   ├── changes/{active,archive}/
│   ├── decisions/
│   ├── gotchas/
│   └── services/
├── notes.md
└── novaspec/
    ├── README.arch.md
    ├── README.quickref.md
    ├── agents/     (context-loader, nova-review-agent)
    ├── commands/   (7 archivos: nova-{start,spec,plan,build,review,wrap,status}.md)
    ├── config.example.yml
    ├── config.yml  (copia del .example; no contiene datos del maintainer)
    ├── guardrails/
    ├── skills/
    └── templates/
```

## Verificaciones automáticas

| Check | Resultado |
|---|---|
| `install.sh` exit 0 | ✅ |
| `context/` usa nomenclatura actual (`decisions/`, `gotchas/`, `services/`) | ✅ |
| No queda `context/adr/`, `context/post-mortems/`, `context/glossary.md` | ✅ |
| 7 comandos `/nova-*` accesibles vía `.claude/commands` | ✅ |
| Symlinks `.claude/{agents,commands,skills}` resuelven | ✅ |
| `novaspec/config.yml` NO contiene URL/email del maintainer | ✅ |
| `novaspec/config.yml` es copia de `config.example.yml` en fresh install | ✅ |
| Reinstalación preserva `config.yml` editado del destino | ✅ (verificado con marcador) |

## Verificación manual pendiente (pasar antes de `/nova-wrap`)

- [ ] Abrir Claude Code en `/tmp/nova-smoke-post` → comprobar que los 7 `/nova-*` aparecen en el selector.
- [ ] Ejecutar `/nova-status` → debe reportar "no hay ticket activo y no hay tickets abiertos".
- [ ] Ejecutar `/nova-start TEST-1` (o cualquier ticket dummy) → debe pedir datos del ticket o invocar `jira-integration` y fallar con mensaje limpio si no hay config.

## Hallazgos registrados durante el smoke

1. **install.sh creaba estructura `context/` obsoleta** (`adr/`, `post-mortems/`, `glossary.md`). Arreglado en T2b.
2. **install.sh filtraba `novaspec/config.yml` del maintainer al destino**. Arreglado en T6b con preservación del config editado del destino.
3. **install.sh no generaba `.gitignore` en el repo destino** — resuelto en este mismo ticket tras `/nova-build`: la función `ensure_gitignore()` añade un bloque `# nova-spec (local) … # /nova-spec` idempotente al `.gitignore` del destino. También se crea `context/decisions/archived/` upfront y se eliminó la flag `-w/--worktrees` como limpieza.
4. **Repo ya era público al llegar a T9**. La visibilidad ya estaba a `PUBLIC` antes de NOVA-38. T9 confirmada por estado, no por acción. El audit T1 cobra valor retroactivo: el historial había sido público y no había secretos reales.
5. **`origin/develop` está 1 commit por detrás de `develop` local** — el commit `e47f6fe` ("chore(config): migrate novaspec/config.yml to .example pattern") nunca se empujó. Housekeeping pendiente fuera de NOVA-38. Un smoke desde clone público hoy trae `install.sh` antiguo; el smoke post-merge de esta rama (tras `/nova-wrap`) será el definitivo.

## Rename ejecutado

- `gh repo rename nova-spec --repo adansuku/NovaSpec` → OK.
- Nuevo remote: `git@github.com:adansuku/nova-spec.git`.
- Verificación: `gh repo view adansuku/NovaSpec` resuelve al nombre nuevo (redirect GitHub funciona).
- `git push --dry-run` OK desde el working tree.
