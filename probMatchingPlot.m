

function probMatchingPlot(~)
%%Calculate the probability matching per participant. 

setting.numParticipants = 31;


[ PLA,ATM ] = loadSessions(setting);

cd('/Users/Christoffer/Documents/MATLAB/matchingData/All_behavior')



%figure(1),clf
%hold on;

for ip = 1:31
    
    load(PLA{ip})
    
    
    %subplot(8,4,ip)
    %hold on;

    
    for ib = 1:length(results.blocks)
        
        %Plot the proportion of rewards recieved for each target
        %rew horizontal recieved but not by participant. Resp 1 == horizontal
        
        rewardRecieved  = results.blocks{ib}.trlinfo(:,8);
        
        rewardRecievedH = sum(results.blocks{ib}.trlinfo(:,7)==1*rewardRecieved);
        
        rewardRecievedV = sum(results.blocks{ib}.trlinfo(:,7)==2*rewardRecieved);
        
        choiceH         = sum(results.blocks{ib}.trlinfo(:,7)==1);
        
        choiceV         = sum(results.blocks{ib}.trlinfo(:,7)==2);
        
        ratioRewardH(ib)    = rewardRecievedH/(rewardRecievedV+rewardRecievedH);
        
        ratioChoiceH(ib)    = choiceH/(choiceV+choiceH);
        
        
        
        
        %plot(ratioRewardH,ratioChoiceH,'o')
    end
    %line([0 1],[0 1])
    %title(results.subjName(1:3))
end


end

