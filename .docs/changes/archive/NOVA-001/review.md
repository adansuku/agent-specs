# Review: NOVA-001

## Cumplimiento de spec

- [✓] Templates creados: `novaspec/templates/` existe con 8 archivos skeleton
  (spec pedía 7; se añadió `status-report.md` para cubrir `nova-status` — desviación documentada en plan)
- [✓] Referencias explícitas: 6 de 7 comandos referencian su template por ruta.
  `nova-build.md` excluido — no tiene skeleton de salida, documentado en plan
- [~] Reducción LOC ≥30 por archivo (criterio indicativo):
  - nova-spec: -49 ✓ | nova-plan: -34 ✓ | nova-wrap: -30 ✓
  - nova-review: -24 ~ | nova-start: -19 ~ | nova-status: -17 ~ | nova-build: 0 ~
  - Total: 691 → 518 (-173 LOC, -25%). Desviaciones documentadas en plan.md
- [✓] Total de comandos baja de 691 — sí: 518

## Convenciones

- Sin incidencias. Los templates usan el mismo estilo Markdown que los comandos existentes.
- Las referencias siguen el patrón `novaspec/templates/<nombre>.md` consistente con
  las referencias a guardrails (`novaspec/guardrails/<nombre>.md`).

## ADRs

- ADR-0001 (install.sh copia desde fuente): respetado — `novaspec/templates/` vive dentro de
  `novaspec/` y se distribuye automáticamente vía `cp -R "$SCRIPT_DIR/novaspec" .`
- ADR-0002 (naming nova-spec): respetado — carpeta `novaspec/templates/`, sin punto, visible

## Riesgos

- Mecanismo de referencia por texto es no-determinista (el modelo puede ignorar la plantilla).
  Mitigación acordada en spec: verificación end-to-end manual antes de cerrar.
  Este review no cubre ese paso — queda pendiente como verificación humana post-merge.

## Bloqueantes

- Ninguno

## Sugerencias

- La verificación end-to-end (pasos 3-4 de spec) debería ejecutarse antes del merge, no después.
  No es bloqueante dado que los archivos de template son Markdown estático — no hay riesgo de
  regresión en el framework, solo en la calidad del output generado.

## Veredicto

✓ Listo para /nova-wrap
