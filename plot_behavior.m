
 


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
    
   
    disp(ipart)
    
end

disp('done')
% % % % 
figure(1)
x=linspace(0.01,20,100);
y=linspace(0.01,3,100);
imagesc(x,y,nanmean(tableTBplaAll,3),[300 320])
%imagesc(mean(tableTBatmAll,3))
set(gca,'YDir','normal')
colorbar





%% Save figure, data
cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/TFGitAnlysis/figures')
print('paramSpaceLocalIncome','-depsc2')

csvwrite('both.csv',both)







