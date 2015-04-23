function numRowsToKeep = uncompressFiles(directory, uncomp)

filePattern1 = fullfile(directory, '*.out');
filePattern2 = fullfile(directory, '*.gz');
theFiles1 = dir(filePattern1);
theFiles2 = dir(filePattern2);
numFiles1 = size(theFiles1, 1); %Number of .out files in the given directory
numFiles2 = size(theFiles2, 1); %Number of .gz files in the given directory


if(uncomp == true && numFiles1 == 0 ||  numFiles1 < numFiles2)
     gunzip(directory, directory); %uncompress all of the .gz files
end

numRowsToKeep = numFiles2;

end