

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % A script for analysing behavioral data, creating plots and simulating
% % strategies. Applied to the matching project using leaky accumulator 
% % model. 13/09/2016. Chris. 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 


%clear all

%Analyse using single or double-parameter model
setting.modeltype              = '3';

%Define the scope of parameter space. 
setting.beta                   = linspace(.1,2,50);
setting.tau                    = linspace(1,20,50);
setting.ls                     = linspace(0,1,50);

%How many participants should be analysed?
setting.numParticipants        = 1; %need to remove JRu and MGo somehow. 

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

%Use simulated behavior or not.
simulate = 0;

%
[ PLA,ATM ] = loadSessions(setting);

%Remove participants post-hoc, nr 20, 24
PLA{20}=[];PLA{24}=[];
ATM{20}=[];ATM{24}=[];

PLA=PLA(~cellfun('isempty',PLA));
ATM=ATM(~cellfun('isempty',ATM));

fnames = fieldnames(paramFits);

%loop over all the fieldnames in the parameter fits. ATM/PLA for beta/tau.
for ifield = 1:length(fnames)
    
    paramFits.(fnames{ifield})(20)=0; %Participant JRu
    paramFits.(fnames{ifield})(24)=0; %Participant MGo

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




%Plot lose-switch vs. performance
contrast                       = 'lose-performance';
scatterPlotMatching(contrast, performance, l_switch, paramFits)
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

