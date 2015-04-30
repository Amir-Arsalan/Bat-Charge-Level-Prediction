function validDataRecords = procIdentifyNoisyDatasets(dataRecord)

%{
This function identifies the data sets that are highly noisy (have low
entropy intuitively) and will discard them in further processes (e.g.
learning models over data and ... )

Input:
- dataRecords: A cell of m by 2 containing all users data records. The 1st
column stores the original, cleaned data set and the 2nd column stores the
time-granulated data set

Output:
- A cell of m by 2 containing data records that are not very noisy and can
contribute positively in the model-learning phase
%}


%% Function code starts here

dataRecordFeatureMatrixOrCell = procExtractFeaturesFromDatasets(dataRecord);

if(~iscell(dataRecordFeatureMatrixOrCell)) %If there is only one data record to evaluate
    
%     noisyDatasetsIndices = false(size(dataRecord, 1), 1); %Stores the logical indices of datasets considered as invalid with some criteria
    stats1= mean(dataRecordFeatureMatrixOrCell(:, 3)) - 1.8 * std(dataRecordFeatureMatrixOrCell(:, 3));% Number of matching records/total
    stats2 = mean(dataRecordFeatureMatrixOrCell(:, 4)) + 2.2 * std(dataRecordFeatureMatrixOrCell(:, 4)); %Rate = 0/total
    stats3 = mean(dataRecordFeatureMatrixOrCell(:, 5)) + 2.5 * std(dataRecordFeatureMatrixOrCell(:, 5)); %Fully charged and idle/total
    stats4 = mean(dataRecordFeatureMatrixOrCell(:, 6)) + 3 * std(dataRecordFeatureMatrixOrCell(:, 6)); %Plugged in/total
    noisyDatasetsIndices = dataRecordFeatureMatrixOrCell(:, 3) <= stats1 | dataRecordFeatureMatrixOrCell(:, 4) >= stats2 | dataRecordFeatureMatrixOrCell(:, 5) >= stats3 | dataRecordFeatureMatrixOrCell(:, 6) >= stats4; %Identify the noisy datasets

    validDataRecords = cell(sum(~noisyDatasetsIndices), 2);
    indices = find(~noisyDatasetsIndices);
    for i=1:sum(~noisyDatasetsIndices)
        validDataRecords{i, 1} = dataRecord{indices(i), 1};
        validDataRecords{i, 2} = dataRecord{indices(i), 2};
    end
    
else %If there are multiple data records
noisyDatasetsIndices = [];
for i=1:size(dataRecordFeatureMatrixOrCell, 1)
    stats1= mean(dataRecordFeatureMatrixOrCell{i, 1}(:, 3)) - 1.8 * std(dataRecordFeatureMatrixOrCell{i, 1}(:, 3));% Number of matching records/total
    stats2 = mean(dataRecordFeatureMatrixOrCell{i, 1}(:, 4)) + 2.2 * std(dataRecordFeatureMatrixOrCell{i, 1}(:, 4)); %Rate = 0/total
    stats3 = mean(dataRecordFeatureMatrixOrCell{i, 1}(:, 5)) + 2.5 * std(dataRecordFeatureMatrixOrCell{i, 1}(:, 5)); %Fully charged and idle/total
    stats4 = mean(dataRecordFeatureMatrixOrCell{i, 1}(:, 6)) + 3 * std(dataRecordFeatureMatrixOrCell{i, 1}(:, 6)); %Plugged in/total
    noisyDatasetsIndices = [noisyDatasetsIndices, dataRecordFeatureMatrixOrCell{i, 1}(:, 3) <= stats1 | dataRecordFeatureMatrixOrCell{i, 1}(:, 4) >= stats2 | dataRecordFeatureMatrixOrCell{i, 1}(:, 5) >= stats3 | dataRecordFeatureMatrixOrCell{i, 1}(:, 6) >= stats4]; %Identify the noisy datasets
end
noisyDatasetsIndices = all(noisyDatasetsIndices')';

%START An alternative method to determine noisy data records
% tempIndices = false(size(noisyDatasetsIndices, 1), 1);
% for i=1:size(noisyDatasetsIndices, 1)
%     tempIndices(i) = sum(noisyDatasetsIndices(i, :)) >= size(noisyDatasetsIndices, 2)/1.5;
% end
%END An alternative method to determine noisy data records

validDataRecords = cell(size(dataRecord, 1), 2);
for i=1:size(validDataRecords, 1)
   validDataRecords{i, 1} = cell(sum(~noisyDatasetsIndices), 2); 
end
indices = find(~noisyDatasetsIndices);
for i=1:size(dataRecord, 1)
    for j=1:sum(~noisyDatasetsIndices)
        validDataRecords{i, 1}{j, 1} = dataRecord{i, 1}{indices(j), 1};
        validDataRecords{i, 1}{j, 2} = dataRecord{i, 1}{indices(j), 2};
    end
    validDataRecords{i, 2} = dataRecord{i, 2};
end

end

end