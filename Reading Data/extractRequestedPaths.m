function dirs = extractRequestedPaths(directory, requestedDirs, uncompress)

%Input:
%directory: A variable containing paths containing all *.gz files
%requestedDirs: A cell containing tag names requested by the user to have
%their paths
%uncompress: Whether to uncompress all .gz files in each directory or not
%and takes values true or false

%Output: nothing; only process on the files

tic
dirsToKeep = boolean(zeros(size(directory, 1), 1));
numRowsToKeep = 0;
i = 1;
% subDirs = char('');
subDir = cell(0, size(requestedDirs, 2));
for i=1:size(subDir, 2)
   subDir{1, i} = '';
end

deviceDirs = cell(0, size(requestedDirs, 2));
counter = 1;

temp = regexp(directory{1, 1}, '\'); %temp contains the indices where the character '\' is in the string
temp2 = fileparts(directory{1, 1});
deviceID = temp2(1, temp(end-6)+1:temp(end-5)-1);

while(i <= size(directory, 1))
%    temp = strsplit(directory{i, 1}, '\');
    temp = regexp(directory{i, 1}, '\'); %temp contains the indices where the character '\' is in the string
%    if(~isempty(find(strcmp(requestedDirs, temp{1, end-4}), 1))) %If the target folder is one of the folders that the user is looking for
    searchRes = find(strcmp(requestedDirs, directory{i, 1}(temp(7)+1:temp(8)-1)), 1);
    if(~isempty(searchRes)) %If the target folder is one of the folders that the user is looking for
        temp2 = fileparts(directory{i, 1});
        numRowsToKeep = uncompressFiles(temp2, uncompress);
        if(strcmp(temp2(1, temp(end-6)+1:temp(end-5)-1), deviceID))
            subDir{1, searchRes} = [subDir{1, searchRes}; temp2];
        else
            deviceID = temp2(1, temp(end-6)+1:temp(end-5)-1); %Replace the deviceID with the most recent one observed
            for j=1:size(requestedDirs, 2)
                deviceDirs{counter, j} = subDir{1, j};
                subDir{1, j} = '';
                subDir{1, searchRes} = temp2;
            end
            counter = counter + 1;
        end
      	dirsToKeep(i:(i+numRowsToKeep-1)) = 1;
        i = i + numRowsToKeep;
    else
        i = i + 1;
    end
end

for j=1:size(requestedDirs, 2)
    deviceDirs{counter, j} = subDir{1, j}; 
end

dirs = deviceDirs;

toc
end