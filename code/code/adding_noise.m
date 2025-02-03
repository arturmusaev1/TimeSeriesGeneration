function noisy_signal = adding_noise(signal, noise_type, noise_level)
% add_noise Добавляет белый или розовый шум к сигналу.
%
% Входные аргументы:
%   signal      - Входной сигнал (вектор).
%   noise_type  - Тип шума: 'white' (белый) или 'pink' (розовый).
%   noise_level - Уровень шума (масштаб коэффициента).
%
% Выход:
%   noisy_signal - Сигнал с добавленным шумом.
%

    if nargin < 3
        noise_level = 0.5;
    end

    % Генерация шума
    switch lower(noise_type)
        case 'white'
            noise = noise_level * randn(size(signal)); % Белый шум
        case 'pink'
            % Генерация розового шума путём фильтрации белого шума
            % Коэффициенты фильтра подобраны так, чтобы обеспечить 1/f спектр
            b = [0.049922035, -0.095993537,  0.050612699, -0.004408786];
            a = [1,           -2.494956002,  2.017265875, -0.522189400];
            
            white_noise = randn(size(signal));
            pink_noise  = filter(b, a, white_noise);
            pink_noise = pink_noise / max(abs(pink_noise(:)));
            
            noise = 5 * noise_level * pink_noise;
        otherwise
            error('Неизвестный тип шума. Используйте "white" или "pink".');
    end

    noisy_signal = signal + noise;
end
