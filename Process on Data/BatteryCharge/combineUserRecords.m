function combinedDatarecords = combineUserRecords(userData)

%{
This functions concatenates/combines all the battery charge level sequence data.
        
    Input:
        userData: an m by n cell where m is the number of days that the
        battery level changes have been recorded and n is 2. The first
        column of batData contains the date in which the changes have been
        recorded and the second column contains the sequence of battery
        level changes in that date.
    
    %}

    combinedDatarecords = [];
    day = 1;
    for i=1:size(userData, 1)
        combinedDatarecords = [combinedDatarecords; userData{i, 2}, ones(size(userData{i, 2}, 1), 1) * day];
        day = day + 1;
    end
    combinedDatarecords = single(combinedDatarecords); %Since the data stored is in uint8
    
    %Remove noisy records, if any
    i = 2;
    while(i <= size(combinedDatarecords, 1) - 1)
       if((combinedDatarecords(i, 1) * 60 + combinedDatarecords(i, 2)) < (combinedDatarecords(i - 1, 1) * 60 + combinedDatarecords(i - 1, 2)) && (combinedDatarecords(i + 1, 1) * 60 + combinedDatarecords(i + 1, 2)) > (combinedDatarecords(i - 1, 1) * 60 + combinedDatarecords(i - 1, 2)))
           combinedDatarecords = [combinedDatarecords(1:i-1, :); combinedDatarecords(i+1:end, :)];
           i = i - 1;
       end
       i = i + 1;
    end

end