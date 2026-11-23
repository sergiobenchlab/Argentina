// M - Nivel Formación. Tabla embebida (14 filas, copia exacta del M08 en uso).
// NVL_FRMCN coincide 1:1 con argentina.programas.tipo_titulo y NVL_ACDMC con programas.nivel
// (Postítulo = Grado en los dos). NVL_FRMCN_2 no está en PG: por eso sigue embebida.
let
    Fuente = #table(
        type table [NVL_ACDMC = text, ID_NVL_FRMCN = Int64.Type, NVL_FRMCN = text, NVL_FRMCN_2 = text], {
        {"Pregrado", 1, "Otros Pregrados", "Tecnicaturas"},
        {"Grado", 2, "Grado", "Licenciatura"},
        {"Posgrado", 3, "Especialización", "Especialidad Y Otros Grados"},
        {"Grado", 4, "Ciclo de Complementación Curricular", "Ciclo"},
        {"Posgrado", 5, "Maestría", "Maestría"},
        {"Grado", 6, "Ciclo de Licenciatura", "Ciclo"},
        {"Posgrado", 7, "Doctorado", "Doctorado"},
        {"Pregrado", 8, "Título Intermedio", "Títulos Intermedios"},
        {"Pregrado", 9, "Técnico Instrumental", "Tecnicaturas"},
        {"Grado", 10, "Ciclo Básico Común", "Ciclo"},
        {"Grado", 11, "Postítulo", "Títulos Intermedios"},
        {"Grado", 12, "Ciclo de Profesorado", "Ciclo"},
        {"Grado", 13, "Ciclo de Traductorado", "Ciclo"},
        {"Grado", 14, "Ciclo Superior", "Ciclo"}})
in
    Fuente
