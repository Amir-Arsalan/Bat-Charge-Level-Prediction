function normalizedData = normalizeData(dataSet, denominatorVector)
%Inputs:
%dataSet = A double matrix with the size n x d OR a cell matrix with the
%size m x f(depends on the number of usage datasets). Each matrix in the each row of the cell has the size n x d
%denominatorVector = A row vector of the maximum value for each of the
%columns d in the dataSet

if(~iscell(dataSet))
    for i=1:size(denominatorVector, 2)
        dataSet(:, i) = dataSet(:, i) / denominatorVector(1, i);
    end
else
    for i=1:size(dataSet, 1)
       tempDataSet = dataSet{i, 1};
       for j=1:size(denominatorVector, 2)
          tempDataSet(:, j) = tempDataSet(:, j) / denominatorVector(1, j); 
       end
       dataSet{i, 1} = tempDataSet;
    end
end
normalizedData = dataSet;
end