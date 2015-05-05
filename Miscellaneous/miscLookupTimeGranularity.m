function timeGranularityIndices = miscLookupTimeGranularity(dataRecord, timeGranularity)
%{
This function finds the indices of elements of the desired timeGranularity 
in the dataRecord cell

Inputs:
- dataRecord: A cell of m by 2 where m is the number of different data set
records, each with a distinct timeGranularity, and the second column stores
the timeGranularity associated with that data set record

- timeGranularity: A vector containing different time granularities

Output:
- timeGranularityIndices: A k by 2 matrix where k is the number of
timeGranularities. The 1st column stores the index of data record set
associated with the time granularity of interest and the 2nd column 
%}

%% Function code starts here

storedTimeGranularity = zeros(1, size(dataRecord, 1));
for i=1:size(dataRecord, 1)
    storedTimeGranularity(i) = dataRecord{i, 2};
end

timeGranularityIndices = zeros(min(length(storedTimeGranularity), length(timeGranularity)), 2);
tempIndex = 1;
for i=1:length(timeGranularity)
    for j=1:length(storedTimeGranularity)
       if(timeGranularity(i) == storedTimeGranularity(j))
           timeGranularityIndices(tempIndex, 1) = j;
           timeGranularityIndices(tempIndex, 2) = timeGranularity(i);
           tempIndex = tempIndex + 1;
       end
    end
end

i = 1;
while(i <= size(timeGranularityIndices))
   if(~all(timeGranularityIndices(i, :)))
       fprintf('The stored time granulated data record sets do not include a data record set with time granularity of %d-minute\n', timeGranularity(i));
       timeGranularityIndices(i, :) = [];
   end
   i = i + 1;
end

end