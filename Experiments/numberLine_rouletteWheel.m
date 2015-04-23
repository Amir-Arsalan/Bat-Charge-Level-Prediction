function Index = numberLine_rouletteWheel(rowVectorOfProbabilities)
%Index is the index in the vector of probability

randomNum = 0.000001 + (1 - 0.000001) * rand(1); %For number line

%%
%Construct a number line
numberLine(1, 1) = rowVectorOfProbabilities(1, 1);
for i=2:size(rowVectorOfProbabilities, 2)
   numberLine(1, i) =  numberLine(1, i - 1) + rowVectorOfProbabilities(1, i);
end

%%
%Toss a coin and generate the index to one of the values!
temp = numberLine(1, 1);
for i=2:size(rowVectorOfProbabilities, 2) + 1
    if(randomNum <= temp)
       Index = i - 1;
       break;
    end
    temp = numberLine(1, i);
end

%randomNum = 0.000000000000000000000000000000000000000000000000000001 + (1 -0.000000000000000000000000000000000000000000000000000001) * rand(1) * 360; %For roulette wheel

%%
%Construct a roulette wheel

% degrees = zeros(1, size(Pi, 2));
% for i=1:size(Pi, 2)
%     degrees(1,i) = Pi(1, i) * 360;
% end

%%
%Toss dice on roulette wheel

% temp = degrees(1, 1);
% for i=2:size(Pi, 2) + 1
%     if(randomNum <= temp)
%        Index = i - 1;
%        break;
%     end
%     temp = temp + degrees(1, i);
% end

end