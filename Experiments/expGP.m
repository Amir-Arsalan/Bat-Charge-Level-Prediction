function expGP(dataset, percentTrain, from, to)

data = [find(dataset(from:to, 8) == 1), dataset(dataset(from:to, 8) == 1, [4, 5, 7])];
target = dataset(dataset(from:to, 8) == 1, 6);

trainData = data(1:round(size(data, 1) * percentTrain), :);
trainTarget = target(1:round(size(target, 1) * percentTrain));

testData = data(size(trainData, 1)+1:end, :);
testTarget = target(size(trainTarget, 1)+1:end);

end