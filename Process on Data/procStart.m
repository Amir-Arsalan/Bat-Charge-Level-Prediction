function dataset = procStart(dataset, tags, timeGranularity)
%{
This function starts processing the data set and 
%Input: an m by n cell where m is the number of users and n is the number
%of tags (only the column corresponding to the tag 
%"PhoneLabSystemAnalysis-BatteryChange" will be processed)
%}

%% Code

acceptableDevices = true(size(dataset, 1), 1); %Contains the deviceIDs to process further for modeling and analysis. The device IDs with having than 5 days will not be considered in the analysis
batCol = find(strcmp('PhoneLabSystemAnalysis-BatteryChange', tags)) + 1; %Find the column number of the tag. The +1 is due to the structure of the dataset where the first column contains the device only

for j=1:size(dataset, 1)
   if(size(dataset{j, batCol}, 1) < 5) %Use the data with at least 5 days of recorded data for each user
      acceptableDevices(j) = false;
   end
end
deviceIndx = find(acceptableDevices); %The value will be used to store the indices in the "dataset" belonging to devices having more than 20 days of record; it is initially assigned a dummy value.
timeGranulatedDataset = cell(sum(acceptableDevices), 2);
    for j=1:sum(acceptableDevices)
        userBatRecord = combineUserRecords(dataset{deviceIndx(j), batCol}); %Combines all battery charge level records of a user into a single matrix
%         [charge, discharge, timeIrregularBatRecord, timeGranulatedBatRecord] = extractBatStats(userBatRecord, granularity); %The returned data set has an additional column "days" containing the number of day in which the data has been recorded
        userBatRecord = cleanData(userBatRecord, 4, false);
        timeIrregularBatRecord = userBatRecord;
        timeGranulatedBatRecord = applyGranularity(userBatRecord, timeGranularity); %Apply the requested time-granularity on the userBatRecord records
    %     timeGranulatedDataset{j, 1} = charge;
    %     timeGranulatedDataset{j, 2} = discharge;
    %     timeGranulatedDataset{j, 3} = originalBatRecord;
    %     timeGranulatedDataset{j, 4} = timeGranulatedBatRecord;
        timeGranulatedDataset{j, 1} = timeIrregularBatRecord;
        timeGranulatedDataset{j, 2} = timeGranulatedBatRecord;
        fprintf('%d\n', j);
    end
    fprintf('Cleaning data and applying %d-minute time granularity has been done successfully\n', timeGranularity);
dataset = timeGranulatedDataset;

end

