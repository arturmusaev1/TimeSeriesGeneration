function trend_with_anomaly = add_impulse(trend, anomaly_type, start_idx, duration, amplitude)
% add_impulse Добавляет аномалию в данные.
%
% Входные аргументы:
%   trend - выделенный ранее тренд данных
%   anomaly_type - тип аномалии. Доступны 'gaussian' - аномалия,
%   моделированная по Гауссу, 'triangle' - треугольный импульс
%   start_idx - индекс начала аномалии
%   duration - длительность аномалии
%   amplitude - амлитуда аномаллии
% Выходные аргументы:
%   trend_with_anomaly - измененный тренд
    trend_with_anomaly = trend;
    n = length(trend);
    
    if start_idx + duration - 1 > n
        error('Аномалия выходит за пределы длины тренда');
    end
    
    switch anomaly_type
        case 'triangle'
            anomaly = amplitude * triang(duration)';
        case 'gaussian'
            x = linspace(-2, 2, duration);
            anomaly = amplitude * exp(-x.^2);
        otherwise
            error('Неизвестный тип аномалии');
    end
    
    trend_with_anomaly(start_idx:start_idx+duration-1) = ...
        trend_with_anomaly(start_idx:start_idx+duration-1) + anomaly;
end