function expHMM(initChargeLvl, HMMmodel, granularity)

chargeLvl = zeros(400, (1440/granularity) * 2); %400 Simulations, each 2-day long
chargeLvl(:, 1) = initChargeLvl;

transition = HMMmodel{1, 1};
emission = HMMmodel{1, 2};
initial = HMMmodel{1, 3};

for i=1:400
    state = 9;
    for j=2:(1440/granularity) * 2
        emitParam = emission{1, state};
        emittedChargeLvl = normrnd(emitParam(1), emitParam(2));
        if(chargeLvl(i, j - 1) - emittedChargeLvl <= 0)
            chargeLvl(i, j) = 0;
            state = 1;
        elseif(chargeLvl(i, j - 1) - emittedChargeLvl >= 100)
             chargeLvl(i, j) = 100;
             state = 9;
        else
            chargeLvl(i, j) = chargeLvl(i, j - 1) - emittedChargeLvl;
        end
        state = numberLine_rouletteWheel(transition(state, :));
    end
end

end