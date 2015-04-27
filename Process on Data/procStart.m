function dataset = procStart(dataset, tags, timeGranularity)
%{
This function starts processing the data set and 
%Input: an m by n cell where m is the number of users and n is the number
%of tags (only the column corresponding to the tag 
%"PhoneLabSystemAnalysis-BatteryChange" will be processed)
%}

%% Code

acceptableDevices = true(size(dataset, 1), 1); %Contains the deviceIDs to process further for the analysis. %The device IDs with less than 10 days will not be considered in the analysis
batCol = find(strcmp('PhoneLabSystemAnalysis-BatteryChange', tags)) + 1; %Find the column number of the tag. The +1 is due to the structure of the dataset where the first column contains the device only

for j=1:size(dataset, 1)
   if(size(dataset{j, batCol}, 1) < 20)
      acceptableDevices(j) = false;
   end
end
deviceIndx = find(acceptableDevices); %The value will be used to store the indices in the "dataset" belonging to devices having more than 20 days of record; it is initially assigned a dummy value.
timeGranulatedDataset = cell(sum(acceptableDevices), 2);
% if(~exist('time-granulated data.mat', 'file'))
    for j=1:sum(acceptableDevices)
        userBatSeq = combineUserRecords(dataset{deviceIndx(j), batCol}); %Combines all battery charge level records of a user into a single matrix
%         [charge, discharge, timeIrregularBatSeq, timeGranulatedBatSeq] = extractBatStats(userBatSeq, granularity); %The returned data set has an additional column "days" containing the number of day in which the data has been recorded
        userBatSeq = cleanData(userBatSeq, 4, false);
        timeIrregularBatSeq = userBatSeq;
        timeGranulatedBatSeq = applyGranularity(userBatSeq, timeGranularity); %Apply the requested time-granularity on the userBatSeq records
    %     timeGranulatedDataset{j, 1} = charge;
    %     timeGranulatedDataset{j, 2} = discharge;
    %     timeGranulatedDataset{j, 3} = originalBatSeq;
    %     timeGranulatedDataset{j, 4} = timeGranulatedBatSeq;
        timeGranulatedDataset{j, 1} = timeIrregularBatSeq;
        timeGranulatedDataset{j, 2} = timeGranulatedBatSeq;
        fprintf('%d\n', j);
    end
    fprintf('Processing data and applying %d-minute time granularity has been done successfully\n', timeGranularity);
% else
%     load('time-granulated data', 'tenMin')
%     load('10Min.mat');
%     load('5Min.mat');
%     load('10MinRefined.mat');
%     HMMmodel = genHMM(tenMin, granularity, 1);
% end
dataset = timeGranulatedDataset;

end
