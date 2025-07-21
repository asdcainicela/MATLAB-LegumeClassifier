function tabla_final = clasificar_y_centroides(tabla_datos, modelo)
    % Extraer los descriptores que usará el modelo
    X = tabla_datos{:, {'Area', 'Eccentricity', 'Circularidad', ...
                   'MeanR', 'MeanG', 'MeanB'}};

    % Predecir clases
    clases = predict(modelo, X);

    % Agregar columna de clases a la tabla original
    tabla_datos.Clase = clases;

    % Devolver tabla con clases incluidas
    tabla_final = tabla_datos;
end
