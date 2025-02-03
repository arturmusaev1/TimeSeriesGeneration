median_values = median(Calm, 1);
trend = trend_highlighting(median_values , 3);
repeated_trend = repmat(trend, 1, 5);
spoiled_trend = add_impulse(repeated_trend, 'gaussian', 300, 200, 2);
spoiled_trend = add_impulse(spoiled_trend, 'triangle', 2000, 500, 2);
rms_signal = sum((mean(median_values(:)) - median_values(:)).^2)/length(median_values);
data = adding_noise(spoiled_trend, 'pink', rms_signal, 1.5);
figure;
hold on;
len_original = length(median_values);
len_generated = length(data);
x_original = 1:len_original;  % Ось X для оригинальных данных
x_generated = (len_original + 1):(len_original + len_generated); % Ось X для новых данных
plot(x_original, median_values, 'k', 'LineWidth', 2); % Исходные данные (черный цвет)
plot(x_original, trend, 'm', 'LineWidth', 2);  % Исходный тренд (фиолетовый)
plot(x_generated, data, 'b', 'LineWidth', 2); % Шумные данные (синий цвет)
plot(x_generated, spoiled_trend, 'g', 'LineWidth', 2); % Тренд с аномалиями (зелёный)
plot(x_generated, repeated_trend, 'r', 'LineWidth', 2); % Повторённый тренд (красный)
xlabel('Номер столбца');
ylabel('Значение тренда');
title('Сравнение оригинальных и сгенерированных данных');
legend({'Исходные данные', 'Исходный тренд', 'Шумные данные', 'Тренд с аномалиями', 'Повторённый тренд'}, ...
    'Location', 'best');
grid on;
hold off;
