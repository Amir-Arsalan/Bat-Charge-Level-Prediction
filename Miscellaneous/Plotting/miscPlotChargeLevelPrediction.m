function miscPlotChargeLevelPrediction(initChargeLvl, interpolatedtSimulationResult, interpolatedOriginalSeqs, timeGranularity, numOfDays)
%{
This function plots mean and standard deviation of reaching to a charge 
level, starting from an initial charge level

Input:
- initChargeLvl: The initial charge level from which the simulations start
- intervalConsistentSimulationResult: The simulation result after applying
the procGenerateIntervalConsistentDataRecord function to make the intervals
consistent
- interpolatedBatSeqs: Interpolated charge levels given the smallest time
granularity
- timeGranularity: A single quantity or a vector of time granularities
- numOfDays: A posotive, preferably integer, quantity that specifies the 
number of days for which the simulation will/is run

Output:
Plotting
%}

%% Function code starts here

% if(~exist('from100discharge.mat', 'file'))
simChargeLvlStat = cell(size(interpolatedtSimulationResult, 1), 3); %The first column for mean and the second for standard deviation
orgChargeLvlStat = cell(size(interpolatedtSimulationResult, 1), 3); %The first column for mean and the second for standard deviation
numOfDays = round(numOfDays);

try
for i=1:size(interpolatedtSimulationResult, 1)
    
    simChargeLvlStat{i, 1} = zeros(100, numOfDays);
    simChargeLvlStat{i, 2} = zeros(100, numOfDays);
    orgChargeLvlStat{i, 1} = zeros(100, numOfDays);
    orgChargeLvlStat{i, 2} = zeros(100, numOfDays);

    j = 0;
    flag = 0;
    while(j <= 99)
        [~, relevantIndexNumsForSimulation] = find(interpolatedtSimulationResult{i, 1} >= j & interpolatedtSimulationResult{i, 1} <= j + 1);
        [~, relevantIndexNumsForInterpolatedRawData] = find(interpolatedOriginalSeqs{i, 1} >= j & interpolatedOriginalSeqs{i, 1} <= j + 1);
        [simChargeLvlStat{i, 1}(j + 1, :), simChargeLvlStat{i, 2}(j + 1, :)] = miscFitGMM(relevantIndexNumsForSimulation, numOfDays);
        [orgChargeLvlStat{i, 1}(j + 1, :), orgChargeLvlStat{i, 2}(j + 1, :)] = miscFitGMM(relevantIndexNumsForInterpolatedRawData, numOfDays);
        if(numOfDays > 1 && (flag == 0 && any(isnan(simChargeLvlStat{i, 1}(j + 1, :))) || any(isnan(simChargeLvlStat{i, 2}(j + 1, :)))))
            [simChargeLvlStat{i, 1}(j + 1, :), simChargeLvlStat{i, 2}(j + 1, :)] = miscFitGMM(relevantIndexNumsForSimulation, numOfDays);
            flag = 1;
        elseif(numOfDays == 1 && (isnan(simChargeLvlStat{i, 1}(j + 1, :)) || isnan(simChargeLvlStat{i, 2}(j + 1, :))))
            [simChargeLvlStat{i, 1}(j + 1, :), simChargeLvlStat{i, 2}(j + 1, :)] = miscFitGMM(relevantIndexNumsForSimulation, numOfDays);
            flag = 1;
        end
        if(numOfDays > 1 && (flag == 0 && any(isnan(orgChargeLvlStat{i, 1}(j + 1, :))) || any(isnan(orgChargeLvlStat{i, 2}(j + 1, :)))))
            [orgChargeLvlStat{i, 1}(j + 1, :), orgChargeLvlStat{i, 2}(j + 1, :)] = miscFitGMM(relevantIndexNumsForInterpolatedRawData, numOfDays);
            flag = 1;
        elseif(numOfDays == 1 && (isnan(orgChargeLvlStat{i, 1}(j + 1, :)) || isnan(orgChargeLvlStat{i, 2}(j + 1, :))))
            [orgChargeLvlStat{i, 1}(j + 1, :), orgChargeLvlStat{i, 2}(j + 1, :)] = miscFitGMM(relevantIndexNumsForInterpolatedRawData, numOfDays);
            flag = 1;
        end
        if(numOfDays > 1 && (any(isnan(simChargeLvlStat{i, 1}(j + 1, :))) || any(isnan(simChargeLvlStat{i, 2}(j + 1, :))) || any(isnan(orgChargeLvlStat{i, 1}(j + 1, :))) || any(isnan(orgChargeLvlStat{i, 2}(j + 1, :)))))
           flag = 1;
        end
        
        if(numOfDays > 1 && (flag == 0 && all(~diff(round(simChargeLvlStat{i, 1}(j + 1, :)))) || all(~diff(round(simChargeLvlStat{i, 2}(j + 1, :)))))) %If all values in one of the rows of the matrix were the same
            [simChargeLvlStat{i, 1}(j + 1, :), simChargeLvlStat{i, 2}(j + 1, :)] = miscFitGMM(relevantIndexNumsForSimulation, numOfDays);
            flag = 1;
        end
        if(numOfDays > 1 && (flag == 0 && all(~diff(round(orgChargeLvlStat{i, 1}(j + 1, :)))) || all(~diff(round(orgChargeLvlStat{i, 2}(j + 1, :)))))) %If all values in one of the rows of the matrix were the same
            [orgChargeLvlStat{i, 1}(j + 1, :), orgChargeLvlStat{i, 2}(j + 1, :)] = miscFitGMM(relevantIndexNumsForInterpolatedRawData, numOfDays);
            flag = 1;
        end
        
        if(flag == 0)
            j = j + 1;
        else
            flag = 0;
        end
    end
    simChargeLvlStat{i, 3} = timeGranularity(i);
    orgChargeLvlStat{i, 3} = timeGranularity(i);
