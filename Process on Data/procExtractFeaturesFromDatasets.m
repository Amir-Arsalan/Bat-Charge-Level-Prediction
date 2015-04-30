function dataRecordFeatureMatrix = procExtractFeaturesFromDatasets(dataRecords)

%{
This function extracts a set of features from each data set to be used to
help identify some data sets that are highly noisy and may be harmful in
model-learning phase.

Input:


Output: A featureMatrix/cell for each data record
%}

%% Function code starts here

if(~iscell(dataRecords))
    dataRecordFeatureMatrix = zeros(size(dataRecords, 1), 8);
    for i=1:size(dataRecords, 1)
        singleUserData = dataRecords{i, 2};
        singleUserData = procCalcChargeRate(singleUserData, 1); %The user data is returned with an added column of "charge/discharge rate"
        dataRecordFeatureMatrix(i, 1) = singleUserData(end, 1); %Number of days that the data has been collected for
        dataRecordFeatureMatrix(i, 2) = size(dataRecords{i, 1}, 1) / size(singleUserData, 1); %The ratio of total number of records in the raw data set to total number of time-granulated data
        dataRecordFeatureMatrix(i, 3) = sum(singleUserData(:, 8) == 1) / size(singleUserData, 1); %The ratio of sum of records that have an existing match in the original, raw data record set to all records of the time-granulated data record set
        dataRecordFeatureMatrix(i, 4) = sum(singleUserData(:, end) == 0) / size(singleUserData, 1); %The ratio of number of dis/recharge rates equal to 0 to total number of records
        dataRecordFeatureMatrix(i, 5) = sum(singleUserData(:, 7) == 1 & singleUserData(:, 6) > 95 & singleUserData(:, end) == 0) / size(singleUserData, 1); %The ratio of number of records indicating that the phone is fully charged and is in idle state to total number of records
        dataRecordFeatureMatrix(i, 6) = sum(singleUserData(:, 7) == 1)/size(singleUserData, 1); %Ratio of the number of records that the phone has been plugged into charge to total number of records
        dataRecordFeatureMatrix(i, 7) = mean(singleUserData(:, 9));
        dataRecordFeatureMatrix(i, 8) = std(singleUserData(:, 9));
    end
else %If the dataRecords was a cell object (containing more than 1 data record set)
    dataRecordFeatureCell = cell(size(dataRecords, 1), 1);
    for i=1:size(dataRecords, 1)
       dataRecordFeatureCell{i, 1} = zeros(size(dataRecords{i, 1}, 1), 8);
    end
    for i=1:size(dataRecords, 1)
        for j=1:size(dataRecords{i, 1}, 1)
            singleUserData = dataRecords{i, 1}{j, 2};
            singleUserData = procCalcChargeRate(singleUserData, 1); %The user data is returned with an additional column of "charge/discharge rate" appended as the last column
            dataRecordFeatureCell{i, 1}(j, 1) = singleUserData(end, 1); %Number of days that the data has been collected for
            dataRecordFeatureCell{i, 1}(j, 2) = size(dataRecords{i, 1}, 1) / size(singleUserData, 1); %The ratio of total number of records in the raw data set to total number of time-granulated data
            dataRecordFeatureCell{i, 1}(j, 3) = sum(singleUserData(:, 8) == 1) / size(singleUserData, 1); %The ratio of sum of records that have an existing match in the original, raw data record set to all records of the time-granulated data record set
            dataRecordFeatureCell{i, 1}(j, 4) = sum(singleUserData(:, end) == 0) / size(singleUserData, 1); %The ratio of number of dis/recharge rates equal to 0 to total number of records
            dataRecordFeatureCell{i, 1}(j, 5) = sum(singleUserData(:, 7) == 1 & singleUserData(:, 6) > 95 & singleUserData(:, end) == 0) / size(singleUserData, 1); %The ratio of number of records indicating that the phone is fully charged and is in idle state to total number of records
            dataRecordFeatureCell{i, 1}(j, 6) = sum(singleUserData(:, 7) == 1)/size(singleUserData, 1); %Ratio of the number of records that the phone has been plugged into charge to total number of records
            dataRecordFeatureCell{i, 1}(j, 7) = mean(singleUserData(:, 9));
            dataRecordFeatureCell{i, 1}(j, 8) = std(singleUserData(:, 9));
        end
    end
end

dataRecordFeatureMatrix = dataRecordFeatureCell;

end