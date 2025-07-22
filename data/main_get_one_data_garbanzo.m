clc, clear, close all;
addpath("../functions/procesamiento")
addpath("../functions/utils")
% Ruta de imagen de prueba
ruta = 'data_garbanzo/G_5.png';

% Procesar imagen
[datos, x, xg, xb, masc, etiquetas] = procesamiento_img(ruta, 0.1, 2, 'garbanzo', 0.05 );

% Mostrar tabla de propiedades
disp(datos);

% === Mostrar imágenes procesadas en una sola figura ===
figure('Name', 'Pasos de procesamiento');
subplot(1,3,1); imshow(xg); title('Escala de grises');
subplot(1,3,2); imshow(xb); title('Binarizada');
subplot(1,3,3); imshow(masc); title('Máscara final');

% === Mostrar anotaciones sobre la imagen original ===
figure('Name', 'Anotaciones en imagen original');
imshow(x);
hold on;

for i = 1:height(datos)
    cx = datos.CentroidX(i);
    cy = datos.CentroidY(i);
    texto = sprintf('R:%.0f G:%.0f B:%.0f - A:%.0f', ...
        datos.MeanR(i), datos.MeanG(i), datos.MeanB(i), datos.Area(i));
    plot(cx, cy, 'r*');
    text(cx+10, cy, texto, 'Color', 'black', 'FontSize', 8);
end
%save_datacsv(datos, 'data_garbanzo.csv');  % Guarda en la carpeta "resultados"