function [lowest, average, highest] = timeToPlugin(userData)
%Extracts the lowest, average and highest battery level difference for each
%user

lowest = 1152;
highest = 0;
average = 0;
for i=1:size(userData, 1)
    if(userData{i, 1}(1, 4) < lowest)
        lowest = userData{i, 1}(1, 4);
    end
    if(userData{i, 1}(1, 4) > highest)
       highest = userData{i, 1}(1, 4); 
    end
    average = average + userData{i, 1}(1, 4);
end

average = average / size(userData, 1);

end