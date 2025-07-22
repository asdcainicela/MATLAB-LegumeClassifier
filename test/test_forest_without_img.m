%% Ejemplo  de random forest : Reconocimiento
clear all,close all,clc;

% --- Cargar datos y características ---
T = readtable('../data/data_legumbres.csv');
load('../train/models/caracteristicas.mat', 'caracteristicas');

data = T(:, caracteristicas);
X=table2array(data);
%Cargar el modelo entrenado 
load '../train/models/modLegumbres_randomForest.mat'
%Reconocer con la función predict 
Y_pred = predict(rfModel, X);
% Mostrar resultado
fprintf('La predicción para la muestra  es: %s\n', string(Y_pred));
