function [ local_fracIncome ] = pertrialLFI( results,nPart)
%For each trial of each session calculate the local fractional income. 


%Is this already done through the model script. At least for the single
%parameter model. 

%Load the already acquired paramter fits per session. 
load('paramFitsReal')

%These are the relevant placebo fits. % Why loop an additional 
%for nfits = 1:length(paramFits.tauPLAfits)

%Using the parameter fit, calculate the per trial local fractional income.
%example
tau  = paramFits.tauPLAfits(nPart);
beta = paramFits.betaPLAfits(nPart);
%Settings cfg1 for model_bodyK code
cfg1.tau  = tau;
cfg1.beta = beta; %Irrelevant, just single value for quick computation
cfg1.numparameter = '2';


%Get the choice and reward history
[choiceStreamAll,rewardStreamAll] = global_matchingK(results);
%By calling model_bodyK I can get the local fractional income per trial. 
[ local_fracIncome] = model_bodyK( cfg1,results,choiceStreamAll,rewardStreamAll);



end

