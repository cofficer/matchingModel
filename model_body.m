function [ rewardCount,max_like] = model_body( tau,results,choiceStreamAll,runsi,rewardCount,max_like)
%Function does almost all model related calculations. Quite complicated,%Removed output resultsComp
%perhaps unnecessarily so. 
%Takenout: mean_sq resultsComp

%%

Totaltrials=length(choiceStreamAll);
Totalblocks=length(results.blocks);

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

%Pre-allocating matrices for optimality.
modelChoiceVerComp=zeros(1,Totaltrials,length(tau));
localIncome_HorComp=zeros(1,Totaltrials,length(tau));
localIncome_VerComp=zeros(1,Totaltrials,length(tau));

%Range of beta values in grid search.
%betas=linspace(1,10,10);
betas=4;

for betaValue=1:length(betas)
    
    for tauer=1:length(tau)
        %Preset variables
        rewardStreamHorComp=0;
        rewardStreamVerComp=0;
        rewardStreamVerAllComp=1;
        rewardStreamHorAllComp=1;
        rewardHor=0;
        rewardVer=0;
        trialAll=1;
        
        for blocksi=1:Totalblocks
            %Parameters for this block
            if sim_data
                %Number of trials per block
                numtrials=ntrls(blocksi); 
                %Reward available from experimental structure.
                [newrewardHor, newrewardVer] = poissonReward(0.8, probHor(blocksi), numtrials,0);
                resultsComp.blocks{1,blocksi}.newrewardHor=newrewardHor;
                resultsComp.blocks{1,blocksi}.newrewardVer=newrewardVer;
            else
                numtrials=results.blocks{blocksi}.ntrls; %How many trials in one block, should be way more. Changed 2/July.
                %Reward available identical to participant.
                newrewardHor=results.blocks{1,blocksi}.newrewardHor; 
                newrewardVer=results.blocks{1,blocksi}.newrewardVer;
            end

            for trialsi=1:numtrials

                %Update rewards on target
                rewardHor = rewardHor+newrewardHor(trialsi);
                rewardVer = rewardVer+newrewardVer(trialsi);
                
                %For the first trial set the prior as 0.5 choice prob.
                %Another way could be to not count the first few trials
                %somehow. 
                if trialAll == 1
                    outputHor = 1;
                    outputVer = 1;
                else
                    
                    %Removing the NaNs
                    Verchoice = rewardStreamVerAllComp(~isnan(rewardStreamVerAllComp));
                    
                    %Removing the NaNs
                    Horchoice = rewardStreamHorAllComp(~isnan(rewardStreamHorAllComp));
                    
                    %Create filter
                    if sum(modelChoiceVerComp(1,2:trialAll,tauer)==0) > 0
                        xk = 1:length(Horchoice);
                        
                    else
                        xk = 1;
                    end
                    k = 1./(exp(-xk/tau(tauer))); % filter equation
                    if sum(modelChoiceVerComp(1,2:trialAll,tauer)==1) > 0
                        xl = 1:length(Verchoice);
                        
                    else
                        xl = 1;
                    end
                    l = 1./(exp(-xl/tau(tauer))); % filter equation
                    k = k/(sum(k));
                    
                    outputHor=Horchoice.*k;
                    
                    l=l/(sum(l));
                    
                    outputVer=Verchoice.*l;
                end
                
                localIncome_HorComp(1,trialAll,tauer)=sum(outputHor)/(sum(outputHor)+sum(outputVer));
                Horlast = localIncome_HorComp(1,1:trialAll,tauer);
                localIncome_VerComp(1,trialAll,tauer)=sum(outputVer)/(sum(outputHor)+sum(outputVer));
                Verlast = localIncome_VerComp(1,1:trialAll,tauer);
                
                diffValue=(localIncome_VerComp(1,trialAll,tauer))-(localIncome_HorComp(1,trialAll,tauer));
                probChoice=softmaxOwn(diffValue,betas);
                
                %modelChoiceVerComp(1,trialAll,tauer)=binornd(1,localIncome_VerComp(1,trialAll,tauer));
                modelChoiceVerComp(1,trialAll,tauer)=binornd(1,probChoice);
                
                %Checking if the model choice results in a reward
                %or not.
                if modelChoiceVerComp(1,trialAll,tauer) == 0 && rewardHor > 0 % Response Horizontal + reward avaiable Horizontal
                    rewardHor = 0;
                    rewardCount(1,tauer,betaValue,runsi) = rewardCount(1,tauer,betaValue,runsi) + 1;
                    
                    rewardStreamVerAllComp(trialAll+1)=NaN; %NaN
                    rewardStreamHorAllComp(trialAll+1)=1;
                    
                elseif modelChoiceVerComp(1,trialAll,tauer) == 1 && rewardVer > 0 % Response Vertical + reward avaiable Vertical
                    rewardVer = 0;
                    rewardCount(1,tauer,betaValue,runsi) = rewardCount(1,tauer,betaValue,runsi) + 1;
                    
                    rewardStreamVerAllComp(trialAll+1)=1;
                    rewardStreamHorAllComp(trialAll+1)=NaN; %NaN
                    
                    
                elseif modelChoiceVerComp(1,trialAll,tauer) == 0 && rewardHor == 0
                    
                    rewardStreamHorAllComp(trialAll+1)=0;
                    rewardStreamVerAllComp(trialAll+1)=NaN; %NaN
                    
                elseif modelChoiceVerComp(1,trialAll,tauer) == 1 && rewardVer == 0
                    
                    rewardStreamHorAllComp(trialAll+1)=NaN; %NaN
                    rewardStreamVerAllComp(trialAll+1)=0;
                    
                end
                
                
                if trialAll==101 && blocksi==3
                    a=1;
                end
                
                %This if-statement is to avoid issues arising due to
                %mismatch in length when running simulated data.
               % if trialAll<=length(choiceStreamAll)
                    l_i=localIncome_VerComp(1,trialAll,tauer);
                    max_like(trialAll,tauer,betaValue,runsi)=(l_i.^choiceStreamAll(1,trialAll)).*(1-l_i).^(1-choiceStreamAll(1,trialAll));
               % end
                trialAll=trialAll+1;
            end
        end
        
        
        
    end
end
end

