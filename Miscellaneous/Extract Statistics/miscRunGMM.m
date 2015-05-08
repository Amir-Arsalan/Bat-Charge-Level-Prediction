function [means, stds] = miscRunGMM(data, numOfClusters, iterNum)
%{
This function executes fitgmdist function given the inputs

Inputs:
- data: The data (only one-dimensional at the moment)
- numOfClusters: Number of clusters
- iterNum: Number of iterations

Outputs:
- means: Mean of the cluster centroids
- stds: Standard deviations of the cluster centroids

%}

%% Function code starts here

i = true;
j = 1;
while(i == true && j <= 100)
    try
        GMMObject = fitgmdist(data, numOfClusters, 'Options', statset('Maxiter', iterNum));
        [means, sortIndices] = sort(GMMObject.mu, 'ascend');
        tempVars = GMMObject.Sigma;
        tempVars = tempVars(:, :, sortIndices);
        stds = sqrt(tempVars);
    catch exception
        
    end
    if(exist('exception', 'var'))
        errMsg = exception.message;
        iterNum = str2num(errMsg(end-4:end-1));
        if(isempty(iterNum))
           iterNum = str2num(errMsg(end-3:end-1));
        end
        if(isempty(iterNum))
          iterNum = str2num(errMsg(end-2:end-1));
        end
        iterNum = max(1, iterNum - 1);
        clear exception
    else
        i = false;
    end
    j = j + 1;
end
if(j >= 100)
    means = zeros(numOfClusters, 1);
    stds = zeros(numOfClusters, 1);
end
end