end
catch
    flag = 2;
    warning('Unable to fit GMMs, re-trying again');
    miscPlotChargeLevelPrediction(initChargeLvl, interpolatedtSimulationResult, interpolatedOriginalSeqs, timeGranularity, numOfDays);
end

% end

% load('from100discharge.mat');
if(flag == 0)
    
    simRes = cell(numOfDays, 1);
    meanSimulationIntervalsRemainedToGetToChargeLvlFor = zeros(size(simChargeLvlStat, 1), 100);
    stdSimulationIntervalsRemainedToGetToChargeLvlFor = zeros(size(simChargeLvlStat, 1), 100);

    meanRawDataIntervalsRemainedToGetToChargeLvlFor = zeros(size(orgChargeLvlStat, 1), 100);
    stdRawDataIntervalsRemainedToGetToChargeLvlFor = zeros(size(orgChargeLvlStat, 1), 100);

    for i=1:numOfDays
        for j=1:size(simChargeLvlStat, 1)
            meanSimulationIntervalsRemainedToGetToChargeLvlFor(j, :) = simChargeLvlStat{j, 1}(:, i)';
            stdSimulationIntervalsRemainedToGetToChargeLvlFor(j, :) = simChargeLvlStat{j, 2}(:, i)';

            meanRawDataIntervalsRemainedToGetToChargeLvlFor(j, :) = orgChargeLvlStat{j, 1}(:, i)';
            stdRawDataIntervalsRemainedToGetToChargeLvlFor(j, :) = orgChargeLvlStat{j, 2}(:, i)';
        end

        figure; subplot(2, 2, [1, 2])
        miscPlotWithDifLineStyles(meanSimulationIntervalsRemainedToGetToChargeLvlFor, meanRawDataIntervalsRemainedToGetToChargeLvlFor, 14);

        miscPlotApplySettings([], [0, numOfDays*1440/timeGranularity(1)], 'Charge Level', sprintf('Time intervals (each interval is %d minutes)', timeGranularity(1)), sprintf('Expected Number of Intervals to Reach a Specific Charge Level in the Next %s hours Shown for Time Granularity(ies) of %s Minutes', num2str((i * 24)), strcat(strcat('[', num2str(timeGranularity')), ']')));

        hold on
        theLegendText = strcat(horzcat('''Prediction(', num2str(timeGranularity(1))), ')''');
        for j=2:length(timeGranularity)
        theLegendText = strcat(strcat(theLegendText, strcat(', ''', horzcat('Prediction(' ,num2str(timeGranularity(j))))), ')''');
        end
        for j=1:size(orgChargeLvlStat, 1)
            theLegendText = strcat(strcat(theLegendText, strcat(', ''', horzcat('Raw Data(' ,num2str(timeGranularity(j))))), ')''');
        end
        eval(['legend(', theLegendText, ', ''Location'', ''Northeast'');']);
        hold off

        subplot(2, 2, [3, 4]);
        miscPlotWithDifLineStyles(stdSimulationIntervalsRemainedToGetToChargeLvlFor, stdRawDataIntervalsRemainedToGetToChargeLvlFor, 14);

        miscPlotApplySettings([], [0, 100], 'Charge Level', sprintf('Time intervals (each interval is %d minutes)', timeGranularity(1)), sprintf('Standard Deviations Intervals to Reach a Specific Charge Level Shown for Time Granularity(ies) of %s Minutes for the Next %s hours', strcat(strcat('[', num2str(timeGranularity')), ']'), num2str(i * 24)));
    
        hold on
        theLegendText = strcat(horzcat('''Prediction(', num2str(timeGranularity(1))), ')''');
        for j=2:length(timeGranularity)
        theLegendText = strcat(strcat(theLegendText, strcat(', ''', horzcat('Prediction(' ,num2str(timeGranularity(j))))), ')''');
        end
        for j=1:size(orgChargeLvlStat, 1)
            theLegendText = strcat(strcat(theLegendText, strcat(', ''', horzcat('Raw Data(' ,num2str(timeGranularity(j))))), ')''');
        end
        eval(['legend(', theLegendText, ', ''Location'', ''Northeast'');']);
        hold off
    end

else
    warning('Failed to fit GMM to either the prediction or the raw data records. Cannot execute plot type ''3''');    
end

end