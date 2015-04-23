function [day, hour, min] = addTime(record, timeToAdd)
%{ 

This function sums the time in "record" with the time in "timeToAdd"

Input:
record: a 1 x 3 row with the elements "day number", "hour" and "min"
respectively
timeToAdd: the number of minutes to be added to the time in record

Output:
day: day number after addition
hour: the hour after addition
min: the minute after addition

%}

min = record(3) + timeToAdd;
if(min >= 60)
    hour = record(2) + floor(min/60);
    min = mod(min, 60);
    if(hour >= 24)
       day = record(1) + floor(hour/24);
       hour = mod(hour, 24);
    else
        day = record(1);
    end
else
    hour = record(2);
    day = record(1);
end

end