function [trend, median_values, C, L] = trend_highlighting(Calm, level, waveletName)
% trend_highlighting Извлекает тренд из данных с помощью вейвлет-преобразования.
%
% Входные аргументы:
%   Calm        - Матрица данных (например, размер MxN).
%   waveletName - Название вейвлета. По умолчанию 'db4'.
%   level       - Уровень декомпозиции. По умолчанию 4.
%   plotDetails - Логический флаг для отображения детализационных коэффициентов. По умолчанию false.
%   thresholding - Логический флаг для применения пороговой фильтрации детализационных коэффициентов. По умолчанию false.
%
% Выходные аргументы:
%   trend         - Извлечённый тренд сигнала.
%   median_values - Вектор медианных значений по столбцам.
%   C             - Коэффициенты вейвлет-преобразования.
%   L             - Векторы длин коэффициентов.
    if nargin < 2 || isempty(level)
        level = 5;
    end
    if nargin < 3 || isempty(waveletName)
        waveletName = 'db4';
    end
    median_values = median(Calm, 1);
    [C, L] = wavedec(median_values, level, waveletName);
    trend = wrcoef('a', C, L, waveletName, level);

    figure;
    plot(median_values, 'LineWidth', 1.5);
    hold on;
    plot(trend, 'r', 'LineWidth', 2);
     xlabel('Номер столбца');
    ylabel('Медиана');
    title('Исходный сигнал и извлечённый тренд с помощью вейвлет-преобразования');
    legend('Исходный сигнал', 'Тренд');
    grid on;
    hold off;

