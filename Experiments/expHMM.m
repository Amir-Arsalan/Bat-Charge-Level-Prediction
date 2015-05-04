function simulation = expHMM(initChargeLvl, HMMmodel, timeGranularity, numOfDays)

%{
This function runs a markov chains over the input model to simulate
charging/discharging

Inputs:
    - initChargeLvl: An initial charge level to start the simulation from
    - HMMmodel = An cell containing an HMM model:
        transition matrix
        initial distribution vector
        a cell containing gaussian distribution parameters for emitting discharge/recharge rate)
    - timeGranularity: The time granularity of simulations
    - numOfDays: A posotive, preferably integer, quantity that specifies 
    the number of days for which the simulation will run

Output:
    - simulation: Simulation results given the model and initial charge lvl
%}

numOfSimulations = 800;
simulation = zeros(numOfSimulations, ceil((1440/timeGranularity) * numOfDays));
simulation(:, 1) = initChargeLvl;

transition = HMMmodel{1, 1};
emission = HMMmodel{1, 2};
initialDist = HMMmodel{1, 3};

for i=1:numOfSimulations %from 1 to # of simulations
%     state = initializeStartState(initChargeLvl);
    state = numberLine_rouletteWheel(initialDist);
    for j=2:ceil((1440/timeGranularity) * numOfDays)
        emitParams = emission{1, state};
        emittedChargeRate = normrnd(emitParams(1), emitParams(2));
        if(simulation(i, j - 1) - emittedChargeRate <= 0)
            simulation(i, j) = 0;
            state = 1;
        elseif(simulation(i, j - 1) - emittedChargeRate >= 100)
             simulation(i, j) = 100;
             state = 9;
        else
            simulation(i, j) = simulation(i, j - 1) - emittedChargeRate;
        end
        state = numberLine_rouletteWheel(transition(state, :));
    end
end

%% Functions

    function state = initializeStartState(initChargeLvl)
        if(initChargeLvl ~= 100 && initChargeLvl ~= 0)
            state = 2; %Idle
        elseif(initChargeLvl == 100)
            state = 9; %Fully charged
        else
            state = 1; %Shutdown
        end 
    end

fprintf('Simulation of charging/discharging behavior of the model with an initial charge level of %d and time-granularity of %d has been done successfully\n', initChargeLvl, timeGranularity);

end