// M - Región (perfil, posicionamiento, rendimiento). Embebida: 26 filas, copia exacta del M03 en uso.
// Se conservan los textos viejos (Cordoba, Santa Fe, Ciudad Autónoma...) porque alimentan los mapas
// (columna calculada Ubicación / PRVNC_). universidades.id_rgn coincide 193/193 con estos ID.
// ID 1 (Bonaerense) no lo usa ninguna IES.
let
    Fuente = #table(type table [ID_RGN = Int64.Type, RGN = text, PRVNC = text, PS = text], {
        {0, "No Asignado", "No Asignado", "Argentina"},
        {1, "Bonaerense", "Buenos Aires", "Argentina"},
        {2, "Centro", "Cordoba", "Argentina"},
        {3, "Centro", "Entre Rios", "Argentina"},
        {4, "Centro", "Santa Fe", "Argentina"},
        {5, "Metropolitana", "Buenos Aires", "Argentina"},
        {6, "Metropolitana", "Ciudad Autónoma de Buenos Aires", "Argentina"},
        {7, "Noreste", "Chaco", "Argentina"},
        {8, "Noreste", "Corrientes", "Argentina"},
        {9, "Noreste", "Formosa", "Argentina"},
        {10, "Noreste", "Misiones", "Argentina"},
        {11, "Noroeste", "Catamarca", "Argentina"},
        {12, "Noroeste", "Jujuy", "Argentina"},
        {13, "Noroeste", "Salta", "Argentina"},
        {14, "Noroeste", "Santiago Del Estero", "Argentina"},
        {15, "Noroeste", "Tucuman", "Argentina"},
        {16, "Nuevo Cuyo", "La Rioja", "Argentina"},
        {17, "Nuevo Cuyo", "Mendoza", "Argentina"},
        {18, "Nuevo Cuyo", "San Juan", "Argentina"},
        {19, "Nuevo Cuyo", "San Luis", "Argentina"},
        {20, "Sur", "Chubut", "Argentina"},
        {21, "Sur", "La Pampa", "Argentina"},
        {22, "Sur", "Neuquen", "Argentina"},
        {23, "Sur", "Rio Negro", "Argentina"},
        {24, "Sur", "Santa Cruz", "Argentina"},
        {25, "Sur", "Tierra Del Fuego", "Argentina"}})
in
    Fuente
