function model = genHMM(dataSequence, timeGranularity, mode)

transitionMatrix = [];
[labeledDataset, usersIndex] = labelDataForHMM(dataSequence, timeGranularity, mode);

%% The code section for generating a model
if(mode == 1) %First model (a simple HMM with 13 states)
    %{
    The first model consists the following states:
    Discharge states:
        (1) Shutdown: When the discharge rate (9th column of the users data
        set) is 0 - This is a very naive assumption because in many times 
        the charge level is 0 but the battery charge level is higher than 
        0 and the phone has not been died out. In a more complex model if 
        the hidden variable is dependent on charge level we can assume that
        when the charge level is between 0 and the discharge rate is 0
        also, then the phone has been died out definately.
        (2) Idle: When the discharge rate is > 0 & <= 0.35/(10/granularity)
        (3) Low: When the discharge rate is > 0.35/(10/granularity) & <= 0.99/(10/granularity)
        (4) Med-Low: When the discharge rate is > 0.99/(10/granularity) & < 2/(10/granularity)
        (5) Med: When the discharge rate is >= 2/(10/granularity) & < 4/(10/granularity)
        (6) Med-High: When the discharge rate is >= 4/(10/granularity) & <= 6.5/(10/granularity)
        (7) High: When the discharge rate is > 6.5/(10/granularity) & <= 9.3/(10/granularity)
        (8) Intense When the discharge rate is > 9.3/(10/granularity)
    
    Recharge states:
        (9) Idle/Fully Charged: When the recharge rate is >-0.5/(10/granularity)
        (10) Early recharge state/getting fully charged: When the rescharge rate is <= -0.5/(10/granularity) & >= -3/(10/granularity)
        (11) About to get fully charged: When the recharge rate is < -3/(10/granularity) & >= -6.5/(10/granularity)
        (12) About to get fully charged: When the recharge rate is < -6.5/(10/granularity)
    %}
    
    transitionMatrix = zeros(12, 12);
    emission = cell(1, 12);
    initialDist = zeros(1, 12);
    
    for i=1:12
       tempChargeRates = labeledDataset(labeledDataset(:, 10) == i, 9);
       emission{1, i} = [mean(tempChargeRates), std(tempChargeRates)];
    end
    
    for i=1:length(usersIndex) - 1
        singleUserData = labeledDataset(usersIndex(i) + 1:usersIndex(i + 1), :);
        labels = double(singleUserData(:, end));
        
        initialDist(labels(1)) = initialDist(labels(1)) + 1;
        
        for j=1:size(labels, 1) - 1
            transitionMatrix(labels(j), labels(j + 1)) = transitionMatrix(labels(j), labels(j + 1)) + 1;
        end

    end
    
    initialDist = initialDist / sum(initialDist);
    
    for i=1:size(transitionMatrix, 1)
       transitionMatrix(i, :) = transitionMatrix(i, :) / sum(transitionMatrix(i, :)); 
    end
    
    model{1, 1} = transitionMatrix;
    model{1, 2} = emission;
    model{1, 3} = initialDist;

end