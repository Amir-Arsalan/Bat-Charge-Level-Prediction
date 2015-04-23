function batteryDataset = import_data(paths)

tic
subDirectoryIndex = 1; %Trevarses on sub-directories of each user's data folder
mainDirectoriesVisited = 206; %
toRemoveIndex = uint8(0);

userCounter = 1;
dayCounter = 1;
samples = cell(0, size(paths, 2));

%% Efficient way of getting subdirectories path
% pathName='F:\BatteryPrediction\Data(2013-14)\20\logcat';%your path
% [stat path]=dos(['dir ' pathName '\*.gz /s /B >path.txt'] );
% name=importdata('path.txt');
% delete path.txt

%%


clear temp
dataSet = cell(0, size(paths, 2)+1);
ttt = 0;

while(mainDirectoriesVisited <= size(paths, 1))
    fprintf('%d\n', mainDirectoriesVisited);
    tagData = cell(0, size(paths, 2));
    for i=1:size(paths, 2)
       tagData{1, i} = cell(0, 2); 
    end
    
    for i=1:size(paths, 2) %loop over each tag in the data set
        subDirList = paths{mainDirectoriesVisited, i};
        
        if(size(subDirList, 1) ~= 0) %If there is at least one directory there
            directory = strtrim(subDirList(1, :));
            temp = strsplit(directory, '\');
            dataSet{mainDirectoriesVisited, 1} = temp(1, end - 5); %Store the device ID
            
            for j=1:size(subDirList, 1)
                directory = strtrim(subDirList(j, :));
                temp = strsplit(directory, '\');
                ttt = ttt + 1;
                if(ttt == 6) %Only for debug purposes
                end
                if(strcmp(temp{1, end-3}, 'PhoneLabSystemAnalysis-BatteryChange'))
                    uncompressFiles(directory, true); %Uncompress all .gz files in the given directory
                    tagData{1, i}{j, 1} = strtrim(sprintf('%s-%s-%s\n', temp{1, end - 1}, temp{1, end}, temp{1, end - 2})); %Store the date in which the data was obtained
                    tagData{1, i}{j, 2} = extractBatteryData(directory);

                elseif(strcmp(temp{1, end-3}, 'PhoneLabSystemAnalysis-Location'))
%                     uncompressFiles(directory, true); %Uncompress all .gz files in the given directory
                    tagData{1, i}{j, 1} = sprintf('%s-%s-%s\n', temp{1, end - 1}, temp{1, end}, temp{1, end - 2}); %Store the date in which the data was obtained

                elseif(strcmp(temp{1, end-3}, 'PhoneLabSystemAnalysis-Wifi'))
%                     uncompressFiles(directory, true); %Uncompress all .gz files in the given directory
                    tagData{1, i}{j, 1} = sprintf('%s-%s-%s\n', temp{1, end - 1}, temp{1, end}, temp{1, end - 2}); %Store the date in which the data was obtained

                elseif(strcmp(temp{1, end-3}, 'PhoneLabSystemAnalysis-Snapshot'))
%                     uncompressFiles(directory, true); %Uncompress all .gz files in the given directory
                    tagData{1, i}{j, 1} = sprintf('%s-%s-%s\n', temp{1, end - 1}, temp{1, end}, temp{1, end - 2}); %Store the date in which the data was obtained

                end
            end
        end
    end
    
    for i=1:size(paths, 2)
       dataSet{mainDirectoriesVisited, i+1} = tagData{1, i};
       tagData{1, i} = [];
    end
    mainDirectoriesVisited = mainDirectoriesVisited + 1;
end

    clear ans i j k l temp fid baseFileName
    
    clear ans i j k l temp tline txtFiles mainDirectoriesVisited mainDirList fid filePattern fullFileName userCounter sampleCounter dayCounter samples
%     batteryDataset = removeRepeatedDataPoints(batteryDataset);
batteryDataset = dataSet;
    toc
%     readyToAnalyzeData = futureBatteryLevel(dataSet);
end