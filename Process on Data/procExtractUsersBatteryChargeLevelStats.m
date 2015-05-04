function [means, stds] = procExtractUsersBatteryChargeLevelStats(timeGranulatedDataRecord, initChargeLvl, exact, expType, numOfDays)
%{
This function extracts users charge levels and takes their mean and
standard deviations

Inputs:
- timeGranulatedDataRecord: A cell of n by 2 where each element in the 
first column contains a matrix of time granulated data record set and 
each element of the second column contains an associated time granularity
- initChargeLvl: The initial charge level from which the extraction begins
- exact: Takes on values of 1 or 0. If 1 the function select the 'starting
charge levels' equal to initChargeLvl exactly. If not, the function selects
the 'starting charge levels' with a boundary of initChargeLvl.
- expType: The experiment type
- numOfDays: A posotive, preferably integer, quantity that specifies the 
number of days for which the simulation will run

Outputs:
- means: Mean of extracted battery charge levels.
- stds: Standard deviations of extracted batery charge levels
%}

%% Function code starts her

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
               if(exact == 1 && granulatedData(k, 6) == initChargeLvl) %The 'starting charge level' must be equal to initChargeLvl
                   if(miscCheckIndexExceeding(k, requiredNumberOfSequences, 0, granulatedData))
                      individualsChargeLvlSequences = [individualsChargeLvlSequences; granulatedData(k:k + requiredNumberOfSequences - 1, 6)'];
                      k = k + requiredNumberOfSequences;
                   else
                       break;
                   end
               elseif(exact == 0 && granulatedData(k, 6) - .83*(timeGranularity/10) < initChargeLvl && granulatedData(k, 6) + .83*(timeGranularity/10) > initChargeLvl) %The 'starting charge level' must be within a bound of initChargeLvl
                   if(miscCheckIndexExceeding(k, requiredNumberOfSequences, 0, granulatedData))
                      individualsChargeLvlSequences = [individualsChargeLvlSequences; granulatedData(k:k + requiredNumberOfSequences - 1, 6)'];
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

% Apply linear interpolation
timeGranularity = [];
for i=1:size(usersChargeLvlSequences, 1)
    timeGranularity = [timeGranularity; usersChargeLvlSequences{i, 2}];
end
interpolatedBatChargeLvlSequences = procGenerateIntervalConsistentDataRecord(usersChargeLvlSequences, timeGranularity, numOfDays);

means = zeros(size(interpolatedBatChargeLvlSequences, 1), size(interpolatedBatChargeLvlSequences{1, 1}, 2));
stds = zeros(size(interpolatedBatChargeLvlSequences, 1), size(interpolatedBatChargeLvlSequences{1, 1}, 2));

for i=1:size(interpolatedBatChargeLvlSequences)
   means(i, :) = mean(interpolatedBatChargeLvlSequences{i, 1});
   stds(i, :) = std(interpolatedBatChargeLvlSequences{i, 1});
end

end