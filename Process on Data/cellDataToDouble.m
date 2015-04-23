function processedUsageData = cellDataToDouble(dataSet)
%Converts cell matrices containing sampled data to double

processedUsageData = cell(size(dataSet, 1), 2);

for i=1:size(dataSet, 1)
   userData = dataSet{i, 2};
   for j=1:size(userData, 1)
      userData{j, 1} = cell2mat(userData{j, 1});
   end
   processedUsageData{i, 1} = dataSet{i, 1};
   processedUsageData{i, 2} = userData;
end

end

