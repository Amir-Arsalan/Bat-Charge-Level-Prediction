function [means, stds] = miscFitGMM(data, numOfClusters)
%{
This function fits a GMM to the input data

Inputs:
- data: The data (only one-dimensional at the moment)
- numOfClusters: Number of clusters

Outputs:
- means: Mean of the cluster centroids
- stds: Standard deviations of the cluster centroids

Note: For now we discard the components responsibilities as we do not need
them
Note: The function is currnetly applicable to one-dimensional
data only
%}
        
        %% The function code stars here
        
        flag = 0;
        if(numOfClusters == 1)
            %In case of numOfCluster == 1 the std becomes zero (usually) and therefore NaN's or empty matrices are returned. This if prevents this happening
            flag = 1;
            numOfClusters = 3; %Temporarily
        end
        tempMeans = zeros(9, numOfClusters);
        tempStds = zeros(9, numOfClusters);
        sortIndices = zeros(1, numOfClusters);
        warning('off');
        i = 1;
        j = 1;
        while(i <= 9)
            try
                [tempMeans(i, :), tempStds(i, :)] = miscRunGMM(data, numOfClusters, 200);
            catch exception
                i = i - 1;
                errMsg = exception.message;
                iterNum = str2num(errMsg(end-4:end-1));
                if(isempty(iterNum))
                   iterNum = str2num(errMsg(end-3:end-1));
                end
                if(isempty(iterNum))
                  iterNum = str2num(errMsg(end-2:end-1));
                end
                [tempMeans(i, :), tempStds(i, :)] = miscRunGMM(data, numOfClusters, max(1, iterNum - 1));
                fprintf('%s\n', exception.message);
            end
            i = i + 1;
            j = j + 1;
            if(j >= 100)
               warning('Fitting GMM is taking too long'); 
            end
        end
        stdStds = std(tempStds);
        meanStds = mean(tempStds);
        toRemoveIndices = tempStds(:, 1) >= meanStds(1) + 0.7 * stdStds(1) | tempStds(:, 1) <= meanStds(1) - 0.7 * stdStds(1);
        tempStds(toRemoveIndices, :) = [];
        tempMeans(toRemoveIndices, :) = [];
        
        if(flag == 0)
            means = mean(tempMeans);
            stds = mean(tempStds);
        else
            means = mean(tempMeans(:, 1));
            stds = mean(tempStds(:, 1));
        end
        warning('on');
end