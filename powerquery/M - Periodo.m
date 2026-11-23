// M - Periodo: 7 filas (2017-2023) desde argentina.periodo.
// El modelo viejo cargaba cada año como semestre 2 (ID_PRD 56 = "2023-2"); se replican esos textos
// para que los slicers se vean igual. ID_PRD pasa a ser el año (2023), igual que en el hecho.
let
    Origen = PostgreSQL.Database("bdbenchlab-centralus.postgres.database.azure.com", "bechlabdatadev"),
    Datos = Value.NativeQuery(Origen,
        "SELECT id_prd                       AS ""ID_PRD"",
                anio * 10 + 2                AS ""CDG_PRD"",
                anio * 10 + 2                AS ""PRD"",
                anio_anterior * 10 + 2       AS ""PRD_AN_ANTRR"",
                2                            AS ""SMSTR"",
                anio                         AS ""AN"",
                anio_anterior                AS ""AN_ANTRR"",
                fch_inc_prd                  AS ""FCH_INC_PRD"",
                fch_inc_prd_anio_anterior    AS ""FCH_INC_PRD_AN_ANTRR"",
                anio::text || '-2'           AS ""PRD_G""
         FROM argentina.periodo",
        null, [EnableFolding = true]),
    Tipos = Table.TransformColumnTypes(Datos, {
        {"ID_PRD", Int64.Type}, {"CDG_PRD", Int64.Type}, {"PRD", Int64.Type}, {"PRD_AN_ANTRR", Int64.Type},
        {"SMSTR", Int64.Type}, {"AN", Int64.Type}, {"AN_ANTRR", Int64.Type},
        {"FCH_INC_PRD", type date}, {"FCH_INC_PRD_AN_ANTRR", type date}})
in
    Tipos
