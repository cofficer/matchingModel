%Model_performance_plots

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