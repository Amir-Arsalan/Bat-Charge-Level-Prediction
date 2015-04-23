function readyToAnalizeData = futureBatteryLevel(dataSet)

readyToAnalizeData = [];
notCharging = [];
charging = [];
maxChargeLevel = [];
futureBatteryLevel = [];
notChargingIndex = 1;
chargingIndex = 1;
maxChargeLevelIndex = 1;
futureBatteryLevelIndex = 1;
readyToAnalizeDataIndex = 1;

for i=1:size(dataSet, 1) %Traverses over all users
    
    readyToAnalizeData{i, 1} = dataSet{i, 1};
   
    userData = dataSet{i, 2};
    futureBatteryLevelIndex = 1;
    for j=1:size(userData, 1) %Traverse over all data sets of different days for a user
       
        usageData = userData{j, 2}; %Extract one-day data set of a user
        maxChargeLevelIndex = 1;
        k = 1;
        while(k <= size(usageData, 1)) %Traverse over one-day data set of a user
           
            if(strcmp(usageData{k, 5}, 'false'))
                
                nextState = nextStateIndex(usageData, k, 'true');
                
                if(nextState > 0) %If there is a different state, compared to current state, in the one-day data set of a user
                    for t=k:nextState-1
                        
                       notCharging{notChargingIndex, 1} = str2double(usageData{t, 4}); %Current Battery Level
                       notCharging{notChargingIndex, 2} = timeInterval(usageData{t, 1}); %Time of Day (in one of the 1440/5 intervals)
                       temp = str2double(usageData{t, 4}) - str2double(usageData{t+1, 4});
                       if(temp < 0)
                           temp = 0;
                       end
                       notCharging{notChargingIndex, 3} = temp; %Charge difference between the current battery level and the battery level in the next data point
                       notCharging{notChargingIndex, 4} = timeInterval(usageData{nextState, 1}) - timeInterval(usageData{t, 1}); %Time left to charge the phone (in one of the 1440/5 intervals)
                       notCharging{notChargingIndex, 5} = str2double(usageData(nextState, 4)); %Chanrge level when charging starts
                       notCharging{notChargingIndex, 6} = notCharging{notChargingIndex, 1} - notCharging{notChargingIndex, 5}; %Differnce
                       notChargingIndex = notChargingIndex + 1; 
                                                  
                    end
                    if(size(notCharging, 1) > 0)
                        futureBatteryLevel{futureBatteryLevelIndex, 1} = notCharging;
                        futureBatteryLevelIndex = futureBatteryLevelIndex + 1;
                        notCharging = [];
                        notChargingIndex = 1;
                    end
                    k = nextState - 1; %k will be added with 1 at the end of the loop. The subtraction helps putting the index at the right place
                    
                else %If nextState = -1
                    
%                     for t=k:size(usageData, 1) - 1
%                        
%                         notCharging{notChargingIndex, 1} = usageData{t, 4};
%                        notCharging{notChargingIndex, 2} = usageData{t, 1};
%                        temp = str2double(usageData{t, 4}) - str2double(usageData{t+1, 4});
%                        if(temp < 0)
%                            temp = 0;
%                        end
%                        notCharging{notChargingIndex, 3} = temp;
%                        notCharging{notChargingIndex, 4} = timeInterval(usageData{size(usageData, 1), 1}) - timeInterval(usageData{t, 1});
%                        notCharging{notChargingIndex, 5} = str2double(usageData(size(usageData, 1), 4));
%                        notChargingIndex = notChargingIndex + 1;
%                         
%                     end
%                     
                    if(size(notCharging, 1) > 0)
                        futureBatteryLevel{futureBatteryLevelIndex, 1} = notCharging;
                        futureBatteryLevelIndex = futureBatteryLevelIndex + 1;
                        notCharging = [];
                        notChargingIndex = 1;
                    end
                    k = size(usageData, 1);
                    
                end
                
%             elseif(strcmp(usageData{k, 5}, 'true'))
%                 nextState = nextStateIndex(usageData, k, 'false');
%                 
%                 if(nextState > 0)
%                     
%                     for t=k:nextState - 1
%                         
%                        charging{chargingIndex, 1} = str2double(usageData{t, 4});
%                        charging{chargingIndex, 2} = usageData{t, 1};
%                        temp = str2double(usageData{t + 1, 4}) - str2double(usageData{t, 4});
%                        temp(temp < 1) = 0;
%                        charging{chargingIndex, 3} = temp;
%                        charging{chargingIndex, 4} = timeInterval(usageData{nextState, 1}) - timeInterval(usageData{t, 1});
%                        charging{chargingIndex, 5} = str2double(usageData{nextState - 1, 4});
%                        chargingIndex = chargingIndex + 1;
%                     end
%                     
%                     if(size(charging, 1) > 0)
%                         maxChargeLevel{maxChargeLevelIndex, 1} = charging;
%                         maxChargeLevelIndex = maxChargeLevelIndex + 1;
%                         charging = [];
%                         chargingIndex = 1;
%                     end
%                     k = nextState - 1;
%                     
%                 else
%                     
%                     k = size(usageData, 1);
%                     
%                 end
%                 
%                 
            end
            k = k + 1;
            
        end
        
    end
    readyToAnalizeData{readyToAnalizeDataIndex, 2} = futureBatteryLevel;
%     readyToAnalizeData{readyToAnalizeDataIndex, 3} = maxChargeLevel;
    readyToAnalizeDataIndex = readyToAnalizeDataIndex + 1;
    futureBatteryLevel = [];
%     maxChargeLevel = [];
end

end