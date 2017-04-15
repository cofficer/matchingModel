
%Script for computing trial-by-trial choice prediction based on leaky
%accumulation and lose-switch model. 
%Store the local fractional income, or probability of choice, 
%But only for the relevant sessions. The placebo.
%

setting.numParticipants = 29;

bhpath = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/All_behavior/';

setting.bhpath = bhpath;

cd(bhpath)

[ PLA,ATM ] = loadSessions(setting);

%skipSubj = {'JRu','MGo'};

%Initiate storage of probability of choice
AllprobChoice = {};
%Initiate storage of order of sessions
order         = {};
%Initiate the index of participants.
nt            = 1;
for nPart = 1:setting.numParticipants
    
    cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/All_behavior')
    
    %If its empty skip
        
        load(PLA{nPart})
        
        order(nt)                    = {PLA{nPart}(1:3)};
        
        %Loop all participants
        numparameter = {'1';'2';'3'};
        
        %Store the PC output from each model. However, from PC3 and PC2 I
        %could alo retrieve the LFI.
        for imodels = 1:length(numparameter)
            
            cfg1.numparameter=numparameter{imodels};
            
            [ probChoice,LocalFract,cfg1 ]          = pertrialLFI(results,nPart,cfg1);
            
            %
            storeTauAT(nt)               = cfg1.tau;
            storeLSAT(nt)                = cfg1.ls;
            if cfg1.numparameter == '3'
                AllprobChoice.PC3{nt}         = probChoice;
                AllprobChoice.LFI3{nt}        = LocalFract;
            elseif cfg1.numparameter == '2'
                AllprobChoice.PC2{nt}         = probChoice;
                AllprobChoice.LFI2{nt}        = LocalFract;
            elseif cfg1.numparameter == '1'
                AllprobChoice.PC1{nt}         = probChoice;
                AllprobChoice.LFI1{nt}        = probChoice;
            end
        end
        %Increase the index of actual participants.
        nt                           = nt+1;

        trlinfos = [];
        for iblocks = 1:length(results.blocks)
            
            trlinfos = [trlinfos;results.blocks{iblocks}.trlinfo];
        end
        
        AllprobChoice.(PLA{nPart}(1:3)) = trlinfos;
    
end

%%
AllprobChoice.order = order;

cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel')

save('-v7.3','AllprobChoice2-1203-17','AllprobChoice')


%%
