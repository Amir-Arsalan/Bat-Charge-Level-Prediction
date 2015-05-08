function miscPlotWithDifLineStyles(simulationResult, originalResult, numberOfInstancesToPlot)
%{
This function plots each row of the input matrix with a different line
style

Input:
- simulationResult: The stats (mean or standard deviation) of simulations, if a 
matrix it has a size of n by t where n is the number of time granularities 
and t is the number of intervals for which simulation has taken place. In
case of cell it has a size of m by 2 where m is the number of simulations
taken place for different time granularities and the second column stores
the associated time granularity. Each element of the first column in the
cell contains a matrix of z by t where z is the number of simulation taken
place and t is the number of intervals for the simulation.
- originalResult: The stats (mean or standard deviation) of original data 
records. It is a matrix of n by t where n is the number of time
granularities and t is the number of intervals for which simulation has
taken place. In case of cell it is a cell of m by 2 where m is the number
of data record sets and the second column stores the associated time 
granularity. Each element of the first column in the cell contains a matrix
 of z by t where z is the number of sequences where with an initial charge
 level, which has been input when program was run first.
- numberOfInstancesToPlot: The number of simulationResult and/or 
originalResult sequences/instances to plot for each time granularity

Output:
(void) Plot
%}

%% Function code starts here

lineStyle = {'-', '--', '-.', '-.o', '--o', ':', 'x', '^', 'v', '-.+', 'd', '-v', ':', '+'};

if(isempty(simulationResult) && isempty(originalResult))
   error('There is no simulation or original battery charge level sequence to plot'); 
end
i = 1;
if(~isempty(simulationResult))
    plot(1:size(simulationResult, 2), simulationResult(1, :), lineStyle{1}, 'MarkerSize', 3);
    hold on
    for i=2:min(numberOfInstancesToPlot, size(simulationResult, 1))
       plot(1:size(simulationResult, 2), simulationResult(i, :), lineStyle{i}, 'MarkerSize', 3);
    end
    hold off
end

if(~isempty(originalResult))
    if(isempty(i))
        i = 1;
    end
    hold on
    if(isempty(simulationResult))
        i = 1;
        nextPlotTypeIndex = 1;
    else
        nextPlotTypeIndex = i + 1;
    end
    
    if(exist('numberOfInstancesToPlot', 'var') && numberOfInstancesToPlot > 1)
       toPlotInstancesIndex = randi([1, size(originalResult, 1)], numberOfInstancesToPlot, 1);
    end
    
    plot(1:size(originalResult, 2), originalResult(toPlotInstancesIndex(1), :), lineStyle{nextPlotTypeIndex}, 'MarkerSize', 3);
    for i=2:min(numberOfInstancesToPlot, size(originalResult, 1))
       plot(1:size(originalResult, 2), originalResult(toPlotInstancesIndex(i), :), lineStyle{nextPlotTypeIndex + i - 1}, 'MarkerSize', 3);
    end
    hold off
end


end