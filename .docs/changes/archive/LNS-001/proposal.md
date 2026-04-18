# LNS-001: Actualizar README.md y crear INSTALL.md

## Historia

Como dev que llega al repo libnova.spec, quiero documentación coherente con
la estructura real del repo (README) y una guía de instalación dedicada
(INSTALL.md), para entender el framework y poder instalarlo en otro repo
sin descubrir incoherencias.

## Objetivo

- Eliminar el desfase entre la estructura documentada en el README y la
  real (sin `openspec/`, con toda la memoria y specs bajo `.docs/`).
- Separar onboarding (README) de instalación (INSTALL.md).
- Validar end-to-end el flujo libnova.spec sobre el propio framework
  (primer ticket real).

## Contexto

Durante la construcción del framework se eliminó la carpeta `openspec/` y
se consolidó toda la memoria arquitectónica y las specs en `.docs/`.
Comandos y skills se actualizaron, pero el README quedó desfasado:
documenta la estructura antigua y describe el flujo de instalación inline.
Falta también un INSTALL.md específico para reproducir la instalación en
otros repos.

Este es además el primer ticket ejecutado con libnova.spec sobre el propio
libnova.spec. Sirve como validación end-to-end del flujo.

## Alcance

### En alcance

- **Modificar `README.md`**:
  - Sección "Estructura del repo": reflejar la estructura real (sin
    `openspec/`, con `.docs/` conteniendo `adr/`, `services/`, `specs/`,
    `changes/` con `archive/` dentro, `post-mortems/`, `glossary.md`).
  - Tabla "Capas de memoria": rutas correctas (`.docs/changes/`,
    `.docs/specs/`, `.docs/services/`) y etiqueta de la capa Organización
    como `Repo base del framework (plantillas)`.
  - Sección "Primer uso": link a `INSTALL.md` + resumen breve 1-2-3-4
    (no los pasos detallados).
- **Crear `INSTALL.md`** en la raíz con las secciones:
  - Requisitos previos
  - Instalación rápida
  - Qué se instala
  - Verificación
  - Personalización
  - Actualización del framework
  - Desinstalación
  - Problemas comunes
- Coherencia terminológica entre ambos archivos.
- Enlaces relativos cruzados funcionales (`./README.md`, `./INSTALL.md`).

### Fuera de alcance

- Cambios en comandos, skills, `.spec/config.yml` o estructura del
  framework.
- Corregir el header del script `install.sh` que aún dice
  `Uso: bash bootstrap-libnova-spec.sh` (queda como follow-up en
  `notes.md`).
- Traducciones a otro idioma.
- Cambios en el naming del framework.
- Documentación adicional (CONTRIBUTING.md, CHANGELOG.md, etc.).

## Decisiones cerradas

- INSTALL.md incluye las 4 secciones obligatorias del ticket más Qué se
  instala, Personalización, Actualización del framework y Desinstalación.
- Nombre del script referenciado: `install.sh` (nombre real del archivo
  en la raíz, no el `bootstrap-libnova-spec.sh` que aparece en su header).
- README "Primer uso": link a INSTALL.md + resumen 1-2-3-4 (no minimal).
- INSTALL.md agnóstico del proyecto destino (vale para cualquier repo).
- Etiqueta de la capa "Organización" en tabla de memorias:
  `Repo base del framework (plantillas)`.
- Idioma: español, coherente con el resto del repo.

## Comportamiento esperado

- **Normal**: un dev nuevo lee README → entiende qué es libnova.spec y
  cómo se usa → sigue el link a INSTALL.md desde "Primer uso" → instala
  el framework en su repo destino siguiendo INSTALL.md.
- **Edge cases**:
  - Dev en Windows sin WSL: INSTALL.md avisa de la limitación de
    symlinks y sugiere WSL como solución recomendada.
  - Repo destino con `.spec/` o `.docs/` previos: el script `install.sh`
    ya es idempotente; INSTALL.md lo menciona.
  - Symlinks rotos al clonar el repo: documentado en "Problemas comunes"
    con la solución (`git config core.symlinks true`).
- **Fallo**: N/A. Es documentación; la verificación es lectura humana.

## Output esperado

- `README.md` modificado.
- `INSTALL.md` nuevo en la raíz del repo.
- Sin cambios en `.spec/`, `.claude/`, `.docs/` (memoria), `install.sh`,
  `notes.md` ni `CLAUDE.md`.

## Criterios de éxito

- `README.md` no menciona `openspec/` en ningún punto.
- La sección "Estructura del repo" del README coincide con la estructura
  real (verificable con `ls` y `find .docs -type d`).
- La tabla "Capas de memoria" usa rutas bajo `.docs/`
  (`.docs/changes/`, `.docs/specs/`, `.docs/services/`).
- "Primer uso" contiene un link a `./INSTALL.md` y un resumen 1-2-3-4
  (no los pasos detallados inline).
- `INSTALL.md` existe en la raíz con todas las secciones acordadas.
- Todos los enlaces relativos entre README ↔ INSTALL.md apuntan a
  archivos existentes.
- Terminología consistente entre ambos: nombres de carpetas (`.docs/`,
  `.spec/`, `.claude/`), tipos de ticket (`quick-fix`/`feature`/
  `architecture`), nombre del script (`install.sh`).

## Impacto arquitectónico

- Servicios afectados: ninguno.
- ADRs referenciados: ninguno.
- ¿Requiere ADR nuevo?: no. Es documentación; no introduce ninguna
  decisión técnica nueva. La eliminación de `openspec/` ocurrió antes
  de este ticket y no se registró como ADR; este ticket no es el lugar
  para hacerlo.

## Verificación sin tests automatizados

### Flujo manual

1. Leer `README.md` completo. Verificar que no aparece la palabra
   `openspec` en ningún punto.
2. Comparar la sección "Estructura del repo" con la salida de
   `ls -la` y `find .docs -type d`. Deben coincidir.
3. Seguir cada enlace relativo en README e INSTALL.md y verificar que
   apunta a un archivo existente.
4. Leer `INSTALL.md` completo. Verificar que un dev sin contexto puede
   ejecutar la instalación siguiendo los pasos.
5. Comprobar que cada criterio de aceptación del ticket original se
   cumple.

### Qué mirar

- Logs: N/A.
- DB: N/A.
- API/UI: N/A. Es documentación.
- Coherencia textual entre README e INSTALL.md: mismos nombres de
  carpetas, mismos tipos de ticket, mismo nombre de script.

## Riesgos

- **Drift futuro entre docs y estructura real**: mitigación → cualquier
  ticket que modifique la estructura del repo debería actualizar también
  README e INSTALL.md (regla a reforzar en revisiones futuras, no
  formalizada en este ticket).
- **Inconsistencia interna de `install.sh`** (su header dice
  `bootstrap-libnova-spec.sh`, distinto del nombre real del archivo):
  fuera de alcance de este ticket. Queda registrado en esta spec
  archivada como follow-up; ningún rastro adicional fuera del
  directorio `.docs/changes/LNS-001/`.
