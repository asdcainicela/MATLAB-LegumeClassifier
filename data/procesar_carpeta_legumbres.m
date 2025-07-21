function procesar_carpeta_legumbres(carpeta, clase, area_min, area_max, circ_min, umbral)
    % Buscar imágenes en la carpeta (varios formatos)
    archivos = [dir(fullfile(carpeta, '*.jpeg')), dir(fullfile(carpeta, '*.JPEG')), ...
                dir(fullfile(carpeta, '*.jpg')),  dir(fullfile(carpeta, '*.JPG')), ...
                dir(fullfile(carpeta, '*.png')),  dir(fullfile(carpeta, '*.PNG'))];

    % Crear carpeta de salida
    output_folder = ['output_data_' carpeta];
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end

    % Inicializar tabla acumulativa
    datos_totales = table();

    % Determinar si se pasaron parámetros opcionales
    usar_circ = exist('circ_min', 'var') && ~isempty(circ_min);
    usar_umbral = exist('umbral', 'var') && ~isempty(umbral);

    for k = 1:length(archivos)
        archivo = archivos(k).name;
        ruta = fullfile(carpeta, archivo);
        fprintf('Procesando: %s\n', archivo);

        try
            % --- Determinar umbral dinámico por imagen ---
            usar_umbral_local = false;

            if usar_umbral
                if isstruct(umbral)
                    if isfield(umbral, 'archivo') && isfield(umbral, 'valor')
                        idx = find(strcmp(archivo, {umbral.archivo}), 1);
                        if ~isempty(idx)
                            umbral_actual = umbral(idx).valor;  % ← CORREGIDO AQUÍ
                            disp(umbral_actual)
                            usar_umbral_local = true;
                        end
                    end
                elseif isnumeric(umbral)
                    umbral_actual = umbral;
                    usar_umbral_local = true;
                end
            end


            % ---- Llamada dinámica a procesamiento_img con argumentos válidos ----

            % Llamar a la función con los argumentos dinámicos
            if usar_circ 
                if usar_umbral_local
                [datos, x] = procesamiento_img(ruta, area_min, area_max, clase, circ_min, umbral_actual);
                else
                [datos, x] = procesamiento_img(ruta, area_min, area_max, clase, circ_min);
                end
            else   
                [datos, x] = procesamiento_img(ruta, area_min, area_max, clase);
            end
 

            % Añadir nombre de imagen
            datos.NombreImagen = repmat({archivo}, height(datos), 1);
            datos_totales = [datos_totales; datos];

            % Mostrar y marcar objetos
            imshow(x); hold on;
            for i = 1:height(datos)
                cx = datos.CentroidX(i);
                cy = datos.CentroidY(i);
                plot(cx, cy, 'r*');
                text(cx + 10, cy, sprintf('%d', i), ...
                    'Color', 'black', 'FontSize', 8, 'FontWeight', 'bold');
            end

            % Guardar imagen anotada
            nombre_salida = fullfile(output_folder, sprintf('proc_%s', archivo));
            frame = getframe(gca);
            imwrite(frame.cdata, nombre_salida);
            close;

        catch ME
            warning('️ Error procesando %s: %s', archivo, ME.message);
        end
    end

    % Guardar CSV con todos los datos
    save_datacsv(datos_totales, ['data_' carpeta '.csv']);
end
