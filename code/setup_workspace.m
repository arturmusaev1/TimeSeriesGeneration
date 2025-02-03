trend = trend_highlighting(Calm, 3);
repeated_trend = repmat(trend, 1, 3);
spoiled_trend_gaussian = add_impulse(repeated_trend, 'gaussian', 300, 500, 2);
spoiled_trend_triangle = add_impulse(repeated_trend, 'triangle', 300, 500, 2);
data = adding_noise(spoiled_trend, 'white');
figure;
hold on; % Позволяет рисовать все графики в одном окне
plot(data, 'b', 'LineWidth', 2); % Шумные данные
plot(spoiled_trend, 'g', 'LineWidth', 2); % Тренд с аномалиями
plot(repeated_trend, 'r', 'LineWidth', 2); % Исходный тренд
xlabel('Номер столбца');
ylabel('Значение тренда');
title('Повторённый тренд с аномалиями');
legend({'Шумные данные', 'Тренд с аномалиями', 'Исходный тренд'}, 'Location', 'best');
grid on;
hold off; 