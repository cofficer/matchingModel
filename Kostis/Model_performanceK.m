
function [allMLE,choiceStreamATM,choiceStreamPLA]=Model_performanceK(cfg1,outputfile)
%Main function to run for the leaky integration model. 
%Model performance should be based on X trials with block conditions identical to those
%made by the participant.
%Needs to become a function to be ran per participant
tic

  

for allSessions=1:2
    
    if allSessions == 1 %load placebo
        
        load(cfg1.PLApath)
        partPath = cfg1.PLApath;
    else                %load atomoxetine
        load(cfg1.ATMpath)
        partPath = cfg1.ATMpath;
        %Store choice probabilities for placebo session.
        allMLE.PLA=modelChoiceP;
        choiceStreamPLA = choiceStreamAll;
        
        
    end
    
    
    %Simulate lose-switch strategy on the same task-structure as the
    %current session of interest. Or run the model on the participants.
    if cfg1.simulateLoseSwitch
        
        [choiceStreamAll,rewardStreamAll] = simulateLoseSwitch(partPath,allSessions,cfg1.AllPart);
        
    else
        %Get the history of choices and rewards, 0 is horizontal and 1 is vertical
        [choiceStreamAll,rewardStreamAll] = global_matchingK(results);
    end
    %Model-specific computations.
    [modelChoiceP] = model_bodyK( cfg1,results,choiceStreamAll,rewardStreamAll);
    
    
end

%Store choice probabilities for atomoxetine session.
allMLE.ATM = modelChoiceP;

choiceStreamATM = choiceStreamAll;

timeTaken=toc;
%Saving all the relevant data per participant.
%save(outputfile,'allMLE','timeTaken','choiceStreamPLA','choiceStreamATM');%'maxTauAll','allMLE','forEffAll','allDelivered','missm','timeTaken')


disp('model done')
end

