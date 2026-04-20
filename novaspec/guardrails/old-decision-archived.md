# Guardrail: old-decision-archived

Valida que las decisiones marcadas como superseded estén archivadas.

## Qué comprueba

Para cada archivo en `context/decisions/*.md` (no en `archived/`) que contiene una línea con el patrón `> Supersedes: <archivo>.md`:

- El `<archivo>.md` referenciado **NO debe existir** en `context/decisions/` (raíz).
- El `<archivo>.md` referenciado **debe existir** en `context/decisions/archived/`.

Si cualquiera de las dos condiciones falla, el guardrail falla.

## Comando de verificación

```bash
failed=0
for f in context/decisions/*.md; do
  [ -f "$f" ] || continue
  while IFS= read -r old; do
    old=$(echo "$old" | sed -E 's/^> Supersedes:[[:space:]]*//')
    [ -z "$old" ] && continue
    if [ -f "context/decisions/$old" ]; then
      echo "⛔ Guardrail: $f referencia '$old' como superseded, pero '$old' vive en context/decisions/ (debe estar en archived/)."
      failed=1
    fi
    if [ ! -f "context/decisions/archived/$old" ]; then
      echo "⛔ Guardrail: $f referencia '$old' como superseded, pero '$old' no aparece en context/decisions/archived/."
      failed=1
    fi
  done < <(grep -E "^> Supersedes:" "$f")
done
exit $failed
```

## Mensaje de error

```
⛔ Guardrail: <archivo-nuevo> referencia '<archivo-viejo>' como superseded,
pero '<archivo-viejo>' vive en context/decisions/ (debe estar en archived/).
```

## Recovery

```bash
git mv context/decisions/<archivo-viejo>.md context/decisions/archived/<archivo-viejo>.md
```

Verifica que el archivo nuevo sigue conteniendo la línea `> Supersedes: <archivo-viejo>.md`. Reintenta.

## Cuándo se ejecuta

Referenciado por `/nova-wrap` como paso previo al commit del ticket.
