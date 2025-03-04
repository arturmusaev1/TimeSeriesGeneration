function trend_with_anomaly = add_impulse(trend, anomaly_type, start_idx, duration, amplitude, user_anomaly)
% add_impulse Добавляет аномалию в данные.
%
% Входные аргументы:
%   trend         - выделенный ранее тренд данных
%   anomaly_type  - тип аномалии. Доступны 'gaussian' - аномалия,
%                   моделированная по Гауссу, 'triangle' - треугольный импульс,
%                   'user' - пользовательская аномалия (при этом длительность вычисляется автоматически)
%   start_idx     - индекс начала аномалии
%   duration      - длительность аномалии (используется для 'gaussian' и 'triangle')
%   amplitude     - амплитуда аномалии (для масштабирования, не применяется для 'user')
%   user_anomaly  - (необязательный) вектор, задающий пользовательскую аномалию
%
% Выходные аргументы:
%   trend_with_anomaly - измененный тренд
%
% Если для типа 'user' параметр user_anomaly не передан, функция пытается использовать
% глобальную переменную user_anomaly_data.

    if nargin < 6 || isempty(user_anomaly)
        global user_anomaly_data;
        user_anomaly = user_anomaly_data;
    end

    trend_with_anomaly = trend;
    
    if strcmp(anomaly_type, 'user')
        duration = length(user_anomaly);
    end

    n = length(trend);
    if start_idx + duration - 1 > n
        error('Аномалия выходит за пределы тренда');
    end
    
    switch anomaly_type
        case 'triangle'
            anomaly = amplitude * triang(duration)';
        case 'gaussian'
            x = linspace(-2, 2, duration);
            anomaly = amplitude * exp(-x.^2);
        case 'user'
            if isempty(user_anomaly)
                error('Пользовательская аномалия не загружена');
            end
            % Для пользовательской аномалии не масштабируем сигнал
            anomaly = user_anomaly;
            anomaly = reshape(anomaly, 1, []);
        otherwise
            error('Неизвестный тип аномалии');
    end

    if size(anomaly,1) > 1
        anomaly = anomaly';
    end

    trend_with_anomaly(start_idx:start_idx+duration-1) = ...
        trend_with_anomaly(start_idx:start_idx+duration-1) + anomaly;
end
