function [midnight_7, seven_noon, noon_3, three_7, seven_midnight, tags] = timeOfDay(userData, requestTagging)
%Extracts the number of times a phone is charged during different times periods of day

midnight_7 = 0;
seven_noon = 0;
noon_3 = 0;
three_7 = 0;
seven_midnight = 0;
tags = uint8(zeros(size(userData, 1), 1));

if(requestTagging == false)
    for i=1:size(userData, 1)
        if(userData{i, 1}(end, 2) >= 0 && userData{i, 1}(end, 2) < 84) %midnight_7
            midnight_7 = midnight_7 + 1;
        elseif(userData{i, 1}(end, 2) >= 84 && userData{i, 1}(end, 2) < 144) %seven_noon
            seven_noon = seven_noon + 1;
        elseif(userData{i, 1}(end, 2) >= 144 && userData{i, 1}(end, 2) < 180) %noon_3
            noon_3 = noon_3 + 1;
        elseif(userData{i, 1}(end, 2) >= 180 && userData{i, 1}(end, 2) < 228) %three_7
            three_7 = three_7 + 1;
        elseif(userData{i, 1}(end, 2) >= 228 && userData{i, 1}(end, 2) <= 288) %seven_midnight
            seven_midnight = seven_midnight + 1;
        end
    end
else
    for i=1:size(userData, 1)
        if(userData{i, 1}(end, 2) >= 0 && userData{i, 1}(end, 2) < 84) %midnight_7
            midnight_7 = midnight_7 + 1;
            tags(i, 1) = 1;
        elseif(userData{i, 1}(end, 2) >= 84 && userData{i, 1}(end, 2) < 144) %seven_noon
            seven_noon = seven_noon + 1;
            tags(i, 1) = 2;
        elseif(userData{i, 1}(end, 2) >= 144 && userData{i, 1}(end, 2) < 180) %noon_3
            noon_3 = noon_3 + 1;
            tags(i, 1) = 3;
        elseif(userData{i, 1}(end, 2) >= 180 && userData{i, 1}(end, 2) < 228) %three_7
            three_7 = three_7 + 1;
            tags(i, 1) = 4;
        elseif(userData{i, 1}(end, 2) >= 228 && userData{i, 1}(end, 2) <= 288) %seven_midnight
            seven_midnight = seven_midnight + 1;
            tags(i, 1) = 5;
        end
    end
end
end

