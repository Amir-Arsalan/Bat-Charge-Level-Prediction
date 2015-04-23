function dirList = getDirectories(path)

[dirCount, dirList] = getDirList(path);

if(size(dirList, 1) == 0)
   dirList = path; 
   return;
end


for i=1:size(dirList, 1)
    temp = strcat(strcat(path, '\'), dirList(i, 1)); %Add '\' to the end of the directory path
    temp1 = temp{1, 1};
    temp1 = getDirectories(temp1); %Start the recursive process of finding sub-directories
    finalPath{i, 1} = char(temp1); %Store the directories found
end

dirList = finalPath;

end