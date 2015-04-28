function expExecute(fromScratch, expType, timeGranularity, initChargeLvl)

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
%}

%% The program code
if(timeGranularity < 0)
    timeGranularity = 0;
end

if(fromScratch == 1 || fromScratch == 0) %Ensure it is assigned a logical quantity
    
    if(fromScratch)
        if(exist('Complete 207 users data.mat', 'file'))
            load('Complete 207 users data.mat', 'Dataset', 'requestedTags', 'requestedPaths');
            if(size(timeGranularity, 2) == 1 && timeGranularity ~= 0)
                timeGranularity = abs(timeGranularity);
                dataSequence = procStart(Dataset, requestedTags, timeGranularity);
                HMMmodel = genHMM(dataSequence, timeGranularity, expType);
                simulationResult = expHMM(initChargeLvl, HMMmodel, timeGranularity);
            else
                if(size(timeGranularity, 2) == 1 && timeGranularity == 0)
                   timeGranularity = [3, 5, 10, 15, 20, 30];
                else
                    timeGranularity = abs(timeGranularity);
                end
               timeGranulatedDatasequences = cell(length(timeGranularity), 2);
               HMMmodel = cell(length(timeGranularity), 2);
               simulationResult = cell(length(timeGranularity), 2);
               for i=1:length(timeGranularity)
                   dataSequence = procStart(Dataset, requestedTags, timeGranularity(i));
                   HMMmodel{i, 1} = genHMM(dataSequence, timeGranularity(i), expType);
                   HMMmodel{i, 2} = timeGranularity(i);
                   simulationResult{i, 1} = expHMM(initChargeLvl, HMMmodel{i, 1}, timeGranularity(i));
                   simulationResult{i, 2} = timeGranularity(i);
                   timeGranulatedDatasequences{i, 1} = dataSequence;
                   timeGranulatedDatasequences{i, 2} = timeGranularity(i);
               end
               miscPlotResults(simulationResult, timeGranularity);
            end
            %TODO: Run experiments
            if(expType == 1) %Experiments numbered "1" are run using simple hidden Markov models
                if(size(timeGranularity, 2) == 1 && timeGranularity > 0)
                    
                end
            end
        else
            error('The file "Complete 207 users data.mat" does not exist in the source directory "%s".\n', pwd)
        end
    else %If not from scracth (want to use a pre-stored data set)
        if(exist('time-granulated data.mat', 'file'))
           if(timeGranularity == 0)
               load('time-granulated data.mat'); %Load all available datasets with different time granularities stored in it
               timeGranularity = [3, 5, 10, 15, 20, 30]; %The pre-defined time-granularities
               HMMmodel = cell(length(timeGranularity), 2);
               simulationResult = cell(length(timeGranularity), 2);
               for i=1:length(timeGranularity)
                   timeGranulatedDataVarName = num2words(timeGranularity(i), 'hyphen', true);
                   timeGranulatedDataVarName = strcat(timeGranulatedDataVarName, 'Min');
                   timeGranulatedDataVarName = miscReplaceWhitespaceWithHyphen(timeGranulatedDataVarName);
                   dataSequence = eval([timeGranulatedDataVarName, ';']);
%                    eval(['clear', timeGranulatedDataVarName, ';']);
                   HMMmodel{i, 1} = genHMM(dataSequence, timeGranularity(i), expType);
                   HMMmodel{i, 2} = timeGranularity(i);
                   simulationResult{i, 1} = expHMM(initChargeLvl, HMMmodel{i, 1}, timeGranularity(i));
                   simulationResult{i, 2} = timeGranularity(i);
               end
               miscPlotResults(simulationResult, timeGranularity);
           else
               timeGranulatedDataVarName = num2words(timeGranularity, 'hyphen', true);
               timeGranulatedDataVarName = strcat(timeGranulatedDataVarName, 'Min');
               timeGranulatedDataVarName = miscReplaceWhitespaceWithHyphen(timeGranulatedDataVarName);
               warning ('off','all');
               load('time-granulated data.mat', timeGranulatedDataVarName);
               if(exist(timeGranulatedDataVarName, 'var'))
                    dataSequence = eval([timeGranulatedDataVarName, ';']); 
                    HMMmodel = genHMM(dataSequence, timeGranularity, 1);
                    simulationResult = expHMM(initChargeLvl, HMMmodel, timeGranularity);
                    miscPlotResults(simulationResult, timeGranularity);
               else
                   error('The stored data sequences does not contain %s dataset that you are looking for. Please try with a time-granularityof 3, 5, 10, 15, 20, 30 or start the program from scratch and input your desired time-granularity\n', timeGranulatedDataVarName);
               end
           end
        else
            error('The file "time-granulated data.mat" does not exist in the source directory "%s\\Data".\n', pwd)
        end
    end
    
end

end