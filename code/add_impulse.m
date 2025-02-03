function trend_with_anomaly = add_impulse(trend, anomaly_type, start_idx, duration, amplitude)
    % Функция добавления аномалии в тренд
    % trend - входной тренд
    % anomaly_type - тип аномалии ('triangle' или 'gaussian')
    % start_idx - индекс начала аномалии
    % duration - продолжительность аномалии
    % amplitude - амплитуда аномалии

    trend_with_anomaly = trend;
    n = length(trend);
    
    if start_idx + duration - 1 > n
        error('Аномалия выходит за пределы длины тренда');
    end
    
    switch anomaly_type
        case 'triangle'
            % Создаём треугольный импульс
            anomaly = amplitude * triang(duration)';
        case 'gaussian'
            % Создаём импульс, моделированный по гауссовскому распределению
            x = linspace(-2, 2, duration);
            anomaly = amplitude * exp(-x.^2);
        otherwise
            error('Неизвестный тип аномалии');
    end
    
    trend_with_anomaly(start_idx:start_idx+duration-1) = ...
        trend_with_anomaly(start_idx:start_idx+duration-1) + anomaly;
end