filename = '../data/matlab_data.csv';
data = readmatrix(filename, 'NumHeaderLines', 1);

[num_samples, sequence_length] = size(data);

min_val = min(data(:));
max_val = max(data(:));
data = (data - min_val) / (max_val - min_val);

latent_dim = 100;

lstmGenerator = dlnetwork(layerGraph([...
    sequenceInputLayer(latent_dim, 'Name', 'input')
    lstmLayer(128, 'OutputMode', 'sequence', 'Name', 'lstm1')
    fullyConnectedLayer(sequence_length, 'Name', 'fc1')
    tanhLayer('Name', 'tanh')
]));

discriminator = dlnetwork(layerGraph([...
    sequenceInputLayer(sequence_length, 'Name', 'input')
    lstmLayer(128, 'OutputMode', 'last', 'Name', 'lstm1')
    fullyConnectedLayer(1, 'Name', 'fc1')
    sigmoidLayer('Name', 'sigmoid')
]));

learnRate = 0.0002;
beta1 = 0.5;

numEpochs = 150;
batchSize = 32;

for epoch = 1:numEpochs
    for i = 1:batchSize:num_samples
        idx = i:min(i+batchSize-1, num_samples);
        realData = data(idx, :);
        realData = dlarray(realData', 'CTB');
        
        noise = randn([latent_dim, 1, numel(idx)]); % Исправлено: добавлен размер батча
        noise = dlarray(noise, 'CTB');
        
        [gradientsD, dLoss] = dlfeval(@discriminatorLoss, discriminator, lstmGenerator, realData, noise);
        [discriminator] = adamupdate(discriminator, gradientsD, [], [], epoch, learnRate, beta1);
        
        [gradientsG, gLoss] = dlfeval(@generatorLoss, lstmGenerator, discriminator, noise);
        [lstmGenerator] = adamupdate(lstmGenerator, gradientsG, [], [], epoch, learnRate, beta1);
    end
    fprintf('Эпоха %d завершена.\n', epoch);
end

numDays = 34;
syntheticData = zeros(sequence_length, numDays);
for day = 1:numDays
    noise = randn([latent_dim, 1, 1]);
    noise = dlarray(noise, 'CTB');
    generatedSeries = predict(lstmGenerator, noise);
    generatedSeries = extractdata(generatedSeries);
    generatedSeries = generatedSeries * (max_val - min_val) + min_val; % Обратная нормализация
    syntheticData(:, day) = generatedSeries;
end

headers = arrayfun(@num2str, 0:sequence_length-1, 'UniformOutput', false);
syntheticTable = array2table(syntheticData', 'VariableNames', headers);

outputFilename = '../data/generated_lstm.csv';;
writetable(syntheticTable, outputFilename);

figure;
plot(syntheticData(:, 1:5));
title('Сгенерированные временные ряды (5 дней) - LSTM-GAN');
xlabel('Время');
ylabel('Значение');
legend(arrayfun(@(x) sprintf('Day %d', x), 1:5, 'UniformOutput', false));

function [gradientsD, lossD] = discriminatorLoss(discriminator, generator, realData, noise)
    fakeData = predict(generator, noise);
    fakeData = dlarray(fakeData, 'CTB');
    
    dReal = predict(discriminator, realData);
    dFake = predict(discriminator, fakeData);
    
    lossD = -mean(log(dReal) + log(1 - dFake));
    lossD = dlarray(lossD, 'CB');
    gradientsD = dlgradient(lossD, discriminator.Learnables);
end

function [gradientsG, lossG] = generatorLoss(generator, discriminator, noise)
    fakeData = predict(generator, noise);
    fakeData = dlarray(fakeData, 'CTB');
    lossG = -mean(log(predict(discriminator, fakeData)));
    lossG = dlarray(lossG, 'CB');
    gradientsG = dlgradient(lossG, generator.Learnables);
end