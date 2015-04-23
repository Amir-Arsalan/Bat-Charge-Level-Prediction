function batteryDataset = import_data(directory)

tic
subDirectoryIndex = 1; %Trevarses on sub-directories of each user's data folder
mainDirectoriesVisited = 1; %
toRemoveIndex = uint8(0);

userCounter = 1;
dayCounter = 1;

mainDirList = getDirectories(directory); %Get a list of all sub-directories in a directory

% for i=1:size(mainDirList, 1)
%    temp = mainDirList{i, 1};
%    numberOfSubDirectories = numberOfSubDirectories + size(temp, 1); %Count how many sub-directories exist
% end

clear temp

while(mainDirectoriesVisited <= size(mainDirList, 1))
   
    subDirList = mainDirList{mainDirectoriesVisited, 1};
    toRemove = false(size(subDirList, 1), 1);
    
    for i=1:size(subDirList, 1)
        directory = strtrim(subDirList(i, :));
        temp = strsplit(directory, '\');
        
        if(strcmp(temp{1, 4}, 'PhoneLabSystemAnalysis-BatteryChange'))
            batteryDataset{userCounter, 1} = temp(1, end - 5); %Store the device ID
            
%             folderExist(directory) %Check whether the directory is a
%             folder or not

            uncompressFiles(directory); %Uncompress all .gz files in the given directory
            
            usageData{dayCounter, 1} = sprintf('%s-%s-%s\n', temp{1, end - 1}, temp{1, end}, temp{1, end - 2}); %Store the date in which the data was obtained
            
            filePattern = fullfile(directory, '*.out');
            theFiles = dir(filePattern);
            sampleCounter = 1;
            for i = 1:length(theFiles)
                baseFileName = theFiles(i).name;
                fullFileName = fullfile(directory, baseFileName);

                % START reading the data line-by-line
                fid = fopen(fullFileName);
                tline = fgets(fid); %To discard the first line in the .txt files
                while ischar(tline) %Continue until there is a line of data available in the file

                    if(tline ~= -1)
%                         temp = strsplit(tline, ', '); %Split it
                        temp = regexp(tline, '..:..:'); %Extracts the first character index where the timestamp starts
                        samples{sampleCounter, 1} = tline(1, temp:temp + 4); %Store the time (HH:MM) of the received sample
                        samples{sampleCounter, 2} = extractStringValue(tline, 'Charged');
                        samples{sampleCounter, 3} = extractStringValue(tline, 'Temparature');
                        samples{sampleCounter, 4} = extractStringValue(tline, 'BatteryLevel');
                        samples{sampleCounter, 5} = extractStringValue(tline, 'Plugged');
                    end

                    sampleCounter = sampleCounter + 1;
                    tline = fgets(fid); %Read a line

                end
                fclose(fid);
            end
            usageData{dayCounter, 2} = samples; %Store the received samples from a user in a specific day 
            samples = {};
            dayCounter = dayCounter + 1;
            
        else
            toRemove(i, 1) = 1;
        end
        
    end
    mainDirList{mainDirectoriesVisited,1} = mainDirList{mainDirectoriesVisited, 1}(~toRemove, :); %Remove the directory addresses considered as useless
    batteryDataset{userCounter, 2} = usageData;
    userCounter = userCounter + 1;
    usageData = {};
    dayCounter = 1;
    mainDirectoriesVisited = mainDirectoriesVisited + 1; %Go for the next user's data
    
end


%     while(mainDirectoriesVisited <= size(mainDirList, 1))
% 
%         subDirList = mainDirList{mainDirectoriesVisited, 1}; %Get a list of one of the sub-directories
%         
%         directory = subDirList(1, :);
%         temp = strsplit(directory, '\'); %Split the directory characters
%         dataSet{userCounter, 1} = temp(1, end - 5);
%         
%        if(strcmp(temp{1, 4}, 'PhoneLabSystemAnalysis-BatteryChange'))
%             
% 
%             for l=1:size(subDirList, 1) %To go through all of the sub-directories
%     
%                 directory = strtrim(subDirList(l, :));
%     
%                 if ~isdir(directory)
%                   errorMessage = sprintf('Error: The following folder does not exist:\n%s', directory);
%                   uiwait(warndlg(errorMessage));
%                   return;
%                 end
%                 
%                 uncompressFiles(directory); %Uncompress all .gz files in the given directory
%                 
%             end
%             
%             for l=1:size(subDirList, 1)
% 
%                     directory = subDirList(l, :);
% 
%                     if ~isdir(directory)
%                         errorMessage = sprintf('Error: The following folder does not exist:\n%s', directory);
%                         uiwait(warndlg(errorMessage));
%                         return;
%                     end
% 
%                     directory = strtrim(directory); %Remove the whitespace before and after the string
%                     temp = strsplit(directory, '\'); %Split the directory characters
% 
%                     usageData{dayCounter, 1} = sprintf('%s-%s-%s\n', temp{1, end - 1}, temp{1, end}, temp{1, end - 2}); %Store the date in which the data was obtained
% 
%                 filePattern = fullfile(directory, '*.out');
%                 theFiles = dir(filePattern);
%                 sampleCounter = 1;
%                 for i = 1:length(theFiles)
%                     baseFileName = theFiles(i).name;
%                     fullFileName = fullfile(directory, baseFileName);
% 
%                     % START reading the data line-by-line
%                     fid = fopen(fullFileName);
%                     tline = fgets(fid); %To discard the first line in the .txt files
%                     while ischar(tline) %Continue until there is a line of data available in the file
% 
%                         if(tline ~= -1)
%     %                         temp = strsplit(tline, ', '); %Split it
%                             temp = regexp(tline, '..:..:'); %Extracts the first character index where the timestamp starts
%                             samples{sampleCounter, 1} = tline(1, temp:temp + 4); %Store the time (HH:MM) of the received sample
%                             samples{sampleCounter, 2} = extractStringValue(tline, 'Charged');
%                             samples{sampleCounter, 3} = extractStringValue(tline, 'Temparature');
%                             samples{sampleCounter, 4} = extractStringValue(tline, 'BatteryLevel');
%                             samples{sampleCounter, 5} = extractStringValue(tline, 'Plugged');
%                         end
% 
%                         sampleCounter = sampleCounter + 1;
%                         tline = fgets(fid); %Read a line
% 
%                     end
%                     fclose(fid);
%                 end
%                 usageData{dayCounter, 2} = samples; %Store the received samples from a user in a specific day 
%                 samples = {};
%                 dayCounter = dayCounter + 1;
% 
%     %             dataSet{subDirectoryIndex, 1} = dataContainer;
% 
%                 subDirectoryIndex = subDirectoryIndex + 1; %When reading the data for a sub-directory is finished, the index for storing new data set increases by one
% 
% 
%             end
% 
%             dataSet{userCounter, 2} = usageData;
%             userCounter = userCounter + 1;
%             usageData = {};
%             dayCounter = 1;
%             
%             mainDirectoriesVisited = mainDirectoriesVisited + 1;
% 
%        end
%     
%     end
    
    clear ans i j k l temp fid baseFileName
    
    clear ans i j k l temp tline txtFiles mainDirectoriesVisited mainDirList fid filePattern fullFileName userCounter sampleCounter dayCounter samples
    batteryDataset = removeRepeatedDataPoints(batteryDataset);
    toc
%     readyToAnalyzeData = futureBatteryLevel(dataSet);
end