function [day, hour, min] = findInterval(interval, granularity)
%{

This function takes the 'interval' in which the data is recorded and the
'granularity' of the problem as inputs and returns the time where the 
'interval' lies in in the format DD:HH:MM (Day:Hour:Minute).

For instance, for 'granularity' of 10 minutes and 'interval' of 1500 the
returned quantities for 'day', 'hour' and 'min' must be 02, 10, 00 (Day
Number 2, 10 O'Clock in the morning)

%}

interval = interval * granularity; %Convert the interval to minutes
interval = interval / 60; %Conver the minutes to hours
day = 1; %We are sure that the day number cannot be less than 1!
hour = floor(interval);
min = (interval - hour) * 60; %Calculate the min in minutes
daysToAdd = floor(hour / 24);

if(daysToAdd > 0)
   day = day + daysToAdd; 
   hour = hour - (daysToAdd * 24);
end

day = day;
hour = int8(hour);
min = int8(min);

end