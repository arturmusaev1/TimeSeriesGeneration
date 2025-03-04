function trend_analysis_gui
    fig = figure('Name', 'Анализ трендов', 'NumberTitle', 'off', 'Position', [100 100 1100 700]);
    
    %% Левая панель управления (ширина примерно 300 пикселей)
    % Кнопка загрузки данных
    uicontrol('Parent', fig, 'Style', 'pushbutton', 'String', 'Загрузить данные', ...
              'Position', [20 630 260 30], 'Callback', @load_data);
    
    % Повторы тренда
    uicontrol('Parent', fig, 'Style', 'text', 'String', 'Повторы тренда:', ...
              'Position', [20 590 100 20], 'HorizontalAlignment', 'left');
    trend_repeat_edit = uicontrol('Parent', fig, 'Style', 'edit', ...
              'Position', [130 590 150 25], 'String', '5');
    
    % Выбор типа шума
    uicontrol('Parent', fig, 'Style', 'text', 'String', 'Тип шума:', ...
              'Position', [20 555 100 20], 'HorizontalAlignment', 'left');
    noise_type_menu = uicontrol('Parent', fig, 'Style', 'popupmenu', ...
              'Position', [130 555 150 25], 'String', {'white', 'pink'});
    
    % Поле для ввода SNR
    uicontrol('Parent', fig, 'Style', 'text', 'String', 'SNR:', ...
              'Position', [20 520 100 20], 'HorizontalAlignment', 'left');
    snr_edit = uicontrol('Parent', fig, 'Style', 'edit', ...
              'Position', [130 520 150 25], 'String', '2');
    
    % Разделитель для параметров аномалии
    uicontrol('Parent', fig, 'Style', 'text', 'String', 'Параметры аномалии:', ...
              'Position', [20 485 260 25], 'FontWeight', 'bold', 'HorizontalAlignment', 'left');
    
    % Выбор типа аномалии
    uicontrol('Parent', fig, 'Style', 'text', 'String', 'Тип аномалии:', ...
              'Position', [20 450 100 20], 'HorizontalAlignment', 'left');
    anomaly_type_menu = uicontrol('Parent', fig, 'Style', 'popupmenu', ...
              'Position', [130 450 150 25], 'String', {'gaussian', 'triangle', 'user'}, 'Callback', @update_anomaly_ui);
    
    % Поля для длительности и амплитуды (видны для gaussian и triangle)
    duration_label = uicontrol('Parent', fig, 'Style', 'text', 'String', 'Длительность:', ...
              'Position', [20 415 100 20], 'HorizontalAlignment', 'left');
    anomaly_duration_edit = uicontrol('Parent', fig, 'Style', 'edit', ...
              'Position', [130 415 150 25], 'String', '300');
    uicontrol('Parent', fig, 'Style', 'text', 'String', 'Начало:', ...
              'Position', [20 380 100 20], 'HorizontalAlignment', 'left');
    anomaly_start_edit = uicontrol('Parent', fig, 'Style', 'edit', ...
              'Position', [130 380 150 25], 'String', '200');
    amplitude_label = uicontrol('Parent', fig, 'Style', 'text', 'String', 'Амплитуда:', ...
              'Position', [20 345 100 20], 'HorizontalAlignment', 'left');
    anomaly_amplitude_edit = uicontrol('Parent', fig, 'Style', 'edit', ...
              'Position', [130 345 150 25], 'String', '2');
    
    % Кнопка загрузки пользовательской аномалии (видна только если выбран тип "user")
    user_anomaly_button = uicontrol('Parent', fig, 'Style', 'pushbutton', 'String', 'Загрузить пользовательскую аномалию', ...
              'Position', [20 415 260 30], 'Callback', @load_user_anomaly, 'Visible', 'off');
    
    % Кнопка добавления аномалии
    uicontrol('Parent', fig, 'Style', 'pushbutton', 'String', 'Добавить аномалию', ...
              'Position', [20 300 260 30], 'Callback', @add_anomaly);
    
    % Список добавленных аномалий
    uicontrol('Parent', fig, 'Style', 'text', 'String', 'Список аномалий:', ...
              'Position', [20 265 260 20], 'HorizontalAlignment', 'left');
    anomaly_list = uicontrol('Parent', fig, 'Style', 'listbox', ...
              'Position', [20 150 260 110]);
    
    % Кнопка удаления аномалии
    uicontrol('Parent', fig, 'Style', 'pushbutton', 'String', 'Удалить аномалию', ...
              'Position', [20 110 260 30], 'Callback', @remove_anomaly);
    
    % Кнопка генерации данных
    uicontrol('Parent', fig, 'Style', 'pushbutton', 'String', 'Генерировать', ...
              'Position', [20 70 260 30], 'Callback', @generate_data);
    
    % Отображение длины тренда
    trend_length_text = uicontrol('Parent', fig, 'Style', 'text', 'String', 'Длина тренда: -', ...
              'Position', [20 30 260 20], 'HorizontalAlignment', 'left');
    
    %% Правая часть окна - область графика
    axes_handle = axes('Parent', fig, 'Units', 'pixels', 'Position', [350 50 720 600]);
    
    %% Глобальные переменные
    global Data anomalies user_anomaly_data file_ext;
    Data = [];
    anomalies = {};
    user_anomaly_data = [];
    file_ext = '';
    
    %% Callback-функции
    function update_anomaly_ui(~, ~)
        type_idx = get(anomaly_type_menu, 'Value');
        type_list = get(anomaly_type_menu, 'String');
        anomaly_type = type_list{type_idx};
        if strcmp(anomaly_type, 'user')
            set(duration_label, 'Visible', 'off');
            set(anomaly_duration_edit, 'Visible', 'off');
            set(amplitude_label, 'Visible', 'off');
            set(anomaly_amplitude_edit, 'Visible', 'off');
            set(user_anomaly_button, 'Visible', 'on');
        else
            set(duration_label, 'Visible', 'on');
            set(anomaly_duration_edit, 'Visible', 'on');
            set(amplitude_label, 'Visible', 'on');
            set(anomaly_amplitude_edit, 'Visible', 'on');
            set(user_anomaly_button, 'Visible', 'off');
        end
    end

    function load_data(~, ~)
        [file, path] = uigetfile({'*.mat;*.csv','Файлы данных (*.mat, *.csv)'; '*.mat','MAT-файлы (*.mat)'; '*.csv','CSV-файлы (*.csv)'}, 'Выберите файл с данными');
        
        if file
            [~, ~, ext] = fileparts(file);
            file_ext = ext;
            
            if strcmp(ext, '.mat')
                data = load(fullfile(path, file));
                if isfield(data, 'Data')
                    Data = data.Data;
                else
                    errordlg('Файл MAT не содержит переменной "Data"', 'Ошибка');
                    return;
                end
            elseif strcmp(ext, '.csv')
                Data = readmatrix(fullfile(path, file));
            else
                errordlg('Выбран неподдерживаемый формат файла!', 'Ошибка');
                return;
            end
            
            set(trend_length_text, 'String', sprintf('Длина тренда: %d', length(Data)));
            median_values = median(Data, 1);
            axes(axes_handle);
            cla;
            plot(median_values, 'k', 'LineWidth', 2);
            xlabel('Номер столбца');
            ylabel('Медианное значение');
            title('График median_values');
            grid on;
        end
    end


    function load_user_anomaly(~, ~)
        [file, path] = uigetfile({'*.mat;*.csv','Файлы аномалии (*.mat, *.csv)'; '*.mat','MAT-файлы (*.mat)'; '*.csv','CSV-файлы (*.csv)'}, 'Выберите файл с пользовательской аномалией');
        if file
            [~, ~, ext] = fileparts(file);
            if strcmp(ext, '.mat')
                anomaly_data = load(fullfile(path, file));
                if isfield(anomaly_data, 'user_anomaly_data')
                    user_anomaly_data = anomaly_data.user_anomaly_data;
                else
                    errordlg('Файл MAT не содержит переменной "user_anomaly_data"', 'Ошибка');
                    return;
                end
            elseif strcmp(ext, '.csv')
                user_anomaly_data = readmatrix(fullfile(path, file));
            else
                errordlg('Выбран неподдерживаемый формат файла!', 'Ошибка');
                return;
            end
            msgbox('Пользовательская аномалия загружена!');
        end
    end

    function add_anomaly(~, ~)
        type_idx = get(anomaly_type_menu, 'Value');
        type_list = get(anomaly_type_menu, 'String');
        anomaly_type = type_list{type_idx};
        if strcmp(anomaly_type, 'user')
            if isempty(user_anomaly_data)
                msgbox('Ошибка: Сначала загрузите пользовательскую аномалию!', 'Ошибка', 'error');
                return;
            end
            start = str2double(get(anomaly_start_edit, 'String'));
            anomalies{end+1} = {anomaly_type, [], start, []};
        else
            if isempty(get(anomaly_duration_edit, 'String')) || isempty(get(anomaly_start_edit, 'String')) || isempty(get(anomaly_amplitude_edit, 'String'))
                msgbox('Ошибка: Поля "Длительность", "Начало" и "Амплитуда" не могут быть пустыми!', 'Ошибка', 'error');
                return;
            end
            duration = str2double(get(anomaly_duration_edit, 'String'));
            start = str2double(get(anomaly_start_edit, 'String'));
            amplitude = str2double(get(anomaly_amplitude_edit, 'String'));
            anomalies{end+1} = {anomaly_type, duration, start, amplitude};
        end
        update_anomaly_list();
    end

    function update_anomaly_list()
        anomaly_strings = cellfun(@(a) sprintf('%s: дл=%s, нач=%s, ампл=%s', ...
            a{1}, num2str(a{2}), num2str(a{3}), num2str(a{4})), anomalies, 'UniformOutput', false);
        set(anomaly_list, 'String', anomaly_strings);
    end

    function remove_anomaly(~, ~)
        selected_index = get(anomaly_list, 'Value');
        if selected_index > 0 && selected_index <= length(anomalies)
            anomalies(selected_index) = [];
            update_anomaly_list();
            if selected_index > length(anomalies)
                set(anomaly_list, 'Value', max(1, length(anomalies)));
            end
        end
    end

    function generate_data(~, ~)
        if isempty(Data)
            msgbox('Сначала загрузите данные!');
            return;
        end
        if isempty(get(trend_repeat_edit, 'String')) || isnan(str2double(get(trend_repeat_edit, 'String')))
            msgbox('Ошибка: Введите корректное число повторов тренда!', 'Ошибка', 'error');
            return;
        end
        median_values = median(Data, 1);
        trend = trend_highlighting(median_values, 3);
        trend_length = length(trend);
        trend_repeats = str2double(get(trend_repeat_edit, 'String'));
        repeated_trend = repmat(trend, 1, trend_repeats);
        spoiled_trend = repeated_trend;
    
        for i = 1:length(anomalies)
            anomaly = anomalies{i};
            if strcmp(anomaly{1}, 'user')
                user_dur = length(user_anomaly_data);
                if anomaly{3} + user_dur - 1 > length(repeated_trend)
                    msgbox('Ошибка: Аномалия выходит за пределы тренда!', 'Ошибка', 'error');
                    return;
                end
                spoiled_trend = add_impulse(spoiled_trend, anomaly{1}, anomaly{3}, user_dur, NaN, user_anomaly_data);
            else
                if anomaly{3} + anomaly{2} - 1 > length(repeated_trend)
                    msgbox('Ошибка: Аномалия выходит за пределы тренда!', 'Ошибка', 'error');
                    return;
                end
                spoiled_trend = add_impulse(spoiled_trend, anomaly{1}, anomaly{3}, anomaly{2}, anomaly{4});
            end
        end
    
        rms_signal = sum((mean(median_values(:)) - median_values(:)).^2) / length(median_values);
        snr = str2double(get(snr_edit, 'String'));
        noise_type_idx = get(noise_type_menu, 'Value');
        noise_types = get(noise_type_menu, 'String');
        noise_type = noise_types{noise_type_idx};
        data = adding_noise(spoiled_trend, noise_type, rms_signal, snr);
    
        if ~exist('data', 'dir')
            mkdir('data');
        end
    
        num_segments = floor(length(data) / trend_length);
        if num_segments == 0
            msgbox('Недостаточно данных для разбиения на тренды!');
            return;
        end
    
        trend_matrix = zeros(num_segments, trend_length);
        for i = 1:num_segments
            trend_matrix(i, :) = data((i - 1) * trend_length + 1 : i * trend_length);
        end
    
        if strcmp(file_ext, '.mat')
            save('generated_data.mat', 'trend_matrix');
        elseif strcmp(file_ext, '.csv')
            writematrix(trend_matrix, 'generated_data.csv');
        end
        axes(axes_handle);
        cla;
        hold on;
        len_original = length(median_values);
        len_generated = length(repeated_trend);
        x_original = -len_original:-1;
        x_generated = 1:len_generated;
        plot(x_original, median_values, 'k', 'LineWidth', 2);
        plot(x_original, trend, 'm', 'LineWidth', 2);
        plot(x_generated, data, 'b', 'LineWidth', 2);
        plot(x_generated, spoiled_trend, 'g', 'LineWidth', 2);
        plot(x_generated, repeated_trend, 'r', 'LineWidth', 2);
        xlabel('Номер столбца');
        ylabel('Значение тренда');
        title('Сравнение оригинальных и сгенерированных данных');
        legend({'Исходные данные', 'Исходный тренд', 'Данные с шумом', 'Тренд с аномалиями', 'Повторённый тренд'}, 'Location', 'best');
        grid on;
        hold off;
    end
end
