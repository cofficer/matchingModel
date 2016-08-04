
 
 
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

figure(1),clf
hold on;

%Each condition
at=squeeze(maxTauAll(:,2,:));
pl=squeeze(maxTauAll(:,1,:));

%Mean each condition
atAV=nanmean(at,2);
plAV=nanmean(pl,2);

bar([1 2],[nanmean(plAV) nanmean(atAV)]')

errorbar([1 2],[mean(plAV) mean(atAV)],[std(plAV) std(atAV)])

%barwitherr([std(atAV(1:end-1)) std(plAV)],[nanmean(atAV) nanmean(plAV)])


plot([1,2],[atAV plAV])
xlim([0.7 2.3])


%%
%Calulate maximulu likelihood estimation
%Load in all the parameters estimations for all participants and
%calculate the averages over all runs. 
clear
%Struct with all the trial likelihoods calculated. 
cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/results')
parts=dir('*.mat');

allParams=zeros(length(parts),2,2); %tau/beta, pla/atm. 1 tau, 1 pla

for ipart = 1:length(parts)
    
    load(parts(ipart).name)
    
    %Placebo
    plaMLE = allMLE.PLA;
    atmMLE = allMLE.ATM;
    
    if ipart == 1
        
        tableTBplaAll     = zeros(size(plaMLE,3),size(plaMLE,2),length(parts));
        
        
        tableTBatmAll     = zeros(size(plaMLE,3),size(plaMLE,2),length(parts));
    end
    
    
    tableTBpla     = zeros(size(plaMLE,3),size(plaMLE,2));
    
    
    tableTBatm     = zeros(size(plaMLE,3),size(plaMLE,2));
    
    
    for eachBeta = 1:size(plaMLE,3)
        for eachTau = 1:size(plaMLE,2)  
            
            
            
            %Calulate the log likelihood for placebo and atomoxetine.
            logLikelihoodPLA = -sum(log(binopdf(choiceStreamPLA,1,plaMLE(:,eachTau,eachBeta)'.*0.99)+0.005));
            
            logLikelihoodATM = -sum(log(binopdf(choiceStreamATM,1,atmMLE(:,eachTau,eachBeta)'.*0.99)+0.005));
            
            
            
            %Store all the likelihood in a matrix
            tableTBpla(eachBeta,eachTau) = logLikelihoodPLA;
            tableTBatm(eachBeta,eachTau) = logLikelihoodATM;
            
            
            
            
        end
    end
    tableTBplaAll(:,:,ipart) = tableTBpla;
    tableTBatmAll(:,:,ipart) = tableTBatm;
    
    
    %[valpla,indpla]=min(tableTBpla(:));
    %[rowpla,colpla]=ind2sub(size(tableTBpla),indpla);
    
    % currTauPla = linspace(2,10,20);
    % currTauPla=currTauPla(colpla);%cfg1{1}.tau(colpla);
    % currBetaPla =linspace(1,5,20);
    % currBetaPla=currBetaPla(rowpla); %cfg1{1}.beta(rowpla);
    %
    % [valatm,indatm]=max(tableTBatm(:));
    % [rowatm,colatm]=ind2sub(size(tableTBatm),indatm);
    %
    % currTauAtm = linspace(2,10,20);
    % currTauAtm=currTauAtm(colatm);%cfg1{1}.tau(colatm);
    % currBetaAtm =  linspace(1,5,20);
    % currBetaAtm=currBetaAtm(rowatm); %cfg1{1}.beta(rowatm)
    %
    % allParams(ipart,1,1) = currTauPla;
    % allParams(ipart,2,1) = currBetaPla;
    % allParams(ipart,1,2) = currTauAtm;
    % allParams(ipart,2,2) = currBetaAtm;
    %
    disp(ipart)
    
end

disp('done')
% % % % 
figure(1)
x=linspace(1,25,50);
y=linspace(0.01,3,50);
imagesc(x,y,nanmean(tableTBplaAll,3),[325 330])
%imagesc(mean(tableTBatmAll,3))
set(gca,'YDir','normal')
colorbar

% 
% 
% for ir = 1:200
% MLEpla(1,ir) = log(prod(plaMLE(:,2,2,ir)));
% end

%%
%plot(prod((mean(plaMLE(:,:,10,:),4)),1),'r')





figure(1),clf
hold on;

%Each condition
at=squeeze(allParams(:,1,2));
pl=squeeze(allParams(:,1,1));

%Mean each condition
atAV=nanmean(at,1);
plAV=nanmean(pl,1);

bar([1 2],[nanmean(plAV) nanmean(atAV)])

errorbar([1 2],[(plAV) (atAV)],[std(pl) std(at)])

%barwitherr([std(atAV(1:end-1)) std(plAV)],[nanmean(atAV) nanmean(plAV)])


plot([1,2],[pl at])
xlim([0.7 2.3])




%% Save figure, data
cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/TFGitAnlysis/figures')
print('paramSpaceLocalIncome','-depsc2')

csvwrite('both.csv',both)







