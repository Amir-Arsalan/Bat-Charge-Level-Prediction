function timeGranulatedDataRecord = procStart(rawDataRecords, tags, timeGranularity)
%{
This function starts processing the data set and applies the desired
time-granularity on it.

Inputs: 
- dataset: An m by n cell where m is the number of users and n is the 
number of tags. Each {i, j} element of the input cell contains a r by x
matrix where r is the number of records of the time-series data and x 
is the number of attributes.
- tags: An 1 by n cell where n is the number of tags. Each element of the
cell contains a string corresponding to each tag.
- timeGranularity: A single quantity; it is the desired timeGranularity
    
Note: Currently only the column corresponding to the tag "PhoneLabSystemAnalysis-BatteryChange" is processed.

Output: An t by x + 1 matrix where t is the number of records after
applying the desired timeGranularity. The added column is a column appended
as the first column to the r by x matrix and stores the day number in which
the record has been collected.
%}

%% Function code starts here

acceptableDevices = true(size(rawDataRecords, 1), 1); %Contains the deviceIDs to process further for modeling and analysis. The device IDs with having than 5 days will not be considered in the analysis
batCol = find(strcmp('PhoneLabSystemAnalysis-BatteryChange', tags)) + 1; %Find the column number of the tag. The +1 is due to the structure of the dataset where the first column contains the device only

for j=1:size(rawDataRecords, 1)
   if(size(rawDataRecords{j, batCol}, 1) < 5) %Use the data with at least 5 days of recorded data for each user
      acceptableDevices(j) = false;
   end
end
deviceIndx = find(acceptableDevices); %The value will be used to store the indices in the "dataset" belonging to devices having more than 20 days of record; it is initially assigned a dummy value.
timeGranulatedDataset = cell(sum(acceptableDevices), 2);
    for j=1:sum(acceptableDevices)
        aggregatedUserBatRecord = combineUserRecords(rawDataRecords{deviceIndx(j), batCol}); %Combines all battery charge level records of a user into a single matrix
%         [charge, discharge, timeIrregularBatRecord, timeGranulatedBatRecord] = extractBatStats(userBatRecord, granularity); %The returned data set has an additional column "days" containing the number of day in which the data has been recorded
        timeIrregularRecords = cleanData(aggregatedUserBatRecord, 4, false);
        timeGranulatedBatRecord = applyGranularity(timeIrregularRecords, timeGranularity); %Apply the requested time-granularity on the userBatRecord records
    %     timeGranulatedDataset{j, 1} = charge;
    %     timeGranulatedDataset{j, 2} = discharge;
    %     timeGranulatedDataset{j, 3} = originalBatRecord;
    %     timeGranulatedDataset{j, 4} = timeGranulatedBatRecord;
        timeGranulatedDataset{j, 1} = timeIrregularRecords;
        timeGranulatedDataset{j, 2} = timeGranulatedBatRecord;
        fprintf('%d\n', j);
    end
    fprintf('Cleaning data and applying %d-minute time granularity has been done successfully\n', timeGranularity);

end

