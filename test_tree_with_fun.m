clear all; close all; clc;

basePath_ = fullfile(pwd, 'functions');  % carpeta raíz para todas las funciones
addpath(genpath(basePath_));    
load train/models/modLegumbres_desicionTree.mat  % rfModel y características

%% 1. Leer imagen directamente
img = imread('media/img-test/test1.jpeg');
%imshow(img); title('Imagen cargada');

[datos, x, x_grises, x_bin, mascara_final, etiquetas_filtradas] = procesamiento_img(img, 500, 90000);

tabla_final = clasificar_y_centroides(datos, treeModel );
disp(tabla_final)
[img_etiquetada, resumen_data] = analizar_legumbres(tabla_final, img);
imshow(img_etiquetada)