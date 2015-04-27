function userBatSeq = applyGranularity(userBatSeq, granularity)

%{

This function applies a time-granularity on the input userBatSeq.
For instance if "granularity" = 10 the function summarizes the records in
"userBatSeq" for each 10-minute interval

%}

%% Variables
userBatSeq = single(userBatSeq);
day = 1; %Starting day counter
hour = userBatSeq(1, 2);
minite = userBatSeq(1, 3);
newUserBatSeq = []; %This matrix will be re-declared in the program section
interval = [];
startInterval = [];
lastInterval = [];
firstIndx = 1;
lastInx = [];
intervalDifference = [];
intervalIndex = 1;
chargeRate = 0;
stats = zeros(1, 5); %The 5th element contains either 1 or 0. 1 for the record being present in the data set, 0 otherwise
tempStats = zeros(1, 5); %The 5th element contains either 1 or 0. 1 for the record being present in the data set, 0 otherwise
flag = false;
sameIntervalRecords = 0;
globalChargeRate = 0;

%% The Program's Code Section

startInterval = findTimeInterval(userBatSeq(1, :), granularity);
lastInterval = findTimeInterval(userBatSeq(end, :), granularity);
newUserBatSeq = single(zeros(lastInterval - startInterval + 1, size(userBatSeq, 2) + 2)); %pre-allocate the matrix which will contain the regularly sampled records, in time
% newUserBatSeq = [newUserBatSeq, zeros(length(newUserBatSeq(:, 1)), 1), zeros(length(newUserBatSeq(:, 1)), 1)];


stats(1) = userBatSeq(1, 4);
stats(2) = userBatSeq(1, 5);
stats(3) = userBatSeq(1, 6);
stats(4) = userBatSeq(1, 7);
i = 2;
flagFill = 0;
while(i <= length(userBatSeq(:, 1)))
    interval = findTimeInterval(userBatSeq(i, :), granularity);
    if(interval == startInterval)
        [day, hour, minite] = findInterval(interval, granularity);
        stats(1) = stats(1) + userBatSeq(i, 4);
        stats(2) = stats(2) + userBatSeq(i, 5);
        stats(3) = stats(3) + userBatSeq(i, 6);
        stats(4) = stats(4) + userBatSeq(i, 7);
        stats(5) = 1; %The 1 means that the data merged records have been in the original data set
    else
        %{
        This section summerizes the records and store them in newUserBatSeq
        %}
        if(any(stats > 0))
            newUserBatSeq(intervalIndex, 1) = day;
            newUserBatSeq(intervalIndex, 2) = hour;
            newUserBatSeq(intervalIndex, 3) = minite;
            newUserBatSeq(intervalIndex, 4) = stats(1) >= (i - firstIndx) / 2.5;
            newUserBatSeq(intervalIndex, 5) = stats(2) / (i - firstIndx);
            newUserBatSeq(intervalIndex, 6) = stats(3) / (i - firstIndx);
            newUserBatSeq(intervalIndex, 7) = stats(4) >= (i - firstIndx) / 2;
            newUserBatSeq(intervalIndex, 8) = stats(5);
            newUserBatSeq(intervalIndex, 9) = 1;
        end
        firstIndx = i;        
        tempStats(1) = userBatSeq(i, 4);
        tempStats(2) = userBatSeq(i, 5);
        tempStats(3) = userBatSeq(i, 6);
        tempStats(4) = userBatSeq(i, 7);
        j = i + 1;
        while (j <= length(userBatSeq(:, 1))) %This while look checks all records equal or after the (i + 1)th record belonging to the 'tempInterval' interval and merge them, if any
            tempInterval = findTimeInterval(userBatSeq(j, :), granularity);
            if(tempInterval == interval)
                tempStats(1) = tempStats(1) + userBatSeq(j, 4);
                tempStats(2) = tempStats(2) + userBatSeq(j, 5);
                tempStats(3) = tempStats(3) + userBatSeq(j, 6);
                tempStats(4) = tempStats(4) + userBatSeq(j, 7);
                sameIntervalRecords = sameIntervalRecords + 1;
            else %The else section merges the records belonging to the same interval, if any except the i'th record itself
                [dayLastRecord, hourLastRecord, minLastRecord] = findInterval(interval, granularity);
                tempStats(1) = tempStats(1) >= (j - i) / 2.5;
                tempStats(2) = tempStats(2) / (j - i);
                tempStats(3) = tempStats(3) / (j - i);
                tempStats(4) = tempStats(4) >= (j - i) / 2;
                tempStats(5) = 1; %The 1 means that the data merged records have been in the original data set
                if(j == length(userBatSeq(:, 1)))
                   flagFill = 1; 
                end
                break;
            end
            j = j + 1;
        end
