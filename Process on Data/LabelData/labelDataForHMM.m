function [labeledDataRecords, usersIndex] = labelDataForHMM(validDatasets, granularity, expType)

%{
This function creates a markov model for the provided data set. It uses
100% of the data set as training set at the moment!

Inputs:
-usersData: A cell of m by 2 containing all users data records. The 1st
column stores the original, cleaned data set and the 2nd column stores the
time-granulated data set
-expType: Specified the type experiment to be run and implicitly the type 
of model to be learned over the data
%}

%% Finding users with useless data
%{
By useless I mean their phones has been used in a weired way (e.g. been
almost 100% idle)
%}

%TODO: Write an algorithm to find noisy data sets which is robust for all time-granularities

% labeledDataRecords = [];
% noisyDatasetsIndices = false(size(dataRecords, 1), 1); %Stores the logical indices of datasets considered as invalid with some criteria
% datasetFeatureMatrix = zeros(size(dataRecords, 1), 7);
% for i=1:size(dataRecords, 1)
%     singleUserData = dataRecords{i, 2};
%     singleUserData = procCalcChargeRate(singleUserData, 1); %The user data is returned with an added column of "charge/discharge rate"
%     datasetFeatureMatrix(i, 1) = size(dataRecords{i, 1}, 1) / size(singleUserData, 1); %The ratio of 
%     datasetFeatureMatrix(i, 2) = sum(singleUserData(:, 8))/size(singleUserData, 1); %The ratio of sum of "existing" records to "all" records
%     datasetFeatureMatrix(i, 3) = sum(singleUserData(:, end) == 0) / size(singleUserData, 1);
%     datasetFeatureMatrix(i, 4) = sum(singleUserData(:, 7) == 1 & singleUserData(:, 6) > 97 & singleUserData(:, end) == 0) / size(singleUserData, 1); %The ratio of number of records indicating that the phone is fully charged and is in idle state to total number of records
%     datasetFeatureMatrix(i, 5) = sum(singleUserData(:, 7) == 1)/size(singleUserData, 1); %Ratio of the number of records that the phone has been plugged into charge to total number of records
%     datasetFeatureMatrix(i, 6) = mean(singleUserData(:, 9));
%     datasetFeatureMatrix(i, 7) = std(singleUserData(:, 9));
%     noisyDatasetsIndices(i) = singleUserData(end, 1) < 100 && (datasetFeatureMatrix(i, 2) < .25 || datasetFeatureMatrix(i, 3) > .38);
% end
% 
% validDatasets = cell(sum(~noisyDatasetsIndices), 2);
% indices = find(~noisyDatasetsIndices);
% for i=1:sum(~noisyDatasetsIndices)
%     validDatasets{i, 1} = dataRecords{indices(i), 1};
%     validDatasets{i, 2} = dataRecords{indices(i), 2};
% end


%% Function code starts here

