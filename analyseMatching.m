

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % A script for analysing behavioral data, creating plots and simulating
% % strategies. Applied to the matching project using leaky accumulator
% % model. 13/09/2016. Chris.
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %


%clear all

%Analyse using single or double-parameter model
setting.modeltype              = '3';

%Define the scope of parameter space.
setting.beta                   = linspace(.1,2,5);
setting.tau                    = linspace(1,20,5);
setting.ls                     = linspace(0,1,5);
setting.simulate               = 0;

bhpath = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/All_behavior/';

setting.bhpath          = bhpath;
%How many participants should be analysed?
setting.numParticipants        = 29; %need to remove JRu and MGo somehow.

%Get parameter fits for the number of participants defined.
[ paramFits, cfg1, PLA, ATM]   = parameterFitting( setting);

%%
%Create barplots for beta parameter:
setting.barplot                   = 'beta';
barplotParameters( paramFits,setting)


%Create barplots for tau parameter:
setting.barplot                   = 'tau';
barplotParameters( paramFits,setting)

%%
%Make scatter plots of the model fits/perfomance/lose-switch strategy.
%Would also be nice to devide this into atm and placebo, to see any
%differences.

%load('paramFits.mat')
setting.numParticipants        = 29; %need to remove JRu and MGo somehow.

%Use simulated behavior or not.
simulate = 0;

bhpath = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/All_behavior/';

setting.bhpath          = bhpath;

%
[ PLA,ATM ] = loadSessions(setting);

%Remove participants post-hoc, nr 20, 24
%PLA{20}=[];PLA{24}=[];
%ATM{20}=[];ATM{24}=[];
%
% PLA=PLA(~cellfun('isempty',PLA));
% ATM=ATM(~cellfun('isempty',ATM));

fnames = fieldnames(paramFits);

%loop over all the fieldnames in the parameter fits. ATM/PLA for beta/tau.
for ifield = 1:length(fnames)

    %paramFits.(fnames{ifield})(20)=0; %Participant JRu
    %paramFits.(fnames{ifield})(24)=0; %Participant MGo

    paramFits.(fnames{ifield})=paramFits.(fnames{ifield})(paramFits.(fnames{ifield})>0);

end

%calculate the lose-switch strategy.
[l_switch]                     = loseSwitch(PLA, ATM, simulate);
%calculate the performance.
[ performance ]                = calcPerformance( PLA,ATM, simulate);

%remove participants based on poor performance, should be JRu and MGo
%Find the sessions from placebo with bad performance.
indBadPer = find(performance<0.6);

%PLA(round(indBadPer(1)/2))

%PLA(round(indBadPer(3)/2))

%cellfun('isempty',PLA)


%Use new plot and make 

%Plot lose-switch vs. performance
contrast                       = 'lose-performance';
scatterPlotMatching(contrast, performance, l_switch)
%Plot tau-performance
contrast                       = 'tau-performance';
scatterPlotMatching(contrast, performance, l_switch, paramFits)
%Plot 'tau-lose'
contrast                       = 'tau-lose';
scatterPlotMatching(contrast, performance, l_switch, paramFits)
%Plot 'beta-performance'
contrast                       = 'beta-performance';
scatterPlotMatching(contrast, performance, l_switch, paramFits)
%Plot 'beta-lose'
contrast                       = 'beta-lose';
scatterPlotMatching(contrast, performance, l_switch, paramFits)

%%
%Calculate the probability matching per participant.
%load('paramFits.mat')
setting.numParticipants        = 29; %need to remove JRu and MGo somehow.

%Use simulated behavior or not.
simulate = 0;

bhpath = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/All_behavior/';

setting.bhpath          = bhpath;

%
[ PLA,ATM ] = loadSessions(setting);

figure(1),clf
hold on

PLA=[PLA,ATM];

