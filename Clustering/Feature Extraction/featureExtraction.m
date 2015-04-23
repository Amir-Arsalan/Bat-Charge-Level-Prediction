function extractedFeatures = featureExtraction(dataSet)
%Input: A cell matrix as input with the size n x 2 where n is the number of
%users and in the second column the data for each user is stored

%Output: A cell matrix with the size n x 2 where n is the number of users
%and the extracted feature vectors are stored in the second column for each
%user

featureVector = zeros(size(dataSet, 1), 13);
%Features explained:
%1- Number of times the individual charges the device in the given time
%series data
%2:4- The lowest, highest and average of CBL and FBL difference for each user
%5:9- The number of charge during the following times of a day: 12am - 7am, 7am - 12pm, 12pm - 3pm, 3pm - 7pm, 7pm - 12am
%10:12- The lowest, highest and average battery CBL when plugged-in to charge
%13:15- The lowest, highest and average time it takes for an individual to plug-in the device into charge
%16:18- The lowest, highest and average time difference between each time the device is plugged-in to charge (the time the device is unplugged)
%19:24 - The average battery level decrement during different times of a day: 12am - 7am, 7am - 12pm, 12pm - 3pm, 3pm - 7pm, 7pm - 12am and overall average of it

for i=1:size(dataSet, 1)
    userData = dataSet{i, 2};
    featureVector(i, 1) = size(userData, 1); %Feature No. 1
    [featureVector(i, 2), featureVector(i, 3), featureVector(i, 4)] = batteryLevelDifference(userData); %Features 2:4
    [featureVector(i, 5), featureVector(i, 6), featureVector(i, 7), featureVector(i, 8), featureVector(i, 9), ~] = timeOfDay(userData, false); %Features 5:9
    [featureVector(i, 10), featureVector(i, 11), featureVector(i, 12)] = batteryLevelWhenPluggedin(userData); %Features 10:12
    [featureVector(i, 13), featureVector(i, 14), featureVector(i, 15)] = timeToPlugin(userData); %Features 13:15
    [featureVector(i, 16), featureVector(i, 17), featureVector(i, 18)] = timeDifferenceOfPlugins(userData); %Features 16:18
    [featureVector(i, 19), featureVector(i, 20), featureVector(i, 21), featureVector(i, 22), featureVector(i, 23), featureVector(i, 24)] = rateOfDischarge(userData); %Features 19:24
    
%     for j=1:size(userData, 1)
%         timeSeriesDataSequence = userData{j, 1};
%     end
% if(i==42)
%     
% end
end

end