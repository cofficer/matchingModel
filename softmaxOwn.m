
function [output]=softmaxOwn(input,beta) 
%%
%Softmax decision rule instead of matching law.
%Input the difference value based on the two local incomes.
%Output the 
%xval=linspace(0,1,100);

%output=1/(1+exp(-(input)*beta));
% 
% 
% figure(1),clf
% hold on;
% for i =1:100
%     plot(xval(i),(exp(xval(i)/beta))/sum([exp((xval(i))/beta),exp((1-xval(i))/beta)]),'o')
% end


output = (exp(input(1)/beta))/sum([exp((input(1))/beta),exp(input(2)/beta)]);


end
