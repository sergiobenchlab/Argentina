// M - Status (perfil). No tiene relaciones ni la usa ninguna medida: se embebe para cortar el CSV.
let
    Fuente = #table(type table [ID_STTS = Int64.Type, STTS = text], {
        {0, "NO ASIGNADO"}, {1, "INSCRITOS"}, {2, "ADMITIDOS"}, {3, "NUEVOS"}, {4, "MATRICULADO"},
        {5, "GRADUADO"}, {6, "ANTIGUOS"}, {7, "OFERTA"}, {8, "TITULADOS"}})
in
    Fuente
