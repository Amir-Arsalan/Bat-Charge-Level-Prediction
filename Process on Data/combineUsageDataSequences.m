function combinedDataSet = combineUsageDataSequences(dataSet)
%dataSet = a cell data set of the size n x 2 where n is the number of users and the second column stores the data corresponding to each of the users
%The data has 6 columns as follow: 
%Current Battery Level
%Time of Day
%Delta T(the difference between CBL at time t and CBL at time t + 1)
%Time to Charge the Phone
%Charge when Plugged-in
%Charge Percentage Remained to Plug-in Time
combinedDataSet = [];
k = 1;
alreadyCombined = false;
for i=1:size(dataSet)
    alreadyCombined = false;
    temp = dataSet{i, 2};
   if(~isempty(temp)) %If the cell was not empty
       if(size(temp, 1) > 1) %Check if there were more than 1 time of charging data for a user (we need to combined them into one cell)
           temp1 = [];
          for j=1:size(temp, 1)
              if(size(temp{j, 1}, 1) > 3) %Store the data only if there were more than three data points
                  alreadyCombined = true;
                  temp1 = [temp1; temp{j, 1}];
                  combinedDataSet{k, 1} = cell2mat(temp{j, 1}(:, [1, 2, 4, 6]));
                  k = k + 1;
              end
          end
          temp = [];
          temp{1, 1} = temp1;
       end
       if(~isempty(temp{1, 1}) && size(temp{1, 1}, 1) > 3 && alreadyCombined == false)
           combinedDataSet{k, 1} = cell2mat(temp{:, 1}(:, [1, 2, 4, 6])); %Only keep the [1, 2, 4, 6] columns as further processes will be done on these columns
           k = k + 1;
       end
   end
end
end