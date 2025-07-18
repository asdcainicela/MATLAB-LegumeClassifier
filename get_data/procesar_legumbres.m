function tabla_total = procesar_legumbres(ruta_carpeta, tipo_legumbre)
    ruta_guardado = ['detection_' tipo_legumbre];

    extensiones = {'*.jpg', '*.jpeg', '*.png'};
    archivos = [];

    for i = 1:length(extensiones)
        archivos = [archivos; dir(fullfile(ruta_carpeta, extensiones{i}))];
    end

    if isempty(archivos)
        error('No se encontraron imágenes en la carpeta: %s', ruta_carpeta);
    end

    tabla_total = [];

    for i = 1:length(archivos)
        archivo = archivos(i);
        ruta_imagen = fullfile(ruta_carpeta, archivo.name);
        fprintf("Procesando: %s\n", archivo.name);

        tabla_individual = procesar_imagen_legumbres(ruta_imagen, ruta_guardado);
        tabla_individual.Imagen = repmat({archivo.name}, height(tabla_individual), 1);
        tabla_individual.Clase = repmat({tipo_legumbre}, height(tabla_individual), 1);

        tabla_total = [tabla_total; tabla_individual];
    end

    tabla_total = tabla_total(:, ...
        ["Clase", "Imagen", "Objeto", "Area", "Perimetro", ...
         "Excentricidad", "Orientacion", "EjeMayor", "EjeMenor", ...
         "CentroideX", "CentroideY"]);

end
