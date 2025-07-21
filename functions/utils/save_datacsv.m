function save_datacsv(tabla, output_path)
    % Verifica que la entrada sea una tabla
    if ~istable(tabla)
        error('La primera entrada debe ser una tabla.');
    end

    % Verifica que la ruta sea un string o char
    if ~(ischar(output_path) || isstring(output_path))
        error('La segunda entrada debe ser una ruta de archivo válida (string o char).');
    end

    % Asegurar que la extensión sea .csv
    [~, ~, ext] = fileparts(output_path);
    if isempty(ext)
        output_path = output_path + ".csv";
    elseif ~strcmp(ext, '.csv')
        warning('La extensión será cambiada a ".csv".');
        output_path = replace(output_path, ext, '.csv');
    end

    % Guardar la tabla
    writetable(tabla, output_path);
    disp(['Archivo CSV guardado en: ', output_path]);
end
