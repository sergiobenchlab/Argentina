// M - Universidad: una fila por IES (193), segmentos pivotados por cluster_ordn.
let
    Origen = PostgreSQL.Database("bdbenchlab-centralus.postgres.database.azure.com", "bechlabdatadev"),
    Datos = Value.NativeQuery(Origen,
        "SELECT u.id_ies          AS ""ID_IES"",
                u.nombre_completo AS ""INSTTCN_EDCCN_SPRR"",
                u.id_rgn          AS ""ID_RGN"",
                u.tp_insttcn      AS ""TP_INSTTCN"",
                u.regimen         AS ""SCTR"",
                u.dmn             AS ""DMN"",
                MAX(CASE WHEN s.cluster_ordn = 1 THEN s.valor_segmento END) AS ""SGMNT_1"",
                MAX(CASE WHEN s.cluster_ordn = 2 THEN s.valor_segmento END) AS ""SGMNT_2"",
                MAX(CASE WHEN s.cluster_ordn = 3 THEN s.valor_segmento END) AS ""SGMNT_3"",
                MAX(CASE WHEN s.cluster_ordn = 4 THEN s.valor_segmento END) AS ""SGMNT_4"",
                u.institucion_ciie AS institucion_ciie,
                u.sd               AS ""SD""
         FROM argentina.universidades u
         LEFT JOIN argentina.universidad_segmento s ON s.id_universidad = u.id_universidad
         GROUP BY u.id_ies, u.nombre_completo, u.id_rgn, u.tp_insttcn, u.regimen, u.dmn, u.institucion_ciie, u.sd",
        null, [EnableFolding = true]),
    Renombrar = Table.RenameColumns(Datos, {{"institucion_ciie", "Institución CIIE"}}),
    Tipos = Table.TransformColumnTypes(Renombrar, {{"ID_IES", Int64.Type}, {"ID_RGN", Int64.Type}})
in
    Tipos
