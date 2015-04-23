function cleanedUsageData = removeUsersWithNoUsageData(dataSet)
%Input: A cell matrix with the size n x 2 where n is the number of users
%and in the second column of each row the user's usage data is stored

%Output: The users having no data will be removed from the data set

index = 1;

for i=1:size(dataSet, 1)
   if(~isempty(dataSet{i, 2})) %If there were no usage data/data points for a user
       cleanedUsageData{index, 1} = dataSet{i, 1};
       cleanedUsageData{index, 2} = dataSet{i, 2};
       index = index + 1;
   end
end

if(index == 1)
   cleanedUsageData = dataSet; 
end

end

