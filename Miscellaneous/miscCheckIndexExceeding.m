function safeToAdd = miscCheckIndexExceeding(currentIndex, sumWith, includeLast, matrix)
%{
This function checks whether adding a number to the current index exceeds
the row length of the input matrix or not

Inputs:
- currentIndex
- sumWith: The number of indices ahead of currentIndex
- includeLast: Takes on either 0 or 1. Shall the sum include the last index
or not?
- matrix: The matrix on which the operations are done

Output:
safeToAdd: 0 or 1; 1 if not exceeds, 0 otherwise
%}

%% Function code starts here

if(currentIndex + sumWith - ~(1 && includeLast) <= size(matrix, 1))
    safeToAdd = 1;
else
    safeToAdd = 0;
end

end