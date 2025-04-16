filename = '../data/matlab_data.csv';
data = readmatrix(filename, 'NumHeaderLines', 1);

min_val = min(data(:));
max_val = max(data(:));
display(min_val(:))
display(max_val(:))
data = (data - min_val) / (max_val - min_val);

model = arima('ARLags', 1:3, 'D', 1, 'MALags', 1:3);
estimated_model = estimate(model, data(:));

estimated_model = estimate(model, data(:));

numDays = 34;
syntheticData = zeros(size(data, 2), numDays);
for day = 1:numDays
    simulated_series = simulate(estimated_model, size(data, 2));
    simulated_series = simulated_series * (max_val - min_val) + min_val;
    syntheticData(:, day) = simulated_series;
end

headers = arrayfun(@num2str, 0:size(data, 2)-1, 'UniformOutput', false);
syntheticTable = array2table(syntheticData', 'VariableNames', headers);
outputFilename = '../data/generated_timeseries_arima.csv';
writetable(syntheticTable, outputFilename);

figure;
plot(syntheticData(:, 1:5));
title('Сгенерированные временные ряды с ARIMA (5 дней)');
xlabel('Время');
ylabel('Значение');
legend(arrayfun(@(x) sprintf('Day %d', x), 1:5, 'UniformOutput', false));
