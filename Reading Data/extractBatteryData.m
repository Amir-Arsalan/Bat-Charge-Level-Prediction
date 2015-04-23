function batteryData = extractBatteryData(directory)
%%
%Input:
%- directory: The directory where the .out files are located

%Output: Battery Data

%% Process

filePattern = fullfile(directory, '*.out');
theFiles = dir(filePattern);
batteryData = uint8(zeros(0, 6));
sampleCounter = 1;
flag = false;

for i=1:length(theFiles)
baseFileName = theFiles(i).name;
fullFileName = fullfile(directory, baseFileName);
% START reading the data line-by-line
fid = fopen(fullFileName);
tline = fgets(fid); %To discard the first line in the .txt files

while ischar(tline) %Continue until there is a line of data available in the file

    if(tline ~= -1)
%                         temp = strsplit(tline, ', '); %Split it
        try
            temp = regexp(tline, '..:..:'); %Extracts the first character index where the timestamp starts
            batteryData(sampleCounter, 1) = uint8(sscanf(tline(1, temp:temp+1), '%d')); %Hour
            batteryData(sampleCounter, 2) = uint8(sscanf(tline(1, temp+3:temp+4), '%d')); %Minute
            try
                batteryData(sampleCounter, 3) = logical(sscanf(extractStringValue(tline, 'Charged'), '%d')); %Whether the phone has been fully charged
            catch err1
                if(uint8(sscanf(extractStringValue(tline, 'BatteryLevel'), '%d')) == 100 && logical(sscanf(extractStringValue(tline, 'Plugged'), '%d')))
                   batteryData(sampleCounter, 3) = 1;
                else
                    batteryData(sampleCounter, 3) = 0;
                end
            end
            batteryData(sampleCounter, 4) = uint8(sscanf(extractStringValue(tline, 'Temparature'), '%d')/10); %Temperature in degrees Celsius divided by 10 (For applicability of the function uint8())
            batteryData(sampleCounter, 5) = uint8(sscanf(extractStringValue(tline, 'BatteryLevel'), '%d')); %Battery level
            batteryData(sampleCounter, 6) = logical(sscanf(extractStringValue(tline, 'Plugged'), '%d')); %Whether the phone has been plugged into charge
        catch err2
            if(sampleCounter ~= 0)
                fprintf('%s\n', fullFileName);
                batteryData(sampleCounter, 1) = batteryData(sampleCounter-1, 1);
                batteryData(sampleCounter, 2) = batteryData(sampleCounter-1, 2);
                batteryData(sampleCounter, 3) = batteryData(sampleCounter-1, 3);
                batteryData(sampleCounter, 4) = batteryData(sampleCounter-1, 4);
                batteryData(sampleCounter, 5) = batteryData(sampleCounter-1, 5);
                batteryData(sampleCounter, 6) = batteryData(sampleCounter-1, 6);
            end
        end
    end

    sampleCounter = sampleCounter + 1;
    tline = fgets(fid); %Read a line

end

fclose(fid);
end

end