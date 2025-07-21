function [datos, x, x_grises, x_bin, mascara_final, etiquetas_filtradas] = procesamiento_img(file_input, area_min, area_max, clase, circ_min, umbral)
    
    if ~exist('circ_min', 'var') || isempty(circ_min)
        circ_min = 0.0;
    end

    usar_umbral_manual = exist('umbral', 'var') && ~isempty(umbral) && isnumeric(umbral);

    % Leer imagen
    if ischar(file_input) || isstring(file_input)
        x = imread(file_input);
    else
        x = file_input;
    end

     % Calcular factor de escala basado en A5
    [alto_img, ancho_img, ~] = size(x);
    cm_ancho = 21.0; %14.8;  % Tamaño A5 horizontal
    cm_alto  = 14.8;%21.0;  % Tamaño A5 vertical
    factor_px_a_cm = mean([cm_ancho / ancho_img, cm_alto / alto_img]);

    fprintf('[INFO] Factor de escala estimado: %.4f cm/px\n', factor_px_a_cm);


    % Escala de grises
    x_grises = rgb2gray(x);

    % Binarización
    if usar_umbral_manual
        fprintf('[INFO] Umbral manual usado: %.3f\n', umbral);
        x_bin = imbinarize(x_grises, umbral);
    else
        umbral_auto = graythresh(x_grises);
        fprintf('[INFO] Umbral automático usado (graythresh): %.3f\n', umbral_auto);
        %x_bin = imbinarize(x_grises, umbral_auto);
        x_bin  = imbinarize(x_grises, 'adaptive', 'ForegroundPolarity', 'dark', 'Sensitivity', 0.5);
    end

    % Invertir y eliminar ruido pequeño
    x_bin = ~x_bin;
    x_bin = bwareaopen(x_bin, 100);

    % Filtrado por área
    etiquetas = bwlabel(x_bin, 8);
    stats = regionprops(etiquetas, 'Area');
    todas_areas = [stats.Area];

    fprintf('\n[INFO] Áreas detectadas: %s\n', num2str(todas_areas));
    indices_validos = find(todas_areas > area_min/(factor_px_a_cm*factor_px_a_cm) & todas_areas < area_max/(factor_px_a_cm*factor_px_a_cm));
    disp(area_min/factor_px_a_cm)
    disp(area_max/factor_px_a_cm)

    fprintf('[INFO] Regiones válidas por área: %d de %d\n', numel(indices_validos), numel(todas_areas));

    mascara_area = ismember(etiquetas, indices_validos);
    etiquetas_area = bwlabel(mascara_area, 8);

    % Propiedades geométricas
    stats_filtradas = regionprops(etiquetas_area, 'Area', 'Perimeter', ...
        'Eccentricity', 'Orientation', 'MajorAxisLength', 'MinorAxisLength', ...
        'Centroid', 'BoundingBox');

    R = x(:,:,1); G = x(:,:,2); B = x(:,:,3);
    N = length(stats_filtradas);
    idx = 0;

    tieneClase = exist('clase', 'var') && ~isempty(clase);

    temp = repmat(struct( ...
        'Area', [], 'Perimeter', [], 'Eccentricity', [], 'Orientation', [], ...
        'MajorAxisLength', [], 'MinorAxisLength', [], 'CentroidX', [], 'CentroidY', [], ...
        'MeanR', [], 'MeanG', [], 'MeanB', [], 'StdR', [], 'StdG', [], 'StdB', [], ...
        'RelacionAspecto', [], 'Circularidad', [], 'Compacidad', [], 'Etiqueta', [], ...
        'BoundingBox', [], ...
        'Area_Scale', [], 'Perimeter_Scale', [], ...
        'MajorAxisLength_Scale', [], 'MinorAxisLength_Scale', [], ...
        'CentroidX_Scale', [], 'CentroidY_Scale', [], ...
        'Circularidad_Scale', [], 'Compacidad_Scale', [], ...
        'BoundingBox_Scale', []), N, 1);

    if tieneClase
        [temp.Clase] = deal(clase);
    end

   

    fprintf('[INFO] === Análisis de regiones ===\n');
    for i = 1:N
        s = stats_filtradas(i);
        obj_mask = etiquetas_area == i;
        circ = 4 * pi * s.Area / (s.Perimeter^2 + eps);

        fprintf('  → Objeto %d: Area=%.1f | Perim=%.1f | Circ=%.3f\n', ...
                i, s.Area, s.Perimeter, circ);

        if circ < circ_min
            fprintf('⚠️  Se descarta por circularidad < %.2f\n', circ_min);
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
        temp(idx).BoundingBox = s.BoundingBox;

        % Color
        r_vals = double(R(obj_mask)); g_vals = double(G(obj_mask)); b_vals = double(B(obj_mask));
        temp(idx).MeanR = mean(r_vals);  temp(idx).StdR = std(r_vals);
        temp(idx).MeanG = mean(g_vals);  temp(idx).StdG = std(g_vals);
        temp(idx).MeanB = mean(b_vals);  temp(idx).StdB = std(b_vals);

        % Escalado
        temp(idx).Area_Scale = s.Area * factor_px_a_cm^2;
        temp(idx).Perimeter_Scale = s.Perimeter * factor_px_a_cm;
        temp(idx).MajorAxisLength_Scale = s.MajorAxisLength * factor_px_a_cm;
        temp(idx).MinorAxisLength_Scale = s.MinorAxisLength * factor_px_a_cm;
        temp(idx).CentroidX_Scale = s.Centroid(1) * factor_px_a_cm;
        temp(idx).CentroidY_Scale = s.Centroid(2) * factor_px_a_cm;
        temp(idx).Circularidad_Scale = 4 * pi * temp(idx).Area_Scale / (temp(idx).Perimeter_Scale^2 + eps);
        temp(idx).Compacidad_Scale = (temp(idx).Perimeter_Scale^2) / (temp(idx).Area_Scale + eps);
        temp(idx).BoundingBox_Scale = s.BoundingBox * factor_px_a_cm;
    end

    fprintf('[INFO] Total objetos aceptados: %d\n', idx);

    if idx > 0
        datos = struct2table(temp(1:idx));
        etiquetas_validas = [temp(1:idx).Etiqueta];
        mascara_final = ismember(etiquetas_area, etiquetas_validas);
    else
        datos = table();
        mascara_final = false(size(x_bin));
    end

    etiquetas_filtradas = bwlabel(mascara_final, 8);
end
