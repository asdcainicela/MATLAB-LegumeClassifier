clear all; close all; clc;

%% 1. Leer imagen directamente
img = imread('media/img-test/test4.jpeg');
imshow(img); title('Imagen cargada');

%% 2. Preprocesamiento: segmentar múltiples legumbres
gray = rgb2gray(img);
BW = imbinarize(gray, 'adaptive', 'ForegroundPolarity', 'dark', 'Sensitivity', 0.4);
BW = imcomplement(BW);
BW = bwareaopen(BW, 500);             
BW = imfill(BW, 'holes');             

% Conectividad de objetos
CC = bwconncomp(BW);
stats = regionprops(CC, 'Area', 'Perimeter', 'Eccentricity', ...
                          'MajorAxisLength', 'MinorAxisLength', ...
                          'Centroid', 'BoundingBox');

%% 3. Cargar modelo de árbol de decisión entrenado
%load(train/models/modLegumbres_desicionTree.mat', 'treeModel');
load train/models/modLegumbres_desicionTree.mat  % rfModel y características

%% 4. Inicializar resultados
n = CC.NumObjects;
predicciones = strings(n, 1);
centroides = zeros(n, 2);
cajas = zeros(n, 4);  

%% 5. Clasificar cada objeto
for i = 1:n
    mask_i = false(size(BW));
    mask_i(CC.PixelIdxList{i}) = true;

    % Aplicar máscara a la imagen RGB
    masked_img = bsxfun(@times, img, cast(mask_i, 'like', img));
    R = double(masked_img(:, :, 1)); G = double(masked_img(:, :, 2)); B = double(masked_img(:, :, 3));
    R = R(mask_i); G = G(mask_i); B = B(mask_i);

    % Geometría
    s = stats(i);
    Area = s.Area;
    Perimetro = s.Perimeter;
    Excentricidad = s.Eccentricity;
    Circularidad = 4 * pi * Area / (Perimetro^2);

    % Color
    MeanR = mean(R); MeanG = mean(G); MeanB = mean(B);

    % Vector de entrada (mismas características usadas para entrenar el árbol)
    x = [Area, Excentricidad, Circularidad, MeanR, MeanG, MeanB];

    % Clasificación con el árbol de decisión
    predicciones(i) = predict(treeModel, x);
    centroides(i, :) = s.Centroid;
    cajas(i, :) = s.BoundingBox;
end

%% 6. Generar IDs reiniciados por clase
clasesUnicas = unique(predicciones);
contadorClase = containers.Map(clasesUnicas, num2cell(zeros(size(clasesUnicas))));
ID_por_clase = zeros(n,1);
for i = 1:n
    claseActual = predicciones(i);
    contadorClase(claseActual) = contadorClase(claseActual) + 1;
    ID_por_clase(i) = contadorClase(claseActual);
end

%% 7. Dibujar resultados en imagen
img_etiquetada = img;
for i = 1:n
    box = cajas(i, :);
    etiqueta = sprintf('%s %d', predicciones(i), ID_por_clase(i));

    img_etiquetada = insertShape(img_etiquetada, 'Rectangle', box, ...
        'Color', 'red', 'LineWidth', 2);

    pos_text = [box(1), box(2) - 40];
    img_etiquetada = insertText(img_etiquetada, pos_text, etiqueta, ...
        'FontSize', 25, 'BoxColor', 'black', ...
        'TextColor', 'yellow', 'BoxOpacity', 1);
end

% Mostrar y guardar imagen final
figure; imshow(img_etiquetada); title('Imagen con etiquetas');
imwrite(img_etiquetada, 'resultado_legumbres.png');
fprintf('✅ Imagen guardada como resultado_legumbres.png\n');

%% 8. Mostrar resumen en tabla
fprintf('\n--- RESULTADOS ---\n');
T = table(ID_por_clase, predicciones, centroides(:,1), centroides(:,2), ...
          'VariableNames', {'ID', 'Clase', 'CentroideX', 'CentroideY'});
T = sortrows(T, {'Clase','ID'});
disp(T);

%% 9. Conteo por clase
fprintf('\n--- CONTEO POR CLASE ---\n');
for i = 1:numel(clasesUnicas)
    clase = clasesUnicas(i);
    fprintf('%s: %d\n', clase, contadorClase(clase));
end
