function [img_etiquetada, resumen_clases, tabla_final] = analizar_legumbres(tabla_final, img_data, name)
    % ANALIZAR_LEGUMBRES: Etiqueta objetos con bounding boxes por clase,
    % devuelve imagen, tabla resumen por clase y tabla con IDs.
    if nargin < 3
        name = '';  % Valor por defecto si no se pasa el argumento
    end
    
    % Verificar columna de clase
    if ~ismember('Clase', tabla_final.Properties.VariableNames)
        error('La tabla no contiene la columna "Clase".');
    end

    % Verificar centroides válidos
    if all(ismember({'CentroidX', 'CentroidY'}, tabla_final.Properties.VariableNames))
        cx_all = tabla_final.CentroidX;
        cy_all = tabla_final.CentroidY;
    elseif all(ismember({'Centroid_X_px', 'Centroid_Y_px'}, tabla_final.Properties.VariableNames))
        cx_all = tabla_final.Centroid_X_px;
        cy_all = tabla_final.Centroid_Y_px;
    else
        error('La tabla no contiene columnas de centroides reconocidas.');
    end

    % Verificar bounding box
    if ~ismember('BoundingBox', tabla_final.Properties.VariableNames)
        error('La tabla no contiene la columna "BoundingBox".');
    end

    % Generar IDs por clase
    tabla_final.ID = zeros(height(tabla_final), 1);
    clases_unicas = unique(tabla_final.Clase);
    for c = 1:length(clases_unicas)
        clase_actual = clases_unicas{c};
        idx = strcmp(tabla_final.Clase, clase_actual);
        tabla_final.ID(idx) = 1:sum(idx);
    end

    % Asignar color por clase
    color_map = lines(numel(clases_unicas));  % Paleta de colores

    % Inicializar imagen
    img_etiquetada = img_data;

    % Dibujar bounding boxes y etiquetas
    for i = 1:height(tabla_final)
        box = tabla_final.BoundingBox(i, :);
        clase = tabla_final.Clase{i};
        id_local = tabla_final.ID(i);
        etiqueta = sprintf('%d, %s', id_local, clase);

        % Color por clase
        clase_idx = find(strcmp(clases_unicas, clase));
        color_rgb = color_map(clase_idx, :) * 255;
        color_str = uint8(color_rgb);

        % Insertar rectángulo
        img_etiquetada = insertShape(img_etiquetada, 'Rectangle', box, ...
            'Color', color_str, 'LineWidth', 8);

        % Insertar etiqueta
        pos_text = [box(1), box(2) - 30];
        img_etiquetada = insertText(img_etiquetada, pos_text, etiqueta, ...
            'FontSize', 22, 'BoxColor', 'black', ...
            'TextColor', 'yellow', 'BoxOpacity', 1);
    end

    % Guardar imagen
    %imwrite(img_etiquetada, 'imagen_etiquetada.png');
    %fprintf('[OK] Imagen etiquetada con colores por clase guardada.\n');

    % Resumen por clase
    resumen_clases = groupsummary(tabla_final, 'Clase');
    resumen_clases.Properties.VariableNames{'GroupCount'} = 'Cantidad';
    disp('[Resumen de clases detectadas:]');
    disp(resumen_clases);

    % Guardar imagen si se pasó 'name'
    if ~isempty(name)
        folder_out = fullfile('results');
        if ~exist(folder_out, 'dir')
            mkdir(folder_out);
        end
        path_out = fullfile(folder_out, [name '.png']);
        imwrite(img_etiquetada, path_out);
        fprintf('[OK] Imagen etiquetada guardada en: %s\n', path_out);
    end
end
