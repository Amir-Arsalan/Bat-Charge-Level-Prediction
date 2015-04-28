function expExecute(fromScratch, expType, timeGranularity, initChargeLvl)

%{
This function is used to run different experiments. It is assumed that the
data set has been stored in "Complete 207 users data.mat" file.

Input:
- fromScratch: Is 1 when the user wants to generate a data set with a
new time granularity than or when the data set is different than the ones
already stored.
- expType: Type of experiment to be executed
- timeGranularity: A single quantity indicating the time granularity 
at which the expriments will run. If is set to zero the experiments will 
run for the time granularities 3, 5, 10, 15, 20 and 30.
- initChargeLvl: The initial charge level from which the simulations start
%}

if(timeGranularity < 0)
    timeGranularity = 0;
end

if(fromScratch == 1 || fromScratch == 0) %Ensure it is assigned a logical quantity
    
    if(fromScratch)
        if(exist('Complete 207 users data.mat', 'file'))
            load('Complete 207 users data.mat', 'Dataset', 'requestedTags', 'requestedPaths');
            if(timeGranularity ~= 0)
                dataSequence = procStart(Dataset, requestedTags, timeGranularity);
                %Learn the model
            else
               timeGranularity = [3, 5, 10, 15, 20, 30];
               timeGranulatedDatasets = cell(length(timeGranularity), 2);
               for i=1:length(timeGranularity)
                   dataSequence = procStart(Dataset, requestedTags, timeGranularity(i));
                   timeGranulatedDatasets{i, 1} = dataSequence;
                   timeGranulatedDatasets{i, 2} = timeGranularity(i);
               end
            end

            %Run experiments
            if(expType == 1) %Experiments numbered "1" are run using simple hidden Markov models

            end
        else
            error('The file "Complete 207 users data.mat" does not exist in the source directory "%s".\n', pwd)
        end
    else
        if(exist('time-granulated data.mat', 'file'))
           if(timeGranularity == 0)
               load('time-granulated data.mat'); %Load all available datasets with different time granularities stored in it
               timeGranularity = [3, 5, 10, 15, 20, 30];
               HMMmodel = cell(length(timeGranularity), 1);
               simulations = cell(length(timeGranularity), 1);
               for i=1:length(timeGranularity)
                   timeGranulatedDataVarName = num2words(timeGranularity(i), 'hyphen', true);
                   timeGranulatedDataVarName = strcat(timeGranulatedDataVarName, 'Min');
                   timeGranulatedDataVarName = miscReplaceWhitespaceWithHyphen(timeGranulatedDataVarName);
                   dataSequence = eval([timeGranulatedDataVarName, ';']);
                   HMMmodel{i, 1} = genHMM(dataSequence, timeGranularity(i), expType);
                   simulations{i, 1} = expHMM(initChargeLvl, HMMmodel{i, 1}, timeGranularity(i));
               end
           else
               timeGranulatedDataVarName = num2words(timeGranularity, 'hyphen', true);
               timeGranulatedDataVarName = strcat(timeGranulatedDataVarName, 'Min');
               timeGranulatedDataVarName = miscReplaceWhitespaceWithHyphen(timeGranulatedDataVarName);
               warning ('off','all');
               load('time-granulated data.mat', timeGranulatedDataVarName);
               if(exist(timeGranulatedDataVarName, 'var'))
                  dataSequence = eval([timeGranulatedDataVarName, ';']); 
                  HMMmodel = genHMM(dataSequence, timeGranularity, 1);
                  simulations = expHMM(initChargeLvl, HMMmodel, timeGranularity);
               else
                   error('The stored data sequences does not contain %s dataset that you are looking for. Please try with a time-granularityof 3, 5, 10, 15, 20, 30 or start the program from scratch and input your desired time-granularity\n', timeGranulatedDataVarName);
               end
           end
        else
            error('The file "time-granulated data.mat" does not exist in the source directory "%s\\Data".\n', pwd)
        end
    end
    
end

plot(1:288, simulations(1:5, :))
ylim([0 100])
figure; plot(mean(simulations))
ylim([0 100])
ylim auto
figure; plot(std(simulations))

end