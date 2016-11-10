


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % Simulate data for the leaky accumulation model. Parameter fits 
% % for a lose-switch agent. 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
function [choice,rewHistory] = simulateLoseSwitch(participantPath,allSessions,AllPart)


load(participantPath)

%Until first reward, randomly choose between the two targets.
firstReward = 0;
itAll       = 1;

figurePlot = 1;

if AllPart == 1 && allSessions==1 
    figure(AllPart),clf
end


if figurePlot == 1 && allSessions==1 
    subplot(8,4,AllPart)
    line([0 1],[0 1])
    title(results.subjName(1:3))

    hold on
end


for ib = 1:length((results.blocks))
    
    
    rewardH = results.blocks{ib}.newrewardHor;
    rewardV = results.blocks{ib}.newrewardVer;
    
    for it = 1:results.ntrls(ib)
        
        
        
        %Randomly make the first choice base on no prior
        if firstReward==0
            choice(1,itAll) = binornd(1,0.5);
        else
            
            %If previous trial recieved reward, stay
            if rewHistory(1,itAll-1) == 1;
                
                choice(1,itAll) = choice(1,itAll-1);
            else
                %Otherwise choose the other option
                choice(1,itAll) = 1-choice(1,itAll-1);
            
            end
            
            %If you got a reward keep choosing otherwise switch
            %if choice == results.blocks{1}
            
            
            
        end
        
        %Find if the choice results in a reward
        if choice(1,itAll) == 1 && rewardV(it) == 1
            firstReward = 1;
            rewHistory(1,itAll) = 1;
        elseif choice(1,itAll) == 0 && rewardH(it)
            firstReward = 1;
            rewHistory(1,itAll) = 1;
        else
            rewHistory(1,itAll) = 0;
        end
        
        %if the target has an reward that was not chosen, move that reward
        %over to the next trial to be available.
        if rewardV(1,it) == 1 && choice(1,itAll) == 0
            rewardV(1,it+1) = 1;
        elseif rewardH(1,it) == 1 && choice(1,itAll) == 1
            rewardH(1,it+1) = 1;
        end
        
        itAll = itAll+1;
        
    end
    
    
    %Plot after each block the prob matching. 
    if figurePlot == 1 && allSessions==1
        
        
        choiceH             = sum(choice(1,itAll-it:itAll-1)==0);
        
        choiceV             = sum(choice(1,itAll-it:itAll-1)==1);
        
        rewardRecievedH     = sum(rewardH(choice(1,itAll-it:itAll-1)==0));
        
        rewardRecievedV     = sum(rewardV(choice(1,itAll-it:itAll-1)==1));
        
        ratioRewardH(ib)    = rewardRecievedH/(rewardRecievedV+rewardRecievedH);
        
        ratioChoiceH(ib)    = choiceH/(choiceV+choiceH);
        
        if ratioChoiceH(ib)>0.7
            a=1;
        end
        
        plot(ratioRewardH,ratioChoiceH,'o')
        hold on;
        
        
    end
    
end
end












