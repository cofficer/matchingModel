

%Main script to run for the leaky integration model. 
%Model performance should be based on X trials with block conditions identical to those
%made by the participant.
%Needs to become a function to be ran per participant

clear all
warning ('off','MATLAB:warn_r14_stucture_assignment') 

cd('/Users/Christoffer/Documents/MATLAB/matchingData/All_behavior')


%Choose numer of participants to analyse, current max 31. 
npart         = 31; %How many participants. 

%Define the block lengths that will be used.    
blocklength     = 30;
%Turn on/off ROC analysis
rocanalysis     = 0;
%Turn on/off participant analysis
partlys         = 0;
%Specify which participant, irrelevant if partlys off
whichPart       = 5;

%The code was written for comparing block lengths. 
%But is needs to compare other things. Need to be dynamic. 


%Picks the current session type.
%blocklengthMax=allBlockLengths(allBlocks); %Block length not relevant anymore.

%Picks the current participant if analysis based on single individual
%currPart=subject;
%namesPart = loadSessions( npart );


%Get the sorted atomoxetine and placebo sessions:
[ PLA,ATM ] = loadSessions();


%Load in all .mat files to analyze order effect
names=dir('*_*.mat');


%Initial states ##MAIN PARAMETERS##
taulen  = 101;
betas   = 1;
%betas=linspace(1,10,10);
tau     = logspace(0,2.5,taulen);
%Linspace for now
tau=linspace(4,14,taulen);
runs    = 1;
%What is the purpose of missm?
missm   = 0;


%Placeholders for storing foraging efficiency
numDelivered=1;
numVa=1;

% %Preallocating: Stores the rewards delivered.
% allDelivered=zeros(1,length(tau),runs+length(structfun(@numel,resultsAll)));
% lowTauAll=zeros(1,length(structfun(@numel,resultsAll)),runs);
% maxTauAll=zeros(1,length(structfun(@numel,resultsAll)),runs);
% forEffAll=zeros(1,length(structfun(@numel,resultsAll)));
% AUCAll=zeros(1,length(tau),length(structfun(@numel,resultsAll)));


%%
for allPart=1:npart

for allSessions=1:2
    
    if allSessions == 1 %load placebo
        
        currParticipant = PLA(allPart);
        
        load(currParticipant{1})
        %load(names(allPart*2-1).name)
    else
        
        currParticipant = ATM(allPart);
        
        load(currParticipant{1})
        %load(names(allPart*2).name)
        
    end
    
    
    %For the output choiceStreamAll, 0 is horizontal and 1 is vertical
    [choiceStreamAll] = global_matching(results);
    
    Totaltrials=length(choiceStreamAll);%results.parameters.trlTotal;
    Totalblocks=length(results.blocks); %Changed 2/july
    
    %Pre-allocating matrices for optimality.
    mean_sq=zeros(1,length(tau),runs);
    mean_sqr=zeros(1,length(tau),runs);
    rewardCount=zeros(1,length(tau),length(betas),runs);
    modelChoiceVerComp=zeros(1,Totaltrials,length(tau));
    max_like=zeros(Totaltrials,length(tau),length(betas),size(mean_sq,3));
    
    %Function model_body does the model-specific computations.
    for runsi=1:runs
        if mod(runsi,10)==1;
            fprintf('\n%d',runsi)
        else
            fprintf('.')
        end
        [rewardCount,max_like] = model_body( tau,results,choiceStreamAll,runsi,rewardCount,max_like);
        
    end
    
    %Calulate the mean of the square difference btw model and behvaior
    mean_sqr=mean(mean_sqr,3);
    mean_sqAll=mean(mean_sq,3);
    
    %Standard error measurement of the squared error between model
    %choice and local income.
    sem=zeros(1,length(tau));
    for itau=1:length(tau)
        sem(itau)=std(mean_sq(1,itau,:))/sqrt(length(mean_sq(1,itau,:))); %SEM
    end
    
    
    %Finding the foraging efficiency of behavioral data. Why the need
    %for the if-else statement. Commented out for now.
    totalReward=0;
    for i = 1:Totalblocks
        %            if i<Totalblocks
        totalReward = totalReward + sum(results.blocks{i}.newrewardHor) + sum(results.blocks{i}.newrewardVer);
        %             else
        %                 totalReward = totalReward + sum(results.blocks{i}.newrewardHor(1:results.blocks{i}.trlinfo(end,1))) + sum(results.blocks{i}.newrewardVer(1:results.blocks{i}.trlinfo(end,1)));
        %             end
    end
    
    %Finding the total possible reward for simulated model data. Different runs
    %are ignored no?
    totalCompReward=0;
    try
        for iC=1:length(resultsComp.blocks)
            totalCompReward = totalCompReward + sum(resultsComp.blocks{iC}.newrewardHor) + sum(resultsComp.blocks{iC}.newrewardVer);
        end
    catch ME
        aa=11; 
    end
    %Optimizing matrix
    rewardDelivered=zeros(1,length(tau),runs);
    
    %Calculates reward delivered overall for model. ###Changed to totalComp
    for runna=1:runs
        for rewDel=1:length(tau)
            rewardDelivered(1,rewDel,runna)= round(rewardCount(1,rewDel,runna)/totalCompReward*100);
        end
    end
    
    %Locates the lowest fitted tau.
    avgReward=min(mean(mean_sq(1,:,:),3));
    %Finds position of lowest tau.
    
    
    for eachrun=1:runs
        [~,lowTau]=min(mean_sq(1,:,eachrun));
        lowTauAll(allPart,allSessions,eachrun)=tau(lowTau);
        
        [~,maxDis]=max(prod(max_like(:,:,1,eachrun)));
        maxTauAll(allPart,allSessions,eachrun)=tau(maxDis);
        
        if lowTauAll(1,allSessions,eachrun)~=maxTauAll(1,allSessions,eachrun)
            missm=missm+1;
        end
    end
    
    %lowTau=find(mean(mean_sq(1,:,:),3)==avgReward);
    forEff=(results.blocks{i}.trlinfo(end)/totalReward)*100;
    %lowTauAll(1,allSessions)=tau(lowTau);
    forEffAll(1,allSessions)=forEff;
    
    %What is necessary for the plot? The average of the rewardDelivered for all
    %sessions. Atm, it is doing it once per session.
    allrun=runs*numDelivered;
    allDelivered(1,:,numVa:allrun)=rewardDelivered;
    numVa=numVa+runs;
    numDelivered=numDelivered+1;
    
end
disp('One participant down')

%plot(allSessions,mean(maxTauAll),'o')


end


disp('model done')


