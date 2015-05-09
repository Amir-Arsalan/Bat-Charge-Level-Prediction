function miscPlotApplySettings(xLimit, yLimit, xLabel, yLabel, Title)
%{
This function sets plot settings easily

Inputs:
- xLimit: A 1 by 2 numeric vector
- yLimit: A 1 by 2 numeric vector
- xLabel: An string to be shown for x axis
- yLabel: An string to be shown for y axix
- Title: An string to be shown as the title of the plot

Output:
(Void) Just applying the appropriate functions given the input values

Note: Any or all of the input variables can be empty
%}

%% Function code starts here

hold on
if(exist('Title', 'var') && ~isempty(Title))
    title(Title)
end
if(exist('xLabel', 'var') && ~isempty(xLabel))
    xlabel(xLabel);
end
if(exist('yLabel', 'var') && ~isempty(yLabel))
    ylabel(yLabel);
end
if(exist('yLimit', 'var') && ~isempty(yLimit))
    ylim(yLimit) %Assuming that the first element of timeGranularity is the smallest one
end
if(exist('xLimit', 'var') && ~isempty(xLimit))
    xlim(xLimit);
hold off

end