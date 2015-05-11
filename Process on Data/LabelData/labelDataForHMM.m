function [labeledDataRecords, usersIndex] = labelDataForHMM(dataRecords, timeGranularity, expType)

%{
This function creates a markov model for the provided data set. It uses
100% of the data set as training set at the moment!

Inputs:
-d ataRecords: A cell of m by 2 containing all users data records. The 1st
column stores the original, cleaned data record set and the 2nd column 
stores the time-granulated, interpolated data record set
- timeGranularity: The time granularity associated with the data record set
- expType: Specified the type experiment to be run and implicitly the type 
of model to be learned over the data
%}


%% Function code starts here

if(expType == 1 || expType == 2) %These two models are explained in genHMM.m
    
    allUsersDataRecords = [];
    dischargeRates = [];
    rechargeRates = [];
    dischargeIndices = [];
    rechargeIndices = [];
    usersIndex = 0; %Stores the index where a new user's records will start
    for i=1:size(dataRecords, 1)
        singleUserDataRecords = dataRecords{i, 2};
        singleUserDataRecords = procCalcChargeRate(singleUserDataRecords, 1); %The user data is returned with an added column of "charge/discharge rate"
        tempIndex = find(singleUserDataRecords(:, 7) == 0 & singleUserDataRecords(:, 9) >= 20/(10/timeGranularity));
        allUsersDataRecords = [allUsersDataRecords; singleUserDataRecords(2:end, :)]; %Remove the first data record in the data set since the discharge rate is 0 due to lack of existence of previous records
        usersIndex = [usersIndex, length(allUsersDataRecords(:, 1))];
    end
    
    %Some more cleaning
    tempIndex = allUsersDataRecords(:, 7) == 0 & allUsersDataRecords(:, 9) < 0;
    allUsersDataRecords(tempIndex, 7) = 1; %Setting all records having a negative charge/discharge rate to recharge status
    tempIndex = allUsersDataRecords(:, 9) > 0 & allUsersDataRecords(:, 7) == 1 & allUsersDataRecords(:, 6) < 97;
    allUsersDataRecords(tempIndex, 7) = 0; %Setting all records having a positive charge/discharge rate while the phone is being charged and the charge level is below 97 to discharge status
    tempIndex = allUsersDataRecords(:, 7) == 0 & allUsersDataRecords(:, 9) >= 20/(10/timeGranularity);
    allUsersDataRecords(tempIndex, 9) = unifrnd(15, 25, sum(tempIndex), 1);
    tempIndex = allUsersDataRecords(:, 7) == 1 & allUsersDataRecords(:, 9) >= 10/(10/timeGranularity);
    allUsersDataRecords(tempIndex, 9) = unifrnd(1, 4, sum(tempIndex), 1);
    clear tempIndx
    
    allUsersDataRecords = [allUsersDataRecords, zeros(length(allUsersDataRecords(:, 1)), 1)];

    
    % Start tagging
    tempIndex = allUsersDataRecords(:, 7) == 0 & allUsersDataRecords(:, 9) == 0; %Shutdown or idle - almost 50/50 for the simplest HMM model (no dependency on time, or any other variable)
    allUsersDataRecords(tempIndex, 10) = 1;
    
    tempIndex = allUsersDataRecords(:, 7) == 0 & allUsersDataRecords(:, 9) > 0 & allUsersDataRecords(:, 9) <= 0.35/(10/timeGranularity); %Idle
    allUsersDataRecords(tempIndex, 10) = 2;
    
    tempIndex = allUsersDataRecords(:, 7) == 0 & allUsersDataRecords(:, 9) > 0.35/(10/timeGranularity) & allUsersDataRecords(:, 9) <= 0.99/(10/timeGranularity); %Low usage
    allUsersDataRecords(tempIndex, 10) = 3;
    
    tempIndex = allUsersDataRecords(:, 7) == 0 & allUsersDataRecords(:, 9) > 0.99/(10/timeGranularity) & allUsersDataRecords(:, 9) < 2/(10/timeGranularity); %Med-low usage
    allUsersDataRecords(tempIndex, 10) = 4;
    
    tempIndex = allUsersDataRecords(:, 7) == 0 & allUsersDataRecords(:, 9) >= 2/(10/timeGranularity) & allUsersDataRecords(:, 9) < 4/(10/timeGranularity); %Med usage
    allUsersDataRecords(tempIndex, 10) = 5;
    
    tempIndex = allUsersDataRecords(:, 7) == 0 & allUsersDataRecords(:, 9) >= 4/(10/timeGranularity) & allUsersDataRecords(:, 9) <= 6.5/(10/timeGranularity); %Med-high usage
    allUsersDataRecords(tempIndex, 10) = 6;
    
    tempIndex = allUsersDataRecords(:, 7) == 0 & allUsersDataRecords(:, 9) > 6.5/(10/timeGranularity) & allUsersDataRecords(:, 9) <= 9.3/(10/timeGranularity); %High usage
    allUsersDataRecords(tempIndex, 10) = 7;
    
    tempIndex = allUsersDataRecords(:, 7) == 0 & allUsersDataRecords(:, 9) > 9.3/(10/timeGranularity); %Intense usage
    allUsersDataRecords(tempIndex, 10) = 8;
    
    %Recharge tags
    tempIndex = allUsersDataRecords(:, 7) == 1 & allUsersDataRecords(:, 9) > -0.5/(10/timeGranularity); %Idle/Fully charged usage (more than 95% of the time)
    allUsersDataRecords(tempIndex, 10) = 9;
    
    tempIndex = allUsersDataRecords(:, 7) == 1 & allUsersDataRecords(:, 9) <= -0.5/(10/timeGranularity) & allUsersDataRecords(:, 9) >= -3/(10/timeGranularity); %Early charge state or getting fully charge (charge level usually > 90)
    allUsersDataRecords(tempIndex, 10) = 10;
    
    tempIndex = allUsersDataRecords(:, 7) == 1 & allUsersDataRecords(:, 9) < -3/(10/timeGranularity) & allUsersDataRecords(:, 9) >= -6.5/(10/timeGranularity); %Getting fully charge (charge level usually > 90)
    allUsersDataRecords(tempIndex, 10) = 11;
    
    tempIndex = allUsersDataRecords(:, 7) == 1 & allUsersDataRecords(:, 9) < -6.5/(10/timeGranularity); % The device is being charged 
    allUsersDataRecords(tempIndex, 10) = 12;
    
% %     This code snippet is used to replace incorrect charging status with
% %     the correct one. For instance, for a certain record, the phone 
% %     might have been in charging status but the charging status might be
% %     discharge or vice versa.

% %     Note: The last code section in the procApplyGranularity function
% %     deals with this problem. Therefore I have commented this code
% %     snippet here
    
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