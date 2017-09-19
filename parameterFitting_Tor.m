

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
[allMLE,choiceStreamAll,rewardStreamAll] = Model_performanceK(cfg1);

if cfg1.simulate
    %Not sure what is meant by modelchoices.
    if ~cfg1.modelchoices
        load(cfg1.path)
        [choiceStreamAll,rewardStreamAll] = global_matchingK(results);
    end

end

%%
%Plot the parameter space figures for ATM and PLA sessions

if ~cfg1.modelchoices && ~cfg1.recover
    tableTBplaAll     = zeros(size(allMLE,3),size(allMLE,2),size(allMLE,4));

    choiceStreamAll=choiceStreamAll';


    %Matrix per participant
    tableTB     = zeros(size(allMLE,3),size(allMLE,2));
    %tableTBatm     = zeros(size(plaMLE,3),size(plaMLE,2));

    %Loop over both parameters
    for eachBeta = 1:size(allMLE,3)
        for eachTau = 1:size(allMLE,2)
            for eachLS = 1:size(allMLE,4)



                %Calulate the log likelihood for placebo and atomoxetine.
                logLikelihood = -sum(log(binopdf(choiceStreamAll,1,allMLE(:,eachTau,eachBeta,eachLS)'.*0.99+0.005)));
                %   logLikelihoodATM = -sum(log(binopdf(choiceStreamATM,1,atmMLE(:,eachTau,eachBeta,eachLS)'.*0.99+0.005)));

                %Store all the log likelihood estimations
                tableTB(eachBeta,eachTau,eachLS) = logLikelihood;
                %      tableTBatm(eachBeta,eachTau,eachLS) = logLikelihoodATM;

            end
        end
    end

    %Insert MLE into larger matrix
    tableTBAll(:,:,:) = tableTB;
    %tableTBatmAll(:,:,:) = tableTBatm;

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



    %%
    %Get the actual parameter fits for each session
    paramIND     = zeros(cfg1.bestfits,3); %need 3 instead of 2.

    %Find the paramter indices for each participant
    MLE      = tableTBAll(:,:,:);

    %Vectorize matrix:
    MLE_vector = MLE(:);

    %Loop the number of best fit parameter pairs are needed
    for iparamPairs = 1:cfg1.bestfits

        [paramVAL, idx] = min(MLE_vector);
        %[paramVALpla, idxpla] = min(plaMLE_vector);

        %Insert NaNs where the best fit was previously
        MLE_vector(idx) =NaN;
        %plaMLE_vector(idxpla) =NaN;

        %Find the position in the 3d matrix of each best fit pair.
        [paramROW,paramCOL,paramZ] = ind2sub(size(MLE),idx);
        %[paramROWpla,paramCOLpla,paramZpla] = ind2sub(size(atmMLE),idxpla);

        %Store the indices in 3d matrix
        paramIND(iparamPairs,:)           = [paramROW,paramCOL,paramZ];
        %paramINDpla(iparamPairs,:)           = [paramROWpla,paramCOLpla,paramZpla];

    end

    %Store the tau parameter fits using the index.
    paramFits.taufits = cfg1.tau(paramIND(:,2));

    %Store the beta parameter fits using the index.
    paramFits.betafits = cfg1.beta(paramIND(:,1));

    %Store the lose-switch parameter fits using the index
    paramFits.lsfits = cfg1.ls(paramIND(:,3));

    disp('Paramater fits are stored!')


    save(outputfile,'allMLE','choiceStreamAll','paramFits','-v7.3');


else%Save all the choice from all the runs.

    %Find the best parameters for the model simulations.
    if cfg1.recover

        %Store the original model predictions and choices.
        o_MLE = allMLE;
        o_choiceStream = choiceStreamAll;
        o_rewardStream = rewardStreamAll;

        for irun = 1:size(allMLE,5)

        choiceStreamAll=o_choiceStream(:,irun)';

        allMLE = o_MLE(:,:,:,:,irun);

        %Matrix per participant
        tableTB     = zeros(size(allMLE,3),size(allMLE,2));
        %tableTBatm     = zeros(size(plaMLE,3),size(plaMLE,2));

        %Loop over both parameters
        for eachBeta = 1:size(allMLE,3)
            for eachTau = 1:size(allMLE,2)
                for eachLS = 1:size(allMLE,4)



                    %Calulate the log likelihood for placebo and atomoxetine.
                    logLikelihood = -sum(log(binopdf(choiceStreamAll,1,allMLE(:,eachTau,eachBeta,eachLS)'.*0.99+0.005)));
                    %   logLikelihoodATM = -sum(log(binopdf(choiceStreamATM,1,atmMLE(:,eachTau,eachBeta,eachLS)'.*0.99+0.005)));

                    %Store all the log likelihood estimations
                    tableTB(eachBeta,eachTau,eachLS) = logLikelihood;
                    %      tableTBatm(eachBeta,eachTau,eachLS) = logLikelihoodATM;

                end
            end
        end

        %Insert MLE into larger matrix
        tableTBAll(:,:,:) = tableTB;
        %tableTBatmAll(:,:,:) = tableTBatm;





        %%
        %Get the actual parameter fits for each session
        paramIND     = zeros(cfg1.bestfits,3); %need 3 instead of 2.

        %Find the paramter indices for each participant
        MLE      = tableTBAll(:,:,:);

        %Vectorize matrix:
        MLE_vector = MLE(:);

        %Loop the number of best fit parameter pairs are needed
        for iparamPairs = 1:cfg1.bestfits

            [paramVAL, idx] = min(MLE_vector);
            %[paramVALpla, idxpla] = min(plaMLE_vector);

            %Insert NaNs where the best fit was previously
            MLE_vector(idx) =NaN;
            %plaMLE_vector(idxpla) =NaN;

            %Find the position in the 3d matrix of each best fit pair.
            [paramROW,paramCOL,paramZ] = ind2sub(size(MLE),idx);
            %[paramROWpla,paramCOLpla,paramZpla] = ind2sub(size(atmMLE),idxpla);

            %Store the indices in 3d matrix
            paramIND(iparamPairs,:)           = [paramROW,paramCOL,paramZ];
            %paramINDpla(iparamPairs,:)           = [paramROWpla,paramCOLpla,paramZpla];

        end

        %Store the tau parameter fits using the index.
        paramFits(irun).taufits = cfg1.tau(paramIND(:,2));

        %Store the beta parameter fits using the index.
        paramFits(irun).betafits = cfg1.beta(paramIND(:,1));

        %Store the lose-switch parameter fits using the index
        paramFits(irun).lsfits = cfg1.ls(paramIND(:,3));

        disp('Paramater fits are stored!')
        end
        save(outputfile,'o_choiceStream','o_rewardStream','paramFits','-v7.3');

    else

        save(outputfile,'allMLE','choiceStreamAll','rewardStreamAll','cfg1','-v7.3');



end
end
