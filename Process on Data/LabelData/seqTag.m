function dataset = seqTag(dataset, tags, granularity)
%This function has the role of tagging charge sequences 

%Input: an m by n cell where m is the number of users and n is the number
%of tags (only the column corresponding to the tag 
%"PhoneLabSystemAnalysis-BatteryChange" will be processed)

%% Variables
batCol = 0; %contains the column number of the tag "PhoneLabSystemAnalysis-BatteryChange" in the dataset
acceptableDevices = true(size(dataset, 1), 1); %Contains the deviceIDs to process further for the analysis. %The device IDs with less than 10 days will not be considered in the analysis
deviceIndx = 0; %The value will be used to store the indices in the "dataset" belonging to devices having more than 20 days of record; it is initially assigned a dummy value.

%% Code

batCol = find(strcmp('PhoneLabSystemAnalysis-BatteryChange', tags)) + 1; %Find the column number of the tag. The +1 is due to the structure of the dataset where the first column contains the device only

for j=1:size(dataset, 1)
   if(size(dataset{j, batCol}, 1) < 20)
      acceptableDevices(j) = false;
   end
end
summ = 0;
deviceIndx = find(acceptableDevices);
summary = cell(sum(acceptableDevices), 4);
tic
if(exist('5Min.mat', 'file'))
    for j=76:sum(acceptableDevices)
        userBatSeq = combineUserRecords(dataset{deviceIndx(j), batCol}); %Combines all battery charge level records of a user into a single matrix
        summ = sum(userBatSeq(:, 6) == 2);
        [charge, discharge, originalBatSeq, timeGranulatedBatSeq] = extractBatStats(userBatSeq, 3, dataset{deviceIndx(j), batCol}); %The returned data set has an additional column "days" containing the number of day in which the data has been recorded
    %     summary{j, 1} = charge;
    %     summary{j, 2} = discharge;
    %     summary{j, 3} = originalBatSeq;
    %     summary{j, 4} = timeGranulatedBatSeq;
        summary{j, 1} = originalBatSeq;
        summary{j, 2} = timeGranulatedBatSeq;
        fprintf('%d\n', j);
    end
else
    load('10Min.mat');
%     load('5Min.mat');
%     load('10MinRefined.mat');
    HMMmodel = genHMM(tenMin, granularity, 1);
end
toc
dataset = summary;

end

