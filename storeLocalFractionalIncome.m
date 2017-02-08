

%Store the local fractional income
%But only for the relevant sessions. The placebo.
%clear

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
        [ probChoice,cfg1 ]          = pertrialLFI(results,nPart);
        
        %
        storeTauAT(nt)               = cfg1.tau;
        
        AllprobChoice.LFI{nt}        = probChoice;
        
        %Increase the index of actual participants. 
        nt                           = nt+1;

        trlinfos = [];
        for iblocks = 1:length(results.blocks)
            
            trlinfos = [trlinfos;results.blocks{iblocks}.trlinfo];
        end
        
        AllprobChoice.(PLA{nPart}(1:3)) = trlinfos;
    
end

AllprobChoice.order = order;

cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel')

save('-v7.3','AllprobChoice3-0702-17','AllprobChoice')


%%
