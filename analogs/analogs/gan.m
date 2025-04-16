
filename = '../data/matlab_data.csv';
data = readmatrix(filename);

[num_samples, sequence_length] = size(data);

min_val = min(data(:));
max_val = max(data(:));
data = (data - min_val) / (max_val - min_val);

latent_dim = 100;

generator = dlnetwork(layerGraph([...
    featureInputLayer(latent_dim, 'Name', 'input')
    fullyConnectedLayer(256, 'Name', 'fc1')
    reluLayer('Name', 'relu1')
    fullyConnectedLayer(512, 'Name', 'fc2')
    reluLayer('Name', 'relu2')
    fullyConnectedLayer(sequence_length, 'Name', 'fc3')
    tanhLayer('Name', 'tanh')
]));

discriminator = dlnetwork(layerGraph([...
    featureInputLayer(sequence_length, 'Name', 'input')
    fullyConnectedLayer(512, 'Name', 'fc1')
    leakyReluLayer(0.2, 'Name', 'lrelu1')
    fullyConnectedLayer(256, 'Name', 'fc2')
    leakyReluLayer(0.2, 'Name', 'lrelu2')
    fullyConnectedLayer(1, 'Name', 'fc3')
    sigmoidLayer('Name', 'sigmoid')
]));

learnRate = 0.0002;
beta1 = 0.5;

trailingAvg = [];
trailingAvgSq = [];
trailingAvgD = [];
trailingAvgSqD = [];

numEpochs = 1000;
batchSize = 32;

for epoch = 1:numEpochs
    for i = 1:batchSize:num_samples
        idx = i:min(i+batchSize-1, num_samples);
        realData = data(idx, :);
        realData = dlarray(realData', 'CB');
        
        noise = randn([latent_dim, numel(idx)]);
        noise = dlarray(noise, 'CB');
        
        [gradientsD, dLoss] = dlfeval(@discriminatorLoss, discriminator, generator, realData, noise);
        [discriminator, trailingAvgD, trailingAvgSqD] = adamupdate(discriminator, gradientsD, trailingAvgD, trailingAvgSqD, epoch, learnRate, beta1);
        
        [gradientsG, gLoss] = dlfeval(@generatorLoss, generator, discriminator, noise);
        [generator, trailingAvg, trailingAvgSq] = adamupdate(generator, gradientsG, trailingAvg, trailingAvgSq, epoch, learnRate, beta1);
    end
    fprintf('Эпоха %d завершена.\n', epoch);
end

numDays = 34;
syntheticData = zeros(sequence_length, numDays);
for day = 1:numDays
    noise = randn([latent_dim, 1]);
    noise = dlarray(noise, 'CB');
    generatedSeries = predict(generator, noise);
    generatedSeries = extractdata(generatedSeries);
    generatedSeries = generatedSeries * (max_val - min_val) + min_val; % Обратная нормализация
    syntheticData(:, day) = generatedSeries;
end
headers = arrayfun(@num2str, 0:sequence_length-1, 'UniformOutput', false);

syntheticTable = array2table(syntheticData', 'VariableNames', headers);

outputFilename = '../data/generated_gan.csv';
writetable(syntheticTable, outputFilename);

figure;
plot(syntheticData(:, 1:5));
title('Сгенерированные GAN временные ряды (5 дней)');
xlabel('Время');
ylabel('Значение');
legend(arrayfun(@(x) sprintf('Day %d', x), 1:5, 'UniformOutput', false));

function [gradientsD, lossD] = discriminatorLoss(discriminator, generator, realData, noise)
    fakeData = predict(generator, noise);
    fakeData = dlarray(fakeData, 'CB');
    
    dReal = predict(discriminator, realData);
    dFake = predict(discriminator, fakeData);
    
    lossD = -mean(log(dReal) + log(1 - dFake));
    lossD = dlarray(lossD, 'CB');
    gradientsD = dlgradient(lossD, discriminator.Learnables);
end

function [gradientsG, lossG] = generatorLoss(generator, discriminator, noise)
    fakeData = predict(generator, noise);
    lossG = -mean(log(predict(discriminator, fakeData)));
    lossG = dlarray(lossG, 'CB');
    gradientsG = dlgradient(lossG, generator.Learnables);
end
