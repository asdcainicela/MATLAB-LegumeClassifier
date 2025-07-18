function dibujar_filtro_legumbres(filtro, carpeta_entrada, carpeta_salida)
    carpeta_salida= ['ouput_detection_' carpeta_salida];

    % Guardar imagen
    if ~exist(carpeta_salida, 'dir')
        mkdir(carpeta_salida);
    end

    nombres = unique(filtro.Imagen);
    for i = 1:numel(nombres)
        nombre_img = nombres{i};
        subfiltro = filtro(strcmp(filtro.Imagen, nombre_img), :);

        ruta_img = fullfile(carpeta_entrada, nombre_img);

        if ~isfile(ruta_img)
            warning(" No se encontró la imagen: %s", nombre_img);
            continue;
        end

        img = imread(ruta_img);

        % Dibujar puntos sobre la imagen
        imshow(img); hold on;
        for j = 1:height(subfiltro)
            plot(subfiltro.CentroideX(j), subfiltro.CentroideY(j), 'ro', 'MarkerSize', 6, 'LineWidth', 1.5);
            text(subfiltro.CentroideX(j)+5, subfiltro.CentroideY(j), ...
                sprintf('%d', j), 'Color', 'black', 'FontSize', 8, 'FontWeight', 'bold');
        end

        % Guardar resultado
        export_path = fullfile(carpeta_salida, nombre_img);
        saveas(gcf, export_path);
        close;
    end

    disp(" Imágenes con objetos filtrados generadas.");
end
