function [datos, x, x_grises, x_bin, mascara_final, etiquetas_filtradas] = procesamiento_img(file_input, area_min, area_max, clase)

    % Leer imagen
    if ischar(file_input) || isstring(file_input)
        x = imread(file_input);
    else
        x = file_input;
    end

    % Conversión a escala de grises y binarización
    x_grises = rgb2gray(x);
    umbral = graythresh(x_grises);
    x_bin = imbinarize(x_grises, umbral);
    x_bin = ~x_bin;
    x_bin = bwareaopen(x_bin, 100);

    % Filtrado por área
    etiquetas = bwlabel(x_bin, 8);
    stats = regionprops(etiquetas, 'Area');
    indices_validos = find([stats.Area] > area_min & [stats.Area] < area_max);
    mascara_area = ismember(etiquetas, indices_validos);
    etiquetas_area = bwlabel(mascara_area, 8);

    % Análisis de propiedades
    stats_filtradas = regionprops(etiquetas_area, 'Area', 'Perimeter', ...
        'Eccentricity', 'Orientation', 'MajorAxisLength', 'MinorAxisLength', ...
        'Centroid');

    R = x(:,:,1); G = x(:,:,2); B = x(:,:,3);
    N = length(stats_filtradas);
    idx = 0;

    tieneClase = exist('clase', 'var');

    % Inicialización dinámica
    temp = repmat(struct( ...
        'Area', [], 'Perimeter', [], 'Eccentricity', [], 'Orientation', [], ...
        'MajorAxisLength', [], 'MinorAxisLength', [], 'CentroidX', [], 'CentroidY', [], ...
        'MeanR', [], 'MeanG', [], 'MeanB', [], 'StdR', [], 'StdG', [], 'StdB', [], ...
        'RelacionAspecto', [], 'Circularidad', [], 'Compacidad', [], 'Etiqueta', [] ...
        ), N, 1);

    if tieneClase
        [temp.Clase] = deal(clase);  % Solo si se pasa clase
    end

    for i = 1:N
        s = stats_filtradas(i);
        obj_mask = etiquetas_area == i;
        circ = 4 * pi * s.Area / (s.Perimeter^2 + eps);

        if circ < 0.05
            continue;
        end

        idx = idx + 1;
        temp(idx).Area = s.Area;
        temp(idx).Perimeter = s.Perimeter;
        temp(idx).Eccentricity = s.Eccentricity;
        temp(idx).Orientation = s.Orientation;
        temp(idx).MajorAxisLength = s.MajorAxisLength;
        temp(idx).MinorAxisLength = s.MinorAxisLength;
        temp(idx).CentroidX = s.Centroid(1);
        temp(idx).CentroidY = s.Centroid(2);
        temp(idx).RelacionAspecto = s.MajorAxisLength / s.MinorAxisLength;
        temp(idx).Circularidad = circ;
        temp(idx).Compacidad = (s.Perimeter^2) / (s.Area + eps);
        temp(idx).Etiqueta = i;

        r_vals = double(R(obj_mask)); g_vals = double(G(obj_mask)); b_vals = double(B(obj_mask));
        temp(idx).MeanR = mean(r_vals);  temp(idx).StdR = std(r_vals);
        temp(idx).MeanG = mean(g_vals);  temp(idx).StdG = std(g_vals);
        temp(idx).MeanB = mean(b_vals);  temp(idx).StdB = std(b_vals);
    end

    if idx > 0
        datos = struct2table(temp(1:idx));
    else
        datos = table();
    end

    % Salida extra
    etiquetas_validas = [temp(1:idx).Etiqueta];
    mascara_final = ismember(etiquetas_area, etiquetas_validas);
    etiquetas_filtradas = bwlabel(mascara_final, 8);
end
