clear all; close all; clc;

basePath_ = fullfile(pwd, 'functions');  % carpeta raíz para todas las funciones
addpath(genpath(basePath_));    
load '../train/models/modLegumbres_desicionTree.mat'  % rfModel y características

%% 1. Leer imagen directamente
img = imread('../media/img-test/img3.jpeg');
%imshow(img); title('Imagen cargada');

[datos, x, x_grises, x_bin, mascara_final, etiquetas_filtradas] = procesamiento_img(img, 0.2, 4);

tabla_final = clasificar_y_centroides(datos, treeModel, '../train/models/caracteristicas.mat' );
[img_etiquetada, resumen_data] = analizar_legumbres(tabla_final, img, 'test3_tree');
%imshow(img_etiquetada)