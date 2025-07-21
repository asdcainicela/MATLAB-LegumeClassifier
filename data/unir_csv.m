clc, clear;
T1 = readtable('data_data_alverjita_verde_partida.csv');
T2 = readtable('data_data_garbanzo.csv');
T3 = readtable('data_data_frejol_canario.csv');
%T3 = readtable('data_frijoles.csv'); % si tienes más clases

T = [T1; T2; T3]; % Unir todas las tablas
T = T(randperm(height(T)), :);

writetable(T, 'data_legumbres.csv'); % Guardar combinado