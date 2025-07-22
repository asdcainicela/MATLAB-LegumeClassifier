%% Ejemplo 2: Bosques Aleatorios para Clasificación de Legumbres
clear; clc; close all;

% --- Carpeta para guardar imágenes ---
outputFolder = 'random/forest';
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% --- Redireccionar salida a archivo log ---
diary(fullfile(outputFolder, 'consola_random_forest.log'));
diary on

% --- Cargar datos y características ---
T = readtable('../data/data_legumbres.csv');
load('models/caracteristicas.mat', 'caracteristicas');

data  = T(:, caracteristicas);
clase = T.Clase;

X = table2array(data);
Y = clase;

% --- Mostrar resumen ---
fprintf('[INFO] Número de muestras: %d\n', size(X,1));
fprintf('[INFO] Número de clases: %d\n\n', numel(unique(Y)));

% --- División entrenamiento/prueba ---
cv = cvpartition(Y, 'HoldOut', 0.3);
X_train = X(training(cv), :);
Y_train = Y(training(cv));
X_test  = X(test(cv), :);
Y_test  = Y(test(cv));

% --- Entrenar Random Forest ---
numTrees = 100;
rfModel = TreeBagger(numTrees, X_train, Y_train, ...
    'Method', 'classification', ...
    'OOBPrediction', 'On', ...
    'MinLeafSize', 5, ...
    'NumPredictorsToSample', round(sqrt(size(X, 2))), ...
    'OOBPredictorImportance', 'on');

% --- Predicción y precisión ---
Y_pred = categorical(predict(rfModel, X_test));
accuracy = sum(Y_pred == Y_test) / numel(Y_test);
fprintf('[INFO] Precisión en test: %.2f%%\n', 100 * accuracy);

% --- Guardar modelo ---
save('models/modLegumbres_randomForest.mat', 'rfModel');

% --- Guardar gráfica de importancia de características ---
fig1 = figure('Color', 'w');
bar(rfModel.OOBPermutedPredictorDeltaError);
xticklabels(caracteristicas);
xtickangle(45);
ylabel('Importancia OOB');
title('Importancia de características (Random Forest)');
grid on;
saveas(fig1, fullfile(outputFolder, 'importancia_caracteristicas.png'));
close(fig1);

% --- Guardar matriz de confusión ---
fig2 = figure('Color', 'w');
Y_test = categorical(Y_test);
Y_pred = categorical(Y_pred);
confusionchart(Y_test, Y_pred);
title('Matriz de Confusión - Random Forest');
saveas(fig2, fullfile(outputFolder, 'matriz_confusion.png'));
close(fig2);

% --- Terminar log ---
fprintf('[INFO] Script finalizado correctamente.\n');
diary off
