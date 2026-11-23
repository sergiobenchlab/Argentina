// M - Universidad (2): formato largo, 772 filas (193 IES x 4 clusters). Atributo = clusters.tbl_clstr (SGMNT_n).
let
    Origen = PostgreSQL.Database("bdbenchlab-centralus.postgres.database.azure.com", "bechlabdatadev"),
    Datos = Value.NativeQuery(Origen,
        "SELECT u.id_ies           AS ""ID_IES"",
                u.nombre_completo  AS ""INSTTCN_EDCCN_SPRR"",
                u.id_rgn           AS ""ID_RGN"",
                u.tp_insttcn       AS ""TP_INSTTCN"",
                u.regimen          AS ""SCTR"",
                u.dmn              AS ""DMN"",
                UPPER(c.tbl_clstr) AS ""Atributo"",
                s.valor_segmento   AS ""Valor"",
                u.institucion_ciie AS institucion_ciie,
                u.sd               AS ""SD""
         FROM argentina.universidad_segmento s
         JOIN argentina.universidades u ON u.id_universidad = s.id_universidad
         JOIN argentina.clusters c      ON c.ordn = s.cluster_ordn",
        null, [EnableFolding = true]),
    Renombrar = Table.RenameColumns(Datos, {{"institucion_ciie", "Institución CIIE"}}),
    Tipos = Table.TransformColumnTypes(Renombrar, {{"ID_IES", Int64.Type}, {"ID_RGN", Int64.Type}})
in
    Tipos