%         startInterval = findTimeInterval(userBatSeq(i - 1, :), granularity) + 1; %We are looking for the next record belonging to the next interval
        startInterval = startInterval + 1; %We are looking for the next record belonging to the next interval
        if(interval ~= startInterval)
            intervalDifference = interval - startInterval + 1;
            chargeRate = (newUserBatSeq(intervalIndex, 6) - tempStats(3)) / intervalDifference; %Recharge if negative, discharge if positive
            chargeRate1 = (newUserBatSeq(intervalIndex, 6) - userBatSeq(i, 6)) / intervalDifference; %Recharge if negative, discharge if positive
            tempChangeRate = (newUserBatSeq(intervalIndex, 5) - tempStats(2)) / intervalDifference;
            for k=intervalIndex+1:intervalIndex+intervalDifference - 1
                [dayMissingRecord, hourMissingRecord, minMissingRecord] = findInterval(startInterval, granularity);
                newUserBatSeq(k, 1) = dayMissingRecord; %The day number for the missing recorord
                newUserBatSeq(k, 2) = hourMissingRecord; %The hour for the missing record
                newUserBatSeq(k, 3) = minMissingRecord; %The minute of the missing record
                newUserBatSeq(k, 4) = newUserBatSeq(intervalIndex, 4); %Copy the previous record's value
                newUserBatSeq(k, 5) = newUserBatSeq(intervalIndex, 5) - ((k-intervalIndex) * tempChangeRate); %New temperature
%                 newUserBatSeq(k, 9) = k;
                if(newUserBatSeq(intervalIndex, 7) == tempStats(4) && chargeRate >= 0)
                    newUserBatSeq(k, 6) = newUserBatSeq(intervalIndex, 6) - ((k-intervalIndex) * chargeRate);
                    newUserBatSeq(k, 9) = chargeRate;
                    globalChargeRate = chargeRate;
                else
                    if(intervalDifference <= round(1440/granularity * 0.07)) %if the time-granularity difference was 7% of (1440/granularity)
                        if(tempStats(4) == 0)
                            if(newUserBatSeq(intervalIndex, 6) > tempStats(3) || newUserBatSeq(intervalIndex, 6) < tempStats(3))
                               newUserBatSeq(k, 6) = newUserBatSeq(intervalIndex, 6) - ((k-intervalIndex) * chargeRate);
                               newUserBatSeq(k, 9) = chargeRate;
                               globalChargeRate = chargeRate;
                            else
                                newUserBatSeq(k, 6) = newUserBatSeq(intervalIndex, 6);
                                newUserBatSeq(k, 9) = 0;
                                globalChargeRate = 0;
                            end
                        else
                            if(userBatSeq(i - 1, 6) ~= 0)
                                if(newUserBatSeq(intervalIndex, 6) > userBatSeq(i, 6) || newUserBatSeq(intervalIndex, 6) < userBatSeq(i, 6))
                                   newUserBatSeq(k, 6) = newUserBatSeq(intervalIndex, 6) - ((k-intervalIndex) * chargeRate1);
                                   globalChargeRate = chargeRate1;
                                   newUserBatSeq(k, 9) = chargeRate1;
                                   if(newUserBatSeq(k, 6) > newUserBatSeq(k - 1, 6) && chargeRate1 <= -normrnd((10/(10/granularity)) - granularity/10, granularity/10)/2.3) %The 2.3 factor is used without any specific reason. Originally I wanted to use a factor of 2.0
                                      flag = 1;
                                      newUserBatSeq(k, 7) = 1;
                                   end
                                else
                                    newUserBatSeq(k, 6) = newUserBatSeq(intervalIndex, 6);
                                    globalChargeRate = 0;
                                end
                            else
                                newUserBatSeq(k, 6) = 0;
                                globalChargeRate = 0;
                            end
                        end
                    else
                        if(newUserBatSeq(intervalIndex, 6) > userBatSeq(i, 6)) %For the discharge period
                            tempRechargeRate = -normrnd((10/(10/granularity)) - granularity/10, granularity/8); %For the mean, the numerator in the first paranthesis represents the 'assumed' charge level at each 10-minute interval. For Sigma the denominator helps the standard deviation get smaller and larger as granularity decreases or increases respectively
                            %Description of the two following conditions: Although the i'th record indicates that the battery must be in discharge period but since the battery is being charged, I proceed charging the battery to 100% and then the discharge period begins
                            if(newUserBatSeq(k - 1, 7) == 1 && newUserBatSeq(k - 1, 6) - tempRechargeRate <= 100 && flag ~= 2)
                                newUserBatSeq(k, 7) = 1;
