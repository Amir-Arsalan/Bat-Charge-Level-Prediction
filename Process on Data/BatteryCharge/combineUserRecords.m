function putTogetherData = combineUserRecords(userData)

%This functions concatenates/combines all the battery charge level
        %sequence data.
        
    %Input:
    %batData: an m by n cell where m is the number of days that the
    %battery level changes have been recorded and n is 2. The first
    %column of batData contains the date in which the changes have been
    %recorded and the second column contains the sequence of battery
    %level changes in that date.

    putTogetherData = [];
    for i=1:size(userData, 1)
        putTogetherData = [putTogetherData; userData{i, 2}];
    end

end