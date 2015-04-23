function [directoryQuantity, dirList] = getDirList(dirAddress)
dirData = dir(dirAddress);
dirIndex = [dirData.isdir];
dirIndex(1, 1:2) = 0; %Disregard the firt two directories located in the given input directory since they are "." and ".." directories
if(length(find(dirIndex)  == 1) >= 1)
    dirList = {dirData(dirIndex).name}';
    directoryQuantity = size(dirList, 1);
else
    dirList = {};
    directoryQuantity = 0;
end
end