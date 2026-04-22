---
name: jira-integration
description: Lee y crea tareas en Jira usando la API REST. Usa la configuración de config.yml del proyecto (sección `jira`).
---

# Jira Integration

Lee y crea issues en Jira usando la API REST v3 de Atlassian.

## Configuración requerida en config.yml

```yaml
jira:
  skill: jira-integration
  url: https://tu-org.atlassian.net   # sin trailing slash
  project: PROJ                        # clave del proyecto por defecto
  email: tu@email.com
  token: ${JIRA_API_TOKEN}             # referencia a variable de entorno
```

El token se obtiene en: https://id.atlassian.com/manage-profile/security/api-tokens

## Cómo usar esta skill

Cuando el usuario pida leer o crear tareas de Jira:

1. **Leer la configuración**: leer `config.yml` del proyecto y extraer la sección `jira`.
2. **Resolver el token**: si el valor empieza con `${`, leer la variable de entorno correspondiente (p.ej. `$JIRA_API_TOKEN`).
3. **Construir las credenciales Basic Auth**: `base64(email:token)`.
4. **Llamar a la API** con `curl` según la operación solicitada.

## Operaciones

### Leer un ticket

```bash
curl -s \
  -H "Authorization: Basic <BASE64>" \
  -H "Accept: application/json" \
  "https://<url>/rest/api/3/issue/<TICKET_KEY>"
```

Mostrar al usuario: clave, resumen (summary), estado (status.name), descripción (description.content[0].content[0].text si existe), asignado (assignee.displayName).

### Listar tickets de un proyecto (últimos abiertos)

```bash
curl -s \
  -H "Authorization: Basic <BASE64>" \
  -H "Accept: application/json" \
  "https://<url>/rest/api/3/search?jql=project=<PROJECT>+AND+statusCategory!=Done+ORDER+BY+created+DESC&maxResults=20&fields=summary,status,assignee,priority"
```

### Crear un ticket

```bash
curl -s -X POST \
  -H "Authorization: Basic <BASE64>" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  "https://<url>/rest/api/3/issue" \
  -d '{
    "fields": {
      "project": { "key": "<PROJECT>" },
      "summary": "<TITULO>",
      "description": {
        "type": "doc", "version": 1,
        "content": [{"type": "paragraph", "content": [{"type": "text", "text": "<DESCRIPCION>"}]}]
      },
      "issuetype": { "name": "<TIPO>" }
    }
  }'
```

Tipos de issue comunes: `Story`, `Task`, `Bug`, `Sub-task`.

Tras crear, mostrar la clave asignada (campo `key` en la respuesta) y la URL directa al ticket.

### Convención de título

El proyecto Jira es `NOVA`. El summary usa el formato `NOVA-<NNN>: <título>` donde `<NNN>` es el número del ticket con cero padding a 3 dígitos (ej: NOVA-17 → `NOVA-017`). Para conocer el número antes de crear, consulta el último ticket del proyecto con la API de búsqueda y suma 1.

## Notas

- Si `token` no está en config.yml, pedir al usuario que lo configure.
- Si el proyecto no se especifica en la petición, usar el `project` del config.yml.
- Ante errores HTTP (401, 403, 404), mostrar el mensaje de error de Jira sin exponerlo completo si contiene el token.
