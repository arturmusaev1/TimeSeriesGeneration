filename = '../Данные/OULU 01.01.2011 - 31.12.2012 форматированное.csv';
data = readmatrix(filename);
[num_samples, sequence_length] = size(data);

min_val = min(data(:));
max_val = max(data(:));
data = 2 * (data - min_val) / (max_val - min_val) - 1;

latent_dim = 100;
numEpochs = 30;
batchSize = 32;
learnRate = 0.0002;
beta1 = 0.5;

layersG = layerGraph([
    sequenceInputLayer(latent_dim, 'Name', 'input')
    lstmLayer(128, 'OutputMode', 'sequence', 'Name', 'lstm1')
    fullyConnectedLayer(sequence_length, 'Name', 'fc')
    tanhLayer('Name', 'tanh')
]);
lstmGenerator = dlnetwork(layersG);

layersD = layerGraph([
    sequenceInputLayer(sequence_length, 'Name', 'input')
    lstmLayer(128, 'OutputMode', 'last', 'Name', 'lstm1')
    fullyConnectedLayer(1, 'Name', 'fc')
    sigmoidLayer('Name', 'sigmoid')
]);
discriminator = dlnetwork(layersD);

for epoch = 1:numEpochs
    idx = randperm(num_samples);
    for i = 1:batchSize:num_samples
        batch_idx = idx(i:min(i+batchSize-1, num_samples));
        realData = data(batch_idx, :)';
        realData = reshape(realData, [sequence_length 1 numel(batch_idx)]);  % [T, 1, N]
        realData = dlarray(realData, 'CTB');

        noise = randn(latent_dim, 1, numel(batch_idx), 'single');
        noise = dlarray(noise, 'CTB');

        [gradientsD, dLoss] = dlfeval(@discriminatorLoss, discriminator, lstmGenerator, realData, noise);
        discriminator = adamupdate(discriminator, gradientsD, [], [], epoch, learnRate, beta1);

        [gradientsG, gLoss] = dlfeval(@generatorLoss, lstmGenerator, discriminator, noise);
        lstmGenerator = adamupdate(lstmGenerator, gradientsG, [], [], epoch, learnRate, beta1);
    end
    fprintf('Эпоха %d: D-LOSS = %.4f, G-LOSS = %.4f\n', epoch, extractdata(dLoss), extractdata(gLoss));
end

numGenerate = 30;
syntheticData = zeros(sequence_length, numGenerate);
for k = 1:numGenerate
    noise = randn(latent_dim, 1, 1, 'single');
    noise = dlarray(noise, 'CTB');
    generated = predict(lstmGenerator, noise);
    generated = extractdata(generated);
    generated = (generated + 1) / 2 * (max_val - min_val) + min_val;
    syntheticData(:, k) = generated;
end

figure;
plot(syntheticData);
title('Сгенерированные временные ряды с LSTM');
xlabel('Время'); ylabel('Значение');
legend(arrayfun(@(k) sprintf('Ряд %d', k), 1:numGenerate, 'UniformOutput', false));

outputFolder = '../data';
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

outputFile = fullfile(outputFolder, 'generated_lstm.csv');
headers = arrayfun(@(i) sprintf('t%d', i), 1:sequence_length, 'UniformOutput', false);
T = array2table(syntheticData', 'VariableNames', headers);
writetable(T, outputFile);

fprintf('Сгенерированные LSTM-данные сохранены в %s\n', outputFile);

function [gradientsD, lossD] = discriminatorLoss(D, G, realData, noise)
    fakeData = predict(G, noise);
    dReal = predict(D, realData);
    dFake = predict(D, fakeData);
    lossD = -mean(log(dReal) + log(1 - dFake));
    gradientsD = dlgradient(lossD, D.Learnables);
end

function [gradientsG, lossG] = generatorLoss(G, D, noise)
    fakeData = predict(G, noise);
    dOut = predict(D, fakeData);
    lossG = -mean(log(dOut));
    gradientsG = dlgradient(lossG, G.Learnables);
end
