function noisy_signal = adding_noise(trend, noise_type, rms_signal, snr)
% add_noise Добавляет белый или розовый шум к сигналу.
%
% Входные аргументы:
%   trend      - Входной тренд (вектор).
%   noise_type  - Тип шума: 'white' (белый) или 'pink' (розовый).
%   noise_level - Уровень шума (масштаб коэффициента).
%
% Выход:
%   noisy_signal - Сигнал с добавленным шумом.

    if nargin < 4
        snr = 1;
    end

    switch lower(noise_type)
        case 'white'
            noise = randn(size(trend));
        case 'pink'
            noise = pinknoise(size(trend));
        otherwise
            error('Неизвестный тип шума. Используйте "white" или "pink".');
    end

    mean_raw_noise = mean(noise(:));
    rms_noise_raw  = sum((mean_raw_noise - noise(:)).^2) / length(noise);
    desired_rms_noise = rms_signal / snr; 
    k = sqrt(desired_rms_noise / rms_noise_raw);
    noise       = k * noise;
    noisy_signal = trend + noise;

end
