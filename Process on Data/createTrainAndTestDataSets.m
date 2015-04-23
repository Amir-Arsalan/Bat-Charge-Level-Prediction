function [trainData, testData] = createTrainAndTestDataSets(dataSet)
%Given an analyzable phone usage data set, the program selects phone usage data for train and test data sets randomly. The train
%data has approximately 5000 data points and the rest will be choosen as
%test data points

num_phoneUsageData = size(dataSet, 1);
randomlySelectedRows = randperm(num_phoneUsageData)'; %Generate random row numbers
num_rows = 0;
i = 0;
trainData = [];
while(num_rows <= 5500) %Until the number of data points in the training data set is less or equal to 5000
    i = i + 1;
    trainData = [trainData; dataSet{randomlySelectedRows(i, 1), 1}]; %Add the selected row to the training data
    num_rows = num_rows + size(dataSet{randomlySelectedRows(i, 1), 1}, 1);
end

randomlySelectedRows = randomlySelectedRows(i:end, 1);
counter = 1;
testData = [];
i = 0;
while(i < size(randomlySelectedRows, 1))
    i = i + 1;
    testData = [testData; dataSet{randomlySelectedRows(i, 1), 1}];
end
denominatorVector = [100, 288, 288, 100];
trainData = normalizeData(trainData, denominatorVector);
testData = normalizeData(testData, denominatorVector);
end