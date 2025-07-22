clc; clear; close all;
addpath("../functions/procesamiento")
addpath("../functions/utils")

alverjita_verde_partida = true;
garbanzo = false;
frejol_canario = false;
frejol_rojo = false;

if alverjita_verde_partida
    % procesa, y guarda en csv
    procesar_carpeta_legumbres('data_alverjita_verde_partida', 'alverjita', 0.2, 0.9);
end

if garbanzo
    procesar_carpeta_legumbres('data_garbanzo', 'garbanzo', 0.4, 2, 0.05);
end

if frejol_canario
    umbral = struct( ...
        'archivo', {'img1.jpg', 'img2.jpg', 'img3.jpg', 'img4.jpg', 'img5.jpg', ...
                    'img6.jpg', 'img7.jpg', 'img8.jpg', 'img9.jpg', 'img10.jpg'}, ...
        'valor',   { 0.65,      0.705,     0.55,      0.7,       0.7, ...
                    0.7,       0.64,      0.64,      0.64,      0.64 } ...
    );

    procesar_carpeta_legumbres('data_frejol_canario', 'frejol_canario', ...
         0.3, 1.5, 0, umbral);
end
if frejol_rojo
    procesar_carpeta_legumbres('data_frejol_rojo', 'frejol_rojo', ...
        00.5, 2.5);
end
