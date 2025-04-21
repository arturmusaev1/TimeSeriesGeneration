user_generated_data = readmatrix('../data/generated_data.csv', 'NumHeaderLines', 1);

mean_val = mean(user_generated_data(:));
std_val = std(user_generated_data(:));
median_val = median(user_generated_data(:));
min_val = min(user_generated_data(:));
max_val = max(user_generated_data(:));

stats_table = table("User Generated", mean_val, std_val, median_val, min_val, max_val, ...
    'VariableNames', {'Dataset', 'Mean', 'Std_Dev', 'Median', 'Min', 'Max'});
disp(stats_table);

user_generated_median = median(user_generated_data, 1);

figure;
plot(user_generated_median, 'LineWidth', 1.5);
legend('User Generated Data');
title('User Generated Data - Median by Time Step');
xlabel('Time Steps');
ylabel('Median Value');
grid on;
