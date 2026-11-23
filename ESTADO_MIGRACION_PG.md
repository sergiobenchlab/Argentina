# Migración de los tableros de Argentina a PostgreSQL: estado al 23/11/2026

Revisión hecha leyendo directamente los 17 `.pbix` de `Downloads/INFORMES ARGENTINA` (consultas M, medidas
DAX, relaciones y datos guardados en cada modelo) y comparándolos con los exports de PG del 23/11.
Ningún `.pbix` fue modificado.

## 1. Resumen

| | Tableros |
|---|---|
| ✅ 100 % PostgreSQL | `arg_registro_calificado`, `arg_caracterizacion_ies`, `arg_oferta_laboral`, `arg_oceanos_azules` |
| 🟡 PG + 1 archivo | `arg_poblaciones` (banderas en Excel), `arg_edutrends` (T39 keywords) |
| 🟢 Listos para migrar hoy (código en `powerquery/`) | `arg_perfil_ies`, `arg_posicionamiento_competitivo`, parte poblacional de `arg_rendimiento_y_pertinencia` |
| 🔴 Dependen de datos que no están en PG | `arg_marketing`, `arg_proyecciones`, `arg_rankings` |
| 🔴 Live a Azure Analysis Services | `arg_general`, `arg_cuota_mercado`, `arg_apertura_programa`, `arg_nuevo_mercado`, `arg_portafolio` |

**4 de 17 al 100 %** (el documento del 14/09 decía 2). Con lo que ya está en PG se pueden cerrar **5 más**
sin esperar a nadie: poblaciones, perfil, posicionamiento, rendimiento (la parte poblacional) y las banderas
de marketing.

Cambios respecto del documento del 14/09:

- `arg_caracterizacion_ies` **ya está migrado**, pero con el **patrón B**: lee las 6 tablas de `argentina.*` con
  sus nombres de PG y las 10 medidas se reescribieron (`fact_poblacion[estudiantes]`, etc.).
- Apareció `arg_oceanos_azules`, que no estaba en el inventario. Lee 7 tablas de PG y tiene 2 tablas embebidas.
  `arg_mercados_adyacentes` no está en la carpeta.
- Los CSV ya no se leen desde rutas locales: **todo lo que no es PG sale de SharePoint**
  (`benchlabonlinecom.sharepoint.com/sites/Benchlab/Documentos compartidos/Aplicativo/...`).

## 2. Qué lee cada tablero hoy

| Tablero | Medidas | PostgreSQL | Archivos en SharePoint |
|---|---:|---|---|
| `arg_registro_calificado` | 3 | 6 de `argentina.*` | — |
| `arg_caracterizacion_ies` | 10 | 6 de `argentina.*` | — |
| `arg_oferta_laboral` | 36 | 12 de `labor_market` + `population.m_banderas_m` | — |
| `arg_oceanos_azules` | 34 | 6 de `argentina.*` + banderas | — (2 tablas embebidas: Filtro Estrategia, Badge_Estado) |
| `arg_poblaciones` | 83 | 6 de `argentina.*` | `Multipais/M_BANDERAS_M.xlsx` |
| `arg_edutrends` | 27 | 4 de `argentina.*` + 3 de `labor_market` | `Argentina/T39_KEYWORDS_ORGANICS.csv` |
| `arg_rendimiento_y_pertinencia` | 30 | 7 de `labor_market` | T01, M01, M02, M03, M05, M06, M07, M08, M09 y T39 |
| `arg_perfil_ies` | 33 | — | T01, M01 (×2), M02, M03, M04, M05, M06, M07, M08, M09 |
| `arg_posicionamiento_competitivo` | 50 | — | T01, M01 (×2), M02, M03, M05, M06, M07, M08, M09 + banderas |
| `arg_marketing` | 43 | `m_banderas_m` **con host mal escrito** (`bdbenlabdatadev`) | T37, T38, T39, M46, M01, M09 + **`España/M22_CALENDARIO.csv`** |
| `arg_proyecciones` | 3 | — | T54 (+ `Historia/Marketing/221130/T54_..._ESTATICO`), M01, M02, M03, M05, M06, M08, M09 |
| `arg_rankings` | 134 | — | 23 archivos: QS, THE, Webometrics, T01, M01–M08, M36, M37; **U-Sapiens y M15 desde `Colombia/`** |
| 5 tableros Live | — | — | `asazure://.../benchlabtabularmodels`: catálogos `Arg_02_General`, `Arg_03_Decision_Programa`, `Arg_04_Decision_nuevo_mercado`, `Arg_05_Analisis portafolio`, `Arg_07_Cuota_Mercado` |

## 3. Verificación de datos

**Los 5 tableros que leen `fact_poblacion` cuadran exacto** con los controles de 2023 (datos guardados en
cada `.pbix`): 760.051 ingresantes, 2.746.768 estudiantes, 160.117 egresados, 178 IES, 6.145 titulaciones y
66.907 filas.

