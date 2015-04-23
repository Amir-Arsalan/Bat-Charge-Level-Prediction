function expHMM(initChargeLvl, HMMmodel)

chargeLvl = zeros(500, 100);
chargeLvl(:, 1) = initChargeLvl;

transition = HMMmodel{1, 1};
emission = HMMmodel{1, 2};
initial = HMMmodel{1, 3};

for i=1:500
    state = 2;
    for j=2:100
        emitParam = emission{1, state};
        emittedChargeLvl = normrnd(emitParam(1), emitParam(2));
        if(chargeLvl(i, j - 1) - emittedChargeLvl <= 0)
            chargeLvl(i, j) = 0;
%             state = 1;
        elseif(chargeLvl(i, j - 1) - emittedChargeLvl >= 100)
             chargeLvl(i, j) = 100;
%              state = 9;
        else
            chargeLvl(i, j) = chargeLvl(i, j - 1) - emittedChargeLvl;
        end
        state = numberLine_rouletteWheel(transition(state, :));
    end
end

end