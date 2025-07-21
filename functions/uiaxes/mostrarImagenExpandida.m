function mostrarImagenExpandida(ax, img)
    % Si es lógica (binaria), convertir a uint8 [0, 255]
    if islogical(img)
        img = uint8(img) * 255;
    end

    % Si es double en rango [0, 1], conviértelo a uint8 [0, 255]
    if isfloat(img) && max(img(:)) <= 1
        img = uint8(img * 255);
    end

    % Si es gris (2D), conviértelo a RGB
    if ndims(img) == 2
        img = repmat(img, 1, 1, 3);
    end

    % Mostrar
    cla(ax, 'reset');
    image(ax, img);

    % Limpieza visual
    ax.XTick = [];
    ax.YTick = [];
    ax.XColor = 'none';
    ax.YColor = 'none';
    ax.Box = 'off';
    ax.YDir = 'reverse';
    ax.Color = [1 1 1];  % Fondo blanco
end
