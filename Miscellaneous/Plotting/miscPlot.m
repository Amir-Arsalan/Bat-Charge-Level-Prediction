function miscPlot(plotType, simulationResult, timeGranularity, succinct, numOfDays, initChargeLvl, rawDataRecMean, rawDataRecStd, interpolatedOriginalSeqs)
%{
Plot the appropriate type of plots

Input:
- plotType: It is a single quantity or a vector to determine the type of 
plots that the user requests after the program has ended execution. If
empty, the program will not plot the results.
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
number of days for which the simulation will/is run
- initChargeLvl: The initial charge level from which the simulations start
- rawDataRecMean: Mean of extracted battery charge levels.
- rawDataRecStd: Standard deviations of extracted batery charge levels
- interpolatedBatSeqs: Interpolated charge levels given the smallest time
granularity

Output: 
Plot tye types of plots requested
%}

%% Plot types:
%{
1- Plot mean and variance for both simulation and raw data battery charge 
level sequences
2- Plot 5 battery charge level sequences of simulation and raw data
3- Plot mean and variance of reaching to battery charge levels 0 to 100 for
simulation and raw data battery charge level sequences, starting from an 
initial charge level
%}

%% The function code starts here

if(~isempty(plotType))
    
    if(size(plotType, 1) > 1)
       if(size(plotType, 2) > 1)
           plotType = plotType(1, :);
       else
           plotType = plotType';
       end
    end
    
    for i=1:length(plotType)
        if(plotType(i) == 1)
            miscPlotSimulationResults(simulationResult, timeGranularity, succinct, numOfDays, rawDataRecMean, rawDataRecStd);
        elseif(plotType(i) == 2)
            miscPlotSimulationResults(simulationResult, timeGranularity, ~succinct , numOfDays, rawDataRecMean, rawDataRecStd, interpolatedOriginalSeqs);
        elseif(plotType(i) == 3)
            intervalConsistentSimulationResult = procGenerateIntervalConsistentDataRecord(simulationResult, timeGranularity, numOfDays);
            miscPlotChargeLevelPrediction(initChargeLvl, intervalConsistentSimulationResult, interpolatedOriginalSeqs, numOfDays);
%             [~, a2] = find(simulationResult{1, 1} <= 75 & simulationResult{1, 1} > 74);
%             [~, a4] = find(interpolatedOriginalSeqs{1, 1} <= 75 & interpolatedOriginalSeqs{1, 1} > 74);
%             figure;hist(a4, 288); xlim([0 288])
%             figure;hist(a2, 288); xlim([0 288])
%             fitgmdist(a2, 2, 'Options', statset('Maxiter', 200));
        end
    end
end