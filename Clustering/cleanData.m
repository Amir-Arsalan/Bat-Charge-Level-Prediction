function cleanedUsageData = cleanData(dataSet)
%This functions tries to reduce the noise level in the data data points for each occured due to
%temperature change

%Input: A cell matrix with the size n x 2 where n is the number of users
%and in the second column of each row the user's usage data is stored

%%
%This part removes the data points in which the battery level increases
%instead of decreasing after some period of time. This may have happened
%due to temperature change in the environment
for i=1:size(dataSet, 1)
    userData = dataSet{i, 2};
    flag = false(size(userData, 1), 1);
    lessImportantDataSequences = false(size(userData, 1), 1);
   for j=1:size(userData, 1)
      timeSeriesDataSequence = userData{j, 1};
      if(size(timeSeriesDataSequence, 1) <= 2)
          lessImportantDataSequences(j, 1) = 1; %If the number of rows of a time series data was less than 3, mark it so that it will be removed at the end of the program
      else
          k = 2;
          while (k <= size(timeSeriesDataSequence, 1)-1)
              if(timeSeriesDataSequence(k-1, 1) == timeSeriesDataSequence(k+1, 1))
                  timeSeriesDataSequence(k-1, :) = []; %Remove the data points
                  timeSeriesDataSequence(k-1, :) = []; %Remove the data points
                  if(size(timeSeriesDataSequence, 1) > 2)
                      flag(j, 1) = 1;
                  end
              end
              k = k + 1;
          end
          if(flag(j, 1) == 1)
              userData{j, 1} = timeSeriesDataSequence;
          end
          if(size(timeSeriesDataSequence, 1) <= 2)
              lessImportantDataSequences(j, 1) = 1;
          end
      end
   end
   if(sum(flag) > 0)
      dataSet{i, 2} = userData; 
   end
   if(sum(lessImportantDataSequences) > 0) %If there was at least one time series data considered as not important
       importantDataSequencesIncides = find(~lessImportantDataSequences);
       valueableUserData = cell(sum(~lessImportantDataSequences), 1);
       if(size(importantDataSequencesIncides, 1) > 0)
           for l=1:sum(~lessImportantDataSequences)
               valueableUserData{l, 1} = userData{importantDataSequencesIncides(l, 1), 1};
           end
       else
           valueableUserData = [];
       end
       dataSet{i, 2} = valueableUserData;
   end
   
end

cleanedUsageData = dataSet;

end

