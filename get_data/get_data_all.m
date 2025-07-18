%clc; clear;

carpeta_entrada_img = 'data_lentejas';
carpeta_salida = 'filtro_obj_det_lentejas';

datalent=procesar_legumbres(carpeta_entrada_img, 'lentejas');
 
% filtramos
[datalent, promedio_Area]=filtro_data(datalent, 3000);

% dibujamos las imagenes finales
dibujar_filtro_legumbres(datalent, carpeta_entrada_img, 'lentejas');
writetable(datalent,'data_lentejas')
% 
% % Guardar a .mat
% save('datalent.mat', 'datalent');