%                                 if((100 - tempStats(3)) / (intervalDifference - round(-(100 - newUserBatSeq(k-1, 6)) / tempRechargeRate) + 1) < normrnd(5, 1.2)) %This condition prevents the discharge rate going too high after the phone's battery level is reached to 100%.
                                if((newUserBatSeq(k - 1, 6) - tempRechargeRate - tempStats(3)) / (interval - startInterval) < normrnd(4.8/(10/granularity), 0.8)) %This condition prevents the discharge rate going too high after the phone's battery level is reached to 100%.
                                    flag = 1;
                                    newUserBatSeq(k, 6) = newUserBatSeq(k - 1, 6) - tempRechargeRate;
                                    globalChargeRate = tempRechargeRate;
                                    newUserBatSeq(k, 9) = tempRechargeRate;
                                else %If the discharge rate goes too high, then stop charging the phone
                                    flag = 2;
                                    newUserBatSeq(k, 6) = min(100, newUserBatSeq(k - 1, 6) - (tempRechargeRate / 1.7)); %1.7 is defined arbitrarly
                                    intervalDifference = interval - startInterval;
                                    chargeRate = (newUserBatSeq(k, 6) - tempStats(3)) / intervalDifference; %Recharge if negative, discharge if positive
                                    chargeRate1 = (newUserBatSeq(k, 6) - userBatSeq(i, 6)) / intervalDifference; %Recharge if negative, discharge if positive
                                    globalChargeRate = (newUserBatSeq(k, 6) - userBatSeq(i, 6)) / intervalDifference;
                                    intervalIndex = k;
                                end
                            elseif(newUserBatSeq(k - 1, 7) == 1 && newUserBatSeq(k - 1, 6) - tempRechargeRate > 100 && flag ~= 2)
                                newUserBatSeq(k, 6) = 100;
                                newUserBatSeq(k, 7) = 1;
                                globalChargeRate = 0;
                                newUserBatSeq(k, 9) = 0;
                                newUserBatSeq(k, 4) = 1; %Fully charged
                                intervalIndex = k;
                                intervalDifference = interval - startInterval;
                                chargeRate = (newUserBatSeq(intervalIndex, 6) - tempStats(3)) / intervalDifference; %Recharge if negative, discharge if positive
                                chargeRate1 = (newUserBatSeq(intervalIndex, 6) - userBatSeq(i, 6)) / intervalDifference; %Recharge if negative, discharge if positive
                                tempChangeRate = (newUserBatSeq(intervalIndex, 5) - tempStats(2)) / intervalDifference;
                                flag = 2;
                            elseif(newUserBatSeq(intervalIndex, 6) - ((k-intervalIndex) * chargeRate) >= 0 && chargeRate > granularity/75) %Discharge period begins here. Granularity/45 is an emprical quantity meaning that che charge level must get dropped by 1% every 45 minutes
                                newUserBatSeq(k, 6) = newUserBatSeq(intervalIndex, 6) - ((k-intervalIndex) * chargeRate);
                                globalChargeRate = chargeRate;
                                newUserBatSeq(k, 7) = 0;
                                flag = 1;
                            elseif(chargeRate <= granularity/75)
                                if(userBatSeq(i - 1, 6) ~= 0)
                                    newUserBatSeq(k, 6) = newUserBatSeq(intervalIndex, 6);
                                    globalChargeRate = 0;
                                else
                                    if(flag == 2)
                                        newUserBatSeq(k, 6) = newUserBatSeq(k - 1, 6);
                                    else
                                        newUserBatSeq(k, 6) = 0;
                                    end
                                    globalChargeRate = 0;
                                end
                                if(flag ~= 2)
                                    newUserBatSeq(k, 7) = 0;
                                    flag = 1;
                                elseif(flag == 2)
                                    newUserBatSeq(k, 7) = newUserBatSeq(k - 1, 7);
                                end
                            else
                                newUserBatSeq(k, 6) = 0;
                                globalChargeRate = 0;
                            end
                        elseif(newUserBatSeq(intervalIndex, 6) < userBatSeq(i, 6) && abs(newUserBatSeq(intervalIndex, 6) - userBatSeq(i, 6)) > 1) %For the recharge period
                            tempRechargeRate = -normrnd((10/(10/granularity)) - granularity/10, granularity/8); %For the mean, the numerator in the first paranthesis represents the 'assumed' charge level at each 10-minute interval. For Sigma the denominator helps the standard deviation get smaller and larger as granularity decreases or increases respectively
                            if(newUserBatSeq(intervalIndex, 6) + ((k-intervalIndex) * chargeRate) <= 100 && chargeRate < -granularity/3)
                                newUserBatSeq(k, 6) = newUserBatSeq(intervalIndex, 6) - ((k-intervalIndex) * chargeRate);
                                globalChargeRate = chargeRate;
                                newUserBatSeq(k, 9) = chargeRate;
                                newUserBatSeq(k, 7) = 1;
                                flag = 1;
