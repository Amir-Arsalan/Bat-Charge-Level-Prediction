function expectedValue = intFunction(intType, conditionalMean, normalized, fun)
%{
Integrates a function given the conditional mean using different
integration methods such as definite, MCMC methods, Variational methods

%Inputs:
- intType: Determines the integration type to be useed
- conditionalMean: A value(vector) around which the integration takes place
- normalized: Takes on values 0 or 1. If 1 the returned expected value is
normalized and vice versa the opposite.
- fun: The integrand over which the integration takes place
%}

%% Function code starts here

end