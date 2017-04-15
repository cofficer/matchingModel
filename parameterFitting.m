

function [ paramFits, cfg1, PLA, ATM] = parameterFitting(setting)
%
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% %Main script for submitting session AWi/20151007 for parameter fits. 
% %Edit: Has now been repurposed for all sessions using changes from Kostis.
% %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 




%Look at order or look at intervention
prompt = 'Sort sessions in order of intervention? ';
drugEffect = input(prompt); %1 for drugeffect, 0 for order.


%Look at simulated lose switch or actual behavior
prompt = 'Simulated data with lose switch heuristic? ';
simulateLoseSwitch = input(prompt); %1 for simulated data, 0 for actual b.

%Use the already computed parameter fits?
prompt = 'Use the already computed parameter fits? ';
useParamFits = input(prompt); %1 for simulated data, 0 for actual b.


%Find the behavioral data. 

dataPath = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/All_behavior/';

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
[ PLA,ATM ] = loadSessions(setting);

%Remove two participants, JRU and MGO
%Remove participants post-hoc, nr 20, 24
%PLA{20}=[];PLA{24}=[];
PLA=PLA(~cellfun('isempty',PLA));
ATM=PLA(~cellfun('isempty',PLA));



%Loop over all participants
for AllPart = 1:setting.numParticipants

    
    if useParamFits
        
        currentParticipant = PLA{AllPart};
        
        currentParticipant = currentParticipant(1:3);
        
        load(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/%s.mat',currentParticipant))
        %Define cfg settings for PLA
        cfg1.beta                   = paramFits.betaPLAfits; %Load already defined fits.
        cfg1.tau                    = paramFits.tauPLAfits;
        cfg1.ls                     = paramFits.lsPLAfits;
        
    else
        
        %Define cfg settings
        cfg1.beta                   = setting.beta;
        cfg1.tau                    = setting.tau;
        cfg1.ls                     = setting.ls;
        
    end

cfg1.runs                   = 1; %Irrelevant
cfg1.simulate               = setting.simulate;
cfg1.session                = 'AWi/20151007';
cfg1.simulateLoseSwitch     = simulateLoseSwitch; %1 for yes, 0 for no. 
cfg1.drugEffect             = drugEffect;
cfg1.numparameter           = setting.modeltype;
%Structure data in order of sessions
if drugEffect
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
cfg1.AllPart = AllPart;
[allMLE,choiceStreamATM,choiceStreamPLA] = Model_performanceK(cfg1,outputfile);

if cfg1.simulate
    load(cfg1.PLApath)
    [choiceStreamAll,rewardStreamAll] = global_matchingK(results);
    choiceStreamPLA = choiceStreamAll;
    load(cfg1.ATMpath)
    [choiceStreamAll,rewardStreamAll] = global_matchingK(results);
    choiceStreamATM = choiceStreamAll;

end

%%
%Plot the parameter space figures for ATM and PLA sessions 
    
%Placebo
plaMLE = allMLE.PLA;
%Atomoxetine
atmMLE = allMLE.ATM;

%Matrix for all parameter values
if AllPart==1;
    tableTBplaAll     = zeros(size(plaMLE,3),size(plaMLE,2),size(plaMLE,4),setting.numParticipants);
    tableTBatmAll     = zeros(size(plaMLE,3),size(plaMLE,2),size(plaMLE,4),setting.numParticipants);
end

%Matrix per participant
tableTBpla     = zeros(size(plaMLE,3),size(plaMLE,2));
tableTBatm     = zeros(size(plaMLE,3),size(plaMLE,2));

%Loop over both parameters
for eachBeta = 1:size(plaMLE,3)
    for eachTau = 1:size(plaMLE,2)
        for eachLS = 1:size(plaMLE,4)
        
        
        
        %Calulate the log likelihood for placebo and atomoxetine.
        logLikelihoodPLA = -sum(log(binopdf(choiceStreamPLA,1,plaMLE(:,eachTau,eachBeta,eachLS)'.*0.99+0.005)));
        logLikelihoodATM = -sum(log(binopdf(choiceStreamATM,1,atmMLE(:,eachTau,eachBeta,eachLS)'.*0.99+0.005)));
        
        %Store all the log likelihood estimations 
        tableTBpla(eachBeta,eachTau,eachLS) = logLikelihoodPLA;
        tableTBatm(eachBeta,eachTau,eachLS) = logLikelihoodATM;
        
        end
    end
end

%Insert MLE into larger matrix
tableTBplaAll(:,:,:,AllPart) = tableTBpla;
tableTBatmAll(:,:,:,AllPart) = tableTBatm;

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
%Get the actual parameter fits for each session
paramINDatm     = zeros(size(tableTBatmAll,4),3); %need 3 instead of 2. 
paramINDpla     = zeros(size(tableTBatmAll,4),3);


%Loop over all participants
for iP = 1:size(tableTBatmAll,4)
    
    %Find the paramter indices for each participant 
    
    atmMLE      = tableTBatmAll(:,:,:,iP);
    plaMLE      = tableTBplaAll(:,:,:,iP);
    
    [paramVALatm, idxatm] = min(atmMLE(:)); 
    [paramVALpla, idxpla] = min(plaMLE(:));
    
    
    [paramROWatm,paramCOLatm,paramZatm] = ind2sub(size(atmMLE),idxatm); 
    [paramROWpla,paramCOLpla,paramZpla] = ind2sub(size(atmMLE),idxpla); 
    
    %Store the indices in 3d matrix
    paramINDatm(iP,:)           = [paramROWatm,paramCOLatm,paramZatm];
    paramINDpla(iP,:)           = [paramROWpla,paramCOLpla,paramZpla];
    
%end


%Store the tau parameter fits using the index. 
paramFits(iP).tauATMfits = cfg1.tau(paramINDatm(iP,2)); 
paramFits(iP).tauPLAfits = cfg1.tau(paramINDpla(iP,2)); 

%Store the beta parameter fits using the index. 
paramFits(iP).betaATMfits = cfg1.beta(paramINDatm(iP,1)); 
paramFits(iP).betaPLAfits = cfg1.beta(paramINDpla(iP,1)); 

%Store the lose-switch parameter fits using the index
paramFits(iP).lsATMfits = cfg1.ls(paramINDatm(iP,3)); 
paramFits(iP).lsPLAfits = cfg1.ls(paramINDpla(iP,3)); 

%paramFits(iP).name = 

end
disp('Paramater fits are stored!')
end

