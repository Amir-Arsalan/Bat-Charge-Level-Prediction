function model = genHMM(timeGranulatedDataRecord, timeGranularity, expType, initChargeLvl, initState, exactMatch, numOfDays)

%{
This function generates a model to be used for simulation porpuses later

Inputs:

- dataRecord: An m by 2 matrix where m is the number of time-granulated 
records for time series data and n is the number of attributes for each
record
- timeGranularity: The time granularity of the data record sets
- expType: Determines the model to be learned over the input data record

    If the expType is:
        - One(1): The model learned in this experiment type (expType)
        is a simple hidden Markod model (HMM) with 12 pre-defined states
        and the set of parameters learned via Maximum Likelihood Estimate (MLE)

- initChargeLvl: The initial charge level from which the user battery 
charge level sequence extraction begins
- initState: Takes on values 0 or 1. It specifies the initial phone's 
charging state: if 1 the phone is charging and 0 otherwise
- exactMatch: Takes on values of 1 or 0. If 1 the function select the 'start
charge levels' equal to initChargeLvl exactly. If not, the function selects
the 'start charge levels' with a boundary of initChargeLvl.
- numOfDays: A posotive, preferably integer, quantity that specifies the 
number of days for which the simulation will run

%}

%% The code section for generating a model

[labeledDataRecord, usersIndex] = labelDataForHMM(timeGranulatedDataRecord, timeGranularity, expType);

if(expType == 1 || expType == 2) %First two models (a simple HMM with 12 states)
    %{
    Discharge states:
        (1) Shutdown: When the discharge rate (9th column of the users data
        set) is 0 - This is a very naive assumption because in many times 
        the charge level is 0 but the battery charge level is higher than 
        0 and the phone has not been died out. In a more complex model if 
        the hidden variable is dependent on charge level we can assume that
        when the charge level is between 0 and 3,s say) the discharge rate 
        is 0 also, then the phone has been died out definately.
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
    
    Note: If expType == 2 then the HMM's initial distribution vector is 
    conditioned on the initial charging status (determined by initState
    variable)
    %}

    numOfStates = 12;
    
    transitionMatrix = zeros(numOfStates, numOfStates);
    emission = cell(1, numOfStates);
    initialDist = zeros(1, numOfStates);
    
    for i=1:numOfStates %Since we are sure we have 12 states
       tempChargeRates = labeledDataRecord(labeledDataRecord(:, 10) == i, 9);
       emission{1, i} = [mean(tempChargeRates), std(tempChargeRates)];
    end
    
    for i=1:length(usersIndex) - 1
        singleUserData = labeledDataRecord(usersIndex(i) + 1:usersIndex(i + 1), :);
        labels = double(singleUserData(:, end));
        
%         if(expType == 1)
%             initialDist(labels(1)) = initialDist(labels(1)) + 1;
%         end
        
        for j=1:size(labels, 1) - 1
            transitionMatrix(labels(j), labels(j + 1)) = transitionMatrix(labels(j), labels(j + 1)) + 1;
            %Note: The last label for each user/data record set does not 
            %follow with another label. Therefore, it is discarded in
            %calculation of transition probabilities in the transition
            %matrix
        end

    end
    
%     if(expType == 1)
%         initialDist = initialDist / sum(initialDist);
%     end
    
    for i=1:size(transitionMatrix, 1)
        %START Prevent NaN probability distribution vectors, if any
        if(sum(transitionMatrix(i, :)) == 0)
           transitionMatrix(i, i) = randi([10 + size(transitionMatrix, 1), 16 + size(transitionMatrix, 1)]);
           tempIndices = 1:size(transitionMatrix, 1);
           tempIndices = [tempIndices(1: i - 1), tempIndices(i + 1:end)];
           transitionMatrix(i, tempIndices) = randi([1, 3], length(tempIndices), 1);
           clear tempIndices
        end
        %END Prevent NaN probability distribution vectors, if any
       transitionMatrix(i, :) = transitionMatrix(i, :) / sum(transitionMatrix(i, :)); 
    end
    
%     if(expType == 2)
        initialDist = procCalcInitialDistVector(labeledDataRecord, timeGranularity, initChargeLvl, initState, exactMatch, expType, numOfDays); %This line of code replaces the previous 'initialDist' with a new one which depends on the initial battery charge level for simulation
%     end
    model{1, 1} = transitionMatrix;
    model{1, 2} = emission;
    model{1, 3} = initialDist;
    
    fprintf('Learning model for experiment type ''%d'' (A simple HMM with the parameters learned via MLE) for the data with time-granularity of %d has been done successfully\n', expType, timeGranularity);

end