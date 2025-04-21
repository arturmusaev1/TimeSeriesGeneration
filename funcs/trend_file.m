inputFile = 'quadratic_series.csv';        
referenceFile = 'quadratic_trend_only.csv'; 
outputFile = 'trend_wavelet.csv';       

waveletName = 'haar';            
level = 5;                               

median_values = readmatrix(inputFile); 
median_values = median_values(:);    

ref_data = readmatrix(referenceFile);   
ref_trend = ref_data(:);    

[C, L] = wavedec(median_values, level, waveletName);

trend = wrcoef('a', C, L, waveletName, level);

mse = mean((trend - ref_trend).^2);
mae = mean(abs(trend - ref_trend));
mape = mean(abs((trend - ref_trend) ./ ref_trend)) * 100;

fprintf('Метрики для сравнения с эталоном:\n');
fprintf('MSE  = %.6f\n', mse);
fprintf('MAE  = %.6f\n', mae);
fprintf('MAPE = %.2f%%\n', mape);

T = (0:length(trend)-1)';
result = table(T, median_values, trend, ref_trend, ...
    'VariableNames', {'Time', 'Original', 'ExtractedTrend', 'ReferenceTrend'});
writetable(result, outputFile);

figure;
plot(T, median_values, 'k:', 'DisplayName', 'Исходный ряд');
hold on;
plot(T, ref_trend, 'g-', 'LineWidth', 1.5, 'DisplayName', 'Эталонный тренд');
plot(T, trend, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Выделенный тренд');
legend;
xlabel('Время');
ylabel('Значение');
title('Сравнение выделенного и эталонного тренда');
grid on;
