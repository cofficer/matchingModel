

function [ choiceStreamAll,rewardStreamAll] = global_matching(results)
%This function will model the global matching law, taking into account all
%the previous reward stream for each stimulus target. 

%Matching is a widely observed behavioral phenomenon in which the proportion
%of a subjects' foraging time or effort invested in an option approximately
%matches the income (rewards per unit time) from that option relative to 
%the total income

%Remove the last block if it does not contain any trials. 
nblocks=length(results.blocks);
if results.blocks{1,nblocks}.ntrls==0
    nblocks=length(results.blocks)-1;
end

%Premake variables
choiceStreamAll=[];
rewardStreamAll=[];

for blocki=1:nblocks
    
    
    
    choiceStreamTot=results.blocks{1,blocki}.trlinfo(:,7); %this are the hor(1) and ver(2)

    
    choiceStreamAll = [choiceStreamAll,choiceStreamTot'];

    
    rewardStreamTot = results.blocks{1,blocki}.trlinfo(:,8); %Reward delivered
    
    rewardStreamAll = [rewardStreamAll,rewardStreamTot'];
    
    
end
choiceStreamAll=choiceStreamAll-1;

end

