function miscPlotChargeLevelPrediction(initChargeLvl, intervalConsistentSimulationResult, interpolatedOriginalSeqs, numOfDays)
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
- numOfDays: A posotive, preferably integer, quantity that specifies the 
number of days for which the simulation will/is run

Output:
Plotting
%}

%% Function code starts here

simChargeLvlStat = cell(size(intervalConsistentSimulationResult, 1), 2); %The first column for mean and the second for standard deviation
orgChargeLvlStat = cell(size(intervalConsistentSimulationResult, 1), 2); %The first column for mean and the second for standard deviation
numOfDays = round(numOfDays);

for i=1:size(intervalConsistentSimulationResult, 1)
    
    simChargeLvlStat{i, 1} = zeros(100, numOfDays);
    simChargeLvlStat{i, 2} = zeros(100, numOfDays);
    orgChargeLvlStat{i, 1} = zeros(100, numOfDays);
    orgChargeLvlStat{i, 2} = zeros(100, numOfDays);

    for j=0:99 %Charge level 0 to 100 (i + 1)
        [~, relevantIndexNumsInSimulation] = find(intervalConsistentSimulationResult{i, 1} >= j & intervalConsistentSimulationResult{i, 1} <= j + 1);
        [~, relevantIndexNumsInInterpolatedData] = find(interpolatedOriginalSeqs{i, 1} >= j & interpolatedOriginalSeqs{i, 1} <= j + 1);
        if(j == initChargeLvl);
        end
        [simChargeLvlStat{i, 1}(j + 1, :), simChargeLvlStat{i, 2}(j + 1, :)] = miscFitGMM(relevantIndexNumsInSimulation, numOfDays);
        [orgChargeLvlStat{i, 1}(j + 1, :), orgChargeLvlStat{i, 2}(j + 1, :)] = miscFitGMM(relevantIndexNumsInInterpolatedData, numOfDays);
    end
end

end