
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% %Main script for submitting session AWi/20151007 for parameter fits. 
% %Edit: Has now been repurposed for all sessions using changes from Kostis.
% %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 


clear all;


%Find the behavioral data. 

dataPath = '/Users/Christoffer/Documents/MATLAB/ModelCode/Results/participantData/';

cd(dataPath)
participantPath = dir('*mat');

%%8

doPlot =0;

if doPlot == 1
%Initialize figure
h = figure(1); set(h,'position',[10 60 400 400 ],'Color','w'); 
hold on; box off; 
end

plotNumber = 1;


%Figure out which session is placebo and which is atomoxetine.
[ PLA,ATM ] = loadSessions;

%Look at order or look at intervention
order = 0; %1 for intervention, 0 for order.

%Loop over all participants
for AllPart = 1:10;%length(participantPath)/2

%Define cfg settings
cfg1.beta                   = linspace(.1,1,100);
cfg1.tau                    = linspace(1,20,100);
cfg1.runs                   = 1; %Irrelevant
cfg1.session                = 'AWi/20151007';
cfg1.simulateLoseSwitch     = 1; %1 for yes, 0 for no. 
%Structure data in order of sessions
if order
    cfg1.ATMpath                = strcat(dataPath,participantPath(AllPart*2).name);
    cfg1.PLApath                = strcat(dataPath,participantPath(AllPart*2-1).name);
%Structure data in order of intervention
else
    cfg1.ATMpath                = strcat(dataPath,ATM{AllPart});
    cfg1.PLApath                = strcat(dataPath,PLA{AllPart});
end
%Define output folder
outputfile                  = '';

%Run model
[allMLE,choiceStreamATM,choiceStreamPLA] = Model_performanceK(cfg1,outputfile);


%%
%Plot the parameter space figures for ATM and PLA sessions 
    
%Placebo
plaMLE = allMLE.PLA;
%Atomoxetine
atmMLE = allMLE.ATM;

%Matrix for all parameter values
if AllPart==1;
    tableTBplaAll     = zeros(size(plaMLE,3),size(plaMLE,2),7);
    tableTBatmAll     = zeros(size(plaMLE,3),size(plaMLE,2),7);
end

%Matrix per participant
tableTBpla     = zeros(size(plaMLE,3),size(plaMLE,2));
tableTBatm     = zeros(size(plaMLE,3),size(plaMLE,2));

