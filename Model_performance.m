
function Model_performance(cfg1,outputfile)
%Main function to run for the leaky integration model. 
%Model performance should be based on X trials with block conditions identical to those
%made by the participant.
%Needs to become a function to be ran per participant
tic

cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/All_behavior')




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


for allSessions=1:2
    
    if allSessions == 1 %load placebo
        load(cfg1.PLApath)

    else                %load atomoxetine
        load(cfg1.ATMpath)
        allMLE.PLA=modelChoiceP;
        choiceStreamPLA = choiceStreamAll;
        
        
    end
    
    
    %For the output choiceStreamAll, 0 is horizontal and 1 is vertical
    [choiceStreamAll,rewardStreamAll] = global_matching(results);
    
    Totaltrials=length(choiceStreamAll);%results.parameters.trlTotal;
    Totalblocks=length(results.blocks); %Changed 2/july
    
    %Pre-allocating matrices for optimality.
    mean_sq=zeros(1,length(cfg1.tau),cfg1.runs);
    mean_sqr=zeros(1,length(cfg1.tau),cfg1.runs);
    rewardCount=zeros(1,length(cfg1.tau),length(cfg1.beta),cfg1.runs);
    modelChoiceVerComp=zeros(1,Totaltrials,length(cfg1.tau));
    max_like=zeros(Totaltrials,length(cfg1.tau),length(cfg1.beta),cfg1.runs);
    
    %Function model_body does the model-specific computations.
    [rewardCount,modelChoiceP] = model_body( cfg1,results,choiceStreamAll,rewardStreamAll,rewardCount);
        
   
    
    %Calulate the mean of the square difference btw model and behvaior
%     mean_sqr=mean(mean_sqr,3);
%     mean_sqAll=mean(mean_sq,3);
%     
%     %Standard error measurement of the squared error between model
%     %choice and local income.
%     sem=zeros(1,length(cfg1.tau));
%     for itau=1:length(cfg1.tau)
%         sem(itau)=std(mean_sq(1,itau,:))/sqrt(length(mean_sq(1,itau,:))); %SEM
%     end
    
    
    %Finding the foraging efficiency of behavioral data. Why the need
    %for the if-else statement. Commented out for now.
%     totalReward=0;
%     for i = 1:Totalblocks
%         %            if i<Totalblocks
%         totalReward = totalReward + sum(results.blocks{i}.newrewardHor) + sum(results.blocks{i}.newrewardVer);
%         %             else
%         %                 totalReward = totalReward + sum(results.blocks{i}.newrewardHor(1:results.blocks{i}.trlinfo(end,1))) + sum(results.blocks{i}.newrewardVer(1:results.blocks{i}.trlinfo(end,1)));
%         %             end
%     end
    
    %Finding the total possible reward for simulated model data. Different runs
    %are ignored no?
%     totalCompReward=0;
%     try
%         for iC=1:length(resultsComp.blocks)
%             totalCompReward = totalCompReward + sum(resultsComp.blocks{iC}.newrewardHor) + sum(resultsComp.blocks{iC}.newrewardVer);
%         end
%     catch ME
%         aa=11; 
%     end
%     %Optimizing matrix
%     rewardDelivered=zeros(1,length(cfg1.tau),cfg1.runs);
%     
%     %Calculates reward delivered overall for model. ###Changed to totalComp
%     for runna=1:cfg1.runs
%         for rewDel=1:length(cfg1.tau)
%             rewardDelivered(1,rewDel,runna)= round(rewardCount(1,rewDel,runna)/totalCompReward*100);
%         end
%     end
    
    %Locates the lowest fitted tau.
 %   avgReward=min(mean(mean_sq(1,:,:),3));
    %Finds position of lowest tau.
    
%     
%     for eachrun=1:cfg1.runs
%         [~,lowTau]=min(mean_sq(1,:,eachrun));
%         lowTauAll(allSessions,eachrun)=cfg1.tau(lowTau);
%         
%         [~,maxDis]=max(prod(max_like(:,:,1,eachrun)));
%         maxTauAll(allSessions,eachrun)=cfg1.tau(maxDis);
%         
%         if lowTauAll(allSessions,eachrun)~=maxTauAll(allSessions,eachrun)
%             missm=missm+1;
%         end
%     end
%     
%     %lowTau=find(mean(mean_sq(1,:,:),3)==avgReward);
%     forEff=(results.blocks{i}.trlinfo(end)/totalReward)*100;
%     %lowTauAll(1,allSessions)=tau(lowTau);
%     forEffAll(1,allSessions)=forEff;
%     
%     %What is necessary for the plot? The average of the rewardDelivered for all
%     %sessions. Atm, it is doing it once per session.
%     allrun=cfg1.runs*numDelivered;
%     allDelivered(1,:,numVa:allrun)=rewardDelivered;
%     numVa=numVa+cfg1.runs;
%     numDelivered=numDelivered+1;
    
end


%plot(allSessions,mean(maxTauAll),'o')
allMLE.ATM = modelChoiceP;

choiceStreamATM = choiceStreamAll;

timeTaken=toc;
%Saving all the relevant data per participant.
save(outputfile,'allMLE','timeTaken','choiceStreamPLA','choiceStreamATM');%'maxTauAll','allMLE','forEffAll','allDelivered','missm','timeTaken')


disp('model done')
end

