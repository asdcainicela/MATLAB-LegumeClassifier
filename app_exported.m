classdef app_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure            matlab.ui.Figure
        UITableCount        matlab.ui.control.Table
        ImageVideo          matlab.ui.control.Image
        ImagePhoto          matlab.ui.control.Image
        Image_en            matlab.ui.control.Image
        Image_es            matlab.ui.control.Image
        UIAxesVideo         matlab.ui.control.UIAxes
        UIAxesPhoto         matlab.ui.control.UIAxes
        UIAxes_03           matlab.ui.control.UIAxes
        UIAxes_04           matlab.ui.control.UIAxes
        UIAxes_05           matlab.ui.control.UIAxes
        UIAxesRandomForest  matlab.ui.control.UIAxes
        UIAxesDecisionTree  matlab.ui.control.UIAxes
    end

    
   properties (Access = public) 
    % Botones
    StartVideoBtn   % Botón Start Video
    CaptureBtn     % Botón Capture 1 
    LoadBtn        % Botón Load 1 
    SaveBtn        % Botón Save 1
    ClearAllBtn     % Botón Clear all 
    ProcessBtn      % Botón Process 

    % idioma
    Language = "en"

    ButtonsByID

    % propeidades para la configuracion---
    translations    % para la tabla de traducciones
    styles          % para la tabla de estilos
    layout          % para la tabla de layout

     % ---- camera ---- %
    cam             % Objeto de webcam
    timerObj        % Objeto de temporizador para actualizar video
    isCameraRunning = false

    imagePhotoData % Data de la imagen 
    DataProcesada % datos procesados

    %--------------- modelos
    modeloTree  % Modelo Árbol de Decisión
    modeloForest % Modelo Random Forest

   end
    
    methods (Access = private)
        function toggleVideo(app)        
            if app.isCameraRunning
                % === detener video ===
                stop(app.timerObj); delete(app.timerObj);
                app.timerObj = [];
                app.isCameraRunning = false;
                app.ImageVideo.Visible = "on";
         
        
            else
                % === iniciar video ===
                if isempty(app.cam) || ~isvalid(app.cam)
                    app.cam = webcam;
                end 
                app.ImageVideo.Visible = "off";
                cla(app.UIAxesVideo,"reset");
                app.timerObj = timer(...
                    'ExecutionMode', 'fixedRate', ...
                    'Period', 0.2, ...
                    'TimerFcn', @(~,~) mostrarVideo(app));
                start(app.timerObj);
                app.isCameraRunning = true;
            end 
        end
        
        function ScreenButton(app)
            if ~app.isCameraRunning
                uialert(app.UIFigure, 'First, you must start the camera', 'Error');
                return;
            end
            
            try
                foto = snapshot(app.cam);
                    app.ImagePhoto.Visible = "off";
                    cla(app.UIAxesPhoto, "reset");
                    image(app.UIAxesPhoto, foto);
                    app.UIAxesPhoto.XTick = [];
                    app.UIAxesPhoto.YTick = [];
                    app.imagePhotoData = foto; % Guardamos imagen
            catch ME
                uialert(app.UIFigure, ME.message, 'Error capturing photo');
            end
        end

                % Cargar imagen desde archivo
        function LoadImage(app)
            [file, path] = uigetfile({'*.png;*.jpg;*.jpeg'}, 'Select an image');
            if isequal(file, 0)
                return;
            end
            img = imread(fullfile(path, file));
            app.imagePhotoData = img;
            app.ImagePhoto.Visible = "off";
            cla(app.UIAxesPhoto, "reset");
            image(app.UIAxesPhoto, img);
            app.UIAxesPhoto.XTick = [];
            app.UIAxesPhoto.YTick = [];
        end

        function SaveImage(app)
            if isempty(app.imagePhotoData)
                uialert(app.UIFigure, "No image to save.", "Warning");
                return;
            end
        
            % Crear carpeta 'results' si no existe
            output_dir = 'results';
            if ~exist(output_dir, 'dir')
                mkdir(output_dir);
            end
        
            % Ruta fija
            file_name = 'ScreenOriginal.png';
            full_path = fullfile(output_dir, file_name);
        
            % Guardar imagen
            imwrite(app.imagePhotoData, full_path);
        
            % Confirmación
            uialert(app.UIFigure, "Imagenes guardadas en results", "Éxito");
        end


        % Limpiar todas las imágenes
        function ClearAll(app)
            % Limpiar los datos
            app.imagePhotoData = [];

            
            % Restaurar imágenes por defecto
            app.ImagePhoto.Visible = 'on';
            cla(app.UIAxesPhoto, 'reset'); 
            cla(app.UIAxes_03, 'reset'); 
            cla(app.UIAxes_04, 'reset');
            cla(app.UIAxes_05, 'reset');

            cla(app.UIAxesDecisionTree, 'reset');
            cla(app.UIAxesRandomForest, 'reset');
            app.UITableCount.Visible = "off";
        
        end
        function ProcessImages(app)
            % Procesar imagen con rangos de área dados
            [datos, input_x, input_xg, input_xb, input_masc, input_etiquetas] = procesamiento_img(app.imagePhotoData, 0.2, 3);
        
            % Mostrar imágenes intermedias
            mostrarImagenExpandida(app.UIAxes_03, input_xg);    % Imagen en grises
            mostrarImagenExpandida(app.UIAxes_04, input_xb);  % Máscara binaria

            mostrarImagenExpandida(app.UIAxes_05, input_etiquetas);  % Máscara binaria
        
            
            % para decision Tree
            tabla_finalTree = clasificar_y_centroides(datos, app.modeloTree);
            [img_etiquetadaTree, resumen_dataTree,tabla_finalTree] = analizar_legumbres(tabla_finalTree, input_x, 'imgTree');
            disp(tabla_finalTree)

            % para random forest
            tabla_finalForest = clasificar_y_centroides(datos, app.modeloForest);
            [img_etiquetadaForest, resumen_dataForest,tabla_finalForest] = analizar_legumbres(tabla_finalForest, input_x, 'imgForest');
            disp(tabla_finalForest)
 
            
            mostrarImagenExpandida(app.UIAxesDecisionTree, img_etiquetadaTree);  
            mostrarImagenExpandida(app.UIAxesRandomForest, img_etiquetadaForest);  
            %% Mostrar resumen en la tabla
            app.UITableCount.Visible = "on";
            
            % Asegúrate de que 'Clase' esté como string
            resumen_dataTree.Clase = string(resumen_dataTree.Clase);
            resumen_dataForest.Clase = string(resumen_dataForest.Clase);
            
            % Renombrar las columnas de cantidad
            resumen_dataTree.Properties.VariableNames{'Cantidad'} = 'DecisionTree';
            resumen_dataForest.Properties.VariableNames{'Cantidad'} = 'RandomForest';
            
            % Hacer outerjoin por 'Clase'
            tablaResumen = outerjoin(resumen_dataTree, resumen_dataForest, ...
                'Keys', 'Clase', 'MergeKeys', true);
            
            % Reemplazar NaN por 0
            tablaResumen.DecisionTree(isnan(tablaResumen.DecisionTree)) = 0;
            tablaResumen.RandomForest(isnan(tablaResumen.RandomForest)) = 0;
            
            % Mostrar tabla en interfaz
            app.UITableCount.Data = tablaResumen;
            
            % Establecer encabezados en el UI Table manualmente
            app.UITableCount.ColumnName = {'Clase', 'Decision Tree', 'Random Forest'};
            
            % Mostrar en consola también
            disp(tablaResumen)



        end



    end
    
    methods (Access = public)
        
         function mostrarVideo(app)
            try
                frame = snapshot(app.cam);
                image(app.UIAxesVideo, frame);
                app.UIAxesVideo.XTick = [];
                app.UIAxesVideo.YTick = [];
            catch ME
                % Si hay error, restauramos el estado
                app.isCameraRunning = false;
                app.ImageVideo.Visible = 'on';
                uialert(app.UIFigure, ME.message, 'Camera error');
            end
         end
    end


    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
          
            if app.Language == "es"
                app.Image_es.Visible = "on";
                app.Image_en.Visible = "off";
            else
                app.Image_es.Visible = "off";
                app.Image_en.Visible = "on";
            end
            basePath_ = fullfile(pwd, 'functions');  % carpeta raíz para todas las funciones
            addpath(genpath(basePath_));             % agrega todas las funciones a la ruta
        
            basePath = fullfile(pwd, 'config');  

            addpath('train/models');
    
            % Carga los modelos
            datosTree = load('modLegumbres_desicionTree.mat');
            datosForest = load('modLegumbres_randomForest.mat');
            
            % Asigna a las propiedades
            app.modeloTree = datosTree.treeModel; 
            app.modeloForest = datosForest.rfModel;  
            
            fprintf('Modelos cargados exitosamente.\n');
            
            % --- Leer CSVs y asignar a propiedades ---
            app.translations = readtable(fullfile(basePath, 'translations.csv'), ...
                'TextType', 'string', 'VariableNamingRule', 'preserve');
        
            app.styles = readtable(fullfile(basePath, 'styles.csv'), ...
                'TextType', 'string', 'VariableNamingRule', 'preserve', ...
                'Delimiter', ',');  % usa el delimitador correcto
            app.layout = readtable(fullfile(basePath, 'layout.csv'), ...
                'TextType', 'string', 'VariableNamingRule', 'preserve');
        
            % Limpiar espacios en encabezados
            app.styles.Properties.VariableNames = strtrim(app.styles.Properties.VariableNames);
            disp('Columnas en styles:'); disp(app.styles.Properties.VariableNames)
            disp(app.translations.Properties.VariableNames)
            disp(app.layout.Properties.VariableNames)
        
            app.ButtonsByID = containers.Map('KeyType','double','ValueType','any');
        
            % Convertir columna Bold a logical
            app.styles.Bold = strcmpi(strtrim(app.styles.Bold), "true"); 
        
            idsToCreate = 1:6;  % solo hasta 6
            for id = idsToCreate
                tr = app.translations(app.translations.ID == id, :);
                st = app.styles(app.styles.ID == id, :);
                pos = app.layout(app.layout.ID == id, :);
        
                btnText = tr.(app.Language);  % es o en
        
                btn = round_button(app.UIFigure, ...
                    "Position", [pos.PosX, pos.PosY, pos.Width, pos.Height], ...
                    "Text", btnText, ...
                    "FontColor", st.FontColor, ...
                    "Bold", st.Bold, ...
                    "Color", st.Color, ...
                    "HoverColor", st.HoverColor, ...
                    "BackgroundHexColor", st.BGColor);
        
                app.ButtonsByID(id) = btn;
        
                switch id
                    case 1
                        btn.ButtonPushedFcn = @(~,~) app.toggleVideo(); 
                    case 3
                        btn.ButtonPushedFcn = @(~,~) app.ScreenButton();
                    case 4
                        btn.ButtonPushedFcn = @(~,~) app.LoadImage();
                    case 5
                        btn.ButtonPushedFcn = @(~,~) app.SaveImage();
                    case 6
                        btn.ButtonPushedFcn = @(~,~) app.ClearAll();
                    case 2
                        btn.ButtonPushedFcn = @(~,~) app.ProcessImages();
                end
            end 

        
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [15 10 1366 778];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.Resize = 'off';
            app.UIFigure.Theme = 'light';

            % Create UIAxesDecisionTree
            app.UIAxesDecisionTree = uiaxes(app.UIFigure);
            title(app.UIAxesDecisionTree, 'Title')
            xlabel(app.UIAxesDecisionTree, 'X')
            ylabel(app.UIAxesDecisionTree, 'Y')
            zlabel(app.UIAxesDecisionTree, 'Z')
            app.UIAxesDecisionTree.Position = [1052 431 300 250];

            % Create UIAxesRandomForest
            app.UIAxesRandomForest = uiaxes(app.UIFigure);
            title(app.UIAxesRandomForest, 'Title')
            xlabel(app.UIAxesRandomForest, 'X')
            ylabel(app.UIAxesRandomForest, 'Y')
            zlabel(app.UIAxesRandomForest, 'Z')
            app.UIAxesRandomForest.Position = [712 431 300 250];

            % Create UIAxes_05
            app.UIAxes_05 = uiaxes(app.UIFigure);
            xlabel(app.UIAxes_05, 'X')
            ylabel(app.UIAxes_05, 'Y')
            zlabel(app.UIAxes_05, 'Z')
            app.UIAxes_05.Position = [1049 18 300 250];

            % Create UIAxes_04
            app.UIAxes_04 = uiaxes(app.UIFigure);
            title(app.UIAxes_04, 'Title')
            xlabel(app.UIAxes_04, 'X')
            ylabel(app.UIAxes_04, 'Y')
            zlabel(app.UIAxes_04, 'Z')
            app.UIAxes_04.Position = [710 18 300 250];

            % Create UIAxes_03
            app.UIAxes_03 = uiaxes(app.UIFigure);
            title(app.UIAxes_03, 'Title')
            xlabel(app.UIAxes_03, 'X')
            ylabel(app.UIAxes_03, 'Y')
            zlabel(app.UIAxes_03, 'Z')
            app.UIAxes_03.Position = [374 18 300 250];

            % Create UIAxesPhoto
            app.UIAxesPhoto = uiaxes(app.UIFigure);
            title(app.UIAxesPhoto, 'Title')
            xlabel(app.UIAxesPhoto, 'X')
            ylabel(app.UIAxesPhoto, 'Y')
            zlabel(app.UIAxesPhoto, 'Z')
            app.UIAxesPhoto.Position = [34 18 300 250];

            % Create UIAxesVideo
            app.UIAxesVideo = uiaxes(app.UIFigure);
            title(app.UIAxesVideo, 'Title')
            xlabel(app.UIAxesVideo, 'X')
            ylabel(app.UIAxesVideo, 'Y')
            zlabel(app.UIAxesVideo, 'Z')
            app.UIAxesVideo.Position = [34 426 300 250];

            % Create Image_es
            app.Image_es = uiimage(app.UIFigure);
            app.Image_es.Position = [0 0 1367 779];
            app.Image_es.ImageSource = fullfile(pathToMLAPP, 'media', 'img-src', 'background-es.png');

            % Create Image_en
            app.Image_en = uiimage(app.UIFigure);
            app.Image_en.Position = [1 0 1367 779];
            app.Image_en.ImageSource = fullfile(pathToMLAPP, 'media', 'img-src', 'background-es.png');

            % Create ImagePhoto
            app.ImagePhoto = uiimage(app.UIFigure);
            app.ImagePhoto.Position = [34 18 299 247];
            app.ImagePhoto.ImageSource = fullfile(pathToMLAPP, 'media', 'img-src', 'img-photo.png');

            % Create ImageVideo
            app.ImageVideo = uiimage(app.UIFigure);
            app.ImageVideo.Position = [34 429 298 248];
            app.ImageVideo.ImageSource = fullfile(pathToMLAPP, 'media', 'img-src', 'img-video.png');

            % Create UITableCount
            app.UITableCount = uitable(app.UIFigure);
            app.UITableCount.ColumnName = '';
            app.UITableCount.RowName = {};
            app.UITableCount.Visible = 'off';
            app.UITableCount.Position = [359 457 315 177];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = app_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end