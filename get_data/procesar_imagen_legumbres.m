function tabla = procesar_imagen_legumbres(ruta_imagen, ruta_guardado)
    [~, nombre_imagen, ~] = fileparts(ruta_imagen);
    x = imread(ruta_imagen);
    x_gris = rgb2gray(x);

    % Segmentación básica
    nivel = graythresh(x_gris);
    x_bin = imbinarize(x_gris, nivel);
    x_bin = imcomplement(x_bin); 
    x_bin = bwareaopen(x_bin, 100);  % Eliminar ruido

    etiquetas = bwlabel(x_bin, 8);

    stats = regionprops(etiquetas, 'Area', 'Perimeter', 'Eccentricity', ...
        'Orientation', 'MajorAxisLength', 'MinorAxisLength', 'Centroid', ...
        'BoundingBox');

    n = length(stats);
    Objeto = (1:n)';
    Area = zeros(n,1);
    Perimetro = zeros(n,1);
    Excentricidad = zeros(n,1);
    Orientacion = zeros(n,1);
    EjeMayor = zeros(n,1);
    EjeMenor = zeros(n,1);
    CentroideX = zeros(n,1);
    CentroideY = zeros(n,1);

    % Dibujo sobre la imagen
    figura = figure('Visible', 'off'); 
    imshow(x); title('Objetos detectados'); hold on;

    for i = 1:n
        Area(i) = stats(i).Area;
        Perimetro(i) = stats(i).Perimeter;
        Excentricidad(i) = stats(i).Eccentricity;
        Orientacion(i) = stats(i).Orientation;
        EjeMayor(i) = stats(i).MajorAxisLength;
        EjeMenor(i) = stats(i).MinorAxisLength;
        CentroideX(i) = stats(i).Centroid(1);
        CentroideY(i) = stats(i).Centroid(2);
    
        % Dibujar centroides y bounding box
        plot(CentroideX(i), CentroideY(i), 'r*', 'MarkerSize', 6);
        rectangle('Position', stats(i).BoundingBox, ...
                  'EdgeColor', 'g', 'LineWidth', 1);
        % Agregar número del objeto
        text(CentroideX(i)-50, CentroideY(i)+20, sprintf('%d', i), ...
             'Color', 'black', 'FontSize', 8, 'FontWeight', 'bold');
    end


    % Guardar imagen
    if ~exist(ruta_guardado, 'dir')
        mkdir(ruta_guardado);
    end
    ruta_salida = fullfile(ruta_guardado, [nombre_imagen, '_detectado.png']);
    saveas(figura, ruta_salida);
    close(figura);

    % Crear tabla
    tabla = table(Objeto, Area, Perimetro, Excentricidad, ...
        Orientacion, EjeMayor, EjeMenor, CentroideX, CentroideY);
end
