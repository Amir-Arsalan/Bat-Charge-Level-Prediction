function expHMM(initChargeLvl, HMMmodel, granularity)

chargeLvl = zeros(400, (1440/granularity) * 2); %400 Simulations, each 2-day long
chargeLvl(:, 1) = initChargeLvl;

transition = HMMmodel{1, 1};
emission = HMMmodel{1, 2};
initial = HMMmodel{1, 3};

for i=1:400
    state = 9;
    for j=2:(1440/granularity) * 2
        emitParams = emission{1, state};
        emittedChargeRate = normrnd(emitParams(1), emitParams(2));
        if(chargeLvl(i, j - 1) - emittedChargeRate <= 0)
            chargeLvl(i, j) = 0;
            state = 1;
        elseif(chargeLvl(i, j - 1) - emittedChargeRate >= 100)
             chargeLvl(i, j) = 100;
             state = 9;
        else
            chargeLvl(i, j) = chargeLvl(i, j - 1) - emittedChargeRate;
        end
        state = numberLine_rouletteWheel(transition(state, :));
    end
end

end