function combinedDataSet = combineAllData(dataSet)
%Input: A cell matrix with the size n x 2 where n is the number of users 
%and the second column of each row contains battery usage data of a user

%Output: Concatenation of all data points for all users

combinedDataSet = [];
for i=1:size(dataSet)
   temp = dataSet{i, 2};
   if(size(temp, 1) > 0) %If the cell was not empty
       if(size(temp, 1) > 1) %Check if there were more than 1 time of charging data for a user (we need to combined them into one cell)
           temp1 = [];
          for j=1:size(temp, 1)
              if(size(temp{j, 1}, 1) > 1) %If there was more than one data point in a cell
                  temp1 = [temp1; temp{j, 1}];
              end
          end
          temp = [];
          temp{1, 1} = temp1;
       end
       combinedDataSet = [combinedDataSet; cell2mat(temp{:, 1})];
   end
end
end