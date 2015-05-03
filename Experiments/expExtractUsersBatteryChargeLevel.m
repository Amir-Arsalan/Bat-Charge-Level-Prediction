function [means, stds] = expExtractUsersBatteryChargeLevel(timeGranulatedDataRecord, initChargeLvl, expType, numOfDays)
%{
This function extracts users charge levels and takes their mean and
standard deviations

Inputs:
- timeGranulatedDataRecord: A cell of n by 2 where each element in the 
first column contains a matrix of time granulated data record set and 
each element of the second column contains an associated time granularity
- initChargeLvl: The initial charge level from which the extraction begins
- expType: The experiment type
- numOfDays: A posotive, preferably integer, quantity that specifies the 
number of days for which the simulation will run

Outputs:
- means: Mean of extracted battery charge levels
- stds: Standard deviations of extracted batery charge levels
%}

%% Function code starts her

smallestTimeGranularity = timeGranulatedDataRecord{1, 2}; %The smallest time granularity


if(expType == 1)
    usersChargeLvlSequences = cell(size(timeGranulatedDataRecord, 1), 2);
    
    for i=1:size(timeGranulatedDataRecord, 1) %Over each data set records belonging to each time granularity
       originalDataRecordSets =  timeGranulatedDataRecord{i, 1};
       timeGranularity = timeGranulatedDataRecord{i, 2};
       requiredNumberOfSequences = numOfDays * (1440/timeGranularity);
       usersChargeLvlSequences{i, 1} = zeros(0, requiredNumberOfSequences);
       usersChargeLvlSequences{i, 2} = timeGranulatedDataRecord{i, 2};
       for j=1:size(originalDataRecordSets, 1) %Over each data record set for each user
           granulatedData = originalDataRecordSets{j, 2};
           individualsChargeLvlSequences = zeros(0, requiredNumberOfSequences);
           k = 1;
           diff1 = 0;
           diff2 = 0;
           while(k <= size(granulatedData, 1) - requiredNumberOfSequences)
               if(granulatedData(k, 6) == initChargeLvl || (granulatedData(k, 6) - .83*(timeGranularity/10) < initChargeLvl && granulatedData(k, 6) + .83*(timeGranularity/10) > initChargeLvl))
                   if(miscCheckIndexExceeding(k, requiredNumberOfSequences, 0, granulatedData))
                      individualsChargeLvlSequences = [individualsChargeLvlSequences; granulatedData(k:k + requiredNumberOfSequences - 1, 6)'];
%                       fprintf('%d, j = %d, k = %d\n', individualsChargeLvlSequences(end, 1), j, k);
                      k = k + requiredNumberOfSequences;
                   else
                       break;
                   end
               else
                   k = k + 1;
               end
               diff1 = 0;
               diff2 = 0;
           end
           usersChargeLvlSequences{i, 1} = [usersChargeLvlSequences{i, 1}; individualsChargeLvlSequences];
       end
       
    end

end

end