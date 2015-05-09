function miscPlotSimulationResults(simulationResult, timeGranularity, succinct, numOfDays, rawDataRecMean, rawDataRecStd, interpolatedOriginalSeqs)

%{
Plots the simulation results

Input:
- simulationResult: It is either a cell of n x 2 where n is the number of
simulations, each element of the first column contains a matrix of m by t 
where m is the number of simulations and t is the number of intervals that
the simulation has taken placed for. Each interval is equivalent to the 
smallest time granularity. The second column of the cell stores the time 
granularity associated with the simulation.
- timeGranulatedDataRecord: A cell of n by 2 where each element in the 
first column contains a matrix of time granulated data record set and 
each element of the second column contains an associated time granularity
- timeGranularity: A single quantity or a vector of time granularities
- succinct: Takes on the values 0 or 1. Determines whether the plots should be succinct or not
- numOfDays: A posotive, preferably integer, quantity that specifies the 
number of days for which the simulation will run
- rawDataRecMean: Mean of extracted battery charge levels.
- rawDataRecStd: Standard deviations of extracted batery charge levels
- interpolatedOriginalSeqs: Interpolated charge levels given the smallest time
granularity


Note: The simulation could be a cell of h x 2 cell where h corresponds to
number of time-granularities for which simulation is done and the second
column stores the time-granularity associated with the simulation result
%}


%% The function code starts here

if(size(timeGranularity, 2) > 1)
    timeGranularity = timeGranularity';
end

if(succinct == 0)
    for i=1:size(simulationResult, 1)
        figure; subplot(2, 2, 1)
        miscPlotWithDifLineStyles(simulationResult{i, 1}, [], 5);
%         plot(1:size(simulationResult{i, 1}(1, :), 2), simulationResult{i, 1}(1:5, :), lineStyle{i}, 'MarkerSize', 3)
        title(sprintf('Five simulations shown for %d-minute time granularity', timeGranularity(i)))
        xlabel(sprintf('Time intervals (each interval represents %d minutes)', timeGranularity(i)));
        ylabel('Charge Level');
        ylim([0 100])
        subplot(2, 2, 2)
        plot(std(simulationResult{i, 1}))
        ylim([0, 45])
        title(sprintf('Standard Deviation of simulations for %d-minute time granularity', timeGranularity(i)))
        xlabel(sprintf('Time intervals (each interval represents %d minutes)', timeGranularity(i)));
        ylabel('Charge Level');
        subplot(2, 2, [3, 4])
        plot(mean(simulationResult{i, 1}))
        title(sprintf('Mean of simulations for %d-minute time granularity', timeGranularity(i)))
        xlabel(sprintf('Time intervals (each interval represents %d minutes)', timeGranularity(i)));
        ylabel('Charge Level');
        ylim([0 100])
    end
    for i=1:size(interpolatedOriginalSeqs, 1)
        figure; subplot(2, 2, 1)
        miscPlotWithDifLineStyles([], interpolatedOriginalSeqs{i, 1}, 5);
%         plot(1:size(simulationResult{i, 1}(1, :), 2), simulationResult{i, 1}(1:5, :), lineStyle{i}, 'MarkerSize', 3)
        title(sprintf('Five raw data sequences shown for %d-minute time granularity', timeGranularity(i)))
        xlabel(sprintf('Time intervals (each interval represents %d minutes)', timeGranularity(i)));
        ylabel('Charge Level');
        ylim([0 100])
        subplot(2, 2, 2)
        plot(std(interpolatedOriginalSeqs{i, 1}))
        ylim([0, 45])
        title(sprintf('Standard Deviation of raw data sequences for %d-minute time granularity', timeGranularity(i)))
        xlabel(sprintf('Time intervals (each interval represents %d minutes)', timeGranularity(i)));
        ylabel('Charge Level');
        subplot(2, 2, [3, 4])
        plot(mean(interpolatedOriginalSeqs{i, 1}))
        title(sprintf('Mean of raw data sequences for %d-minute time granularity', timeGranularity(i)))
        xlabel(sprintf('Time intervals (each interval represents %d minutes)', timeGranularity(i)));
        ylabel('Charge Level');
        ylim([0 100])
    end
elseif(succinct == 1)
    interpolatedSimulationResult = procGenerateIntervalConsistentDataRecord(simulationResult, timeGranularity, numOfDays);
    means = zeros(size(interpolatedSimulationResult, 1), size(interpolatedSimulationResult{1, 1}, 2));
    stds = zeros(size(interpolatedSimulationResult, 1), size(interpolatedSimulationResult{1, 1}, 2));
    for i=1:size(interpolatedSimulationResult, 1)
        means(i, :) = mean(interpolatedSimulationResult{i, 1});
        stds(i, :) = std(interpolatedSimulationResult{i, 1});
    end

    figure; 
    miscPlotWithDifLineStyles(means, rawDataRecMean, 14);
    miscPlotApplySettings([], [0, 100], sprintf('Time intervals (each interval is %d minutes)', timeGranularity(1)), 'Charge Level', sprintf('Means of simulations and real data with time granularities of %s minutes shown. Not exact + With conditional state dist + With csd for next state + with Smoothing', strcat(strcat('[', num2str(timeGranularity')), ']')))

    hold on
    theLegendText = strcat(horzcat('''Prediction Mean (', num2str(timeGranularity(1))), ')''');
    for i=2:length(timeGranularity)
    theLegendText = strcat(strcat(theLegendText, strcat(', ''', horzcat('Prediction Mean (' ,num2str(timeGranularity(i))))), ')''');
    end
    for i=1:size(rawDataRecMean, 1)
        theLegendText = strcat(strcat(theLegendText, strcat(', ''', horzcat('Raw Data Mean (' ,num2str(timeGranularity(i))))), ')''');
    end
    eval(['legend(', theLegendText, ', ''Location'', ''Southeast'');']);
    hold off

    figure;
    miscPlotWithDifLineStyles(stds, rawDataRecStd, 14);
    miscPlotApplySettings([], [0, 45], sprintf('Time intervals (each interval is %d minutes)', timeGranularity(1)), 'Charge Level', sprintf('Standard Deviations of simulations and real data with time granularities of  %s minutes shown. Not exact + With conditional state dist + With csd for next state + with Smoothing', strcat(strcat('[', num2str(timeGranularity')), ']')))

    hold on
    theLegendText = strcat(horzcat('''Prediction Std (', num2str(timeGranularity(1))), ')''');
    for i=2:length(timeGranularity)
    theLegendText = strcat(strcat(theLegendText, strcat(', ''', horzcat('Prediction Std (' ,num2str(timeGranularity(i))))), ')''');
    end
    for i=1:size(rawDataRecMean, 1)
        theLegendText = strcat(strcat(theLegendText, strcat(', ''', horzcat('Raw Data Std (' ,num2str(timeGranularity(i))))), ')''');
    end
    eval(['legend(', theLegendText, ', ''Location'', ''Southeast'');']);
    hold off
else
    error('Succinct cannot take any value differnet than 0 or 1');
end

end