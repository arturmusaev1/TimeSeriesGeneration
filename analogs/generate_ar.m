filename = '../Данные/OULU 01.01.2011 - 31.12.2012 форматированное.csv';
data = readmatrix(filename);

mean_series = mean(data, 1); 

min_val = min(mean_series);
max_val = max(mean_series);
normalized_series = (mean_series - min_val) / (max_val - min_val);

model = arima('ARLags', 1:3, 'D', 1, 'MALags', 1:3);

estimated_model = estimate(model, normalized_series');

numGenerated = 30;                        
sequence_length = length(mean_series);  
syntheticData = zeros(sequence_length, numGenerated);

for k = 1:numGenerated
    simulated = simulate(estimated_model, sequence_length);
    simulated = simulated * (max_val - min_val) + min_val;
    syntheticData(:, k) = simulated;
end

figure;
plot(syntheticData);
title('Сгенерированные временные ряды с помощью ARIMA');
xlabel('Время'); ylabel('Значение');
legend(arrayfun(@(k) sprintf('Ряд %d', k), 1:numGenerated, 'UniformOutput', false));

T = array2table(syntheticData', 'VariableNames', ...
    arrayfun(@(i) sprintf('t%d', i), 1:sequence_length, 'UniformOutput', false));
writetable(T, 'generated_arima.csv');

outputFolder = '../data';
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

outputFile = fullfile(outputFolder, 'generated_arima.csv');
headers = arrayfun(@(i) sprintf('t%d', i), 1:sequence_length, 'UniformOutput', false);
T = array2table(syntheticData', 'VariableNames', headers);
writetable(T, outputFile);

fprintf('Сгенерированные ARIMA-данные сохранены в %s\n', outputFile);
