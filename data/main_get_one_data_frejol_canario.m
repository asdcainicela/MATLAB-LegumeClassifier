clc, clear, close all;
addpath("../functions/procesamiento")
addpath("../functions/utils")
% Ruta de imagen de prueba
ruta = 'data_frejol_canario/img6.jpg';

% Procesar imagen
[datos, x, xg, xb, masc, etiquetas] = procesamiento_img(ruta, 8000, 45000, 'frejol_canario',0,0.7);

% img1.jpg procesamiento_img(ruta, 8000, 45000, 'frejol_canario',0,0.65);
% umbral es el 0.65,etc
% img2.jpg  procesamiento_img(ruta, 8000, 40000, 'frejol_canario',0,0.705);
% img3.jpg  procesamiento_img(ruta, 8000, 45000, 'frejol_canario',0,0.55);
% img4.jpg  procesamiento_img(ruta, 8000, 45000, 'frejol_canario',0,0.7);
% img5.jpg   procesamiento_img(ruta, 8000, 45000, 'frejol_canario',0,0.7);
% img6.jpg  procesamiento_img(ruta, 8000, 45000, 'frejol_canario',0,0.7);
% img7.jpg  procesamiento_img(ruta, 8000, 45000, 'frejol_canario',0,0.64);
% img8.jpg  procesamiento_img(ruta, 8000, 45000, 'frejol_canario',0,0.64);
% img9.jpg  procesamiento_img(ruta, 8000, 45000, 'frejol_canario',0,0.64);
% img10.jpg  procesamiento_img(ruta, 8000, 45000, 'frejol_canario',0,0.64);
%

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