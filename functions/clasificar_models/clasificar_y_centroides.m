function tabla_final = clasificar_y_centroides(tabla_datos, modelo, ruta_caract)
    % CLASIFICAR_Y_CENTROIDES: Clasifica y agrega la columna 'Clase'
    % tabla_datos: tabla con características
    % modelo: modelo de clasificación
    % ruta_caract (opcional): ruta al archivo .mat con variable 'caracteristicas'

    if nargin < 3 || isempty(ruta_caract)
        ruta_caract = 'train/models/caracteristicas.mat';  % Ruta por defecto
    end

    % Cargar características
    load(ruta_caract, 'caracteristicas');

    % Extraer los descriptores que usará el modelo
    X = tabla_datos{:, caracteristicas};

    % Predecir clases
    clases = predict(modelo, X);

    % Agregar columna de clases a la tabla original
    tabla_datos.Clase = clases;

    % Devolver tabla con clases incluidas
    tabla_final = tabla_datos;
end
