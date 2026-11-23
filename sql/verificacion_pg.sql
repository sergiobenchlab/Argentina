-- Verificación de argentina.* antes y después de repuntar cada tablero.
-- Correr en bechlabdatadev (host bdbenchlab-centralus.postgres.database.azure.com).

-- 1. Controles anuales del hecho. Esperado 2023: 760.051 / 2.746.768 / 160.117 / 178 IES / 6.145 titulaciones.
SELECT p.anio,
       SUM(f.nuevos_inscriptos)         AS ingresantes,
       SUM(f.estudiantes)               AS estudiantes,
       SUM(f.egresados)                 AS egresados,
       COUNT(DISTINCT f.id_universidad) AS ies_con_datos,
       COUNT(DISTINCT f.id_titulo)      AS titulaciones,
       COUNT(*)                         AS filas
FROM argentina.fact_poblacion f
JOIN argentina.periodo p ON f.id_periodo = p.id_prd
GROUP BY ROLLUP (p.anio) ORDER BY p.anio;        -- la fila NULL es el total: esperado 66.907 filas

-- 2. Llaves huérfanas del hecho (todas deben dar 0).
SELECT 'universidad' AS dim, COUNT(*) FROM argentina.fact_poblacion f
  LEFT JOIN argentina.universidades u ON u.id_universidad = f.id_universidad WHERE u.id_universidad IS NULL
UNION ALL
SELECT 'titulo', COUNT(*) FROM argentina.fact_poblacion f
  LEFT JOIN argentina.programas p ON p.id_titulo = f.id_titulo WHERE p.id_titulo IS NULL
UNION ALL
SELECT 'periodo', COUNT(*) FROM argentina.fact_poblacion f
  LEFT JOIN argentina.periodo p ON p.id_prd = f.id_periodo WHERE p.id_prd IS NULL;

-- 3. Grano del hecho: no debe haber duplicados (Católica Argentina ya consolidada).
SELECT id_universidad, id_titulo, id_periodo, COUNT(*)
FROM argentina.fact_poblacion GROUP BY 1,2,3 HAVING COUNT(*) > 1;

-- 4. Llave institucional. Esperado: 193 / 193 / 193 / 132 (confirmado con el export del 23/11).
SELECT COUNT(*), COUNT(DISTINCT id_universidad), COUNT(DISTINCT id_ies), COUNT(DISTINCT nombre_completo)
FROM argentina.universidades;

-- 5. Segmentos: 772 filas, 4 por universidad, y la llave contra clusters.
SELECT COUNT(*) AS filas, COUNT(DISTINCT id_universidad) AS ies,
       COUNT(*) FILTER (WHERE c.ordn IS NULL) AS sin_cluster
FROM argentina.universidad_segmento s
LEFT JOIN argentina.clusters c ON c.ordn = s.cluster_ordn;

-- 6. ¿digital_marketing ya trae Argentina? (decide marketing, edutrends y mercados adyacentes)
SELECT table_name, column_name FROM information_schema.columns
WHERE table_schema = 'digital_marketing' AND column_name ILIKE ANY (ARRAY['%pais%','%country%'])
ORDER BY 1;
