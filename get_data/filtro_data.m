function [datos, mean_area] = filtro_data(datalent, variacion)
    % FILTRO_DATA - Filtra elementos de la tabla 'datalent' por centroide válido y área.
    % Entradas:
    %   datalent  - Tabla con al menos las columnas 'Area', 'CentroideX', 'CentroideY'
    %   variacion - Rango aceptable alrededor del área promedio
    %
    % Salidas:
    %   datos   - Subtabla filtrada
    %   mean_a  - Área promedio original

    % Verifica existencia de campos necesarios
    if all(ismember({'CentroideX', 'CentroideY', 'Area'}, datalent.Properties.VariableNames))
        datalent = datalent(datalent.CentroideX > 0 & datalent.CentroideY > 0, :);
    else
        warning('Campos CentroideX y CentroideY no están presentes. Se omite el filtrado por centroide.');
    end

    % Calcular área promedio
    mean_area = mean(datalent.Area);

    % Filtrar por rango de variación
    datos = datalent(datalent.Area > (mean_area - variacion) & datalent.Area < (mean_area + variacion), :);
    fprintf(" Objetos seleccionados: %d\n", height(datos));
    fprintf(" Area promedio: %0.2f , promedio2: %0.2f \n", mean_area, mean(datos.Area));
    fprintf(" Variacion: %0.2f\n", variacion);
    fprintf(" Area min: %0.2f\n", min(datos.Area));
    fprintf(" Area max: %0.2f\n", max(datos.Area));
end
