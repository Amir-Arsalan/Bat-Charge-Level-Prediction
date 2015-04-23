function combinedDataSet = combineIndividualsUsageData(dataSet)
%dataSet = a data set containing individuals records in as rows and their
%battery level data as a cell stored in the second column of the cell. The
%data has 6 columns as follow: 
%Current Battery Level
%Time of Day
%Delta T(the difference between CBL at time t and CBL at time t + 1)
%Time to Charge the Phone
%Charge when Plugged-in
%Charge Percentage Remained to Plug-in Time
combinedDataSet = [];
k = 1;
for i=1:size(dataSet)
   temp = dataSet{i, 2};
   if(~isempty(temp)) %If the cell was not empty
       if(size(temp, 1) > 1) %Check if there were more than 1 time of charging data for a user (we need to combined them into one cell)
           userData = [];
          for j=1:size(temp, 1)
              if(size(temp{j, 1}, 1) > 3) %If there was more than three data point in a cell
                  userData = [userData; temp{j, 1}];
              end
          end
          temp = [];
          temp{1, 1} = userData;
       end
       if(~isempty(temp{1, 1}))
           combinedDataSet{k, 1} = cell2mat(temp{:, 1}(:, [1, 2, 4, 6])); %Only keep the [1, 2, 4, 6] columns since further processes will be done on these columns
           k = k + 1;
       end
   end
end
end