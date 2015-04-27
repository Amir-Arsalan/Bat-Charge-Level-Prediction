function [charge, discharge, timeIrregularBatSeq, timeGranulatedBatSeq] = extractBatStats(userBatSeq, granularity)
        
        userBatSeq = cleanData(userBatSeq, 4, false);
        timeIrregularBatSeq = userBatSeq;
        userBatSeq = applyGranularity(userBatSeq, granularity); %Apply the requested time-granularity on the userBatSeq records
        timeGranulatedBatSeq = userBatSeq;
        
        discharge = [];
        charge = [];
        status = userBatSeq(1, 7); %stores the values 1 or 0: 1 for when the phone is being charged and 0 the opposite
        startIndex = 1;
        for i=2:size(userBatSeq, 1)
            if(status ~= userBatSeq(i, 7))
                if(userBatSeq(i, 4) == 1) %If the "fully charged" attribute was 1 (true)
                    batLvlDiff = abs(userBatSeq(startIndex, 6) - 100);
                else
                    batLvlDiff = abs(userBatSeq(startIndex, 6) - userBatSeq(i-1, 6));
                end
                dayDiff = userBatSeq(i-1, 1) - userBatSeq(startIndex, 1) ;
                timeElapsed = ((dayDiff * 24 + userBatSeq(i-1, 2)) * 60 + userBatSeq(i-1, 3)) - (userBatSeq(startIndex, 2) * 60 + userBatSeq(startIndex, 3));
                if(batLvlDiff > 0)
                    if(userBatSeq(i, 7) == 1) %end of discharge period
                        discharge = [discharge; startIndex, i-1, timeElapsed, userBatSeq(startIndex, 2), userBatSeq(startIndex, 3), userBatSeq(i-1, 2), userBatSeq(i, 3), mean(userBatSeq(startIndex:i-1, 5)), std(userBatSeq(startIndex:i-1, 5)), batLvlDiff/timeElapsed];
                    else %end of recharge period
                        charge = [charge; startIndex, i-1, timeElapsed, userBatSeq(startIndex, 2), userBatSeq(startIndex, 3), userBatSeq(i-1, 2), userBatSeq(i, 3), mean(userBatSeq(startIndex:i-1, 5)), std(userBatSeq(startIndex:i-1, 5)), batLvlDiff/timeElapsed];
                    end
                end
                status = userBatSeq(i, 7);
                startIndex = i;
            end
        end
end