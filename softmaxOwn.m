
function [output]=softmaxOwn(input,beta) 
%%
%Softmax decision rule instead of matching law.
%Input the difference value based on the two local incomes.
% % %Output the 
% h = figure; set(h,'position',[10 60 400 400 ],'Color','w'); 
% hold on; box off; 
% 
%   xval=linspace(0,1,100);
% %xval=rand(1,1000);
% %xval2=rand(1,1000);
% %  % 
% % %output=1/(1+exp(-(input)*beta));
% % % 
% % % 

% for i =1:100
%     x(i)=xval(i)-(1-xval(i));
%     y(i)=exp(xval(i)/beta)/sum([exp((xval(i))/beta),exp((1-xval(i))/beta)]);
% end
% 
% plot(x,y)

output = (exp(input(1)/beta))/sum([exp((input(1))/beta),exp(input(2)/beta)]);


end
