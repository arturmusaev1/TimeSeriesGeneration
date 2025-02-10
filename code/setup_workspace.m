function trend_analysis_gui
    % Создаем графический интерфейс с увеличенным размером
    fig = figure('Name', 'Анализ трендов', 'NumberTitle', 'off', 'Position', [100 100 900 700]);

    % Кнопка загрузки данных
    uicontrol('Style', 'pushbutton', 'String', 'Загрузить данные', 'Position', [20 650 150 30], ...
              'Callback', @load_data);

    % Поле для ввода количества повторов
    uicontrol('Style', 'text', 'String', 'Повторы тренда:', 'Position', [200 650 100 20]);
    trend_repeat_edit = uicontrol('Style', 'edit', 'Position', [310 650 50 25], 'String', '5');

    % Кнопка добавления аномалий
    uicontrol('Style', 'pushbutton', 'String', 'Добавить аномалию', 'Position', [20 600 150 30], ...
              'Callback', @add_anomaly);

    % Поля для ввода параметров аномалий
    uicontrol('Style', 'text', 'String', 'Тип аномалии:', 'Position', [200 600 100 20]);
    anomaly_type_menu = uicontrol('Style', 'popupmenu', 'Position', [310 600 100 25], ...
                                  'String', {'gaussian', 'triangle'});
    % Поле задания длительности аномалии
    uicontrol('Style', 'text', 'String', 'Длительность:', 'Position', [200 570 100 20]);
    anomaly_duration_edit = uicontrol('Style', 'edit', 'Position', [310 570 50 25], 'String', '300');
    % Поле для ввода аномалии
    uicontrol('Style', 'text', 'String', 'Начало:', 'Position', [200 540 100 20]);
    anomaly_start_edit = uicontrol('Style', 'edit', 'Position', [310 540 50 25], 'String', '200');
    % Поле задания амплитуды аномалии
    uicontrol('Style', 'text', 'String', 'Амплитуда:', 'Position', [200 510 100 20]);
    anomaly_amplitude_edit = uicontrol('Style', 'edit', 'Position', [310 510 50 25], 'String', '2');
    % Поле выбора типа шума
    uicontrol('Style', 'text', 'String', 'Тип шума:', 'Position', [200 470 100 20]);
    noise_type_menu = uicontrol('Style', 'popupmenu', 'Position', [310 470 100 25], ...
                                'String', {'white', 'pink'});
    % Поле для ввода SNR
    uicontrol('Style', 'text', 'String', 'SNR:', 'Position', [200 440 100 20]);
    snr_edit = uicontrol('Style', 'edit', 'Position', [310 440 50 25], 'String', '2');
    
    uicontrol('Style', 'text', 'String', 'Тип аномалии: длительность, начало, амплитуда', ...
          'Position', [650 605 200 27], 'FontWeight', 'bold', 'HorizontalAlignment', 'left');

    % Поле для отображения длины тренда
    trend_length_text = uicontrol('Style', 'text', 'String', 'Длина тренда: -', 'Position', [20 420 200 20]);

    % Кнопка генерации данных
    uicontrol('Style', 'pushbutton', 'String', 'Генерировать', 'Position', [20 450 150 30], ...
              'Callback', @generate_data);

    % Окно для графика (увеличенное)
    axes_handle = axes('Units', 'pixels', 'Position', [50 100 800 300]);

    % Поле для отображения списка аномалий
    anomaly_list = uicontrol('Style', 'listbox', 'Position', [650 450 200 150]);

    % Кнопка удаления аномалий
    uicontrol('Style', 'pushbutton', 'String', 'Удалить аномалию', 'Position', [20 550 150 30], ...
              'Callback', @remove_anomaly);

    % Глобальные переменные
    global Calm anomalies;
    Calm = [];
    anomalies = {};

    function load_data(~, ~)
        [file, path] = uigetfile('*.mat', 'Выберите файл с данными');
        if file
            data = load(fullfile(path, file));
            Calm = data.Calm;
            trend_length = length(median(Calm, 1));
            set(trend_length_text, 'String', sprintf('Длина тренда: %d', trend_length));
            msgbox('Данные загружены!');
        end
    end

    function add_anomaly(~, ~)
        if isempty(get(anomaly_duration_edit, 'String')) || isempty(get(anomaly_start_edit, 'String'))
            msgbox('Ошибка: Поля "Длительность" и "Середина" не могут быть пустыми!', 'Ошибка', 'error');
            return;
        end
        type_idx = get(anomaly_type_menu, 'Value');
        type_list = get(anomaly_type_menu, 'String');
        anomaly_type = type_list{type_idx};
        duration = str2double(get(anomaly_duration_edit, 'String'));
        amplitude = str2double(get(anomaly_amplitude_edit, 'String'));
        start = str2double(get(anomaly_start_edit, 'String'));
        anomalies{end + 1} = {anomaly_type, duration, start, amplitude};
        update_anomaly_list();
    end

    function update_anomaly_list()
        anomaly_strings = cellfun(@(a) sprintf('%s: %d, %d, %d', a{1}, a{2}, a{3}, a{4}), anomalies, 'UniformOutput', false);
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
        if isempty(Calm)
            msgbox('Сначала загрузите данные!');
            return;
        end
        if isempty(get(trend_repeat_edit, 'String')) || isnan(str2double(get(trend_repeat_edit, 'String')))
            msgbox('Ошибка: Введите корректное число повторов тренда!', 'Ошибка', 'error');
            return;
        end
        median_values = median(Calm, 1);
        trend = trend_highlighting(median_values, 3);
        trend_length = length(trend);
        trend_repeats = str2double(get(trend_repeat_edit, 'String'));
        repeated_trend = repmat(trend, 1, trend_repeats);
        spoiled_trend = repeated_trend;

        for i = 1:length(anomalies)
            anomaly = anomalies{i};
            if anomaly{3} + anomaly{2} > length(repeated_trend)
                msgbox('Ошибка: Аномалия выходит за пределы тренда!', 'Ошибка', 'error');
                return;
            end
            spoiled_trend = add_impulse(spoiled_trend, anomaly{1}, anomaly{3}, anomaly{2}, anomaly{4});
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

        save('trend_data.mat', 'trend_matrix');

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
        legend({'Исходные данные', 'Исходный тренд', 'Данные с шумом', 'Тренд с аномалиями', 'Повторённый тренд'}, ...
            'Location', 'best');
        grid on;
        hold off;

        msgbox('Данные сохранены в файл "data/trend_data.mat"!');
    end
end
