// T - Población (perfil, posicionamiento) / T - Poblacion (rendimiento: mismo código, otro nombre de consulta)
// ID_IES = universidades.id_ies (NO id_universidad): es la llave del modelo viejo y la de KEYWORDS_ORGANICS.
let
    Origen = PostgreSQL.Database("bdbenchlab-centralus.postgres.database.azure.com", "bechlabdatadev"),
    Datos = Value.NativeQuery(Origen,
        "SELECT u.id_ies            AS ""ID_IES"",
                f.id_titulo         AS ""ID_PRGRM"",
                f.id_periodo        AS ""ID_PRD"",
                f.fch_inc_prd       AS ""FCH_INC_PRD"",
                f.nuevos_inscriptos AS ""Nuevos"",
                f.estudiantes       AS ""Matriculado"",
                f.egresados         AS ""Graduado""
         FROM argentina.fact_poblacion f
         JOIN argentina.universidades u ON u.id_universidad = f.id_universidad",
        null, [EnableFolding = true]),
    Tipos = Table.TransformColumnTypes(Datos, {
        {"ID_IES", Int64.Type}, {"ID_PRGRM", Int64.Type}, {"ID_PRD", Int64.Type}, {"FCH_INC_PRD", type date},
        {"Nuevos", Int64.Type}, {"Matriculado", Int64.Type}, {"Graduado", Int64.Type}})
in
    Tipos
