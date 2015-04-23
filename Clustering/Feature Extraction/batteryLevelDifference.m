function [lowest, average, highest] = batteryLevelDifference(userData)
%Extracts the lowest, average and highest battery level difference for each
%user

lowest = 100;
highest = 0;
average = 0;
for i=1:size(userData, 1)
    if(userData{i, 1}(1, end) < lowest)
        lowest = userData{i, 1}(1, end);
    end
    if(userData{i, 1}(1, end) > highest)
       highest = userData{i, 1}(1, end); 
    end
    average = average + userData{i, 1}(1, end);
end

average = average / size(userData, 1);

end