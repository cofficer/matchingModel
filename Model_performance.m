

%Main script to run for the leaky integration model. 
%Model performance should be based on X trials with block conditions identical to those
%made by the participant.

clear 
warning ('off','MATLAB:warn_r14_stucture_assignment') 

cd('/Users/Christoffer/Dropbox/Data-sets-matching-task/HH_behavior')

%Choose which subject and session to analyse
subject         = 'JRu';
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
%currPart=partAll{whichPart};
%[ resultsAll ] = loadSessions( currPart(1,:),whichPart );

%Initial states ##MAIN PARAMETERS##
taulen  = 30;
betas   = 4;
%betas=linspace(1,10,10);
tau     = logspace(0,2.5,taulen);
%tau=linspace(1,15,taulen);
runs    = 1;
%What is the purpose of missm?
missm   = 0;
%number of participants
numParts= 1;

%Placeholders for storing foraging efficiency
numDelivered=1;
numVa=1;

%Preallocating: Stores the rewards delivered.
allDelivered=zeros(1,length(tau),runs+length(structfun(@numel,resultsAll)));
lowTauAll=zeros(1,length(structfun(@numel,resultsAll)),runs);
maxTauAll=zeros(1,length(structfun(@numel,resultsAll)),runs);
forEffAll=zeros(1,length(structfun(@numel,resultsAll)));
AUCAll=zeros(1,length(tau),length(structfun(@numel,resultsAll)));

%%
for allPart=1:numParts

for allSessions=1:1
    
    varSess=sprintf('sess%d',allSessions);
    results=resultsAll.(varSess);
    
    %For the output choiceStreamAll, 0 is horizontal and 1 is vertical
    [choiceStreamAll] = global_matching(results);
    
    Totaltrials=results.parameters.trlTotal;
    Totalblocks=length(results.blocks); %Changed 2/july
    
    %Pre-allocating matrices for optimality.
    mean_sq=zeros(1,length(tau),runs);
    mean_sqr=zeros(1,length(tau),runs);
    rewardCount=zeros(1,length(tau),length(betas),runs);
    modelChoiceVerComp=zeros(1,Totaltrials,length(tau));
    max_like=zeros(Totaltrials,length(tau),length(betas),size(mean_sq,3));
    
    %Function model_body does the model-specific computations.
    for runsi=1:runs
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
    for iC=1:length(resultsComp.blocks)
        totalCompReward = totalCompReward + sum(resultsComp.blocks{iC}.newrewardHor) + sum(resultsComp.blocks{iC}.newrewardVer);
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
        lowTauAll(1,allSessions,eachrun)=tau(lowTau);
        
        [~,maxDis]=max(prod(max_like(:,:,1,eachrun)));
        maxTauAll(1,allSessions,eachrun)=tau(maxDis);
        
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
end


disp('model done')
%%
%Save
%save('perfData.mat','allDelivered','runs','tau','Totalblocks','lowTauAll','forEffAll','results','AUCAll')

%initStates contain all single element values necessary for plots. 
initStates=[tau,runs,allSessions,blocklength];
cluster_plots(allDelivered,initStates,lowTauAll,forEffAll,results,AUCAll,currPart,maxTauAll);

% figure(6),clf
% plot(mean(prod(max_like),3))
% 
% plot((prod(max_like(:,:,1))))

%%
%This cell is meant to plot the different tau (optimal and best-fit for the same experiment as well as the generative process)
figure(1)

subplot(1,4,4)


%Best-fit
R = mean(mean(maxTauAll,2));

stdeBestfit=std(mean(maxTauAll,2),0,3)/(sqrt(length(maxTauAll)));

%Model optimal
[~,Q]=max(mean(allDelivered(1,:,:),3));
Q=tau(Q);

[~,indexModel]=max(mean(allDelivered(1,:,:),3));
[~,indexModelAll]=max(allDelivered);

%Standard deviation of model. Divided by two length because of the
%structure of allDelivered where runs and sessions and on same axis. 
stdeModel=std(tau(indexModelAll),0,3)/(sqrt(length(indexModelAll)/2));

