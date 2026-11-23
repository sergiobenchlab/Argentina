let
    Origen = PostgreSQL.Database("bdbenchlab-centralus.postgres.database.azure.com", "bechlabdatadev"),
    Datos = Value.NativeQuery(Origen,
        "SELECT nmbr_clstr AS ""Nmbr_Clstr"", ordn AS ""Ordn"", tbl_clstr AS ""Tbl_clstr"" FROM argentina.clusters",
        null, [EnableFolding = true]),
    Tipos = Table.TransformColumnTypes(Datos, {{"Ordn", Int64.Type}})
in
    Tipos
