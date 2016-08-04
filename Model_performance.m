
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
        
   
    
    
end


%plot(allSessions,mean(maxTauAll),'o')
allMLE.ATM = modelChoiceP;

choiceStreamATM = choiceStreamAll;

timeTaken=toc;
%Saving all the relevant data per participant.
save(outputfile,'allMLE','timeTaken','choiceStreamPLA','choiceStreamATM');%'maxTauAll','allMLE','forEffAll','allDelivered','missm','timeTaken')


disp('model done')
end

