function [ modelChoiceP] = model_body( cfg1,results,choiceStreamAll,rewardStreamAll)
%Function does almost all model related calculations. Quite complicated,%Removed output resultsComp
%perhaps unnecessarily so. 
%Takenout: mean_sq resultsComp

%%

Totaltrials=length(choiceStreamAll);
Totalblocks=length(results.blocks);

%modelChoiceP = zeros(Totaltrials,length(cfg1.tau),length(cfg1.beta));

%Simulation of reward stream:
sim_data=0;

if sim_data
    parameters.trlTotal     = 500;  % total number of trials in session
    parameters.trlPause     = 100;   % insert a break every x trials.
    parameters.blocklength  = results.parameters.blocklength; % range of number of trial before next block switch
    
    parameters.COD          = 0;    % COD = change-over delay: this means that there is no reward available on the forst trial after switching, to ensure mathcing behavior
    parameters.toneCounterBalance = 1; % 1: reward = high, 2: reward = low
    parameters.probabilities = [7/8, 5/6, 3/4, 1/2, 1/2, 1/4, 1/6, 1/8];
    
    % pre-dermine the number of trials per block, and total number of blocks
    ntrls = 0;
    while sum(ntrls)<=parameters.trlTotal
        dum = round((parameters.blocklength(2)-parameters.blocklength(1)).*rand(1)+parameters.blocklength(1));
        ntrls = [ntrls, dum];
    end
    ntrls = ntrls(2:end);
    ntrls(end) = parameters.trlTotal-sum(ntrls(1:end-1));
    nblocks = length(ntrls);
    
    % pre-dermine the probability ratio of rewards
    probHor = 0;
    while length(probHor)<=nblocks
        dum = Shuffle(parameters.probabilities);
        probHor = [probHor, dum];
    end
    probHor = probHor(2:nblocks+1);
    
    % some things to pre-allocate
    trlCount = 0;
    Totalblocks=nblocks;
    Totaltrials=parameters.trlTotal ;
else
    resultsComp=[]; %Just to avoid output error
end

%%
%Rest.
% 
% %Pre-allocating matrices for optimality.
% modelChoiceVerComp=zeros(1,Totaltrials,length(cfg1.tau));
% localIncome_HorComp=zeros(1,Totaltrials,length(cfg1.tau));
% localIncome_VerComp=zeros(1,Totaltrials,length(cfg1.tau));

%Range of beta values in grid search.



for betaValue=1:length(cfg1.beta)
    
    for tauer=1:length(cfg1.tau)
        %Preset variables
        Horchoice = [];
        Verchoice = [];
        startHor = false;
        startVer = false;
        %Allocating the variable that wont begin counting until model start.
        %startTrial = 1;

        
        for trialAll=1:Totaltrials
            
   
            %Seperate reward histories into hor and ver.
            %Horizontal == 0, vertical ==1
            if rewardStreamAll(trialAll) == 1 && choiceStreamAll(trialAll) == 0
                Horchoice = [Horchoice,1];
                Verchoice = [Verchoice,NaN];
                startHor = true;
            elseif rewardStreamAll(trialAll) == 0 && choiceStreamAll(trialAll) == 0
                Horchoice = [Horchoice,0];
                Verchoice = [Verchoice,NaN];
            elseif rewardStreamAll(trialAll) == 1 && choiceStreamAll(trialAll) == 1
                Verchoice = [Verchoice,1];
                Horchoice = [Horchoice,NaN];
                startVer = true;
            elseif rewardStreamAll(trialAll) == 0 && choiceStreamAll(trialAll) == 1
                Verchoice = [Verchoice,0];
                Horchoice = [Horchoice,NaN];
            end
            
            %Start model if both targets has recieved a reward
            %if startHor*startVer
                %Removing the NaNs
                Verchoice=Verchoice(~isnan(Verchoice));
                Horchoice=Horchoice(~isnan(Horchoice));
                
                %Create filter
                if sum(choiceStreamAll(1,1:trialAll)==0) > 0
                    xk = 1:length(Horchoice);
                    
                else
                    xk = 1;
                end
                k = 1./(exp(-xk/cfg1.tau(tauer))); % filter equation
                if sum(choiceStreamAll(1,1:trialAll)==1) > 0
                    xl = 1:length(Verchoice);
                    
                else
                    xl = 1;
                end
                l = 1./(exp(-xl/cfg1.tau(tauer))); % filter equation
                k = k/(sum(k));
                
                outputHor=Horchoice.*k;
                
                l=l/(sum(l));
                
                outputVer=Verchoice.*l;
                %  end
                
                %localIncome_HorComp(1,trialAll,tauer)=sum(outputHor)/(sum(outputHor)+sum(outputVer));
                localIncome_VerComp(1,trialAll,tauer)=sum(outputVer)/(sum(outputHor)+sum(outputVer));
                
                if isnan(localIncome_VerComp(1,trialAll,tauer))
                    localIncome_VerComp(1,trialAll,tauer)=0.5;
                end
                
                %diffValue=sum(outputVer)-sum(outputHor);%(localIncome_VerComp(1,trialAll,tauer))-(localIncome_HorComp(1,trialAll,tauer));
                
                
                probChoice=softmaxOwn([localIncome_VerComp(1,trialAll,tauer), 1-localIncome_VerComp(1,trialAll,tauer)],cfg1.beta(betaValue));
                
                %The probabiliy of choice per parameter pair and trial generated by the model
                modelChoiceP(trialAll,tauer,betaValue) = probChoice;%localIncome_VerComp(1,trialAll,tauer);
                
                %startTrial = startTrial+1;
                
    
                
                if trialAll==100
                    a=1;
                end
            
                
            %end
        end
        
        
        
        
    end
end
end

