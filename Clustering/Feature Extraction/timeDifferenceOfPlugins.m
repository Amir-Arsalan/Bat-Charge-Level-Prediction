function [lowest, average, highest] = timeDifferenceOfPlugins(userData)
%Extracts the lowest, average and highest time difference for two consecutive data sequence of a user

if(size(userData, 1) > 1)
    lowest = 1152;
    highest = 0;
    average = 0;
    numOfDays = 1;
    for i=2:size(userData, 1)
        if(userData{i-1, 1}(end, 2) > userData{i, 1}(1, 2))
            numOfDays = numOfDays + 1;
            difference = (userData{i, 1}(1, 2) + (1440/5)) - userData{i-1, 1}(end, 2);
        else
            difference = userData{i, 1}(1, 2) - userData{i-1, 1}(end, 2);
        end
        if(difference < lowest)
            lowest = difference;
        end
        if(difference > highest)
            highest = difference;
        end
        average = average + difference;
    end
average = average / (size(userData, 1) - 1);
else
    lowest = -1;
    highest = -1;
    average = -1;
end

end