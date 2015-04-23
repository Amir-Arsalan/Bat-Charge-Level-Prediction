function [midnight_7, seven_noon, noon_3, three_7, seven_midnight, totalAverageTimeElapsed] = rateOfDischarge(userData)
%The average battery level decrement during different times of a day: 12am - 7am, 7am - 12pm, 12pm - 3pm, 3pm - 7pm, 7pm - 12am and overal average of it
result = zeros(5, 1);
if(size(userData, 1) > 1)
    [~, ~, ~, ~, ~, tags] = timeOfDay(userData, true);
    totalAverageTimeElapsed = 0;
    counter = zeros(5, 1);
    for i=1:size(tags, 1)
        decrementRate = userData{i, 1}(1, 4) / (userData{i, 1}(1, 1) - userData{i, 1}(1, 5));
       if(tags(i, 1) == 1)
           result(1, 1) = result(1, 1) + decrementRate;
           counter(1, 1) = counter(1, 1) + 1;
       elseif(tags(i, 1) == 2)
           result(2, 1) = result(2, 1) + decrementRate;
           counter(2, 1) = counter(2, 1) + 1;
       elseif(tags(i, 1) == 3)
           result(3, 1) = result(3, 1) + decrementRate;
           counter(3, 1) = counter(3, 1) + 1;
       elseif(tags(i, 1) == 4)
           result(4, 1) = result(4, 1) + decrementRate;
           counter(4, 1) = counter(4, 1) + 1;
       elseif(tags(i, 1) == 5)
           result(5, 1) = result(5, 1) + decrementRate;
           counter(5, 1) = counter(5, 1) + 1;
       end
       totalAverageTimeElapsed = totalAverageTimeElapsed + decrementRate;
    end
    indices = find(counter > 0);
    for i=1:size(indices, 1)
       result(indices(i, 1), 1) =  result(indices(i, 1), 1) / counter(indices(i, 1), 1);
    end
    
    for i=1:size(result, 1)
       if(result(i, 1) == 0)
          result(i, 1) = -1; 
       end
    end
    midnight_7 = result(1, 1);
    seven_noon = result(2, 1);
    noon_3 = result(3, 1);
    three_7 = result(4, 1);
    seven_midnight = result(5, 1);
    totalAverageTimeElapsed = totalAverageTimeElapsed / (size(userData, 1));
else
    [result(1, 1), result(2, 1), result(3, 1), result(4, 1), result(5, 1), ~] = timeOfDay(userData, false);
     
    for i=1:size(result, 1)
       if(result(i, 1) == 0)
          result(i, 1) = -1; 
       end
    end
    midnight_7 = result(1, 1);
    seven_noon = result(2, 1);
    noon_3 = result(3, 1);
    three_7 = result(4, 1);
    seven_midnight = result(5, 1);
    
    decrementRate = userData{1, 1}(1, 4) / (userData{1, 1}(1, 1) - userData{1, 1}(1, 5));
    if(result(1, 1) > 0)
        midnight_7 = decrementRate;
        totalAverageTimeElapsed = midnight_7;
    elseif(result(2, 1) > 0)
        seven_noon = decrementRate;
        totalAverageTimeElapsed = seven_noon;
    elseif(result(3, 1) > 0)
        noon_3 = decrementRate;
        totalAverageTimeElapsed = noon_3;
    elseif(result(4, 1) > 0)
        three_7 = decrementRate;
        totalAverageTimeElapsed = three_7;
    elseif(result(5, 1) > 0)
        seven_midnight = decrementRate;
        totalAverageTimeElapsed = seven_midnight;
    end
end

end

