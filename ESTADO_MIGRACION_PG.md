# Migración de los tableros de Argentina a PostgreSQL: estado al 23/11/2026

Fuentes: `CONTEXTO_ARG_POSTGRES.md` (consolidado al 14/09) y los exports de PG del 23/11 10:28
(`universidades`, `universidad_segmento`, `programas`, `periodo`). Faltan en el export:
`fact_poblacion` y `clusters`, por eso los controles del hecho todavía no están verificados.

## 1. Qué confirma el export del 23/11

| Tabla PG | Filas | Resultado frente al plan del 14/09 |
|---|---:|---|
| `periodo` | 7 | ✅ 2017–2023. Trae `fch_inc_prd`, `anio_anterior`, `fch_inc_prd_anio_anterior`, `periodo_label`. No trae `SMSTR`, `PRD`, `PRD_AN_ANTRR`: se siguen generando en Power Query |
| `universidades` | 193 | ✅ 193 / 193 / 193 / 132 (`id_universidad` / `id_ies` / `concat_ies` / `nombre_completo`). Cero nulos. Vale la verificación del 14/09; **Límites del Bot sigue mal** |
| `universidad_segmento` | 772 | ✅ 4 filas por cada una de las 193 IES, sin huérfanos. ⚠️ La llave es `cluster_ordn` (1–4), **no `tbl_clstr`**: el join a `clusters` tiene que ser por `cluster_ordn` |
| `programas` | 7.732 | ✅ 37 disciplinas, cada una con una sola área (`M - Area Conocimiento` = 37 filas). Cero nulos |

Hallazgos nuevos que afectan las consultas M:

1. **Modalidad:** PG trae solo `Presencial` (6.858) y `A Distancia` (874). Confirmado: el CSV viejo dice `Distancia`, hay que mapear o el slicer pierde la opción.
2. **Nivel:** `nivel` tiene 3 valores (Pregrado 2.039, Grado 2.543, Posgrado 3.150) y `tipo_titulo` 14. Coincide con las 14 filas de la tabla embebida. `Postítulo` (5 títulos) **queda como Grado** en PG; si el diccionario lo pone en Posgrado, la tabla embebida tiene que seguir a PG para no romper `es_posgrado`.
3. **Región:** `id_rgn` es en realidad provincial (24 valores, 2–25). Toda la provincia de Buenos Aires está en `id_rgn = 5` (Metropolitana) y CABA en 6. **El ID 1 (Bonaerense) no lo usa ninguna IES.** La tabla embebida de 26 filas (0 + 1 + 24) funciona, pero `Bonaerense` va a aparecer vacío en los slicers.
4. **`id_provincia` ≠ `id_rgn`** (CABA: provincia 5, región 6). No usar `id_provincia` como llave a `M - Región`.
5. **Nombres de provincia** en PG: `Santa Fé`, `Ciudad Autonoma de Buenos Aires` (sin tilde). La tabla embebida tiene que escribirlos igual si se cruza por texto.
6. **`id_universidad = 180` (FLACSO, régimen `Internacional`)** tiene los 4 segmentos en `Otros`. Es la única con régimen distinto de Estatal/Privado: revisar que los filtros de `SCTR` la contemplen.
7. **Calidad de dato en el cluster 4:** `> 0,7 & <= 0.9` mezcla coma y punto decimal. Hay que avisar al ETL; mientras tanto, el orden del slicer puede quedar raro.

## 2. Estado por tablero

Sin cambios respecto del 14/09 hasta que se abran los `.pbix` (no hay evidencia de que la sección 4 se haya aplicado).

