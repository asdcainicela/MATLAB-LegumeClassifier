%% Ejemplo de Árbol de Decisión para Clasificación de Legumbres
clear; clc; close all;

% --- Carpeta de salida ---
outputFolder = 'random/tree';
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% --- Redirigir salida de consola a un archivo .log ---
diary(fullfile(outputFolder, 'ejecucion.log'));
diary on

fprintf('[INFO] Inicio del proceso: %s\n', datestr(now));

% --- Cargar la tabla de legumbres ---
T = readtable('../data/data_legumbres.csv');

% --- Cargar características ---
load('models/caracteristicas.mat', 'caracteristicas');
data = T(:, caracteristicas);
clase = T.Clase;

% --- Convertir a arrays ---
X = table2array(data);
Y = clase;

fprintf('[INFO] Número de muestras: %d\n', size(X,1));
fprintf('[INFO] Número de clases: %d\n\n', numel(unique(Y)));

% --- División entrenamiento/prueba (70/30) ---
cv = cvpartition(Y, 'HoldOut', 0.3);
X_train = X(training(cv), :);
Y_train = Y(training(cv));
X_test  = X(test(cv), :);
Y_test  = Y(test(cv));

% --- Entrenar árbol de decisión con optimización ---
treeModel = fitctree(X_train, Y_train, ...
    'OptimizeHyperparameters', 'auto', ...
    'HyperparameterOptimizationOptions', ...
    struct('AcquisitionFunctionName', 'expected-improvement-plus'));

% --- Guardar el modelo ---
save('models/modLegumbres_desicionTree.mat', 'treeModel');

% --- Predicción y precisión ---
Y_test = categorical(Y_test);
Y_pred = categorical(predict(treeModel, X_test));
accuracy = sum(Y_pred == Y_test) / numel(Y_test);
fprintf('[INFO] Precisión en test: %.2f%%\n', 100 * accuracy);

% --- Matriz de Confusión ---
fig1 = figure('Color', 'w'); % fondo blanco
confusionchart(Y_test, Y_pred);
title('Matriz de Confusión - Árbol de Decisión');
saveas(fig1, fullfile(outputFolder, 'matriz_confusion.png'));
close(fig1);

% --- Visualizar árbol de decisión ---
view(treeModel, 'Mode', 'graph');

fprintf('[INFO] Fin del proceso: %s\n', datestr(now));

% --- Finalizar log ---
diary off;
