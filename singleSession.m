

%Main script for submitting session AWi/20151007 for parameter fits.
%clear all;
%Define cfg settings
cfg1.tau                   = linspace(1,20,20);
cfg1.beta                    = linspace(0.01,1,20);
cfg1.runs                   = 1; %Irrelevant
cfg1.session                = 'AWi/20151007';
cfg1.ATMpath                = '/Users/Christoffer/Documents/MATLAB/ModelCode/Results/HJu_sess1_2015_10_4_15_4.mat';
cfg1.PLApath                = '/Users/Christoffer/Documents/MATLAB/ModelCode/Results/HJu_sess2_2015_10_10_16_0.mat';

%Define output folder
outputfile                  = '/mnt/homes/home024...';

%Run model
[allMLE,choiceStreamATM,choiceStreamPLA] = Model_performance(cfg1,outputfile);


%%
%Plot the parameter fit figures for ATM and PLA sessions 
for ipart = 1:length(1)
    
    
    %Placebo
    plaMLE = allMLE.PLA;
    atmMLE = allMLE.ATM;
    
    if ipart == 1
        
        tableTBplaAll     = zeros(size(plaMLE,3),size(plaMLE,2),1);
        
        
        tableTBatmAll     = zeros(size(plaMLE,3),size(plaMLE,2),1);
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
figure(1),clf
x=cfg1.tau;
y=cfg1.beta;
imagesc(x,y,(tableTBplaAll),[260 300])
%imagesc(mean(tableTBatmAll,3))
set(gca,'YDir','normal')
colorbar

% % % % 
figure(2),clf
x=cfg1.tau;
y=cfg1.beta;
imagesc(x,y,(tableTBatmAll),[260 300])
%imagesc(mean(tableTBatmAll,3))
set(gca,'YDir','normal')
colorbar
