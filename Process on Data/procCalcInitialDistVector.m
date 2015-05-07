function initialDist = procCalcInitialDistVector(labeledDataRecord, timeGranularity, initChargeLvl, exactMatch, expType, numOfDays)
%{
This function calculates a vector of initial probability distribution given
 initial charge level is equal to initChargeLvl

Inputs:
- labeledDataRecord: A matrix with size n by 10 for one specific time 
granularity where n is the number of labeled records and 10 is the number 
of attribute for each record
- timeGranularity: The time granularity of the data record sets
- initChargeLvl: The initial charge level from which the user battery 
charge level sequence extraction begins
- exactMatch: Takes on values of 1 or 0. If 1 the function select the 'start
charge levels' equal to initChargeLvl exactly. If not, the function selects
the 'start charge levels' with a boundary of initChargeLvl.
- numOfDays: A posotive, preferably integer, quantity that specifies the 
number of days for which the simulation will run

Output:
- initialDist: A vector of initial probability distribution given initial
charge level is equal to initChargeLvl

%}

%% Function code stars here

numOfStates = length(unique(labeledDataRecord(:, end))); %Get the number of states
initialDist = zeros(1, numOfStates);
boundary = 0.35; %Emprically chosen

if(expType == 1)
    exactNumberOfRequestedIntervals = numOfDays * (1440/timeGranularity);
    if(exactMatch == 1)
        exactMatchIndices = (find(labeledDataRecord(:, 6) == initChargeLvl));
        if(~isempty(exactMatchIndices))
          startIndex = exactMatchIndices(1);
          initialDist(labeledDataRecord(startIndex, end)) = initialDist(labeledDataRecord(startIndex, end)) + 1;
          k = 2;
           while(k <= length(exactMatchIndices))
              if(exactMatchIndices(k) < startIndex + exactNumberOfRequestedIntervals - 1 && startIndex + exactNumberOfRequestedIntervals - 1 <= size(labeledDataRecord, 1))
                  exactMatchIndices(k) = [];
                  k = k - 1;
              elseif(exactMatchIndices(k) > startIndex + exactNumberOfRequestedIntervals - 1)
                  if(startIndex + exactNumberOfRequestedIntervals - 1 <= size(labeledDataRecord, 1))
                      initialDist(labeledDataRecord(min(size(labeledDataRecord, 1), startIndex + 1), end)) = initialDist(labeledDataRecord(min(size(labeledDataRecord, 1), startIndex + 1), end)) + 1;
                      startIndex = exactMatchIndices(k);
                  else
                      exactMatchIndices(k - 1:end) = [];
                      break;
                  end
              else
                  exactMatchIndices(k - 1:end) = [];
                  break;
              end
              k = k + 1;
           end
        end
    elseif(exactMatch == 0) %If not looking for exact matches
           k = 1;
           while(k <= size(labeledDataRecord, 1) - exactNumberOfRequestedIntervals)
               if(labeledDataRecord(k, 6) - boundary*(timeGranularity/10) < initChargeLvl && labeledDataRecord(k, 6) + boundary*(timeGranularity/10) > initChargeLvl) %The 'starting charge level' must be within a bound of initChargeLvl
                   if(miscCheckIndexExceeding(k, exactNumberOfRequestedIntervals, 0, labeledDataRecord))
                      initialDist(labeledDataRecord(min(size(labeledDataRecord, 1), k + 1), end)) = initialDist(labeledDataRecord(min(size(labeledDataRecord, 1), k + 1), end)) + 1;
                      k = k + exactNumberOfRequestedIntervals;
                   else
                       break;
                   end
               else
                   k = k + 1;
               end
           end
    end
end

initialDist = initialDist + randi([1, 3]); %Smoothing
initialDist = initialDist / sum(initialDist); %Transform to probability density

end