%                             elseif(newUserBatSeq(k - 1, 6) - tempRechargeRate <= 100 && newUserBatSeq(k - 1, 7) == 1 && (100 - tempStats(3)) / round(intervalDifference + ((100 - newUserBatSeq(intervalIndex, 6)) / -(10/(10/granularity)) - granularity/10)) <= 20/(10/granularity)) %The condition "(100 - tempStats(3)) / max(1, round(intervalDifference + ((100 - newUserBatSeq(intervalIndex, 6)) / tempRechargeRate))) < 18/(10/granularity)" is there to ensure that the discharge rate is not going to be extremely high, and therefore impossible after the phone's charge level reaches to 100 and starts dropping to the value "tempStats(3)"
                                elseif(newUserBatSeq(k - 1, 6) - tempRechargeRate <= 100 && newUserBatSeq(k - 1, 7) == 1 && flag ~= 2)
                                newUserBatSeq(k, 7) = 1;
                                if((newUserBatSeq(k - 1, 6) - tempRechargeRate - tempStats(3)) / (interval - startInterval) < normrnd(4.8/(10/granularity), 0.8)) %This condition prevents the discharge rate going too high after the phone's battery level is reached to 100%.
                                    newUserBatSeq(k, 6) = newUserBatSeq(k - 1, 6) - tempRechargeRate;
                                    globalChargeRate = tempRechargeRate;
                                    newUserBatSeq(k, 9) = tempRechargeRate;
                                    flag = 1;
                                else %If the discharge rate goes too high, then stop charging the phone
                                    flag = 2;
                                    newUserBatSeq(k, 6) = min(100, newUserBatSeq(k - 1, 6) - (tempRechargeRate / 1.7)); %1.7 is defined arbitrarly
                                    intervalDifference = interval - startInterval;
                                    chargeRate = (newUserBatSeq(k, 6) - tempStats(3)) / intervalDifference; %Recharge if negative, discharge if positive
                                    chargeRate1 = (newUserBatSeq(k, 6) - userBatSeq(i, 6)) / intervalDifference; %Recharge if negative, discharge if positive
                                    globalChargeRate = (newUserBatSeq(k, 6) - userBatSeq(i, 6)) / intervalDifference;
                                    intervalIndex = k;
                                end
                            elseif(newUserBatSeq(k - 1, 6) - tempRechargeRate > 100 && newUserBatSeq(k - 1, 7) == 1 && flag ~= 2)
                                newUserBatSeq(k, 6) = 100;
                                globalChargeRate = 0;
                                newUserBatSeq(k, 7) = 1;
                                newUserBatSeq(k, 4) = 1; %Fully charged
                                intervalIndex = k;
                                intervalDifference = interval - startInterval;
                                chargeRate = (newUserBatSeq(intervalIndex, 6) - tempStats(3)) / intervalDifference; %Recharge if negative, discharge if positive
                                chargeRate1 = (newUserBatSeq(intervalIndex, 6) - userBatSeq(i, 6)) / intervalDifference; %Recharge if negative, discharge if positive
                                tempChangeRate = (newUserBatSeq(intervalIndex, 5) - tempStats(2)) / intervalDifference;
                                flag = 2;
                            elseif(chargeRate >= -granularity/3)
                                if(userBatSeq(i - 1, 6) ~= 0)
                                    newUserBatSeq(k, 6) = newUserBatSeq(intervalIndex, 6);
                                    globalChargeRate = 0;
                                else
                                    newUserBatSeq(k, 6) = 0;
                                    globalChargeRate = 0;
                                end
                                newUserBatSeq(k, 7) = newUserBatSeq(intervalIndex, 7);
                                flag = 1;
                            else
                                newUserBatSeq(k, 6) = 100;
                                globalChargeRate = 0;
                            end
                        else %Battery level remains constant
                            newUserBatSeq(k, 6) = newUserBatSeq(intervalIndex, 6);
                            globalChargeRate = 0;                            
                        end
                    end
                end
                if(flag == 0)
                    if(globalChargeRate > 0) %globalChargeRate???????????
                        if(abs(newUserBatSeq(k, 6) - tempStats(3)) >= 5 && newUserBatSeq(k, 6) >= tempStats(3) && intervalDifference >= round(1440/granularity * 0.07))
                           newUserBatSeq(k, 7) = 0; %Discharge
                        elseif(abs(newUserBatSeq(k, 6) - tempStats(3)) >= 5 && newUserBatSeq(k, 6) <= tempStats(3) && intervalDifference >= round(1440/granularity * 0.07))
                            newUserBatSeq(k, 7) = 1; %Recharge
                        elseif(newUserBatSeq(intervalIndex, 7) ~= tempStats(4))
                            newUserBatSeq(k, 7) = tempStats(4);
                        else
                            if(newUserBatSeq(intervalIndex, 7) == 1 && tempStats(4) == 1 && newUserBatSeq(intervalIndex, 6) - userBatSeq(i, 6) >= 5)
                                newUserBatSeq(k, 7) = 0;
                            else
                                newUserBatSeq(k, 7) = newUserBatSeq(intervalIndex, 7);
                            end
                        end

                    else
                        if(newUserBatSeq(intervalIndex, 7) ~= tempStats(4))
                            newUserBatSeq(k, 7) = newUserBatSeq(intervalIndex, 7);
                        elseif(userBatSeq(i - 1, 6) == 0)
                            newUserBatSeq(k, 7) = 1;
                        else
                            newUserBatSeq(k, 7) = tempStats(4);
                        end
                    end
                end
                startInterval = startInterval + 1;
            end
            intervalIndex = k + 1;
        else
            if(j >= length(userBatSeq(:, 1)))
                [dayLastRecord, hourLastRecord, minLastRecord] = findInterval(interval, granularity);
                if(flagFill == 0)
                    tempStats(1) = tempStats(1) >= (j - i) / 2.5;
                    tempStats(2) = tempStats(2) / (j - i);
                    tempStats(3) = tempStats(3) / (j - i);
                    tempStats(4) = tempStats(4) >= (j - i) / 2;
                    tempStats(5) = 1; %The 1 means that the data merged records have been in the original data set
                end
            end
            chargeRate = newUserBatSeq(intervalIndex, 6) - tempStats(3);
            intervalIndex = intervalIndex + 1;
            newUserBatSeq(intervalIndex, 9) = chargeRate;
            globalChargeRate = -100;
        end
            startInterval = interval;
            if(j > length(userBatSeq(:, 1)))
                [dayLastRecord, hourLastRecord, minLastRecord] = findInterval(interval, granularity);
            end
            newUserBatSeq(intervalIndex, 1) = dayLastRecord;
            newUserBatSeq(intervalIndex, 2) = hourLastRecord;
            newUserBatSeq(intervalIndex, 3) = minLastRecord;
            newUserBatSeq(intervalIndex, 4) = tempStats(1);
            newUserBatSeq(intervalIndex, 5) = tempStats(2);
            newUserBatSeq(intervalIndex, 6) = tempStats(3);
            newUserBatSeq(intervalIndex, 7) = tempStats(4);
            newUserBatSeq(intervalIndex, 8) = tempStats(5);
            newUserBatSeq(intervalIndex, 9) = newUserBatSeq(intervalIndex - 1, 6) - tempStats(3);
            if(globalChargeRate > -100)
                newUserBatSeq(intervalIndex, 9) = globalChargeRate;
            end
            firstIndx = firstIndx + sameIntervalRecords + 1;
            stats = zeros(1, 4);
            globalChargeRate = 0;
    end
    i = i + sameIntervalRecords + 1;
    sameIntervalRecords = 0;
    flag = 0;
    flagFill = 0;
