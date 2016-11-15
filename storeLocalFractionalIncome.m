

%Store the local fractional income 
%But only for the relevant sessions. The placebo. 
clear

setting.numParticipants = 31;

bhpath = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/All_behavior/';

setting.bhpath = bhpath;

cd(bhpath)

[ PLA,ATM ] = loadSessions(setting);

skipSubj = {'DWe','JRu','MGo','EIv','JFo','SKo'};


AllprobChoice = {};
nt=1;
for nPart = 1:setting.numParticipants
    
    cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/All_behavior')
    
    %If its empty skip
    if ~isempty(setdiff(PLA{nPart}(1:3),skipSubj))
    
    load(PLA{nPart})

    %Loop all participants
    [ probChoice,cfg1 ] = pertrialLFI(results,nPart);
    
    storeTau(nt)=cfg1.tau;
    nt=nt+1;
    AllprobChoice.LFI{nPart}        = probChoice;
    trlinfos = [];
    for iblocks = 1:length(results.blocks)
    
        trlinfos = [trlinfos;results.blocks{iblocks}.trlinfo];
    end
    AllprobChoice.(PLA{nPart}(1:3)) = trlinfos;
    end
end 

AllprobChoice.order = PLA; 

%save('-v7.3','AllprobChoice2','AllprobChoice')


%%
