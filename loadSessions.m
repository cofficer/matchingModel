function [ resultsAll ] = loadSessions( partSess,whichPart )
%Loads all the data necessary from the sessions

% session=0;
% 
% 
% if iscell(partSess)
% 
%     %Loops through all the sessions and loads the data in resultsAll.
%     for participants=1:length(partSess)
%         for sessLength=1:length(partSess{participants})
%             if partSess{participants}~=0
%                 
%                 session=session+1;
%                 
%                 sessNum=cell2mat(partSess(participants));
%                 
%                 results=load_data(participants,sessNum(sessLength));
%                 results=results.results;
%                 %Stores all the results in one struct.
%                 varField=sprintf('sess%s',num2str(session));
%                 resultsAll.(varField)=results;
%                 
%             end
%             
%         end
%     end
% else
%     for sessions=1:length(partSess)
%         
%         results=load_data(whichPart,partSess(sessions));
%         results=results.results;
%         %Stores all the results in one struct.
%         varField=sprintf('sess%s',num2str(sessions));
%         resultsAll.(varField)=results;
%     end
% end
% 

results=load_data



end

