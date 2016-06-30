

%Main script to run for the leaky integration model. 
%Model performance should be based on X trials with block conditions identical to those
%made by the participant.

clear all
warning ('off','MATLAB:warn_r14_stucture_assignment') 

cd('/Users/Christoffer/Documents/MATLAB/matchingData/All_behavior')

load('/Users/Christoffer/Documents/MATLAB/matchingData/All_behavior/HRi_sess1_2015_8_15_13_44.mat')

%Choose which subject and session to analyse
npart         = 26; %How many participants. 
session         = 1; %Currently atomoxetine. 

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


cd('/Users/Christoffer/Documents/MATLAB/matchingData/All_behavior')

names=dir('*sess1*mat');

names=names(cell2mat({names.bytes})>5000);

names=names(1:npart); %npart decides how many sessions to loop


%Initial states ##MAIN PARAMETERS##
taulen  = 40;
betas   = 1;
%betas=linspace(1,10,10);
tau     = logspace(0,2.5,taulen);
%Linspace for now
tau=linspace(4,14,taulen);
runs    = 30;
%What is the purpose of missm?
missm   = 0;
%number of participants
numParts= 1;

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
    else
        
        currParticipant = ATM(allPart);
        
        load(currParticipant{1})
        
    end
    
    %Seems unneccessary. 
    %varSess=sprintf('sess%d',allSessions);
    %results=resultsAll.(varSess);
    
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
        [ mean_sq,rewardCount,localIncome_VerComp,modelChoiceVerComp,max_like,resultsComp] = model_body( tau,...
            results,choiceStreamAll,Totaltrials,Totalblocks,runsi,rewardCount,mean_sq,max_like);
        
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
    
    
    %COMMENTS: Try with ignoring some trials for fitting instead of assumptions. ROC analysis.
    %Inserted ROC analysis
    
    if rocanalysis==1
        for tauer=1:length(tau)
            [ AUCroc ] = rocAnalysis( localIncome_VerComp, choiceStreamAll , modelChoiceVerComp,tauer);
            AUCAll(1,tauer,allSessions)=AUCroc;
        end
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
        lowTauAll(npart,allSessions,eachrun)=tau(lowTau);
        
        [~,maxDis]=max(prod(max_like(:,:,1,eachrun)));
        maxTauAll(npart,allSessions,eachrun)=tau(maxDis);
        
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


%%


mean_sqAll=mean(mean_sq,3);
std_mean_sqAll = std(squeeze(mean_sq)')./sqrt(runs);

figure(3),clf
hold on
for ina=1:runs
semilogx(tau,mean_sq(1,:,ina))
title('Model fit of tau to behavioral data')
xlabel('Values of the single model parameter Tau')
ylabel('Mean squared error')
end
errorbar(tau,mean_sqAll,std_mean_sqAll, 'r', 'linewidth', 3);
set(gca, 'xscale', 'log')

%%
%Plot the average tau comparing atomoxetine and placebo. 

%Each condition
at=squeeze(maxTauAll(:,2,:));
pl=squeeze(maxTauAll(:,1,:));

%Mean each condition
atAV=mean(at,2);
plAV=mean(pl,2);

bar([1 2],[atAV plAV]')

