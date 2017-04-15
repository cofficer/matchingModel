function [ probChoice,LocalFract,cfg1 ] = pertrialLFI( results,nPart,cfg1)
%For each trial of each session calculate the local fractional income. 


%Is this already done through the model script. At least for the single
%parameter model. 

%Load the already acquired paramter fits per session. 
%load('paramFitsReal')

%Define what type of parameter fits to use.
optimal = 1;

if cfg1.numparameter=='3'
    cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/optimized/')
elseif cfg1.numparameter=='2'
    cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/2params/optimized')
elseif cfg1.numparameter=='1'    
    cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/1params/optimized')
end
load([results.subjName(1:3) '1.mat'])

%These are the relevant placebo fits. % Why loop an additional 
%for nfits = 1:length(paramFits.tauPLAfits)

%Using the parameter fit, calculate the per trial local fractional income.
%example
if optimal
    for istart = 1:30
        
        MLE (istart)   = optimizedFits(istart).MLE ;
        
        
    end
    %position of best fit out of 30 parameter starting points
    [v,pos]=min(MLE);
    
    %if there is more than one minimum value, pick the first one.
    if length(pos)>1
        pos=pos(1);
    end
    
    if cfg1.numparameter=='3'
        tau  = optimizedFits(pos).xbest(2);
        
        beta = optimizedFits(pos).xbest(1);
        
        ls = optimizedFits(pos).xbest(3);
        
    elseif cfg1.numparameter=='2'
        tau  = optimizedFits(pos).xbest(2);
        
        beta = optimizedFits(pos).xbest(1);
        
        ls = optimizedFits(pos).startfit(3);
        
    elseif cfg1.numparameter=='1'
        tau  = optimizedFits(pos).xbest(1);
        
        beta = optimizedFits(pos).startfit(1);
        
        ls = optimizedFits(pos).startfit(3);
    end
    
    
else
    tau  = paramFits.tauPLAfits;%(nPart);
    beta = paramFits.betaPLAfits;%(nPart);
    ls   = paramFits.lsPLAfits;
end
%Settings cfg1 for model_bodyK code
cfg1.tau  = tau;
cfg1.beta = beta; %Irrelevant, just single value for quick computation
cfg1.ls   = ls;
cfg1.simulate = 0; %Why as simulate on before?? makes no sense- 


%Get the choice and reward history
[choiceStreamAll,rewardStreamAll] = global_matchingK(results);
%By calling model_bodyK I can get the local fractional income per trial. 
[ probChoice,LocalFract,choiceStreamAll,rewardStreamAll] = model_bodyK( cfg1,results,choiceStreamAll,rewardStreamAll);

%Find trials where the choice was horizontal and take 1-localfractincome. 
indHor = choiceStreamAll==0;


probChoice(indHor)=1-probChoice(indHor);
LocalFract(indHor)=1-LocalFract(indHor);



end

