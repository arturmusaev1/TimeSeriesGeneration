
original_data = readmatrix('../Данные/OULU 01.01.2011 - 31.12.2012 форматированное.csv', 'NumHeaderLines', 1);
user_generated_data = readmatrix('../data/generated_data.csv', 'NumHeaderLines', 1);
gan_generated_data = readmatrix('../data/generated_gan.csv', 'NumHeaderLines', 1);
arima_generated_data = readmatrix('../data/generated_arima.csv', 'NumHeaderLines', 1);
lstm_generated_data = readmatrix('../data/generated_lstm.csv', 'NumHeaderLines', 1);

mean_values = [mean(original_data(:)), mean(user_generated_data(:)), mean(gan_generated_data(:)), mean(arima_generated_data(:)), mean(lstm_generated_data(:))];
std_values = [std(original_data(:)), std(user_generated_data(:)), std(gan_generated_data(:)), std(arima_generated_data(:)), std(lstm_generated_data(:))];
median_values = [median(original_data(:)), median(user_generated_data(:)), median(gan_generated_data(:)), median(arima_generated_data(:)), median(lstm_generated_data(:))];

min_values = [min(original_data), min(user_generated_data), min(median(gan_generated_data)), min(median(arima_generated_data)), min(median(lstm_generated_data))];
max_values = [max(original_data), max(user_generated_data), max(median(gan_generated_data)), max(median(arima_generated_data)), max(median(lstm_generated_data))];

stats_table = table({'Original', 'User Generated', 'GAN Generated', 'ARIMA Generated', 'LSTM Generated'}', mean_values', std_values', median_values', min_values', max_values', ...
    'VariableNames', {'Dataset', 'Mean', 'Std_Dev', 'Median', 'Min', 'Max'});
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
title('Original Data');
xlabel('Time Steps');
ylabel('Median Value');
grid on;

subplot(5,1,2);
plot(user_generated_median, 'LineWidth', 1.5);
legend('User Generated Data');
title('User Generated Data');
xlabel('Time Steps');
ylabel('Median Value');
grid on;

subplot(5,1,3);
plot(gan_generated_median,'LineWidth', 1.5);
legend('GAN Generated Data');
title('GAN Generated Data');
xlabel('Time Steps');
ylabel('Median Value');
grid on;

subplot(5,1,4);
plot(arima_generated_median, 'LineWidth', 1.5);
legend('ARIMA Generated Data');
title('ARIMA Generated Data');
xlabel('Time Steps');
ylabel('Median Value');
grid on;

subplot(5,1,5);
plot(lstm_generated_median, 'LineWidth', 1.5);
legend('LSTM Generated Data');
title('LSTM Generated Data');
xlabel('Time Steps');
ylabel('Median Value');
grid on;