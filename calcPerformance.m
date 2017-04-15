function [ performance ] = calcPerformance( PLA,ATM, simulate )
%%
%Calculate the performance level per session

%Loop all participants
participant=1;
PLAper = [];
ATMper = [];
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
    
    
    %Calculate the reward delivered,
    rewarDelivered = 0;
    for i = 1:results.nblocks
        
        rewarDelivered = rewarDelivered +...
            sum(results.blocks{i}.newrewardHor) +...
            sum(results.blocks{i}.newrewardVer);
        
        
    end
    if mod(sess,2) == 1
        PLAper = [PLAper, sum(rewardStreamAll)/rewarDelivered];
    else
        ATMper = [ATMper, sum(rewardStreamAll)/rewarDelivered];
    end
    
    %No enough. Need to find the reward delivered to be found.
    performance(sess) = sum(rewardStreamAll)/rewarDelivered;
    if performance(sess)<0.6
        aa=1;
    end
    
    
end

end

