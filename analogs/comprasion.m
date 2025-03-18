
original_data = readmatrix('../data/matlab_data.csv', 'NumHeaderLines', 1);
user_generated_data = readmatrix('../data/generated_data.csv', 'NumHeaderLines', 1);
gan_generated_data = readmatrix('../data/generated_gan.csv', 'NumHeaderLines', 1);
arima_generated_data = readmatrix('../data/generated_timeseries_arima.csv', 'NumHeaderLines', 1);
lstm_generated_data = readmatrix('../data/generated_lstm.csv', 'NumHeaderLines', 1);

mean_values = [mean(original_data(:)), mean(user_generated_data(:)), mean(gan_generated_data(:)), mean(arima_generated_data(:)), mean(lstm_generated_data(:))];
std_values = [std(original_data(:)), std(user_generated_data(:)), std(gan_generated_data(:)), std(arima_generated_data(:)), std(lstm_generated_data(:))];
median_values = [median(original_data(:)), median(user_generated_data(:)), median(gan_generated_data(:)), median(arima_generated_data(:)), median(lstm_generated_data(:))];
cv_values = std_values ./ mean_values;
mad_values = [mad(original_data(:)), mad(user_generated_data(:)), mad(gan_generated_data(:)), mad(arima_generated_data(:)), mad(lstm_generated_data(:))];
kurtosis_values = [kurtosis(original_data(:)), kurtosis(user_generated_data(:)), kurtosis(gan_generated_data(:)), kurtosis(arima_generated_data(:)), kurtosis(lstm_generated_data(:))];
skewness_values = [skewness(original_data(:)), skewness(user_generated_data(:)), skewness(gan_generated_data(:)), skewness(arima_generated_data(:)), skewness(lstm_generated_data(:))];

min_values = [min(median(original_data, 2)), min(median(user_generated_data, 2)), min(median(gan_generated_data, 2)), min(median(arima_generated_data, 2)), min(median(lstm_generated_data, 2))];
max_values = [max(median(original_data)), max(median(user_generated_data)), max(median(gan_generated_data)), max(median(arima_generated_data)), max(median(lstm_generated_data))];

stats_table = table({'Original', 'User Generated', 'GAN Generated', 'ARIMA Generated', 'LSTM Generated'}', mean_values', std_values', median_values', min_values', max_values', cv_values', mad_values', kurtosis_values', skewness_values', ...
    'VariableNames', {'Dataset', 'Mean', 'Std_Dev', 'Median', 'Min', 'Max', 'CV', 'MAD', 'Kurtosis', 'Skewness'});
disp(stats_table);

original_median = median(original_data, 1);
user_generated_median = median(user_generated_data, 1);
gan_generated_median = median(gan_generated_data, 1);
arima_generated_median = median(arima_generated_data, 1);
lstm_generated_median = median(lstm_generated_data, 1);

figure;

subplot(5,1,1);
plot(original_median, 'LineWidth', 1.5);
legend('Original Data');
title('Median Values (Original Data)');
xlabel('Time Steps');
ylabel('Median Value');
grid on;

subplot(5,1,2);
plot(user_generated_median, 'LineWidth', 1.5);
legend('User Generated Data');
title('Median Values (User Generated Data)');
xlabel('Time Steps');
ylabel('Median Value');
grid on;

subplot(5,1,3);
plot(gan_generated_median,'LineWidth', 1.5);
legend('GAN Generated Data');
title('Median Values (GAN Generated Data)');
xlabel('Time Steps');
ylabel('Median Value');
grid on;

subplot(5,1,4);
plot(arima_generated_median, 'LineWidth', 1.5);
legend('ARIMA Generated Data');
title('Median Values (ARIMA Generated Data)');
xlabel('Time Steps');
ylabel('Median Value');
grid on;

subplot(5,1,5);
plot(lstm_generated_median, 'LineWidth', 1.5);
legend('LSTM Generated Data');
title('Median Values (LSTM Generated Data)');
xlabel('Time Steps');
ylabel('Median Value');
grid on;