if(expType == 1) %Tag each single record (No hierarchical model)
    
    allUsersDataRecords = [];
    dischargeRates = [];
    rechargeRates = [];
    dischargeIndices = [];
    rechargeIndices = [];
    usersIndex = 0; %Stores the index where a new user's records will start
    for i=1:size(validDatasets, 1)
        singleUserData = validDatasets{i, 2};
        singleUserData = procCalcChargeRate(singleUserData, 1); %The user data is returned with an added column of "charge/discharge rate"
        tempIndex = find(singleUserData(:, 7) == 0 & singleUserData(:, 9) >= 20/(10/granularity));
        allUsersDataRecords = [allUsersDataRecords; singleUserData(2:end, :)]; %Remove the first data record in the data set since the discharge rate is 0 due to lack of existence of previous records
        usersIndex = [usersIndex, length(allUsersDataRecords(:, 1))];
    end
    
    %Some more cleaning
    tempIndex = allUsersDataRecords(:, 7) == 0 & allUsersDataRecords(:, 9) < 0;
    allUsersDataRecords(tempIndex, 7) = 1; %Setting all records having a negative charge/discharge rate to recharge status
    tempIndex = allUsersDataRecords(:, 9) > 0 & allUsersDataRecords(:, 7) == 1 & allUsersDataRecords(:, 6) < 97;
    allUsersDataRecords(tempIndex, 7) = 0; %Setting all records having a positive charge/discharge rate while the phone is being charged and the charge level is below 97 to discharge status
    tempIndex = allUsersDataRecords(:, 7) == 0 & allUsersDataRecords(:, 9) >= 20/(10/granularity);
    allUsersDataRecords(tempIndex, 9) = unifrnd(15, 25, sum(tempIndex), 1);
    tempIndex = allUsersDataRecords(:, 7) == 1 & allUsersDataRecords(:, 9) >= 10/(10/granularity);
    allUsersDataRecords(tempIndex, 9) = unifrnd(1, 4, sum(tempIndex), 1);
    clear tempIndx
    
    allUsersDataRecords = [allUsersDataRecords, zeros(length(allUsersDataRecords(:, 1)), 1)];

    
    % Start tagging
    tempIndex = allUsersDataRecords(:, 7) == 0 & allUsersDataRecords(:, 9) == 0; %Shutdown or idle - almost 50/50 for the simplest HMM model (no dependency on time, or any other variable)
    allUsersDataRecords(tempIndex, 10) = 1;
    
    tempIndex = allUsersDataRecords(:, 7) == 0 & allUsersDataRecords(:, 9) > 0 & allUsersDataRecords(:, 9) <= 0.35/(10/granularity); %Idle
    allUsersDataRecords(tempIndex, 10) = 2;
    
    tempIndex = allUsersDataRecords(:, 7) == 0 & allUsersDataRecords(:, 9) > 0.35/(10/granularity) & allUsersDataRecords(:, 9) <= 0.99/(10/granularity); %Low usage
    allUsersDataRecords(tempIndex, 10) = 3;
    
    tempIndex = allUsersDataRecords(:, 7) == 0 & allUsersDataRecords(:, 9) > 0.99/(10/granularity) & allUsersDataRecords(:, 9) < 2/(10/granularity); %Med-low usage
    allUsersDataRecords(tempIndex, 10) = 4;
    
    tempIndex = allUsersDataRecords(:, 7) == 0 & allUsersDataRecords(:, 9) >= 2/(10/granularity) & allUsersDataRecords(:, 9) < 4/(10/granularity); %Med usage
    allUsersDataRecords(tempIndex, 10) = 5;
    
    tempIndex = allUsersDataRecords(:, 7) == 0 & allUsersDataRecords(:, 9) >= 4/(10/granularity) & allUsersDataRecords(:, 9) <= 6.5/(10/granularity); %Med-high usage
    allUsersDataRecords(tempIndex, 10) = 6;
    
    tempIndex = allUsersDataRecords(:, 7) == 0 & allUsersDataRecords(:, 9) > 6.5/(10/granularity) & allUsersDataRecords(:, 9) <= 9.3/(10/granularity); %High usage
    allUsersDataRecords(tempIndex, 10) = 7;
    
    tempIndex = allUsersDataRecords(:, 7) == 0 & allUsersDataRecords(:, 9) > 9.3/(10/granularity); %Intense usage
    allUsersDataRecords(tempIndex, 10) = 8;
    
    %Recharge tags
    tempIndex = allUsersDataRecords(:, 7) == 1 & allUsersDataRecords(:, 9) > -0.5/(10/granularity); %Idle/Fully charged usage (more than 95% of the time)
    allUsersDataRecords(tempIndex, 10) = 9;
    
    tempIndex = allUsersDataRecords(:, 7) == 1 & allUsersDataRecords(:, 9) <= -0.5/(10/granularity) & allUsersDataRecords(:, 9) >= -3/(10/granularity); %Early charge state or getting fully charge (charge level usually > 90)
    allUsersDataRecords(tempIndex, 10) = 10;
    
    tempIndex = allUsersDataRecords(:, 7) == 1 & allUsersDataRecords(:, 9) < -3/(10/granularity) & allUsersDataRecords(:, 9) >= -6.5/(10/granularity); %Getting fully charge (charge level usually > 90)
    allUsersDataRecords(tempIndex, 10) = 11;
    
    tempIndex = allUsersDataRecords(:, 7) == 1 & allUsersDataRecords(:, 9) < -6.5/(10/granularity); % The device is being charged 
    allUsersDataRecords(tempIndex, 10) = 12;
    
    
%     dischargeIndices = find(allUsersData(:, 7) == 0);
%     rechargeIndices = find(allUsersData(:, 7) == 1);
    
%     disIndxTemp = false(length(dischargeIndices), 1);
%     reIndxTemp = false(length(rechargeIndices), 1);
%     j = 1;
%     while(j <= length(dischargeIndices) - 1)
%         if(dischargeIndices(j) - dischargeIndices(j + 1) < -1 && j + 2 <= length(dischargeIndices))
%            disIndxTemp(j + 1) = 1; %Mark the indices that do not belong to discharge period
%         end
%         j = j + 1;
%     end
%     rechargeIndices = [rechargeIndices; dischargeIndices(disIndxTemp)];
%     dischargeIndices(disIndxTemp) = [];
%     clear disIndxTemp
%     j = 1;
%     dischargeIndices = [dischargeIndices; rechargeIndices(1)];
%     rechargeIndices = rechargeIndices(2:end);
%     while(j <= length(rechargeIndices) - 1)
%         if(rechargeIndices(j) - rechargeIndices(j + 1) < -1 && j + 2 <= length(rechargeIndices))
%             reIndxTemp(j + 1) = 1; %Mark the indices that do not belong to recharge period
%         end
%         j = j + 1;
%     end
%     dischargeIndices = [dischargeIndices; rechargeIndices(reIndxTemp)];
%     rechargeIndices(reIndxTemp) = [];
%     clear reIndxTemp
    
%     dischargeRates = [dischargeRates; allUsersData(dischargeIndices, 9)];
%     rechargeRates = [rechargeRates; allUsersData(rechargeIndices, 9)];
    
%     disMean = mean(dischargeRates); %Discharge rate mean
%     disStd = std(dischargeRates); %Discharge rate standard deviation
%     
%     reMean = mean(rechargeRates); %Rescharge rate mean
%     reStd = std(rechargeRates); %Recharge rate standard deviation
    
    
    % Start tagging records
    
    labeledDataRecords = allUsersDataRecords;
    
end

end