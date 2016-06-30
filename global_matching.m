

function [ choiceStreamAll] = global_matching(results)
%This function will model the global matching law, taking into account all
%the previous reward stream for each stimulus target. 

%Matching is a widely observed behavioral phenomenon in which the proportion
%of a subjects' foraging time or effort invested in an option approximately
%matches the income (rewards per unit time) from that option relative to 
%the total income

%Number of blocks
nblocks=length(results.blocks);
if results.blocks{1,nblocks}.ntrls==0
    nblocks=length(results.blocks)-1;
end

globMatchAll=zeros(4,2,nblocks);

rewStreamHorAll=[];
rewStreamVerAll=[];
choiceStreamAll=[];

for blocki=1:nblocks
    
    
%    rewStreamTot=results.blocks{1,blocki}.trlinfo(:,8); %this is the total reward stream
    
    choiceStreamTot=results.blocks{1,blocki}.trlinfo(:,7); %this are the hor(1) and ver(2)
%     
%     
%     %Calculating the global income
%     rewStreamHor=zeros(results.blocks{1,blocki}.ntrls,1);
%     rewStreamVer=zeros(results.blocks{1,blocki}.ntrls,1);
%     
%     
%     for i=1:results.blocks{1,blocki}.ntrls
%         if choiceStreamTot(i)==1 && rewStreamTot(i)==1 %then it is horizontal choice + reward
%             rewStreamHor(i)=1;
%             rewStreamVer(i)=NaN; %NaN
%             
%         elseif choiceStreamTot(i)==2 && rewStreamTot(i)==1 %then it is vertical choice + reward
%             rewStreamVer(i)=1;
%             rewStreamHor(i)=NaN; %NaN
%         %else 
% %             rewStreamHor(i)=0;
% %             rewStreamVer(i)=0; 
%             
%         elseif choiceStreamTot(i) == 1 && rewStreamTot(i) == 0
%             
%             rewStreamHor(i)=0;
%             rewStreamVer(i)=NaN; %NaN
%             
%         elseif choiceStreamTot(i) == 2 && rewStreamTot(i) == 0
%             
%             rewStreamHor(i)=NaN; %NaN
%             rewStreamVer(i)=0;
%         else
%             %The else- dispays position of error of participant. 
%             %disp('Look here')
%             %disp(i)
%             %disp(blocki)
%         end
%     end
%     
%     
%     horReward=sum(rewStreamHor)/(sum(rewStreamHor)+sum(rewStreamVer));
%     
%     verReward=sum(rewStreamVer)/(sum(rewStreamHor)+sum(rewStreamVer));
%     
%     
%     %Calculating the global choice
%     
%     choiceStreamHor=zeros(results.blocks{1,blocki}.ntrls,1);
%     choiceStreamVer=zeros(results.blocks{1,blocki}.ntrls,1);
%     
%     
%     for i=1:results.blocks{1,blocki}.ntrls
%         if choiceStreamTot(i)==1 %then it is horizontal choice
%             choiceStreamHor(i)=1;
%             choiceStreamVer(i)=0;
%             
%         elseif choiceStreamTot(i)==2 %then it is vertical choice
%             choiceStreamVer(i)=1;
%             choiceStreamHor(i)=0;
%         else
%             choiceStreamHor(i)=0;
%             choiceStreamVer(i)=0;
%         end
%     end
    
    
 %   horChoice=sum(choiceStreamHor)/(sum(choiceStreamHor)+sum(choiceStreamVer));
    
 %   verChoice=sum(choiceStreamVer)/(sum(choiceStreamHor)+sum(choiceStreamVer));
    
%    global_matching={{'horReward',horReward};{'verReward',verReward};{'horChoice',horChoice};{'verChoice',verChoice}};
    
%     global_matching=cat(1,global_matching{:});
%     
%     
%     
%     globMatchAll.blocks{1,blocki}=global_matching;
%     global_matching=[];
    
    
   % rewStreamHorAll=[rewStreamHorAll,rewStreamHor'];
    
    
    %rewStreamVerAll=[rewStreamVerAll,rewStreamVer'];
    
    choiceStreamAll=[choiceStreamAll,choiceStreamTot'];
    
end
choiceStreamAll=choiceStreamAll-1;

end

