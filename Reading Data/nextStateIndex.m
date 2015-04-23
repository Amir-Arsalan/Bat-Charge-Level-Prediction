function nextStateIndex = nextStateIndex(usageData, currentRowIndex, requestedState)

if(currentRowIndex < size(usageData, 1))
    for i=currentRowIndex+1:size(usageData, 1)
        
        if(strcmp(usageData{i, 5}, requestedState))
            nextStateIndex = i;
            return;
        elseif(i == size(usageData, 1)) %If the requestedState was not found in the usageData instances
            nextStateIndex = -1;
            return;
        end
        
    end
    
else
    nextStateIndex = -1;
end

end