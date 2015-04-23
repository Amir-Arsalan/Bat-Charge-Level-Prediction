function clusters = clusterUsers(dataSet)
%usageData = A cell matrix with the size m x f(depends on the number of usage datasets). Each matrix in each row of the cell has the size n x d

dataSet = cellDataToDouble(dataSet);
dataSet = removeUsersWithNoUsageData(dataSet);
dataSet = cleanData(dataSet);
dataSet = removeUsersWithNoUsageData(dataSet);

denominatorVector = [100, 288, 288, 100];
normalizedData = normalizeData(dataSet, denominatorVector);
tempDataSet = zeros(size(dataSet, 1), size(dataSet{1, 1}, 2));
for i=1:size(dataSet, 1)
    tempDataSet(i, :) = normalizedData{i, 1}(1, :);
end
[U, S, V] = svd(tempDataSet);
temp = U(:, 1:2) * eye(2) .* S(:, 1:2);
figure;
plot(temp(:, 1), temp(:, 2), 'r');
clusters = tempDataSet;
end