| Bloque | Tableros | Estado | Bloqueado por |
|---|---|:---:|---|
| Ya en PG | `arg_registro_calificado`, `arg_oferta_laboral` | ✅ | Nada |
| Repunte parcial | `arg_poblaciones` (banderas), `arg_rendimiento_y_pertinencia` (parte poblacional) | 🟡 | Nada: se puede hacer ya |
| Listos para migrar (patrón A) | `arg_caracterizacion_ies`, `arg_perfil_ies`, `arg_posicionamiento_competitivo` | 🔴→🟢 | Aplicar el M en Power BI Desktop (Windows) |
| Depende de `digital_marketing` | `arg_marketing`, `arg_mercados_adyacentes`, `arg_edutrends` | 🟡/🔴 | Correr la consulta 6 de `sql/verificacion_pg.sql`; host mal escrito en `arg_marketing` |
| Datos que no están en PG | `arg_proyecciones` (T54), `arg_rankings` (QS, THE, Webometrics, U-Sapiens) | 🔴 | Equipo de datos |
| Azure Analysis Services | `arg_general`, `arg_cuota_mercado`, `arg_apertura_programa`, `arg_nuevo_mercado`, `arg_portafolio` | 🔴 | Extraer el DAX vía XMLA |

Resumen: **2 de 17 al 100 %**. Con lo que ya hay en PG se pueden cerrar **5 más** (los 3 comparativos + poblaciones + rendimiento) sin esperar a nadie. Los otros 10 dependen de terceros.

## 3. Pasos a seguir

**Paso 0, hoy (30 min).**
1. Correr `sql/verificacion_pg.sql` completo. Si las consultas 1–3 dan lo esperado, el hecho está listo. Si la 5 falla porque `clusters` no tiene `cluster_ordn`, pasar el `\d argentina.clusters`.
2. Abrir cada `.pbix` y anotar en `Transformar datos → Configuración del origen` qué lee cada consulta. Así se sabe si algo de la sección 4 ya se aplicó.
3. Respaldar cada `.pbix` en `_NO_USADOS_APLICATIVO_BENCHLAB/` con el sufijo `_pre_postgres`.

**Paso 1: ajustar el M de la sección 4 a los hallazgos del punto 1** (antes de pegarlo):
- `M - Universidad`: pivotar `universidad_segmento` por `cluster_ordn` y traer el nombre desde `clusters` por `cluster_ordn`.
- `M - Modalidad`: `A Distancia → Distancia` en Power Query (patrón A: se conservan los valores del modelo viejo) + centinela `No Asignado`.
- `M - Región` y `M - Nivel Formación`: revisar que la tabla embebida use los textos de PG (Santa Fé, Postítulo = Grado).
- `M - Periodo`: `SMSTR = 1`, `PRD = codigo_periodo`, `PRD_AN_ANTRR = periodo_anio_anterior`.

**Paso 2: los 3 comparativos, en este orden**, comparando con los controles 2023 antes y después:
`arg_caracterizacion_ies` (7 medidas) → `arg_perfil_ies` (33; `M - Status` queda en CSV) → `arg_posicionamiento_competitivo` (40; banderas a `population.m_banderas_m`).
Relaciones Programa→Área/Nivel/Modalidad pasan a texto; `FCH_INC_PRD` sigue inactiva.

**Paso 3:** `arg_poblaciones` (solo banderas) y `arg_rendimiento_y_pertinencia` (parte poblacional, mismo patrón).

**Paso 4:** corregir el host de `arg_marketing` (`bdbenlabdatadev` → `bdbenchlab-centralus`) y, según la consulta 6, decidir marketing, mercados adyacentes y edutrends.

**Paso 5 (en paralelo, pedidos a terceros):**
- Camilo: validar el patrón A. Es lo único que bloquea el paso 2 en lo formal.
- Datos: T54, rankings, M04 Status, M22, `NVL_FRMCN_2`, y corregir el separador decimal del cluster 4.
- ETL: columna normalizada en `programas` para el join con KEYWORDS_ORGANICS.
- Producto: llave `labor_market` ↔ `argentina`.
- Azure: acceso XMLA para extraer el DAX de los 5 tableros Live.

**Documentación:** corregir `ARG_Limites_del_Bot.md` y los `_semantic.md` (`id_ies` = 193, no ≈ 130) y agregar los hallazgos 3, 4 y 6.