end

%% Post-processing begins here to fix some issues left unfixed at either cleaning or granularity applying process

flag = 0;
i = 1;
while(i <= length(newUserBatSeq(:, 1)) - 1)
   if((newUserBatSeq(i, 6) == 100 || (newUserBatSeq(i, 6) == 99)) && newUserBatSeq(i + 1, 6) == 99 && newUserBatSeq(max(1, i - 1), 7) == 1 && newUserBatSeq(i + 1, 8) == 0)
      newUserBatSeq(i + 1, 7) = 1;
   end
   if((newUserBatSeq(i, 7) == 0 || newUserBatSeq(i, 6) < 98) && newUserBatSeq(i, 4) == 1)
       newUserBatSeq(i, 4) = 0;
   end
   if(newUserBatSeq(i, 7) == 1 && newUserBatSeq(i, 4) == 0 && newUserBatSeq(i, 8) == 0 && newUserBatSeq(i, 6) >= 99 && newUserBatSeq(i + 1, 7) == 1)
       j = i + 1;
       while(newUserBatSeq(j, 7) == 1 &&  j <= size(newUserBatSeq, 1) - 1)
           if(newUserBatSeq(j, 4) == 1 && newUserBatSeq(j, 8) == 1)
              flag = 1;
              break;
           elseif(newUserBatSeq(i, 6) >= 99)
               flag = 0;
           end
           j = j + 1;
       end
       if(flag == 0)
          newUserBatSeq(j - 1, 4) = 1; 
       else
           flag = 0;
       end
   end
   if(newUserBatSeq(max(i - 1, 1), 7) == 0 && newUserBatSeq(i, 7) == 1 && newUserBatSeq(i + 1, 7) == 0 && newUserBatSeq(i + 1, 6) < newUserBatSeq(i, 6) && newUserBatSeq(max(i - 1, 1), 6) >= newUserBatSeq(i, 6))
       j = min(i + 1, length(newUserBatSeq(:, 1) - 1));
       while(j <= min(i + 3, length(newUserBatSeq(:, 1)) - 1))
          if(newUserBatSeq(j, 7) == 0)
             flag = 1;
          end
           j = j + 1;
       end
       if(flag == 1)
          newUserBatSeq(i, 7) = 0;
          flag = 0;
       end
   end
   %This section finds all records that are potentially indicating that the
   %phone has been charged but are incorrectly marked as discharing records
   if(newUserBatSeq(i, 6) == newUserBatSeq(i + 1, 6) && newUserBatSeq(i, 7) == 1 && newUserBatSeq(i + 1, 7) == 0 && newUserBatSeq(i + 1, 8) == 0)
      j = i + 1;
      while(newUserBatSeq(j, 6) == newUserBatSeq(i + 1, 6))
         j = j + 1; 
      end
      if(abs(newUserBatSeq(j, 6) - newUserBatSeq(i + 1, 6)) <= 5 * granularity * 0.1)
         newUserBatSeq(i + 1:j - 1, 7) = 1; 
         i = j - 1;
      end
   end
   
   if(newUserBatSeq(i, 6) - newUserBatSeq(i + 1, 6) <= -40 && newUserBatSeq(i, 8) == 1 && newUserBatSeq(max(1, i - 1), 8) == 0 && newUserBatSeq(max(1, i - 1), 6) - newUserBatSeq(i, 6) <= 1 * granularity * 0.1 && newUserBatSeq(i, 6) == 0)
      newUserBatSeq(i, 8) = 0;
      i = i - 1;
   end
   
   %Fix the issue of records being marked as discharge although they should
   %indicate charging status
    if(newUserBatSeq(i, 7) == 0 && newUserBatSeq(max(1, i - 1), 6) - newUserBatSeq(i, 6) < -3 * granularity * 0.1 && newUserBatSeq(i, 6) - newUserBatSeq(i + 1, 6) < -2 * granularity * 0.1)
        newUserBatSeq(i, 7) = 1;
        i = i - 1;
    end
    
    if(newUserBatSeq(max(1, i - 1), 8) == 1 && newUserBatSeq(i, 8) == 0 && newUserBatSeq(i, 7) == 1 && newUserBatSeq(i, 6) <= 95 && newUserBatSeq(max(1, i - 1), 6) - newUserBatSeq(i, 6) > 0)
        if(newUserBatSeq(max(1, i - 2), 7) == 0)
            newUserBatSeq(max(1, i - 1), 7) = 0;
        end
        j = i;
        while(newUserBatSeq(j, 8) == 0 && newUserBatSeq(j, 7) == 1 && newUserBatSeq(j - 1, 6) - newUserBatSeq(j, 6) >= 0)
           newUserBatSeq(j, 7) = 0;
           j = j + 1;
        end
        if(j > i)
            i = i - 1;
        end
    end
    
    if(newUserBatSeq(max(1, i - 1), 8) == 1 && newUserBatSeq(i, 8) == 0 && newUserBatSeq(i, 7) == 0 && newUserBatSeq(i, 6) > 0 && newUserBatSeq(max(1, i - 1), 6) - newUserBatSeq(i, 6) < 0)
        if(newUserBatSeq(max(1, i - 2), 7) == 1)
