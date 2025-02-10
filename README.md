# TimeSeriesGeneration

Приложение на MATLAB, предназначенное для генерации временных рядов.

# Установка

## 1. Требования для развертывания

Убедитесь, что MATLAB Runtime (R2024a) установлен.  
Если нет, вы можете запустить установщик MATLAB Runtime.  
Чтобы найти его местоположение, введите:

```
>>mcrinstaller
```

в командной строке MATLAB.

Вы можете установить его, запустив MyAppInstaller_web.exe из папки installer.

**Примечание:** Для запуска установщика MATLAB Runtime вам потребуются права администратора. 

В качестве альтернативы, загрузите и установите версию MATLAB Runtime для Windows (R2024a)  
по следующей ссылке на сайте MathWorks:

[MATLAB Runtime](https://www.mathworks.com/products/compiler/mcr/index.html)

Для получения дополнительной информации о MATLAB Runtime и установщике MATLAB Runtime  
см. раздел **"Distribute Applications"** в документации MATLAB Compiler  
на сайте MathWorks.

---

## 2. Файлы для развертывания

После установки MATLAB R2024a нужно запустить TimeSeriesGenerator.exe. Приложение готово к использованию.

# Использование

После запуска экран приложение будет выглядеть следующим образом

<img src="images/Экран%20после%20загрузки.png" alt="image" width="75%" height="auto">

Чтобы загрузить данные нужно нажать кнопку "Загрузка данных". Можно выбрать уже имеющийся набор в data. На данный момент обязательно, чтобы это был .mat файл, в котором будет сохранена переменная Calm. После загрузки появится уведомление об успешной загрузке. Кроме того, сразу выведется длина изначальных данных - надпись "Длина тренда".

Если запустить приложение без дополнительных настроек, нажав коопку "Генерировать", появится график и уведомление о создании файла с новыми данными, они сохранются в папке data в той же папке, где лежит "TimeSeriesGenerator.exe".

<img src="images/Запуск приложения без настроек.png" alt="image" width="75%" height="auto">

Ниже появляется график, где черным цветом выделены исходные данные, розовым - тренд в исходных данных. Красным - повторенный тренд, количество повторов тренда задается в окошке "Повторы тренда". И синим - добавленные шумы, то есть итоговые данные. 

Вид шума можно задавать в окошке "Тип шума". На данный момент можно добавить white - белый, pink - розовый. SNR - задаёт соотношение амплитуды шума и изначальных данных, то есть:

$$ SNR = \frac{A^2_{данные}}{A^2_{шум}} $$

Рекомендуется ставить этот параметр от 1 до 2. Если в SNR ближе к 1, то данные более хаотичные, если к 2 - данные более приближены к тренду. Если поставить 0 или пустое значение, то будет сгенерирован только тренд.

Есть возможность добавить аномалии. Доступные типы аномалий на данный момент - имитированная Гауссовским распределением и треугольная. В окошке начало задается, где мы добавляем шум, начиная от начала данных, в окошке длительность задаётся размер данной аномалии. Аномалии отображаются в списке и есть возможность добавлять их и удалять соответствующими кнопками. Можно задать амплитуду аномалии в окошке амплитуда. При добавлении аномалии, которая выходит за длину тренда, будет выдана ошибка. 

<img src="images/Запуск приложения с аномалиями.png" alt="image" width="75%" height="auto">

Кроме того, добавляется зеленый график, показывающий измененный тренд.

После завершения генерации создается файл, в котором каждая строчка - это один повторенный, а затем измененный тренд. 

# Работа

На вход подаётся матрица, в которой каждая строка - это измеренеия за определенный период. Например, матрица 1000x500, в которой содержится 1000 дней и в каждый день по 500 измерений. 

```
median_values = median(Calm, 1);
```

Далее происходит выделение тренда с помощью Вейвлет-преобразований. В коде есть возможность редактировать Вейвлет и до какого уровня происходит разложение, по умолчанию стоит Вейлет - db4 и уровень 3.

```
trend = trend_highlighting(median_values, 3);
```

Код функции trend_highlighting для выделения:

```
[C, L] = wavedec(median_values, level, waveletName);
trend = wrcoef('a', C, L, waveletName, level);
```

Тренд повторяется 5 раз и получаются новые данные. Далее в тренд добавляются аномалии функцией add_impulse(trend, anomaly_type, start_idx, duration, amplitude). Код функции без комментариев:

```
function trend_with_anomaly = add_impulse(trend, anomaly_type, start_idx, duration, amplitude)
    trend_with_anomaly = trend;
    n = length(trend);
    
    if start_idx + duration - 1 > n
        error('Аномалия выходит за пределы длины тренда');
    end
    
    switch anomaly_type
        case 'triangle'
            anomaly = amplitude * triang(duration)';
        case 'gaussian'
            x = linspace(-2, 2, duration);
            anomaly = amplitude * exp(-x.^2);
        otherwise
            error('Неизвестный тип аномалии');
    end
    
    trend_with_anomaly(start_idx:start_idx+duration-1) = ...
        trend_with_anomaly(start_idx:start_idx+duration-1) + anomaly;
end
```

После идёт добавление шума. Сначала подсчитывается средне-квадратичное отклонение в данных:

```
rms_signal = sum((mean(median_values(:)) - median_values(:)).^2) / length(median_values);
```

Эти данные передаются в функцию adding_noise:

```
function noisy_signal = adding_noise(trend, noise_type, rms_signal, snr)
    if nargin < 4
        snr = 1;
    end

    % Генерация шума
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
    noise = k * noise;
    noisy_signal = trend + noise;

end
```

В итоге мы имеем готовые данные, которые осталось только разбить в новую матрицу:

```
trend_matrix = zeros(num_segments, trend_length);
for i = 1:num_segments
    trend_matrix(i, :) = data((i - 1) * trend_length + 1 : i * trend_length);
end

```