%Making correct x-label

xlabTau=sprintf('Best-fit Optimal %d',blocklength);

%Plotting Best fit and model
%barweb([R Q ],[stdeBestfit stdeModel],[],xlabTau)

%Plotting only model
barweb([Q ],[ stdeModel],[],xlabTau)
ylim([0 14])

legend('best-fit','optimal')



%%
%Plot AUC against tau per participant. 

%The following for loop will plot a single participants AUC - tau
figure(1),clf
semilogx(tau,mean(AUCAll,3),'w')
hold on;

%[l,p]=boundedline(tau,squeeze(AUCAll(1,:,1)),zeros(size(tau)),'-g',tau,squeeze(AUCAll(1,:,2)),tau,squeeze(AUCAll(1,:,3)),zeros(size(tau)),'-b');
[l]=plot(tau,squeeze(AUCAll),'-g');
set(l(1),'Color','g')
set(l(2),'Color','r')
set(l(3),'Color','k')
legend(l,sprintf('block %d',currPart(2,1)),sprintf('block %d',currPart(2,2)),sprintf('block %d',currPart(2,3)))


ylabel('Area under the curve (ROC)')
xlabel('Tau parameter values')

%%
%Not sure about this celll.
blall=[30,50,70,100];
%This for loop loads previosly saved matrixes of ROC analyses for each
%block length. 
figure(2),clf
currcol=['r','k','b','m'];
for blocksl=1:4
    filname=sprintf('b%d.mat',blall(blocksl));
    blo=load(filname);
    filname=sprintf('b%d',blall(blocksl));
    blo=blo.(filname);
    semilogx(tau,mean(blo,3),currcol(blocksl))
    hold on;
    semBlo=std(blo,0,3)/sqrt(length(blo));
    %semBlo=semBlo.*rand(1,length(semBlo))>0.5;
    [hl,hp]=boundedline(tau,mean(blo,3),semBlo,sprintf('-%s',currcol(blocksl)),[],[],0.9);
    legend(hl,'b30')
    %errorbar(tau,mean(blo,3),semBlo,currcol(blocksl))
     % currcol=rand(1,3);
%  for sessio=1:size(blo,3)
%      %semilogx(tau,blo(:,:,sessio),currcol(blocksl))
%      hold on;
%      
%  end
end
legend(hl,'b30')
xlim([0,350])

%Saves different block lengths in AUC.
b100=AUCAll;
save('matrixAuc','matrixAuc','tau')


%%
%
%This for loop loads previosly saved matrixes of ROC analyses for each
%block length. Generates a plot showing all blocks at once using stored
%data.
blall=[30,50,70,100];
matrixAuc=zeros(1,length(tau),4);
semBloAll=zeros(1,length(tau),4);
tauAll=zeros(1,length(tau),4);
for blocksl=1:4
    filname=sprintf('b%d.mat',blall(blocksl));
    blo=load(filname);
    filname=sprintf('b%d',blall(blocksl));
    blo=blo.(filname);
    matrixAuc(1,:,blocksl)=mean(blo,3);
    semBlo=std(blo,0,3)/sqrt(length(blo));
    semBloAll(1,:,blocksl)=semBlo;
    tauAll(1,:,blocksl)=tau;
end

load('matrixAuc.mat')

figure(2),clf
semilogx(tau,squeeze(matrixAuc(1,:,1)),'r')
hold on;
%plot(tau,squeeze(matrixAuc))

[l,p]=boundedline(tau,squeeze(matrixAuc(1,:,1)),squeeze(semBloAll(1,:,1)),'-g',tau,squeeze(matrixAuc(1,:,2)),squeeze(semBloAll(1,:,2)),'-r',tau,squeeze(matrixAuc(1,:,3)),squeeze(semBloAll(1,:,3)),'-b',tau,squeeze(matrixAuc(1,:,4)),squeeze(semBloAll(1,:,4)),'-k');
%outlinebounds(l,p);
legend(l,'15-30','30-50','50-70','70-100')

ylabel('Area under the curve (ROC)')
xlabel('Tau parameter values')

