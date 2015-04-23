function folderExist(directory)
    if ~isdir(directory)
        errorMessage = sprintf('Error: The following folder does not exist:\n%s', directory);
        uiwait(warndlg(errorMessage));
        return;
    end
end