**El modelo viejo (CSV) también cuadra** en 2023 (mismos tres totales y las mismas 178 IES), y coincide IES
por IES (178/178), con 66.909 filas en lugar de 66.907.

### Corrección importante a la sección 3 del contexto: la llave institucional

> El mapeo del 14/09 decía `id_universidad → ID_IES`. **Es incorrecto.** El `ID_IES` del modelo viejo es
> **`universidades.id_ies`**: coincide 193/193, mientras que `id_universidad` coincide solo en 29.

Si se aplicara el mapeo del 14/09, los totales generales seguirían cuadrando, pero:

- `KEYWORDS_ORGANICS` (T39), que sigue en CSV, se cruzaría con la universidad equivocada en rendimiento,
  edutrends y marketing;
- lo mismo pasaría con cualquier CSV que quede por `ID_IES`: rankings, T54 y M04.

El código de `powerquery/` ya resuelve esto: lleva el hecho a `id_ies` con un join a `universidades`.

Otros cruces confirmados (alineando por `id_ies`):

- `SGMNT_1..4`: 193/193 iguales. `ID_RGN`: 193/193. `SD` y `TP_INSTTCN`: 193/193. `SCTR` y nombre: 192/193.
- `DMN`: el CSV trae `www.` adelante (`www.uai.edu.ar` frente a `uai.edu.ar`). No lo usa ninguna medida; revisar
  si algún visual arma logos o enlaces con esa columna.
- Las 37 disciplinas y las 154 áreas de PG coinciden con las del CSV.
- Los 14 `tipo_titulo` de PG coinciden con `NVL_FRMCN` del M08, y `Postítulo` es Grado en los dos
  (la duda del 14/09 queda resuelta).
- Las 96 filas de `population.m_banderas_m` son iguales al Excel. Solo cambian los nombres de columna a minúsculas.
- `M - Status` no tiene relaciones ni la usa ninguna medida en perfil: se puede embeber.

### ⚠️ KPI que va a cambiar: "Cantidad de programas"

El `ID_PRGRM` del CSV **no es el `id_titulo` de PG**: están numerados distinto y tienen distinto grano.

| 2023 | Valor |
|---|---:|
| `ID_PRGRM` distintos en el CSV (lo que muestra hoy perfil) | 9.802 |
| Títulos distintos en PG (`id_titulo`, lo que muestra caracterización) | 6.145 |
| Pares IES × título en PG (oferta real) | 10.307 |

El catálogo viejo tiene 12.246 programas para 7.708 combinaciones únicas de título × modalidad × nivel:
duplica títulos por IES de forma irregular (475 `ID_PRGRM` aparecen en más de una IES). Por eso 9.802 no se
puede reproducir desde PG. **Producto tiene que decidir qué se publica como "programas":** 6.145 títulos o
10.307 ofertas (IES × título). Los totales de matriculados, nuevos y graduados no cambian.

Esto también significa que los CSV que se quedan por `ID_PRGRM` (T54 pronósticos y la `T - Población` de
rankings) **no se pueden mezclar con PG** hasta que datos los regenere con `id_titulo`.

## 4. Cómo migrar perfil, posicionamiento y rendimiento (patrón A)

El código está en `powerquery/`, una consulta por archivo. Se reemplaza el contenido de cada consulta en
**Editor avanzado** de Power Query y se mantiene el nombre de la consulta. Con esto:

- **No se toca ninguna medida ni ninguna relación.** Se conservan los nombres de tabla y columna y también
  las llaves enteras (`ID_AR_CNCMNT` 1–37, `ID_NVL_FRMCN` 1–14, `ID_MDLDD` 0–2, `ID_RGN` 0–25). Las
  relaciones no tienen que pasar a texto, al contrario de lo que decía el plan del 14/09.
- El hecho, Universidad, Universidad (2), Clusters, Periodo, Programa, Área y banderas salen de PG.
- Región, Nivel Formación, Modalidad y Status quedan **embebidas** con el contenido exacto del CSV en uso,
  porque PG no tiene `NVL_FRMCN_2`, ni los textos de provincia que usan los mapas, ni el centinela `No Asignado`.

