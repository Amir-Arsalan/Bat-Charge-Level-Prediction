function [labeledDataset, usersIndex] = labelDataForHMM(usersData, granularity, mode)

%{
This function creates a markov model for the provided data set. It uses
100% of the data set as training set at the moment!

Inputs:
usersData: A cell containing all users data records
mode: Specified the type of model to be learned over the data
%}

%% Finding users with useless data
%{
By useless I mean their phones has been used in a weired way (e.g. been
almost 100% idle)
%}

%TODO: Write an algorithm to find noisy data sets which is robust for all time-granularities
labeledDataset = [];
noisyDatasetsIndices = false(size(usersData, 1), 1); %Stores the logical indices of datasets considered as invalid with some criteria
temp = zeros(size(usersData, 1), 5);
for i=1:size(usersData, 1)
    singleUserData = usersData{i, 2};
    singleUserData = procCalcChargeRate(singleUserData, 1); %The user data is returned with an added column of "charge/discharge rate"
    temp(i, 1) = size(usersData{i, 1}, 1) / size(singleUserData, 1); %The ratio of 
    temp(i, 2) = sum(singleUserData(:, 8))/size(singleUserData, 1); %The ratio of sum of "existing" records to "all" records
    temp(i, 3) = sum(singleUserData(:, end) == 0) / size(singleUserData, 1);
    noisyDatasetsIndices(i) = singleUserData(end, 1) < 100 && (temp(i, 2) < .25 || temp(i, 3) > .38);
end

validDatasets = cell(sum(~noisyDatasetsIndices), 2);
indices = find(~noisyDatasetsIndices);
for i=1:sum(~noisyDatasetsIndices)
    validDatasets{i, 1} = usersData{indices(i), 1};
    validDatasets{i, 2} = usersData{indices(i), 2};
end


%% The main program starts here
if(mode == 1) %Tag each single record (No hierarchical model)
    
    allUsersData = [];
    dischargeRates = [];
    rechargeRates = [];
    dischargeIndices = [];
    rechargeIndices = [];
    usersIndex = 0; %Stores the index where a new user's records will start
    for i=1:size(validDatasets, 1)
        singleUserData = validDatasets{i, 2};
        singleUserData = procCalcChargeRate(singleUserData, 1); %The user data is returned with an added column of "charge/discharge rate"
        tempIndex = find(singleUserData(:, 7) == 0 & singleUserData(:, 9) >= 20/(10/granularity));
        allUsersData = [allUsersData; singleUserData(2:end, :)]; %Remove the first data record in the data set since the discharge rate is 0 due to lack of existence of previous records
        usersIndex = [usersIndex, length(allUsersData(:, 1))];
    end
    
    %Some more cleaning
    tempIndex = allUsersData(:, 7) == 0 & allUsersData(:, 9) < 0;
    allUsersData(tempIndex, 7) = 1; %Setting all records having a negative charge/discharge rate to recharge status
    tempIndex = allUsersData(:, 9) > 0 & allUsersData(:, 7) == 1 & allUsersData(:, 6) < 97;
    allUsersData(tempIndex, 7) = 0; %Setting all records having a positive charge/discharge rate while the phone is being charged and the charge level is below 97 to discharge status
    tempIndex = allUsersData(:, 7) == 0 & allUsersData(:, 9) >= 20/(10/granularity);
    allUsersData(tempIndex, 9) = unifrnd(15, 25, sum(tempIndex), 1);
    tempIndex = allUsersData(:, 7) == 1 & allUsersData(:, 9) >= 10/(10/granularity);
    allUsersData(tempIndex, 9) = unifrnd(1, 4, sum(tempIndex), 1);
    clear tempIndx
    
    allUsersData = [allUsersData, zeros(length(allUsersData(:, 1)), 1)];

    
    % Start tagging
    tempIndex = allUsersData(:, 7) == 0 & allUsersData(:, 9) == 0; %Shutdown or idle - almost 50/50 for the simplest HMM model (no dependency on time, or any other variable)
    allUsersData(tempIndex, 10) = 1;
    
    tempIndex = allUsersData(:, 7) == 0 & allUsersData(:, 9) > 0 & allUsersData(:, 9) <= 0.35/(10/granularity); %Idle
    allUsersData(tempIndex, 10) = 2;
    
    tempIndex = allUsersData(:, 7) == 0 & allUsersData(:, 9) > 0.35/(10/granularity) & allUsersData(:, 9) <= 0.99/(10/granularity); %Low usage
    allUsersData(tempIndex, 10) = 3;
    
    tempIndex = allUsersData(:, 7) == 0 & allUsersData(:, 9) > 0.99/(10/granularity) & allUsersData(:, 9) < 2/(10/granularity); %Med-low usage
    allUsersData(tempIndex, 10) = 4;
    
    tempIndex = allUsersData(:, 7) == 0 & allUsersData(:, 9) >= 2/(10/granularity) & allUsersData(:, 9) < 4/(10/granularity); %Med usage
    allUsersData(tempIndex, 10) = 5;
    
    tempIndex = allUsersData(:, 7) == 0 & allUsersData(:, 9) >= 4/(10/granularity) & allUsersData(:, 9) <= 6.5/(10/granularity); %Med-high usage
    allUsersData(tempIndex, 10) = 6;
    
    tempIndex = allUsersData(:, 7) == 0 & allUsersData(:, 9) > 6.5/(10/granularity) & allUsersData(:, 9) <= 9.3/(10/granularity); %High usage
    allUsersData(tempIndex, 10) = 7;
    
    tempIndex = allUsersData(:, 7) == 0 & allUsersData(:, 9) > 9.3/(10/granularity); %Intense usage
    allUsersData(tempIndex, 10) = 8;
    
    %Recharge tags
    tempIndex = allUsersData(:, 7) == 1 & allUsersData(:, 9) > -0.5/(10/granularity); %Idle/Fully charged usage (more than 95% of the time)
    allUsersData(tempIndex, 10) = 9;
    
    tempIndex = allUsersData(:, 7) == 1 & allUsersData(:, 9) <= -0.5/(10/granularity) & allUsersData(:, 9) >= -3/(10/granularity); %Early charge state or getting fully charge (charge level usually > 90)
    allUsersData(tempIndex, 10) = 10;
    
    tempIndex = allUsersData(:, 7) == 1 & allUsersData(:, 9) < -3/(10/granularity) & allUsersData(:, 9) >= -6.5/(10/granularity); %Getting fully charge (charge level usually > 90)
    allUsersData(tempIndex, 10) = 11;
    
    tempIndex = allUsersData(:, 7) == 1 & allUsersData(:, 9) < -6.5/(10/granularity); % The device is being charged 
    allUsersData(tempIndex, 10) = 12;
    
    
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
    
    labeledDataset = allUsersData;
    
end

end