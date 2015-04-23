function [lowest, average, highest] = batteryLevelWhenPluggedin(userData)
%Extracts the lowest, average and highest battery level for each user

lowest = 100;
highest = 0;
average = 0;
for i=1:size(userData, 1)
    if(userData{i, 1}(end, 1) < lowest)
        lowest = userData{i, 1}(end, 1);
    end
    if(userData{i, 1}(end, 1) > highest)
       highest = userData{i, 1}(end, 1); 
    end
    average = average + userData{i, 1}(end, 1);
end

average = average / size(userData, 1);

end