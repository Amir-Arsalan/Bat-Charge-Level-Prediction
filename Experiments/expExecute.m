function simulationResult = expExecute(fromScratch, expType, timeGranularity, initChargeLvl, numOfDays, plotSimResult)

%% Function Description
%{
This function is used to run different experiments. It is assumed that the
data set has been stored in "Complete 207 users data.mat" file.

Input:
- fromScratch: Is 1 when the user wants to generate a data set with a
new time granularity than or when the data set is different than the ones
already stored.
- expType: Type of experiment to be executed
- timeGranularity: A single quantity or a row vector indicating the time
granularity(ies) at which the expriments will run. If is set to zero the 
experiments will run for  time granularities of 3, 5, 10, 15, 20 and 30 minutes.
- initChargeLvl: The initial charge level from which the simulations start
- numOfDays: A posotive, preferably integer, quantity that specifies the 
number of days for which the simulation will run
- plotSimReuslt: Takes on values 1 or 0. If 1, the simulation result will
plot and otherwise for the value 0.

Output:
Plot() the simulation result
- simulationResult: The simulation result after learning a model over the
data and using it for simulation
%}

%% The program code

if(numOfDays <= 0)
    numOfDays = 1;
end

initChargeLvl = abs(initChargeLvl);
if(initChargeLvl < 0)
    initChargeLvl = 0;
elseif(initChargeLvl > 100)
    initChargeLvl = 100;
end

if(size(timeGranularity, 1) > 1)
   if(size(timeGranularity, 2) == 1)
      timeGranularity = timeGranularity';
       timeGranularity = timeGranularity(1, :); %Take the first row only
   end
end
if(size(timeGranularity, 2) == 1 && timeGranularity < 0 || isempty(timeGranularity))
    timeGranularity = 0;
end

plotSimResult = plotSimResult(1, 1); %Cannot be a vector
if(plotSimResult < 0)
    plotSimResult = abs(plotSimResult);
end
if(plotSimResult >= 1)
   plotSimResult = 1;
else
    plotSimResult = 0;
end


timeGranularity = sort(timeGranularity, 'ascend');

if(fromScratch == 1 || fromScratch == 0) %Ensure it is assigned a logical quantity
    
    if(fromScratch)
        if(exist('Complete 207 users data.mat', 'file'))
            load('Complete 207 users data.mat', 'Dataset', 'requestedTags', 'requestedPaths');
            if(size(timeGranularity, 2) == 1 && timeGranularity ~= 0)
                timeGranularity = abs(timeGranularity);
                timeGranulatedDataRecord = cell(1, 2);
                timeGranulatedDataRecord{1, 1} = procStart(Dataset, requestedTags, timeGranularity);
                timeGranulatedDataRecord{1, 2} = timeGranularity;
                validDataRecords = procDiscardNoisyDatasets(timeGranulatedDataRecord);
                HMMmodel = genHMM(validDataRecords{1, 1}, timeGranularity, expType);
                simulationResult = expHMM(initChargeLvl, HMMmodel, timeGranularity, numOfDays);
            else %If the timeGranularity is a vector
                if(size(timeGranularity, 2) == 1 && timeGranularity == 0)
                   timeGranularity = [3, 5, 10, 15, 20, 30];
                else
                    timeGranularity = abs(timeGranularity);
                    timeGranularity = timeGranularity(timeGranularity ~= 0);
                    if(isempty(timeGranularity))
                       error('You cannot have a time-granularity vector with all of its elements zeros(0). Please try with a time-granularity greater than zero');
                    end
                end
               timeGranulatedDataRecord = cell(length(timeGranularity), 2);
               HMMmodel = cell(length(timeGranularity), 2);
               simulationResult = cell(length(timeGranularity), 2);
               for i=1:length(timeGranularity)
                   timeGranulatedDataRecord{i, 1} = procStart(Dataset, requestedTags, timeGranularity(i));
                   timeGranulatedDataRecord{i, 2} = timeGranularity(i);
               end
            end
            
            if(size(timeGranularity, 2) > 1)
                timeGranulatedDataRecord = procDiscardNoisyDatasets(timeGranulatedDataRecord);
                for i=1:size(timeGranularity, 2)
                   HMMmodel{i, 1} = genHMM(timeGranulatedDataRecord{i, 1}, timeGranularity(i), expType);
                   HMMmodel{i, 2} = timeGranularity(i);
                   simulationResult{i, 1} = expHMM(initChargeLvl, HMMmodel{i, 1}, timeGranularity(i), numOfDays);
                   simulationResult{i, 2} = timeGranularity(i);
                end
            end
        else
            error('The file "Complete 207 users data.mat" does not exist in the source directory "%s".\n', pwd)
        end
    else %If want to use a pre-stored data set (fromScratch = 0)
        if(exist('time granulated Data.mat', 'file'))
           if(timeGranularity == 0)
               load('time granulated Data.mat'); %Load all available datasets with different time granularities stored in it
               timeGranularity = [3, 5, 10, 15, 20, 30]; %The pre-defined time-granularities
               timeGranularityIndices = miscLookupTimeGranularity(timeGranulatedDataRecord, timeGranularity);
               timeGranularityIndices = sortrows(timeGranularityIndices, 2); %Sort with respect to the time granularity colummn
               timeGranularity = timeGranularityIndices(:, 2);
               timeGranularityIndices = timeGranularityIndices(:, 1);
               HMMmodel = cell(length(timeGranularity), 2);
               simulationResult = cell(length(timeGranularity), 2);
                for i=1:length(timeGranularityIndices)
                   HMMmodel{i, 1} = genHMM(timeGranulatedDataRecord{timeGranularityIndices(i), 1}, timeGranularity(i), expType);
                   HMMmodel{i, 2} = timeGranularity(i);
                   simulationResult{i, 1} = expHMM(initChargeLvl, HMMmodel{i, 1}, timeGranularity(i), numOfDays);
                   simulationResult{i, 2} = timeGranularity(i);
               end
           else %If the user has input a timeGranularity (or a vector of timeGranularity) and the user wants to use the pre-labeled data record sets that are already stored
               load('time granulated Data.mat'); %Load all available datasets with different time granularities stored in it
               timeGranularityIndices = miscLookupTimeGranularity(timeGranulatedDataRecord, timeGranularity);
               if(~isempty(timeGranularityIndices))
                   timeGranularityIndices = sortrows(timeGranularityIndices, 2); %Sort with respect to the time granularity colummn
                   timeGranularity = timeGranularityIndices(:, 2);
                   timeGranularityIndices = timeGranularityIndices(:, 1);
                   HMMmodel = cell(length(timeGranularity), 2);
                   simulationResult = cell(length(timeGranularity), 2);
                   for i=1:length(timeGranularityIndices)
                       HMMmodel{i, 1} = genHMM(timeGranulatedDataRecord{timeGranularityIndices(i), 1}, timeGranularity(i), expType);
                       HMMmodel{i, 2} = timeGranularity(i);
                       simulationResult{i, 1} = expHMM(initChargeLvl, HMMmodel{i, 1}, timeGranularity(i), numOfDays);
                       simulationResult{i, 2} = timeGranularity(i);
                   end
               else
                   error('Unable to find data record sets associated with the entered time granularities. Make sure you are entering the correct time granularities');
               end
           end
        else
            error('The file "time-granulated data.mat" does not exist in the source directory "%s\\Data".\n', pwd)
        end
    end
    
    if(plotSimResult == 1)
        miscPlotSimulationResults(simulationResult, timeGranulatedDataRecord, timeGranularity, initChargeLvl, 1, 1, expType, numOfDays);
    end
    
end

end