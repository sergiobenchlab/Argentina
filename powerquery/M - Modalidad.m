// M - Modalidad. Embebida (3 filas, igual al M07). PG dice "A Distancia"; M - Programa la mapea al ID 2.
let
    Fuente = #table(type table [ID_MDLDD = Int64.Type, MDLDD = text], {
        {0, "No Asignado"}, {1, "Presencial"}, {2, "Distancia"}})
in
    Fuente