%             newUserBatSeq(max(1, i - 1), 7) = 1;
        end
        j = i;
        difference = [];
        while(newUserBatSeq(j, 8) == 0 && newUserBatSeq(j, 7) == 0 && newUserBatSeq(j - 1, 6) - newUserBatSeq(j, 6) < 0)
%            newUserBatSeq(j, 7) = 1;
           difference = [difference, newUserBatSeq(j - 1, 6) - newUserBatSeq(j, 6)];
           j = j + 1;
        end
        tempRechargeRate = -normrnd((10/(10/granularity)) - 4 * granularity/10, granularity/7, j - i, 1); %For the mean, the numerator in the first paranthesis represents the 'assumed' charge level at each 10-minute interval. For Sigma the denominator helps the standard deviation get smaller and larger as granularity decreases or increases respectively
        if(sum(difference) <= sum(tempRechargeRate) + (j - i) * granularity/6)
            newUserBatSeq(i:j-1, 7) = 1;
        else
            newUserBatSeq(i:j-1, 6) = newUserBatSeq(max(1, i - 1), 6);
            newUserBatSeq(j-1, 7) = 1;
            tempRechargeRate = sort(tempRechargeRate, 'descend');
            tempIndx = 1;
            if(j - i > 1)
                while(j > 0 && j >= i)
                   if(newUserBatSeq(max(1, j - tempIndx + 1), 6) + tempRechargeRate(tempIndx) >= newUserBatSeq(max(1, i - 1), 6))
                       newUserBatSeq(j - tempIndx, 6) = newUserBatSeq(j - tempIndx + 1, 6) + tempRechargeRate(tempIndx);
                       newUserBatSeq(j - tempIndx, 7) = 1;
                   else
                       break;
                   end
                    tempIndx = tempIndx + 1;
                end
            else
                newUserBatSeq(j - tempIndx, 7) = 1;
                if(newUserBatSeq(j - tempIndx + 1, 6) + tempRechargeRate(tempIndx) >= newUserBatSeq(max(1, i - 1), 6))
                    newUserBatSeq(j - tempIndx, 6) = newUserBatSeq(j - tempIndx + 1, 6) + tempRechargeRate(tempIndx);
                end
            end
        end
        if(j > i)
            i = i - 1;
        end
    end
        
    if(i < 0)
        i = 0;
    end
   i = i + 1;
