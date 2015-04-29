function validDataRecords = procIdentifyNoisyDatasets(dataRecord)

%{
This function identifies the data sets that are highly noisy (have low
entropy intuitively) and will discard them in further processes (e.g.
learning models over data and ... )

Input:
- datasetFeatureMatrix: A matrix or cell (if there are multiple data sets
to get evaluated) containing features for each data set

Output:
- A cell of m by 2 containing data records that are not very noisy and can
contribute positively in the model-learning phase
%}


%% Function code starts here

dataRecordFeatureMatrix = procExtractFeaturesFromDatasets(dataRecord);

if(~iscell(dataRecordFeatureMatrix)) %If there is only one data record to evaluate
    
    noisyDatasetsIndices = false(size(dataRecord, 1), 1); %Stores the logical indices of datasets considered as invalid with some criteria
    stats1= mean(dataRecordFeatureMatrix(:, 3)) - 1.8 * std(dataRecordFeatureMatrix(:, 3));% Number of matching records/total
    stats2 = mean(dataRecordFeatureMatrix(:, 4)) + 2.2 * std(dataRecordFeatureMatrix(:, 4)); %Rate = 0/total
    stats3 = mean(dataRecordFeatureMatrix(:, 5)) + 2.5 * std(dataRecordFeatureMatrix(:, 5)); %Fully charged and idle/total
    stats4 = mean(dataRecordFeatureMatrix(:, 6)) + 3 * std(dataRecordFeatureMatrix(:, 6)); %Plugged in/total
    noisyDatasetsIndices = dataRecordFeatureMatrix(:, 3) <= stats1 | dataRecordFeatureMatrix(:, 4) >= stats2 | dataRecordFeatureMatrix(:, 5) >= stats3 | dataRecordFeatureMatrix(:, 6) >= stats4; %Identify the noisy datasets

    validDataRecords = cell(sum(~noisyDatasetsIndices), 2);
    indices = find(~noisyDatasetsIndices);
    for i=1:sum(~noisyDatasetsIndices)
        validDataRecords{i, 1} = dataRecord{indices(i), 1};
        validDataRecords{i, 2} = dataRecord{indices(i), 2};
    end
    
else %If there are multiple data records
%TODO: Complete this section
end

end