%Loop over both parameters
for eachBeta = 1:size(plaMLE,3)
    for eachTau = 1:size(plaMLE,2)
        
        
        
        %Calulate the log likelihood for placebo and atomoxetine.
        logLikelihoodPLA = -sum(log(binopdf(choiceStreamPLA,1,plaMLE(:,eachTau,eachBeta)'.*0.99+0.005)));
        logLikelihoodATM = -sum(log(binopdf(choiceStreamATM,1,atmMLE(:,eachTau,eachBeta)'.*0.99+0.005)));
        
        %Store all the log likelihood estimations 
        tableTBpla(eachBeta,eachTau) = logLikelihoodPLA;
        tableTBatm(eachBeta,eachTau) = logLikelihoodATM;
        

    end
end

%Insert MLE into larger matrix
tableTBplaAll(:,:,AllPart) = tableTBpla;
tableTBatmAll(:,:,AllPart) = tableTBatm;

%Plot current participant
if doPlot==1
    disp('done')
    % % % %
    subplot(7,2,plotNumber*2)
    %figure(1),clf
    
    x=cfg1.tau;
    y=cfg1.beta;
    imagesc(x,y,nanmean(tableTBplaAll,3))
    %imagesc(mean(tableTBatmAll,3))
    set(gca,'YDir','normal')
    colorbar
    ntitle(participantPath(AllPart*2-1).name(1:9),'location','northeast','fontsize',10,'edgecolor','k');
    % % % %
    subplot(7,2,plotNumber*2-1)
    %figure(2),clf
    
    x=cfg1.tau;
    y=cfg1.beta;
    imagesc(x,y,nanmean(tableTBatmAll,3))
    %imagesc(mean(tableTBatmAll,3))
    set(gca,'YDir','normal')
    colorbar
    ntitle(participantPath(AllPart*2).name(1:9),'location','northeast','fontsize',10,'edgecolor','k');
    
    plotNumber = plotNumber+1;

end








end

%%
%Plot single or average participant on a line plot of MLE for one
%session-type

h=figure(1);clf;
hold on;box off;
set(h,'position',[10 60 1280 800 ],'Color','w'); 

x=cfg1.tau;
y=cfg1.beta;
for i = 1:size(tableTBplaAll,3)
plot((tableTBplaAll(:,:,i)))
end
%imagesc(mean(tableTBatmAll,3))
ntitle(participantPath(AllPart*2-1).name(1:9),'location','northeast','fontsize',10,'edgecolor','k');
set(gca,'XTick',[11,21,31,41,51,61,71] );
set(gca,'XTickLabel',cfg1.tau([11,21,31,41,51,61,71]) );


title('Maximum likelihood estimation','FontSize',20)
xlabel('tau parameter values','FontSize',15)
legend
%ylabel

%%
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
%Plot a bar plot including all participants of the tau and beta double parameter
%model. Originally made 8th September 2016. 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

paramINDatm     = zeros(size(tableTBatmAll,3),2);
paramINDpla     = zeros(size(tableTBatmAll,3),2);


%Loop over all participants
for iP = 1:size(tableTBatmAll,3)
    
    %Find the paramter indices for each participant 
    
    atmMLE      = tableTBatmAll(:,:,iP);
    plaMLE      = tableTBplaAll(:,:,iP);
    
    paramVALatm = min(atmMLE(:)); 
    paramVALpla = min(plaMLE(:));
    
    
    [paramROWatm,paramCOLatm] = find(atmMLE==paramVALatm); 
    [paramROWpla,paramCOLpla] = find(plaMLE==paramVALpla); 
    
    %Store the indices in 3d matrix
    paramINDatm(iP,:)           = [paramROWatm,paramCOLatm];
    paramINDpla(iP,:)           = [paramROWpla,paramCOLpla];
    
end


%Store the tau parameter fits using the index. 
tauATMfits = cfg1.tau(paramINDatm(:,2)); 
tauPLAfits = cfg1.tau(paramINDpla(:,2)); 

%Store the beta parameter fits using the index. 
betaATMfits = cfg1.beta(paramINDatm(:,1)); 
betaPLAfits = cfg1.beta(paramINDpla(:,1)); 

%%
%Create barplot with individual data for beta.
h=figure(2);
clf;hold on;box off;

set(h,'position',[10 60 1280 800 ],'Color','w'); 


bar([mean(betaPLAfits),mean(betaATMfits)])

errorbar([1 2],[mean(betaPLAfits) mean(betaATMfits)],[std(betaPLAfits)/sqrt(length(betaPLAfits)) std(betaATMfits)/sqrt(length(betaATMfits))],'color','k')
x=cfg1.tau;
y=cfg1.beta;
%plot(nanmean(tableTBplaAll,3))
%imagesc(mean(tableTBatmAll,3))
%ntitle('Bar plot of placebo and ATM','location','northeast','fontsize',10,'edgecolor','k');
set(gca,'XTick',[1,2] );
set(gca,'XTickLabel',{'1st ','2nd'} );
set(gca,'fontsize',14);
title('Parameter fits compared between session order','FontSize',20)
ylabel('beta parameter values','FontSize',15)
%xlabel('First session and second session')


plot([squeeze(betaPLAfits)' squeeze(betaATMfits)']')


%%
%Create barplot with individual data for tau.
h=figure(2);
clf;hold on;box off;

set(h,'position',[10 60 1280 800 ],'Color','w'); 


bar([mean(tauPLAfits),mean(tauATMfits)])

errorbar([1 2],[mean(tauPLAfits) mean(tauATMfits)],[std(tauPLAfits)/sqrt(length(tauPLAfits)) std(tauATMfits)/sqrt(length(tauATMfits))],'color','k')
x=cfg1.tau;
y=cfg1.beta;
%plot(nanmean(tableTBplaAll,3))
%imagesc(mean(tableTBatmAll,3))
%ntitle('Bar plot of placebo and ATM','location','northeast','fontsize',10,'edgecolor','k');
set(gca,'XTick',[1,2] );
set(gca,'XTickLabel',{'1st ','2nd'} );
set(gca,'fontsize',14);
title('Maximum likelihood estimation over sessions','FontSize',20)
ylabel('tau parameter values','FontSize',15)
%xlabel('First session and second session')


plot([squeeze(tauPLAfits)' squeeze(tauATMfits)']')

%%
%Indexing the position of best fit tau for single parameter model
%Plot a bar plot including all participants of the tau parameter single
%model.


[~,minMLEpla]       = min(tableTBplaAll);

[~,minMLEatm]       = min(tableTBatmAll);

%Store the parameter fits using the index. 
tauPLAfits = cfg1.tau(minMLEpla); 
tauATMfits = cfg1.tau(minMLEatm); 

maxFit = 30;

%Remove all the sessions with maxiumum fits.
tauPLA = tauPLAfits(((tauPLAfits<maxFit)+(tauATMfits<maxFit))>1);
tauATM = tauATMfits(((tauPLAfits<maxFit)+(tauATMfits<maxFit))>1);
 
 
plaDiscriptives = [mean(tauPLA),std(tauPLA)/sqrt(length(tauPLA))];
atmDiscriptives = [mean(tauATM),std(tauATM)/sqrt(length(tauATM))];

%Create barplot with individual data.
h=figure(3);
clf;hold on;box off;

set(h,'position',[10 60 1280 800 ],'Color','w'); 

%barwitherr([plaDiscriptives(2) atmDiscriptives(2)],[plaDiscriptives(1) atmDiscriptives(1)])

bar([plaDiscriptives(1) atmDiscriptives(1)])
errorbar([1 2],[plaDiscriptives(1) atmDiscriptives(1)],[plaDiscriptives(2) atmDiscriptives(2)],'color','k')
x=cfg1.tau;
y=cfg1.beta;
%plot(nanmean(tableTBplaAll,3))
%imagesc(mean(tableTBatmAll,3))
%ntitle('Bar plot of placebo and ATM','location','northeast','fontsize',10,'edgecolor','k');
set(gca,'XTick',[1,2] );
set(gca,'XTickLabel',{'1st ','2nd'} );
set(gca,'fontsize',14);
title('Maximum likelihood estimation over sessions','FontSize',20)
ylabel('tau parameter values','FontSize',15)
%xlabel('First session and second session')


plot([squeeze(tauPLA)' squeeze(tauATM)']')




%%
cd('/Users/Christoffer/Documents/MATLAB/ModelCode/Results/')
print('MLEbarPlotOrderEffectBETA','-dpdf')