end

newUserBatSeq = newUserBatSeq(1:end-2, :); %Remove the last two rows (empirically, I had seen the last two rows having completely irelevant charge rates for an unknown reason)

chargeRate = procCalcChargeRate(newUserBatSeq(:, 1:8), 0);
indices = find(chargeRate <= -12);

for i=1:length(indices)
   if(~isempty(indices) && newUserBatSeq(max(indices(i)-1, 1), 8) == 0 && chargeRate(max(indices(i)-1)) == 0)
       startingChargeRate = newUserBatSeq(indices(i)-1, 6);
       j = 1;
       if(startingChargeRate > 0)
           tempRechargeRate = -normrnd((10/(10/granularity)) - granularity/10, granularity/10); %For the mean, the numerator in the first paranthesis represents the 'assumed' charge level at each 10-minute interval. For Sigma the denominator helps the standard deviation get smaller and larger as granularity decreases or increases respectively
       else
           tempRechargeRate = -normrnd((10/(10/granularity)), granularity/10); %For the mean, the numerator in the first paranthesis represents the 'assumed' charge level at each 10-minute interval. For Sigma the denominator helps the standard deviation get smaller and larger as granularity decreases or increases respectively
       end
       cumulativeRechargeRate = tempRechargeRate;
       while(indices(i) - j >= 1 && -cumulativeRechargeRate + chargeRate(indices(i)) <= 0 && newUserBatSeq(indices(i) - j, 6) == startingChargeRate)
           newUserBatSeq(indices(i) - j, 6) = newUserBatSeq(indices(i) - j + 1, 6) + tempRechargeRate;
           newUserBatSeq(indices(i) - j, 7) = 1; %Recharge
           newUserBatSeq(indices(i) - j, 8) = 2;
           if(startingChargeRate > 0)
               tempRechargeRate = -normrnd((10/(10/granularity)) - granularity/10, granularity/10); %For the mean, the numerator in the first paranthesis represents the 'assumed' charge level at each 10-minute interval. For Sigma the denominator helps the standard deviation get smaller and larger as granularity decreases or increases respectively
           else
               tempRechargeRate = -normrnd((10/(10/granularity)), granularity/10); %For the mean, the numerator in the first paranthesis represents the 'assumed' charge level at each 10-minute interval. For Sigma the denominator helps the standard deviation get smaller and larger as granularity decreases or increases respectively
           end
           cumulativeRechargeRate = cumulativeRechargeRate + tempRechargeRate;
           j = j + 1;
       end
       if(newUserBatSeq(indices(i) - j, 6) == startingChargeRate)
           newUserBatSeq(indices(i) - j, 7) = 1;
           newUserBatSeq(indices(i) - j, 8) = 2;
       end
   end
end


userBatSeq = newUserBatSeq(:, 1:8); %I still cannot make sure the 9th column has been calculated correctly. Therefore I ignore it here.

end