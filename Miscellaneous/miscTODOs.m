%%
%{
TODOs:

05/18/2015:

- intFunction:
    - Start writing code for it!

- Research Directions/Impacts:
    - Biometrics:
        - Identifying users given a battery charge level sequence

    - Machine Learning:
        - Maybe something new for inference
        - Applicability of such methods for non-linear regression problems

    - Application:
        - Increase the trust level of mobile users on prediction algorithms
        - Applications in other fields
        - 

- Implement inference techniques:
    - Possible challenge: Continuous observation variable
    - Possible challenge: GMM as the observation
    - Possible challenge: The length of observations (should I use approx.
    inference methods?)
    - Compute the loss based on the deviation of real data states vs. 
    generated states of Viterbi algorithm

- Start writing the paper

- Write a function for creating flexible legends

- miscPlot.m:
    - Titles must show the experiment type

- procRawDataBatChargeSeqsStat.m:
    - Identify and remove noisy records

- expHMM.m:
    - Estimate the initial distribution parameters given the charging state 
    the user has been in

- RunExps.m:
    - Write a new function named "runExps" that runs different experiments
    by differnet parameters and evaluates the results (error and ... )

- genHMM.m:
    - expType == 2: Learn model type 1, but the initial distribution vector
    parameters are learned conditioned on the discharge/recharge state as input 
    - expType == 3: Learn model type 1, but the difference is the observation is
        a GMM instead of one Normal distribution
    - expType = 4: Learn a model for each user
    
____________________

- genHMM.m:
    - expType == 3: Learn model type 1, but the difference is the observation is
        a GMM instead of one Normal distribution
    - expType = 4: Learn a model for each user
    - expType = 5: Learn a model for each user dependent on battery charge level
    - expType = 6: Learn model type 4, with GMM observations
    - expType = 7: Learn a model dependent on time of day
    - expType = 8: expType 5 + dependency on battery charge lvl
    - expType = 9: expType 5 with GMM observations
    - expType = 10: expType 6 with GMM observations

- miscPlotResults.m:
    - (Done) Plot time consistent simulation result
    - (Done) Plot the mean and variance in one plot
    - (Done) Plot means of battery charge levels of users against mean of each
    simulation for each time granularity along with the respective legend
    - (Done) Define plotType which help plotting with different formats
    - (Done) Remove the code snippet to avoid unnecessary computations from
    procRawDataBatChargeSeqsStat.m and place it in miscPlotResults.m

- procGenerateIntervalConsistentDataRecord.m
    - (Done) Interpolate simulation results of all time granularities within
    the smallest time granularity to ease plotting their means and standard
    deviations in one elaborative graph
    - (Done)Plot the results with different, automatically chosen line styles

- expHMM.m:
    - (Done) The initial state distribution is dependent on the initial charge
    level
    - (Done) The number of simulations should be the same as number of instances
    in the original data set with the same battery charge level

- Missing value problem:
    - Fill the missing values with learned model

- Maybe sometime in the future:
    - (Done) Create a separate plot function that gets plot() arguments
    with the goal of making the code more readable (miscPlot.m)
%}