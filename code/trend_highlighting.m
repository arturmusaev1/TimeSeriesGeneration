function [trend, median_values, C, L] = trend_highlighting(median_values, level, waveletName)
% trend_highlighting Извлекает тренд из данных с помощью вейвлет-преобразования.
%
% Входные аргументы:.
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
    [C, L] = wavedec(median_values, level, waveletName);
    trend = wrcoef('a', C, L, waveletName, level);