%Decided to plot all the blocks in one figuere as it stands.
allblocks=1;
for sess =1:length(PLA)%-2
    %Load the results per participant

    load(PLA{sess})
    %participantPath = PLA{participant};

    %load(ATM{participant})
    %participantPath = ATM{participant};
    %participant = participant+1;


    [choiceStreamAll,rewardStreamAll] = global_matchingK(results);


    %subplot(1,1,sess)
    hold on
    %Calculate the reward delivered,
    rewarDelivered = 0;
    allpropCV=0;
    allpropRV=0;
    for ib = 1:results.nblocks



        validTrials=results.blocks{ib}.trlinfo(:,7)~=0;

        rewarDelivered = rewarDelivered +...
            sum(results.blocks{ib}.newrewardHor(validTrials)) +...
            sum(results.blocks{ib}.newrewardVer(validTrials));



        %All collected rewards
        allR=(results.blocks{ib}.trlinfo(:,8));
        allR=allR(validTrials);
        %All verticl choices
        allCV=(results.blocks{ib}.trlinfo(:,7)-1);
        allCV=allCV(validTrials);
        %All verticl rewards
        allRV=allR(logical(allCV));

        %Proportion of verticl choices
        propCV=sum(allCV)/length(allCV);

        %Proportion vertical rewards
        propRV=sum(allRV)/sum(allR);

        %All reward recieved from vertical choice
        %Proportion vertical choice == proportion vertical reward.

        plot(propRV,propCV,'.','color','k','markers',15)

        %Save all reward ratios and choice ratios from all blocks.
        propRV_all_blocks(allblocks) = log(propRV);
        propCV_all_blocks(allblocks) = log(propCV);
        allblocks=allblocks+1;

        allpropCV=allpropCV+propCV;
        allpropRV=allpropRV+propRV;

        if propRV>1
            disp(PLA{sess})
            disp(sess)
            disp(ib)

        end

    end
    %line([0 1],[0 1],'color','r')
    %title(PLA{sess}(1:3))
    %plot(allpropCV/ib,allpropRV/ib,'.','color','k','markers',15)
    rewgot(sess)=sum(rewardStreamAll)/rewarDelivered;
    %     percrew(sess)=rewarDelivered/length(rewardStreamAll)
    %     disp(PLA{sess})
    %     disp(rewarDelivered)
    %     disp(sum(rewardStreamAll))
end

%title('Probability matching for all blocks')
%xlabel('Proportion vertical choices')
%ylabel('Proportion vertical rewards')
line([0 1],[0 1],'color','r')


%New way of saving Figure using gramm
g=gramm('x',propCV_all_blocks,'y',propRV_all_blocks);
g.geom_point();
g.stat_glm();
g.set_names('column','Origin','x','Choice ratio','y','Reward ratio','color','#');
g.set_text_options('base_size',15);
g.set_title('Heuristic');
g.draw();

cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/TFGitAnlysis/figures')
%Name of figure
filetyp='svg';
%name files
formatOut = 'yyyy-mm-dd';
todaystr = datestr(now,formatOut);
namefigure = sprintf('overall-probability-matching');%fractionTrialsRemaining
filetype    = 'svg';
figurename = sprintf('%s_%s.%s',todaystr,namefigure,filetype);
g.export('file_name',figurename,'file_type',filetype);

%%
%Figure out which sessions to ignore, how to divide up the sessions
%according to good fits. Median split on lose-switch.


PLAl_s = l_switch(1:2:end);

quantile(PLAl_s,[0.5])

lowswitch = PLAl_s<0.6209;

highswitch = PLAl_s>=0.6209;

lowswitchID = PLA(lowswitch);

highswitchID = PLA(highswitch);


%%
cd('/Users/Christoffer/Documents/MATLAB/ModelCode/Results/version2plots/')
print('SimulatedParametersbarplot','-dpdf')


%%
%save csv parameter fits

atm=paramFits.tauATMfits';

pla=paramFits.tauPLAfits';

csvwrite('botparams.csv',[atm pla])
