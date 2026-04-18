# Plan: LNS-001

## Estrategia

Dos archivos independientes en una sola pasada cada uno (no por trozos).
Se crea primero `INSTALL.md` y después se modifica `README.md`, para que
el enlace relativo `[INSTALL.md](./INSTALL.md)` que añadimos al README
ya apunte a un archivo presente y se pueda validar al final con un
simple listado de archivos.

## Archivos a tocar

- `README.md`:
  - **Sección "Estructura del repo"** (~líneas 71-95): sustituir el
    bloque para que `.docs/` aparezca como contenedor de toda la memoria
    y las specs (`adr/`, `services/`, `specs/`, `changes/archive/`,
    `post-mortems/`, `glossary.md`). Eliminar el bloque `openspec/`.
  - **Tabla "Capas de memoria"** (~líneas 111-118): cambiar
    `openspec/changes/<ticket>/` → `.docs/changes/<ticket>/`; añadir
    `.docs/specs/` a la fila de Sistema; cambiar etiqueta de
    Organización a `Repo base del framework (plantillas)`.
  - **Sección "Primer uso"** (~líneas 133-145): reemplazar los pasos
    detallados inline por un link a `./INSTALL.md` y un resumen breve
    1-2-3-4 (ejecutar bootstrap → verificar symlinks → abrir Claude
    Code → primer ticket).

## Archivos nuevos

- `INSTALL.md` (raíz): guía de instalación agnóstica de proyecto
  destino, en español, con las 8 secciones acordadas:
  1. Requisitos previos
  2. Instalación rápida
  3. Qué se instala
  4. Verificación
  5. Personalización
  6. Actualización del framework
  7. Desinstalación
  8. Problemas comunes

## Dependencias entre cambios

- `INSTALL.md` antes que la modificación de "Primer uso" del README:
  el link relativo necesita un destino existente para validarse al
  final.
- Las tres modificaciones del README son independientes entre sí; el
  orden interno entre ellas no importa.

## Safety net

- **Reversibilidad**: cambios estrictamente en documentación, sin
  impacto en código ejecutable. Para revertir basta:
  - `git checkout HEAD -- README.md`
  - `rm INSTALL.md`
  - o revertir el commit completo.
- **Qué puede romperse**: solo enlaces relativos rotos en docs. Ningún
  sistema, comando del framework, skill, ni script depende de estos
  archivos en runtime.
- **Plan de rollback**: revertir el commit del PR. Cero efectos
  colaterales.

## Characterization tests

N/A. Es documentación. La preservación del contenido válido del README
se hace por:

- [ ] Estado actual del README ya cargado en contexto previo
      (lectura completa hecha en `/sdd-spec`).
- [ ] Diff final revisado contra los criterios de éxito antes del
      commit.

## Verificación

Por cada criterio de éxito de la spec:

1. **Cero menciones a `openspec/`**:
   `grep -i "openspec" README.md INSTALL.md` → sin resultados.
2. **Estructura del README coincide con la real**: comparar el bloque
   "Estructura del repo" con `find .docs -type d` y `ls -la`.
3. **Tabla de capas con rutas bajo `.docs/`**:
   `grep -E "\.docs/(changes|specs|services)" README.md` → al menos
   una coincidencia por ruta en la tabla.
4. **"Primer uso" delega a INSTALL.md**:
   `grep "INSTALL.md" README.md` presente; los pasos detallados ya no
   están en README.
5. **INSTALL.md existe con todas las secciones**:
   `grep "^## " INSTALL.md` lista las 8 secciones acordadas en orden.
6. **Enlaces relativos funcionan**: para cada `[texto](./archivo.md)`
   en README e INSTALL.md, el archivo existe.
7. **Terminología consistente**: mismos nombres de carpetas
   (`.docs/`, `.spec/`, `.claude/`), tipos de ticket
   (`quick-fix`/`feature`/`architecture`), nombre del script
   (`install.sh`) en ambos archivos.
