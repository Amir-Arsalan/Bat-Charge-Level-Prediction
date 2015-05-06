%{
TODOs:

05/06/2015:

- Start writing the paper

- expExecute.m:
    - The number of simulations should be the same as number of instances
    in the original data set with the same battery charge level
    
- procExtractUsersBatteryChargeLevelStats.m:
    - Identify and remove noisy records

- RunExps.m:
    - Write a new function named "runExps" that runs different experiments
    by differnet parameters and evaluates the results (error and ... )

- genHMM.m:
    - expType == 2: Learn model type 1, but the difference is the observation is
        a GMM instead of one Normal distribution
    - expType = 3: Learn a model for each user

- miscPlotResults.m:
    - Plot histogram of meeting different charge levels in different
    intervals
    - Remove the code snippet to avoid unnecessary computations from
    procExtractUsersBatteryChargeLevelStats.m and place it in miscPlotResults.m
    
____________________

- genHMM.m:
    - expType == 2: Learn model type 1, but the difference is the observation is
    a GMM instead of one Normal distribution
    - expType = 3: Learn a model for each user
    - expType = 4: Learn a model for each user dependent on battery charge level
    - expType = 4: Learn model type 4, with GMM observations
    - expType = 5: Learn a model dependent on time of day
    - expType = 6: expType 5 + dependency on battery charge lvl
    - expType = 7: expType 5 with GMM observations
    - expType = 8: expType 6 with GMM observations

- miscPlotResults.m:
    - (Done) Plot time consistent simulation result
    - (Done) Plot the mean and variance in one plot
    - (Done) Plot means of battery charge levels of users against mean of each
    simulation for each time granularity along with the respective legend

- procGenerateIntervalConsistentDataRecord.m
    - (Done) Interpolate simulation results of all time granularities within
    the smallest time granularity to ease plotting their means and standard
    deviations in one elaborative graph
    - (Done)Plot the results with different, automatically chosen line styles

- expHMM.m:
    - (Done) The initial state distribution is dependent on the initial charge
    level

- Missing value problem:
    - Fill the missing values with learned model

- Maybe later sometime:
    - Create a separate plot function that gets plot() arguments with the goal of making the code more readable
%}