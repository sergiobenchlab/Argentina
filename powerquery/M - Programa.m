// M - Programa (perfil, posicionamiento, rendimiento). Grano: título de argentina.programas (7.732).
// Se conservan las llaves ENTERAS del modelo viejo (ID_AR_CNCMNT 1-37, ID_NVL_FRMCN 1-14, ID_MDLDD 0-2),
// así que no hay que tocar ninguna relación. ID_IES e ID_RGN no existen a nivel título: quedan en null
// (solo los usaba la relación inactiva M - Programa[ID_IES] -> M - Universidad, que ninguna medida usa).
// En arg_rendimiento_y_pertinencia descomentar el paso "Copia" (ese modelo tiene "PRGRM_ACDMC - Copia").
let
    Origen = PostgreSQL.Database("bdbenchlab-centralus.postgres.database.azure.com", "bechlabdatadev"),
    Datos = Value.NativeQuery(Origen,
        "SELECT id_titulo, profesion, titulo, area, dspln, tipo_titulo, modalidad FROM argentina.programas",
        null, [EnableFolding = true]),
    IdArea = [
        #"Otras Ciencias Sociales" = 1, #"Economía y Administración" = 2, #"Biología" = 3, #"Ingeniería" = 4,
        #"Química" = 5, #"Paramédicas y Auxiliares de la Medicina" = 6, #"Informática" = 7, #"Industrias" = 8,
        #"Medicina" = 9, #"Relaciones Institucionales y Humanas" = 10, #"Sociología, Antropología y Servicio Social" = 11,
        #"Ciencias de la Información y de la Comunicación" = 12, #"Arquitectura y Diseño" = 13, #"Artes" = 14,
        #"Educación" = 15, #"Ciencias Políticas, Relaciones Internacionales y Diplomacia" = 16, #"Derecho" = 17,
        #"Historia" = 18, #"Odontología" = 19, #"Demografía y Geografía" = 20, #"Arqueología" = 21, #"Física" = 22,
        #"Matemáticas" = 23, #"Teología" = 24, #"Veterinaria" = 25, #"Filosofía" = 26, #"Letras e Idiomas" = 27,
        #"Ciencias del Suelo" = 28, #"Sin Disciplina" = 29, #"Ciencias Agropecuarias" = 30, #"Estadística" = 31,
        #"Psicología" = 32, #"Astronomía" = 33, #"Salud Pública" = 34, #"Sanidad" = 35, #"Bioquímica y Farmacia" = 36,
        #"Meteorología" = 37],
    IdNivel = [
        #"Otros Pregrados" = 1, #"Grado" = 2, #"Especialización" = 3, #"Ciclo de Complementación Curricular" = 4,
        #"Maestría" = 5, #"Ciclo de Licenciatura" = 6, #"Doctorado" = 7, #"Título Intermedio" = 8,
        #"Técnico Instrumental" = 9, #"Ciclo Básico Común" = 10, #"Postítulo" = 11, #"Ciclo de Profesorado" = 12,
        #"Ciclo de Traductorado" = 13, #"Ciclo Superior" = 14],
    IdModalidad = [#"Presencial" = 1, #"A Distancia" = 2, #"Distancia" = 2],
    Llaves = Table.AddColumn(Datos, "tmp", each [
        ID_AR_CNCMNT = Record.FieldOrDefault(IdArea, [dspln], 29),
        ID_NVL_FRMCN = Record.FieldOrDefault(IdNivel, [tipo_titulo], null),
        ID_MDLDD     = Record.FieldOrDefault(IdModalidad, [modalidad], 0)]),
    Expandir = Table.ExpandRecordColumn(Llaves, "tmp", {"ID_AR_CNCMNT", "ID_NVL_FRMCN", "ID_MDLDD"}),
    Columnas = Table.SelectColumns(Expandir, {"id_titulo", "profesion", "ID_AR_CNCMNT", "ID_NVL_FRMCN", "ID_MDLDD", "titulo", "area"}),
    Renombrar = Table.RenameColumns(Columnas, {
        {"id_titulo", "ID_PRGRM"}, {"profesion", "PRGRM_ACDMC"}, {"titulo", "TTL_ACDMC"}}),
    Area = Table.TransformColumns(Renombrar, {{"area", Text.Upper, type text}}),
    AreaNombre = Table.RenameColumns(Area, {{"area", "AREA"}}),
    Nulos = Table.AddColumn(Table.AddColumn(AreaNombre, "ID_RGN", each null, Int64.Type), "ID_IES", each null, Int64.Type),
    // Copia = Table.DuplicateColumn(Nulos, "PRGRM_ACDMC", "PRGRM_ACDMC - Copia"),
    Orden = Table.ReorderColumns(Nulos, {"ID_PRGRM", "PRGRM_ACDMC", "ID_AR_CNCMNT", "ID_NVL_FRMCN", "ID_MDLDD", "ID_RGN", "TTL_ACDMC", "AREA", "ID_IES"}),
    Tipos = Table.TransformColumnTypes(Orden, {
        {"ID_PRGRM", Int64.Type}, {"ID_AR_CNCMNT", Int64.Type}, {"ID_NVL_FRMCN", Int64.Type}, {"ID_MDLDD", Int64.Type}})
in
    Tipos
