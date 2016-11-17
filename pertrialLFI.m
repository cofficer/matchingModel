function [ local_fracIncome,cfg1 ] = pertrialLFI( results,nPart)
%For each trial of each session calculate the local fractional income. 


%Is this already done through the model script. At least for the single
%parameter model. 

%Load the already acquired paramter fits per session. 
%load('paramFitsReal')



cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits')

load([results.subjName(1:3) '.mat'])

%These are the relevant placebo fits. % Why loop an additional 
%for nfits = 1:length(paramFits.tauPLAfits)

%Using the parameter fit, calculate the per trial local fractional income.
%example
tau  = paramFits.tauPLAfits;%(nPart);
beta = paramFits.betaPLAfits;%(nPart);
ls   = paramFits.lsPLAfits;
%Settings cfg1 for model_bodyK code
cfg1.tau  = tau;
cfg1.beta = beta; %Irrelevant, just single value for quick computation
cfg1.ls   = ls;
cfg1.numparameter = '3';
cfg1.simulate = 0;

cfg1
%Get the choice and reward history
[choiceStreamAll,rewardStreamAll] = global_matchingK(results);
%By calling model_bodyK I can get the local fractional income per trial. 
[ local_fracIncome] = model_bodyK( cfg1,results,choiceStreamAll,rewardStreamAll);



end

