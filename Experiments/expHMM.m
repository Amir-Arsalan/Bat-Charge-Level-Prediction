function simulations = expHMM(initChargeLvl, HMMmodel, timeGranularity)

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
%}

simulations = zeros(400, ceil((1440/timeGranularity) * 2)); %400 Simulations, each 2-day long
simulations(:, 1) = initChargeLvl;

transition = HMMmodel{1, 1};
emission = HMMmodel{1, 2};
initial = HMMmodel{1, 3};

for i=1:400 %Do it for 400 simulations
    state = determineInitState(initChargeLvl);
    for j=2:ceil((1440/timeGranularity) * 2)
        emitParams = emission{1, state};
        emittedChargeRate = normrnd(emitParams(1), emitParams(2));
        if(simulations(i, j - 1) - emittedChargeRate <= 0)
            simulations(i, j) = 0;
            state = 1;
        elseif(simulations(i, j - 1) - emittedChargeRate >= 100)
             simulations(i, j) = 100;
             state = 9;
        else
            simulations(i, j) = simulations(i, j - 1) - emittedChargeRate;
        end
        state = numberLine_rouletteWheel(transition(state, :));
    end
end

%% Functions

    function state = determineInitState(initChargeLvl)
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