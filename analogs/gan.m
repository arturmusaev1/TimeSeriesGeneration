filename = '../Данные/OULU 01.01.2011 - 31.12.2012 форматированное.csv';
data = readmatrix(filename);
[num_samples, sequence_length] = size(data);

min_val = min(data(:));
max_val = max(data(:));
data = 2 * (data - min_val) / (max_val - min_val) - 1;

latent_dim = 100;
numEpochs = 100;
batchSize = 32;
learnRate = 0.0002;
beta1 = 0.5;

generator = dlnetwork(layerGraph([
    featureInputLayer(latent_dim, 'Name', 'input')
    fullyConnectedLayer(256, 'Name', 'fc1')
    reluLayer('Name', 'relu1')
    fullyConnectedLayer(512, 'Name', 'fc2')
    reluLayer('Name', 'relu2')
    fullyConnectedLayer(sequence_length, 'Name', 'fc3')
    tanhLayer('Name', 'tanh')
]));

discriminator = dlnetwork(layerGraph([
    featureInputLayer(sequence_length, 'Name', 'input')
    fullyConnectedLayer(512, 'Name', 'fc1')
    leakyReluLayer(0.2, 'Name', 'lrelu1')
    fullyConnectedLayer(256, 'Name', 'fc2')
    leakyReluLayer(0.2, 'Name', 'lrelu2')
    fullyConnectedLayer(1, 'Name', 'fc3')
    sigmoidLayer('Name', 'sigmoid')
]));

trailingAvg = []; trailingAvgSq = [];
trailingAvgD = []; trailingAvgSqD = [];

for epoch = 1:numEpochs
    idx = randperm(num_samples);
    for i = 1:batchSize:num_samples
        batch_idx = idx(i:min(i+batchSize-1, num_samples));
        realData = data(batch_idx, :)';
        realData = dlarray(realData, 'CB');

        noise = randn(latent_dim, numel(batch_idx), 'single');
        noise = dlarray(noise, 'CB');

        [gradientsD, dLoss] = dlfeval(@discriminatorLoss, discriminator, generator, realData, noise);
        [discriminator, trailingAvgD, trailingAvgSqD] = adamupdate(discriminator, gradientsD, ...
            trailingAvgD, trailingAvgSqD, epoch, learnRate, beta1);

        [gradientsG, gLoss] = dlfeval(@generatorLoss, generator, discriminator, noise);
        [generator, trailingAvg, trailingAvgSq] = adamupdate(generator, gradientsG, ...
            trailingAvg, trailingAvgSq, epoch, learnRate, beta1);
    end
    fprintf('Эпоха %d: D-LOSS = %.4f, G-LOSS = %.4f\n', epoch, extractdata(dLoss), extractdata(gLoss));
end

num_generate = 30;
syntheticData = zeros(sequence_length, num_generate);
for k = 1:num_generate
    noise = randn(latent_dim, 1, 'single');
    noise = dlarray(noise, 'CB');
    generated = predict(generator, noise);
    generated = extractdata(generated);
    generated = (generated + 1) / 2 * (max_val - min_val) + min_val;
    syntheticData(:, k) = generated;
end

figure;
plot(syntheticData);
title('Сгенерированные временные ряды GAN');
xlabel('Время'); ylabel('Счёт');
legend(arrayfun(@(k) sprintf('Ряд %d', k), 1:num_generate, 'UniformOutput', false));

outputFolder = '../data';
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

outputFile = fullfile(outputFolder, 'generated_gan.csv');
headers = arrayfun(@(i) sprintf('t%d', i), 1:sequence_length, 'UniformOutput', false);
T = array2table(syntheticData', 'VariableNames', headers);
writetable(T, outputFile);

fprintf('Сгенерированные данные сохранены в %s\n', outputFile);


function [gradientsD, lossD] = discriminatorLoss(D, G, realData, noise)
    fakeData = predict(G, noise);
    fakeData = dlarray(fakeData, 'CB');
    outReal = predict(D, realData);
    outFake = predict(D, fakeData);
    lossD = -mean(log(outReal) + log(1 - outFake));
    gradientsD = dlgradient(lossD, D.Learnables);
end

function [gradientsG, lossG] = generatorLoss(G, D, noise)
    fakeData = predict(G, noise);
    out = predict(D, fakeData);
    lossG = -mean(log(out));
    gradientsG = dlgradient(lossG, G.Learnables);
end
