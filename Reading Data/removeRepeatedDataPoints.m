function cleanedData = removeRepeatedDataPoints(dataSet)
%Removes the two same data rows in dailyUsageData

%Input: a cell matrix of size n x 2 where n is the number of users and the
%second column contains usage data for users.

%Output: A cleaner dataSet

for i=1:size(dataSet, 1)
    
   userData = dataSet{i, 2};
   
   for j=1:size(userData, 1)
       
      dailyUsageData = userData{j, 2};
      dailyUsageDataSize = size(dailyUsageData, 1);
      
      k = 2;
      while(k <= dailyUsageDataSize)
                   
         if(strcmp(dailyUsageData(k-1, :), dailyUsageData(k, :))) %If the data point was exactly similar to the previous data point
            
             dailyUsageData(k, :) = []; %Remove the data point
             dailyUsageDataSize = dailyUsageDataSize - 1;             
         end
         k = k + 1;
          
      end
      
      userData{j, 2} = dailyUsageData;
       
   end
   
   dataSet{i, 2} = userData;
    
end

cleanedData = dataSet;

end