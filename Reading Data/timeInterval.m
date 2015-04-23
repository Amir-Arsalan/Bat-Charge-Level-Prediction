function interval = timeInterval(time)
%Takes a time (HH:MM) as input and outputs a time interval (one of 288 time
%intervals in a day (1440 minutes / 5)

temp = strsplit(time, ':');
temp = str2double(temp{1, 1}) * 60 + str2double(temp{1, 2});
interval = round(temp/5);


end