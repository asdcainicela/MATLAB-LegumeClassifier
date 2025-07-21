classdef round_button < matlab.ui.componentcontainer.ComponentContainer
    properties
        Color (1,:) char = '#ffffff'                % Color del botón
        FontColor (1,:) char = 'black'              % Color del texto
        BackgroundHexColor (1,:) char = '#ffffff'   % Fondo del HTML
        Text (1,:) char = 'Button'                  % Texto del botón
        Bold (1,1) logical = false                  % Texto en negrita
        HoverColor (1,:) char = '#cccccc'           % Color al hacer hover
    end

    properties (Access = private, Transient, NonCopyable)
        HTMLComponent matlab.ui.control.HTML
    end

    events (HasCallbackProperty, NotifyAccess = protected)
        ButtonPushed
    end 

    methods
        function set.Color(obj, val)
            validateColor(val, 'Color');
            obj.Color = val;
        end

        function set.BackgroundHexColor(obj, val)
            validateColor(val, 'BackgroundHexColor');
            obj.BackgroundHexColor = val;
        end

        function set.HoverColor(obj, val)
            validateColor(val, 'HoverColor');
            obj.HoverColor = val;
        end
    end

    methods (Access = protected)
        function setup(obj)
            obj.Position = [100 100 80 40];
            htmlPath = fullfile(fileparts(mfilename("fullpath")), "round_button.html");
            obj.HTMLComponent = uihtml(obj, ...
                "Position", [1 1 obj.Position(3:4)], ...
                "HTMLSource", htmlPath);
            obj.HTMLComponent.HTMLEventReceivedFcn = @(src, event) notify(obj, "ButtonPushed");
        end

        function update(obj)
            obj.HTMLComponent.Data = struct( ...
                "Color", obj.Color, ...
                "FontColor", obj.FontColor, ...
                "Text", obj.Text, ...
                "BackgroundColor", obj.BackgroundHexColor, ...
                "Bold", obj.Bold, ...
                "HoverColor", obj.HoverColor ...
            );
            obj.HTMLComponent.Position = [1 1 obj.Position(3:4)];
        end
    end
end

function validateColor(val, name)
    assert(~isempty(regexp(val, '^#[0-9a-fA-F]{6}$', 'once')), ...
        name + " must be a hex code like '#ffcc00'.");
end
