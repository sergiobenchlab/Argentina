// M - Area Conocimiento (perfil, rendimiento) / M - Área de Conocimiento (posicionamiento). 37 filas.
// Disciplina y área salen de PG; el ID entero es el del modelo viejo (mismo diccionario que M - Programa).
let
    Origen = PostgreSQL.Database("bdbenchlab-centralus.postgres.database.azure.com", "bechlabdatadev"),
    Datos = Value.NativeQuery(Origen,
        "SELECT DISTINCT ar_cncmnt AS ""AR_CNCMNT"", dspln AS ""DSPLN"" FROM argentina.programas",
        null, [EnableFolding = true]),
    Ids = #table(type table [DSPLN = text, ID_AR_CNCMNT = Int64.Type], {
        {"Otras Ciencias Sociales", 1}, {"Economía y Administración", 2}, {"Biología", 3}, {"Ingeniería", 4},
        {"Química", 5}, {"Paramédicas y Auxiliares de la Medicina", 6}, {"Informática", 7}, {"Industrias", 8},
        {"Medicina", 9}, {"Relaciones Institucionales y Humanas", 10}, {"Sociología, Antropología y Servicio Social", 11},
        {"Ciencias de la Información y de la Comunicación", 12}, {"Arquitectura y Diseño", 13}, {"Artes", 14},
        {"Educación", 15}, {"Ciencias Políticas, Relaciones Internacionales y Diplomacia", 16}, {"Derecho", 17},
        {"Historia", 18}, {"Odontología", 19}, {"Demografía y Geografía", 20}, {"Arqueología", 21}, {"Física", 22},
        {"Matemáticas", 23}, {"Teología", 24}, {"Veterinaria", 25}, {"Filosofía", 26}, {"Letras e Idiomas", 27},
        {"Ciencias del Suelo", 28}, {"Sin Disciplina", 29}, {"Ciencias Agropecuarias", 30}, {"Estadística", 31},
        {"Psicología", 32}, {"Astronomía", 33}, {"Salud Pública", 34}, {"Sanidad", 35}, {"Bioquímica y Farmacia", 36},
        {"Meteorología", 37}}),
    Unir = Table.NestedJoin(Datos, {"DSPLN"}, Ids, {"DSPLN"}, "id", JoinKind.LeftOuter),
    Expandir = Table.ExpandTableColumn(Unir, "id", {"ID_AR_CNCMNT"}),
    Orden = Table.ReorderColumns(Expandir, {"ID_AR_CNCMNT", "AR_CNCMNT", "DSPLN"})
in
    Orden