| Consulta | Archivo | perfil | posicionamiento | rendimiento |
|---|---|:-:|:-:|:-:|
| `T - Población` / `T - Poblacion` | `T - Poblacion.m` | ✔ | ✔ | ✔ (nombre sin tilde) |
| `M - Universidad` | `M - Universidad.m` | ✔ | ✔ | ✔ |
| `M - Universidad (2)` | `M - Universidad (2).m` | ✔ | ✔ | ✔ |
| `M - Clusters` | `M - Clusters.m` | ✔ | ✔ | ✔ |
| `M - Periodo` | `M - Periodo.m` | ✔ | ✔ | ✔ |
| `M - Programa` | `M - Programa.m` | ✔ | ✔ | ✔ (descomentar el paso `Copia`) |
| `M - Area Conocimiento` / `M - Área de Conocimiento` | `M - Area Conocimiento.m` | ✔ | ✔ | ✔ |
| `M - Nivel Formación` | `M - Nivel Formacion.m` | ✔ | ✔ | ✔ |
| `M - Modalidad` | `M - Modalidad.m` | ✔ | ✔ | ✔ |
| `M - Región` | `M - Region.m` | ✔ | ✔ | ✔ |
| `M - Status` | `M - Status.m` | ✔ | — | — |
| `M_BANDERAS_M` | `M_BANDERAS_M.m` | — | ✔ | — |

Diferencias que se esperan y **no son errores**:

- `M - Universidad`: 214 → 193 filas. `M - Universidad (2)`: 856 → 772. Las 21 IES que desaparecen no tienen matrícula.
- `M - Periodo`: 81 → 7 filas. Se mantiene el texto `2023-2` en `PRD_G` porque el CSV cargaba los años como semestre 2.
- `M - Programa`: 12.246 → 7.732 filas, con el cambio de KPI explicado en la sección 3.
- Hecho: 66.909 → 66.907 filas (Católica Argentina consolidada).
- Power BI va a pedir **una vez** que apruebes las consultas nativas (`Value.NativeQuery`).

Después de aplicar cada tablero:

1. Actualizar y comparar los 4 controles de 2023.
2. Revisar que ningún visual quede en blanco, sobre todo los mapas, los slicers de segmento y los de nivel.
3. Anotar el nuevo valor de "Cantidad de programas" para que producto lo valide.

## 5. Pasos a seguir, en orden

1. **Respaldar** cada `.pbix` con el sufijo `_pre_postgres` antes de tocarlo. Repuntar las consultas requiere
   Power BI Desktop en Windows.
2. **`arg_poblaciones`**: cambiar solo `M_BANDERAS_M` (`powerquery/M_BANDERAS_M.m`). Son 5 minutos y el tablero
   queda al 100 %.
3. **`arg_marketing`**: corregir el host en `M - Banderas` (`bdbenlabdatadev` → `bdbenchlab-centralus`).
4. **`arg_perfil_ies`**, luego **`arg_posicionamiento_competitivo`**, con el código de `powerquery/` y los controles de la sección 4.
5. **`arg_rendimiento_y_pertinencia`**: la parte poblacional con el mismo código. T39 queda en CSV y funciona,
   porque cruza por `ID_IES = id_ies`.
6. **Decisiones para producto y para Camilo:**
   - Validar el patrón A. Caracterización se hizo con el B, así que conviene elegir uno solo para los demás.
   - Elegir la definición de "Cantidad de programas": 6.145 títulos o 10.307 ofertas.
7. **Pedidos al equipo de datos:**
   - T39, T37, T38 y M46 (marketing): confirmar si el esquema `digital_marketing` ya trae Argentina
     (consulta 6 de `sql/verificacion_pg.sql`).
   - Cargar a PG M22 Calendario, que hoy se lee de la carpeta de **España**.
   - Regenerar T54 pronósticos con `id_titulo` e `id_ies` de PG y cargarlo a PG.
   - Cargar a PG los rankings (QS ×4, THE ×5, Webometrics, U-Sapiens) con `id_ies`. U-Sapiens y M15 hoy se
     leen de la carpeta de **Colombia**.
   - Columna de texto normalizada en `programas` para el join con keywords.
   - Corregir el separador decimal del cluster 4 (`> 0,7 & <= 0.9`).
8. **Los 5 Live:** pedir acceso XMLA a `benchlabtabularmodels` para extraer el DAX de los 5 catálogos y
   rehacerlos como modelos importados.
9. **Documentación:**
   - Corregir el mapeo `id_universidad → ID_IES` (es `id_ies`) en `ARG_Migracion_M_a_Postgres.md`.
   - Corregir el conteo de `id_ies` en `ARG_Limites_del_Bot.md` y en los `_semantic.md`.
   - Agregar al inventario `arg_oceanos_azules` y el cambio de caracterización al patrón B.

## 6. Hallazgos de las tablas de PG (export del 23/11)

- `periodo` 7 · `universidades` 193 (193/193/193/132) · `universidad_segmento` 772 · `programas` 7.732, sin nulos.
- La llave de `universidad_segmento` es `cluster_ordn` y cruza con `clusters.ordn`.
- `id_rgn` es provincial. Toda la provincia de Buenos Aires está en el 5 y CABA en el 6; el 1 (Bonaerense)
  no lo usa ninguna IES. `id_provincia` ≠ `id_rgn`.
- FLACSO (`id_ies` 219) es la única de régimen `Internacional` y tiene los 4 segmentos en `Otros`.
