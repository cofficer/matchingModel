function [l_switch] = loseSwitch(PLA, ATM, simulate)
%Compute the lose-switch strategy. This cell counts the number of time a
%participant changes from previous choice if the got no reward. Normalized
%by number of trials. Maybe should be normalized by number of trials with
%no reward. Change the order to the correct pla/atm order.


participant = 1;

%Loop all participants
for sess =1:length(PLA)*2

%Load the results per participant
if mod(sess,2) == 1
    load(PLA{participant})
    participantPath = PLA{participant};
else
    load(ATM{participant})
     participantPath = ATM{participant};
    participant = participant+1;
end
%Load the choice and reward history
if simulate
    [choiceStreamAll,rewardStreamAll] = simulateLoseSwitch(participantPath);
else
    [choiceStreamAll,rewardStreamAll] = global_matchingK(results);
end
a=1;
switches=0;
for it = 1:length(choiceStreamAll)
    
    %Skip first trial because there is no previous trial
    if it>1
        
        
        choice = choiceStreamAll(it);
        reward = rewardStreamAll(it);
        
        %Previous trial reward and choice
        c_prev = choiceStreamAll(it-1);
        r_prev = rewardStreamAll(it-1);
        
        if ~r_prev
       
            switches(a) = choice-c_prev;
            a=a+1; 
        end
    end

end



%Loose switch cases normalized by n of trials.
l_switch(sess) = sum(switches.^2)/sum((rewardStreamAll-1).^2);

end
end


