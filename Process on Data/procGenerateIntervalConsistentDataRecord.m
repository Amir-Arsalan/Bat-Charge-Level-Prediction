function intervalConsistentSimulationResult = procGenerateIntervalConsistentDataRecord(simulationResult, timeGranularity, numOfDays)
%{
This function generates interval-consistent data record sets

Inputs:
- simulationResults: It is either a matrix of n x m where n is the number
of simulations and m is the number of intervals (dependent on time
granularity selected for the simulation) or a cell of t by 2 where each 
element of the first column contains an n x m matrix and each element of
the second column stores the associated time granularity.
- timeGranularity: A vector of time granularity sorted in ascending order
- numOfDays: A posotive, preferably integer, quantity that specifies the 
number of days for which the simulation will run

Output:
- intervalConsistentSimulationResult: The simulation results with a
consistent time granularity equal to the smallest time granularity

%}

%% Function code starts here

intervalConsistentSimulationResult = cell(size(simulationResult, 1), 2);
intervalConsistentSimulationResult{1, 1} = simulationResult{1, 1};
intervalConsistentSimulationResult{1, 2} = simulationResult{1, 2};
smallestTimeGranularity = timeGranularity(1); %Since we know timeGranularity is sorted in ascending order

for i=2:size(simulationResult, 1)
   originalDataRecordSet = single(simulationResult{i, 1});
   interpolatedDataRecordSet = zeros(size(originalDataRecordSet, 1), ceil(1440/smallestTimeGranularity) * numOfDays);
   for j=1:size(interpolatedDataRecordSet, 1)
       interpolatedDataRecordSet(j, 1) = originalDataRecordSet(j, 1);
       firstIndex = 1;
      for k=1:size(originalDataRecordSet, 2)
          lastIndex = round(timeGranularity(i)/smallestTimeGranularity * k);
          interpolatedDataRecordSet(j, lastIndex) = originalDataRecordSet(j, k);
          if(lastIndex - firstIndex > 1)
              numbersInBetween = linspace(interpolatedDataRecordSet(j, firstIndex), interpolatedDataRecordSet(j, lastIndex), lastIndex - firstIndex + 1);
              interpolatedDataRecordSet(j, firstIndex + 1:lastIndex - 1) = numbersInBetween(2:end-1); %Fill the missing values by a linear interpolation
          end
          firstIndex = lastIndex;
      end
   end
   intervalConsistentSimulationResult{i, 1} = interpolatedDataRecordSet;
   intervalConsistentSimulationResult{i, 2} = timeGranularity(i);
end

end