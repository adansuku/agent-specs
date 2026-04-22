# Un repo único público en vez de split oficial + dev

**Fecha**: 2026-04-22
**Ticket**: NOVA-38
**Estado**: Aceptada

## Decisión

`nova-spec` se distribuye como un único repo público (`adansuku/nova-spec`). La memoria del framework (`context/`) vive en el mismo repo como dogfood y ejemplo vivo, no en un repo separado.

## Alternativa descartada

Split en dos repos: uno oficial distribuible (`novaspec/` + `install.sh` + docs top-level) y otro de desarrollo con la memoria interna del framework. Era la propuesta original del ticket.

## Por qué

- `install.sh` no copia `context/` al destino (solo `novaspec/` + `CLAUDE.md` + `AGENTS.md`). La "contaminación" que motivaba el split ya está resuelta por diseño.
- Dos repos reintroducen el drift que `install-sh-copia-desde-fuente.md` (AGEX-009) eliminó: cualquier cambio en `novaspec/` obliga a sincronizar dos sources.
- El `context/` del propio repo es marketing vivo: specs reales, decisiones reales, dogfooding visible. En un repo separado se vuelve invisible.
- No hay datos confidenciales que proteger; el objetivo declarado es open-source.
- Un solo repo simplifica el dev loop (no hay "promocionar" entre repos), los PRs externos y el mantenimiento.

## Coste aceptado

- Quien entre al repo público ve trabajo in-flight del maintainer (`context/changes/active/`). Aceptado: trabajo in-flight con ticket es trabajo del proyecto, no del individuo.
- Si en el futuro aparece contenido confidencial (datos de cliente, PII, decisiones que no quieras exponer), habrá que re-evaluar el split como ticket nuevo. Hoy no aplica.
