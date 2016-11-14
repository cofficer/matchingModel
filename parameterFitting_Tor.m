

function parameterFitting_Tor(cfg1)
%
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% %Main script for submitting session AWi/20151007 for parameter fits. 
% %Edit: Has now been repurposed for all sessions using changes from Kostis.
% %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
%tic

outputfile = cfg1.outputfile ;

%Look at order or look at intervention
%prompt = 'Sort sessions in order of intervention? ';
%drugEffect = input(prompt); %1 for drugeffect, 0 for order.


%Look at simulated lose switch or actual behavior
%prompt = 'Simulated data with lose switch heuristic? ';
%simulateLoseSwitch = input(prompt); %1 for simulated data, 0 for actual b.


%Find the behavioral data. 

%dataPath = '/Users/Christoffer/Documents/MATLAB/ModelCode/Results/participantData/';

%cd(dataPath)
%participantPath = dir('*mat');

%%8

doPlot =0;

%if doPlot == 1
%Initialize figure
%h = figure(1); set(h,'position',[10 60 400 400 ],'Color','w'); 
%hold on; box off; 
%end

%plotNumber = 1;


%Figure out which session is placebo and which is atomoxetine.
%[ PLA,ATM ] = loadSessions(setting);

%Remove two participants, JRU and MGO
%Remove participants post-hoc, nr 20, 24
%PLA{20}=[];PLA{24}=[];
%PLA=PLA(~cellfun('isempty',PLA));
%ATM=PLA(~cellfun('isempty',PLA));



%Loop over all participants
%for AllPart = 1:setting.numParticipants

%Define cfg settings
%cfg1.beta                   = setting.beta;
%cfg1.tau                    = setting.tau;
%cfg1.ls                     = setting.ls;
%cfg1.runs                   = 1; %Irrelevant
%cfg1.session                = 'AWi/20151007';
%cfg1.simulateLoseSwitch     = simulateLoseSwitch; %1 for yes, 0 for no. 
%cfg1.drugEffect             = drugEffect;
%cfg1.numparameter           = setting.modeltype;
%Structure data in order of sessions
% if cfg1.drugEffect
%     cfg1.ATMpath                = strcat(dataPath,participantPath(AllPart*2).name);
%     cfg1.PLApath                = strcat(dataPath,participantPath(AllPart*2-1).name);
% %Structure data in order of intervention
% else
%     cfg1.ATMpath                = strcat(dataPath,ATM{AllPart});
%     cfg1.PLApath                = strcat(dataPath,PLA{AllPart});
% end
%Define output folder
%outputfile                  = '';

%Run model
%cfg1.AllPart = AllPart;
[allMLE,choiceStreamATM,choiceStreamPLA] = Model_performanceK(cfg1,outputfile);


%%
%Plot the parameter space figures for ATM and PLA sessions 
    
%Placebo
plaMLE = allMLE.PLA;
%Atomoxetine
atmMLE = alqlMLE.ATM;

%Matrix for all parameter values
%if AllPart==1;
    tableTBplaAll     = zeros(size(plaMLE,3),size(plaMLE,2),size(plaMLE,4));
    tableTBatmAll     = zeros(size(plaMLE,3),size(plaMLE,2),size(plaMLE,4));
%end

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
tableTBplaAll(:,:,:) = tableTBpla;
tableTBatmAll(:,:,:) = tableTBatm;

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








%end

%%
%Get the actual parameter fits for each session
paramINDatm     = zeros(size(tableTBatmAll,4),3); %need 3 instead of 2. 
paramINDpla     = zeros(size(tableTBatmAll,4),3);


%Loop over all participants
%for iP = 1:size(tableTBatmAll,4)
    
    %Find the paramter indices for each participant 
    
    atmMLE      = tableTBatmAll(:,:,:);
    plaMLE      = tableTBplaAll(:,:,:);
    
    paramVALatm = min(atmMLE(:)); 
    paramVALpla = min(plaMLE(:));
    
    
    [paramROWatm,paramCOLatm,paramZatm] = ind2sub(size(atmMLE),find(atmMLE==paramVALatm)); 
    [paramROWpla,paramCOLpla,paramZpla] = ind2sub(size(atmMLE),find(plaMLE==paramVALpla)); 
    
    %Store the indices in 3d matrix
    paramINDatm(:)           = [paramROWatm,paramCOLatm,paramZatm];
    paramINDpla(:)           = [paramROWpla,paramCOLpla,paramZpla];
    
%end


%Store the tau parameter fits using the index. 
paramFits.tauATMfits = cfg1.tau(paramINDatm(:,2)); 
paramFits.tauPLAfits = cfg1.tau(paramINDpla(:,2)); 

%Store the beta parameter fits using the index. 
paramFits.betaATMfits = cfg1.beta(paramINDatm(:,1)); 
paramFits.betaPLAfits = cfg1.beta(paramINDpla(:,1)); 

%Store the lose-switch parameter fits using the index
paramFits.lsATMfits = cfg1.ls(paramINDatm(:,3)); 
paramFits.lsPLAfits = cfg1.ls(paramINDpla(:,3)); 

disp('Paramater fits are stored!')
%allMLE
%paramFits
%timeTaken=toc;

save(outputfile,'allMLE','choiceStreamPLA','choiceStreamATM','paramFits');

end

