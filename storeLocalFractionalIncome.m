

%Store the local fractional income 
%But only for the relevant sessions. The placebo. 

setting.numParticipants = 31;

[ PLA,ATM ] = loadSessions(setting);

cd('/Users/Christoffer/Documents/MATLAB/matchingData/All_behavior/')

AllprobChoice = {};

for nPart = 1:setting.numParticipants

    load(PLA{nPart})

    %Loop all participants
    [ probChoice ] = pertrialLFI(results,nPart);

    
    AllprobChoice.LFI{nPart}        = probChoice;
    trlinfos = [];
    for iblocks = 1:length(results.blocks)
    
        trlinfos = [trlinfos;results.blocks{iblocks}.trlinfo];
    end
    AllprobChoice.(PLA{nPart}(1:3)) = trlinfos;
end 

AllprobChoice.order = PLA; 

%save('-v7.3','AllprobChoice2','AllprobChoice')


%%
