// M_BANDERAS_M (poblaciones, posicionamiento). Mismas 96 filas que el Excel de Multipais.
// En arg_marketing la consulta se llama "M - Banderas" y además hay que corregir el host (bdbenlabdatadev -> bdbenchlab-centralus).
let
    Origen = PostgreSQL.Database("bdbenchlab-centralus.postgres.database.azure.com", "bechlabdatadev"),
    Datos = Value.NativeQuery(Origen,
        "SELECT cdg_ps AS ""CDG_PS"", ps AS ""PS"", bandera AS ""Bandera"", id_pais FROM population.m_banderas_m",
        null, [EnableFolding = true]),
    Tipos = Table.TransformColumnTypes(Datos, {{"id_pais", Int64.Type}})
in
    Tipos
